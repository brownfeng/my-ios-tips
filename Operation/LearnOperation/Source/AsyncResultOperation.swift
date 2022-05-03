//
//  File.swift
//  ChainedAsyncOperation
//
//  Created by brown on 2022/5/3.
//

import Foundation

open class AsyncResultOperation<Success, Failure>: AsyncOperation where Failure: Error {
   
    /// 注意这里定义使用的是 ! 强制解包, 但是 extension 中调用时候使用的是:
    ///     var output: Any? { try? result?.get() }
    /// 这样能解决 output 内容的问题
    public private(set) var result: Result<Success, Failure>! {
        didSet {
            onResult?(result)
        }
    }
    
    public var onResult:((_ result: Result<Success, Failure>) -> Void)?
    
    final override public func finish() {
        guard !isCancelled else {
            return super.finish()
        }
        fatalError("Make use of finish(with:) instead to ensure a result")
    }
    
    public func finish(with result: Result<Success, Failure>) {
        self.result = result
        super.finish()
    }
    
    open override func cancel() {
        fatalError("yout should use cancel(with:) to ensure a result")
    }
    
    public func cancel(with error: Failure) {
        result = .failure(error)
        super.cancel()
    }
}
