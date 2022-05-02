//: [Previous](@previous)

import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 DispatchWorkItem

 use DispatchWorkItem as a DispatchSource!

 - runnable block
 - notify
 - cancelable
 
 用来做 Debouncer 和 Throttle
 参考: https://juejin.cn/post/7091609789502849031
 
 */

class TestDemo {
    var workItem: DispatchWorkItem?
    let queue = DispatchQueue.global(qos: .utility)

    func test() {
        workItem = DispatchWorkItem { [weak self] in
            for i in 1...10 {
                guard let wkItem = self?.workItem, !wkItem.isCancelled else {
                    debugPrint("work item is cancelled")
                    return
                }
                debugPrint("\(i)")
                Thread.sleep(forTimeInterval: 3)
            }
        }
        
        workItem?.notify(queue: .main, execute: {
            debugPrint("done print numbsers")
        })
        
        queue.async(execute: workItem!)
        queue.asyncAfter(deadline: .now() + 3) {
            self.workItem?.cancel()
            PlaygroundPage.current.finishExecution()
        }
    }
}

let testDemo = TestDemo()
testDemo.test()


//: [Next](@next)
