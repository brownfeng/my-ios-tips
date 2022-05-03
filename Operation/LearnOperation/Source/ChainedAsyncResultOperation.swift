//
//  ChainedAsyncResultOperation.swift
//  ChainedAsyncOperation
//
//  Created by brown on 2022/5/3.
//

import Foundation

protocol ChainedOperationOutputProviding {
    var output: Any? { get }
}

extension AsyncResultOperation: ChainedOperationOutputProviding {
    var output: Any? { try? result?.get() }
}

class ChainedAsyncResultOperation<Input, Output, Failure>: AsyncResultOperation<Output, Failure> where Failure: Error {
    
    private(set) var input: Input?
    
    init(input: Input? = nil) {
        self.input = input
        super.init()
    }
    
    override func start() {
        if input == nil {
            updateInputFromDependencies()
        }
        super.start()
    }
    
    private func updateInputFromDependencies() {
        self.input = dependencies.compactMap { operation in
            return operation as? ChainedOperationOutputProviding
        }.first?.output as? Input
    }
}
