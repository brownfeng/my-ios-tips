//
//  Extension.swift
//  OperationPractice
//
//  Created by brown on 2022/5/4.
//

import Foundation

// 定义一个操作符
precedencegroup Chainable {
    associativity: left
}

infix operator |>: Chainable
extension Operation {
//    @discardableResult
    static func |>(lhs: Operation, rhs: Operation) -> Operation {
        rhs.addDependency(lhs)
        return rhs
    }
}

extension Array where Element == Operation {
    func chained() -> [Element] {
        for item in enumerated() where item.offset > 0 {
            item.element.addDependency(self[item.offset - 1])
        }
        return self
    }
}

extension Result {
    public var error: Error? {
        guard case .failure(let error) = self else { return nil }
        return error
    }

    public var value: Success? {
        guard case .success(let value) = self else { return nil }
        return value
    }
}
