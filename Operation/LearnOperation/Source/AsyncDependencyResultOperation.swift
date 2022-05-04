//
//  File.swift
//  LearnOperation
//
//  Created by brown on 2022/5/4.
//

import Foundation

class AsyncDependencyResultOperation<Success>: AsyncResultOperation<Success, AsyncDependencyResultOperation.Error> {
    enum Error: Swift.Error {
        case canceled
        case unkownError
        case underlying(Swift.Error)
    }
    
    override func main() {
        let output = dependencies.compactMap { operation in
            return operation as? ChainedOperationOutputProviding
        }.first?.output as? Success
        
        if let output = output {
            self.finish(with: .success(output))
            return
        }
        
        if let lastError = dependencies.compactMap({ operation in
            return operation as? ChainedOperationOutputProviding
        }).first?.error {
            self.finish(with: .failure(.underlying(lastError)))
        } else {
            self.finish(with: .failure(.unkownError))
        }
    }
    
    override func cancel() {
        cancel(with: .canceled)
    }
}
