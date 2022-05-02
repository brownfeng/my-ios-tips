//: [Previous](@previous)

import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 GCD 中 serialQueue 的强顺序执行
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
        
        let queue = DispatchQueue(label: "serialQueue")
        queue.async {
            let runnableA = RunnableA()
            runnableA.run()
        }
        queue.async {
            debugPrint("I am middle runnable")
        }
        queue.async {
            let runnableB = RunnableB()
            runnableB.run()
        }
        
        let finishItem = DispatchWorkItem(flags: []) {
            debugPrint("all operation in queue is finshed")
        }
        queue.asyncAndWait(execute: finishItem)
    }
}

let runnableManager = RunnableManager()
runnableManager.startToTest()


DispatchQueue.concurrentPerform(iterations: 10) { i in
    print("item: \(i)")
}


//: [Next](@next)
