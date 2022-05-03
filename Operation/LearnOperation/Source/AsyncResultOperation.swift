//
//  File.swift
//  ChainedAsyncOperation
//
//  Created by brown on 2022/5/3.
//

import Foundation

open class AsyncResultOperation<Success, Failure>: AsyncOperation where Failure: Error {
   
    public private(set) var result: Result<Success, Failure>? {
        didSet {
            guard let result = result else {
                return
            }

            onResult?(result)
        }
    }
    
    public var onResult:((_ result: Result<Success, Failure>) -> Void)?
    
    public override func finish() {
        fatalError("yout should use finish(with:) to ensure a result")
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
