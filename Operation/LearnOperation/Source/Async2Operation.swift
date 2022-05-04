//
//  Async2Operation.swift
//  LearnOperation
//
//  Created by brown on 2022/5/3.
//

import Foundation

open class Async2Operation: Operation {
    override public var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override public var isAsynchronous: Bool {
        return true
    }
    
    override public var isExecuting: Bool {
        return state == .executing
    }
    
    override public var isFinished: Bool {
        return state == .finished
    }
    
    override public func start() {
        if isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }
    
    override open func main() {
        if isCancelled {
            state = .finished
        } else {
            state = .executing
            print("main start async executing...")
            /// Use a dispatch after 模拟 long-running task.
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
                print("main end async Executing... ")
                self.finish()
            })
        }
    }
    
    public func finish() {
        state = .finished
    }
    
    // MARK: - State management

    public enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + rawValue }
    }
    
    /// Thread-safe computed state value
    public var state: State {
        get {
            stateQueue.sync {
                stateStore
            }
        }
        set {
            // kvo 兼容
            let oldValue = state
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            stateQueue.sync(flags: .barrier) {
                stateStore = newValue
            }
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }

    private let stateQueue = DispatchQueue(label: "AsynchronousOperation State Queue", attributes: .concurrent)
    
    /// Non thread-safe state storage, use only with locks
    private var stateStore: State = .ready
}
