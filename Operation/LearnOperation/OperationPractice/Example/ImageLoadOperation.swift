//
//  File.swift
//  OperationPractice
//
//  Created by brown on 2022/5/4.
//

import Foundation
import UIKit

// 定义一个操作符
precedencegroup Chainable {
    associativity: left
}

infix operator |>: Chainable
extension Operation {
    static func |>(lhs: Operation, rhs: Operation) -> Operation {
        rhs.addDependency(lhs)
        return rhs
    }
}

class ImageLoadOperation: ChainedAsynchronousResultOperation<String, UIImage> {
    enum Error: Swift.Error {
        case invalidImageName
    }
    
    
    override func execute(_ input: String) {
        simulateAsyncNetworkLoadImage(named: input) { [weak self] image in
            if let image = image {
                self?.finish(with: .success(image))
            }else {
                self?.finish(with: .failure(Error.invalidImageName))
            }
        }
    }

    private func simulateAsyncNetworkLoadImage(named: String?, callback: @escaping (UIImage?) -> ()) {
        OperationQueue().addOperation {
            let image = self.simulateNetworkLoadImage(named: named)
            callback(image)
        }
    }

    private func simulateNetworkLoadImage(named: String?) -> UIImage? {
        sleep(1)
        guard let named = named else { return nil }
        return UIImage(named: named)
    }
}
