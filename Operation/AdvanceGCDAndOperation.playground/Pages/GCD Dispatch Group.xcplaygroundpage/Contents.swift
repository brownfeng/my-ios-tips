//: [Previous](@previous)

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 Task Group -- DispatchGroup
 */

class DispatchGroupExample {
    let ccQueue = DispatchQueue(label: "com.brownfeng.concurrentQueue", attributes: .concurrent)

    func test() {
        let group = DispatchGroup()

        group.notify(queue: .main) {
            print("dispatch group is down")
        }
        
        group.enter()
        ccQueue.async {
            debugPrint("task 1 is running")
            Thread.sleep(forTimeInterval: 1)
            group.leave()
        }
        
        group.enter()
        ccQueue.async {
            debugPrint("task 2 is running")
            Thread.sleep(forTimeInterval: 1 )
            group.leave()
        }
    }
}

let dispatchGroupExample = DispatchGroupExample()
//dispatchGroupExample.test()


/*:
 
 Nested Closure vs DispatchGroup
 
 - async-await
 - rx
 - promise
 */

class NestedClosureExample {
    func test1() {
        var arr: [String] = []
        let startTime = Date()
        callApiA { responseA in
            self.callApiB { responseB in
                self.callApiC { responseC in
                    arr.append(responseA)
                    arr.append(responseB)
                    arr.append(responseC)
                    debugPrint(Date().timeIntervalSince(startTime))
                    
                    let result = arr.reduce(into: "") { result, item in
                        result += item + " "
                    }
                    debugPrint(result)
                }
            }
        }
    }
    
    
    func test2() {
        var arr: [String] = []
        let startTime = Date()
        let group = DispatchGroup()
        
 
        
        group.enter()
        callApiA {
            arr.append($0)
            group.leave()
        }
        group.enter()

        callApiB {
            arr.append($0)
            group.leave()
        }
        
        group.enter()
        callApiB {
            arr.append($0)
            group.leave()
        }
        group.notify(queue: .main) {
            debugPrint(Date().timeIntervalSince(startTime))
        }

    }
    func callApiA(completion: @escaping (String) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            debugPrint("data from API A")
            completion("data from API A")
        }
    }
    
    func callApiB(completion: @escaping (String) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            debugPrint("data from API B")

            completion("data from API B")
        }
    }
    
    func callApiC(completion: @escaping (String) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            debugPrint("data from API C")
            completion("data from API C")
        }
    }
}
let nestedClouseExample = NestedClosureExample()
//nestedClouseExample.test1()
nestedClouseExample.test2()


//: [Next](@next)
