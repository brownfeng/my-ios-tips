//: [Previous](@previous)

import Foundation
import PlaygroundSupport

PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 Operation的生命周期:
    - pending -> Ready -> Executing -> Finished
    - 除了 Finished, 其他的状态都能转移到 -> Cancelled
 
 Operation 的自定义类型:
    - SyncOperation: 直接实现 main() 方法
    - AsyncOperation: 实现很多!!! -> 注意点也很多
 
 > The dependencies supported by NSOperation make no distinction about whether a dependent operation finished successfully or unsuccessfully. (In other words, canceling an operation similarly marks it as finished.) It is up to you to determine whether an operation with dependencies should proceed in cases where its dependent operations were cancelled or did not complete their task successfully. This may require you to incorporate some additional error tracking capabilities into your operation objects
 */
class MySyncOperation: Operation {
    // 默认情况下任务会在 OperationQueue 的调度队列中同步执行!!!
    // Operation的 isFinished/isExcuting状态不需要我们维护!!!
    override func main() {
        // isCancelled 默认的实现是线程安全的!!!
        if isCancelled {
            return
        }
        debugPrint("My Operation is running...")
        Thread.sleep(forTimeInterval: 3)
        // we want to finish operation here!!!
        // 任务结束 -> Operation抽象类会处理好 isFinished 和 isExcuting 的KVO通知!!!
    }
}

let queue = OperationQueue()
var syncOperation = MySyncOperation()
//let observations = syncOperation.observeStateChanges()

syncOperation.completionBlock = {
    debugPrint("syncOperation completed!")
}
queue.addOperation(syncOperation)

queue.waitUntilAllOperationsAreFinished()

//queue.addOperations([syncOperation], waitUntilFinished: true)
debugPrint("syncOperation is down")
/*:
 AsyncOperation 自定义实现注意点:
 
 - isAsynchronous 方法返回 true
 - 自己管理: isFinished, isExcuting 状态, 支持 KVO, 保证多线程安全
 - 自己实现 main() start(), 在执行开始时, isFinished = false, isExcuting = true
 - 在 main() 中任务异步执行(不再 OperationQueue 调度队列中执行), 并且在异步任务完成的时候设置 isFinished = true, isExcuting = false
 - 部分场景实现 cancel, 通常来说 isCancelled 状态由系统管理!!!
 - Operation 的 dependency Operation cancel 的兼容逻辑!!!
 - Operation 的  Parameter dependency!!!
 */

class MyAsyncOperation: Operation {
    
    // concurrent queue + barrier write
    private let lockQueue = DispatchQueue(label: "com.cocoaheads.nl", attributes: .concurrent)

    // 自定义 Operation 服务的异步状态 (默认如果只实现 main() 方法 是 syncOperation)
    override var isAsynchronous: Bool { true }

    // 需要完全自定义 - Excuting 和 Finshing 状态
    private var _isExecuting: Bool = false
    override var isExecuting: Bool {
        get {
            lockQueue.sync { _isExecuting }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished: Bool = false
    override var isFinished: Bool {
        get {
            lockQueue.sync { _isFinished }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    // OperationQueue 调度 Operation 的时候, 会使用 operation.start()
    // 因为 start() 方法内部会对 Operation 的内部状态进行改变, 但是 Custom Operation
    // 需要我们自己维护 CustomOperation的状态 - 因此这里一定不能调用 super.start() 方法
    override func start() {
        isFinished = false
        isExecuting = true
        // 真实的调度逻辑 - 使用 main 即可
        main()
    }

    override func main() {
        // 任何状态执行钱, 需要判断 isCancelled 状态服务
        guard !isCancelled else { return }
        // 真实的耗时任务, 不在 OperationQueue的调度队列执行, 因此这里是AsyncOperation
        /// Use a dispatch after to mimic the scenario of a long-running task.
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            print("Perform operation")
            // 真实结束时, 状态变化 -> 通知 OperationQueue 的结果通知
            self.finish()
        }
        
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}

let asyncOperation = MyAsyncOperation()
asyncOperation.observeStateChanges()
asyncOperation.completionBlock = { print("asyncOperation completed") }
// 内部的状态变化时ok的!
queue.addOperations([asyncOperation], waitUntilFinished: true)

debugPrint("asyncOperation is done")
//: [Next](@next)
