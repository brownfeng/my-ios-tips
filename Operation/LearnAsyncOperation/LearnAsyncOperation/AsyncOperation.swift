//
//  AsyncOperation.swift
//  LearnAsyncOperation
//
//  Created by brown on 2022/5/1.
//

import Foundation

/*
 https://developer.apple.com/documentation/foundation/nsoperation?language=swift#1661262
 
 自定义 Operation, 一定要管理 Operation State
 
 override the isFinished and isExecuting properties with multi-threading and KVO support
 
 1. isExecuting
 2. isFinished
 3. multi-threading support
 4. KVO
 5. cancel 支持
 
 */
class AsyncOperation: Operation {
    // 使用 concurrentQueue 多线程异步读, 同步写!!!
    private let lockQueue = DispatchQueue(label: "com.swiftlee.asyncoperation", attributes: .concurrent)
    // 使用私有变量维护 excuting
    private var _isExcuting: Bool = false
    
    override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExcuting
            }
        }
        set {
            willChangeValue(forKey: "isExcuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExcuting = newValue
            }
            didChangeValue(forKey: "isExcuting")
        }
    }
    
    private var _isFinished: Bool = false
    override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        print("Starting")
        guard !isCancelled else {
            finish()
            return
        }

        isFinished = false
        isExecuting = true
        main()
    }
    
//    override func main() {
//        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
//            print("Executing...")
//            self.finish()
//        }
//    }

    override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
}

