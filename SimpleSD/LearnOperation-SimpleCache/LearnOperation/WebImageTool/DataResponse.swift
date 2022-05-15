//
//  DataResponse.swift
//  LearnOperation
//
//  Created by brown on 2022/5/15.
//

import Foundation

struct DataResponse<Success, Failure: Error> {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    
    public let result: Result<Success, Failure>

    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    public var value: Success? {
        guard case let .success(value) = result else { return nil }
        return value
    }

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: Failure? {
        guard case let .failure(error) = result else { return nil }
        return error
    }
    
    public init(request: URLRequest?,
                response: HTTPURLResponse?,
                data: Data?,
                result: Result<Success, Failure>) {
        self.request = request
        self.response = response
        self.data = data
        self.result = result
    }
}
