//: [Previous](@previous)

import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 OperationQueue
 
 - Operation -> 抽象类, BlockOperation!
 - Queue
 
 OperationQueue vs GCD
 - OperationQueue 使用 DispatchQueue 调度 operations!!!
 - operation有同步和异步之分, 但是operation会执行在另外一个dispatchQueue中, 不论Operation本身是synchronous or asynchronous!!
 - OperationQueue 的 underlyingQueue 可以关联 GCD queue
 - pros:
    - denpency (当有依赖的时, 不一定是 serial!!! maxConcurentCount = 1时)
    - OperationQueue - suspend/resume
    - oop - custom Operation
    - long term task
    - reUse operation
 - cons:
    - Complex
 
 
 SimpleTask: GCD
 Control + dependency: OperationQueue
 
 
  dependency 种类!!!
  
  - 时序上的依赖(api chaining)
     - bOperation.addDependency(aOperation)
     - dispatch semaphore
     - dispatch group wait!
     - rx/combine/async
  - 参数依赖: Parameter based dependency
     - AOperation的 response 是 BOperation 的 input
  
  比较复杂的是 Parameter dependency!!!
  
 */

struct RunnableA {
    func run() {
        debugPrint("\(self) started")
        Thread.sleep(forTimeInterval: 2)
        debugPrint("\(self) completed")
    }
}


struct RunnableB {
    func run() {
        debugPrint("\(self) started")
        Thread.sleep(forTimeInterval: 2)
        debugPrint("\(self) completed")
    }
}

struct RunnableManager {
    func startToTest() {
        let AOperatioin = BlockOperation()
        AOperatioin.addExecutionBlock {
            let runnableA = RunnableA()
            runnableA.run()
        }
        let BOperatioin = BlockOperation()
        BOperatioin.addExecutionBlock {
            let runnableB = RunnableB()
            runnableB.run()
        }
        
        AOperatioin.addDependency(BOperatioin)
        
        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
        
        queue.addOperation(AOperatioin)
        queue.addOperation {
            debugPrint("I am middle runnable")
        }
        queue.addOperation(BOperatioin)

        queue.waitUntilAllOperationsAreFinished()
        
        debugPrint("all operation in queue is finshed")
//        operationQueue.addOperations([employeeSyncOperation, departmentSyncOperation], waitUntilFinished: true)

    }
    
    
}

let runnableManager = RunnableManager()
runnableManager.startToTest()

//: [Next](@next)
