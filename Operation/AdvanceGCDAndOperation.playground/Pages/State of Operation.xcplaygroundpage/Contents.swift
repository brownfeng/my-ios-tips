//: [Previous](@previous)

import Foundation

class MySyncOperation: Operation {
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

class MyAsyncOperation: Operation {
    override func main() {
        if isCancelled {
            return
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            print("Perform operation")
            // 真实结束时, 状态变化 -> 通知 OperationQueue 的结果通知
        }
    }
}

let queue = OperationQueue()
//var syncOperation = MySyncOperation()
//let observations = syncOperation.observeStateChanges()
//queue.addOperations([syncOperation], waitUntilFinished: true)
var asyncOperation = MyAsyncOperation()
let observations = asyncOperation.observeStateChanges()
queue.addOperations([asyncOperation], waitUntilFinished: true)


//: [Next](@next)
