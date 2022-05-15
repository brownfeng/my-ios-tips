//
//  BaseAsyncOperation.swift
//  LearnOperation
//
//  Created by brown on 2022/5/15.
//

import Foundation

class BaseAsyncOperation: Operation {
    private let lockQueue = DispatchQueue(label: "com.brownfeng.baseAsyncOperation", attributes: .concurrent)

    override open var isAsynchronous: Bool {
        return true
    }

    private var _isExecuting: Bool = false
    override open private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
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
    override open private(set) var isFinished: Bool {
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

    override open func start() {
        guard !isCancelled else {
            finish()
            return
        }
        
        isFinished = false
        isExecuting = true
        main()
    }

    override open func main() {
        /// Use a dispatch after 模拟 long-running task.
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
            print("Executing")
            self.finish()
        })
    }

    open func finish() {
        isExecuting = false
        isFinished = true
    }
}
