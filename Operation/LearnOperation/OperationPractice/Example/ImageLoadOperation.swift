//
//  File.swift
//  OperationPractice
//
//  Created by brown on 2022/5/4.
//

import Foundation
import UIKit

class ImageLoadOperation: ChainedAsyncResultOperation<String, UIImage, ImageLoadOperation.Error > {
    enum Error: Swift.Error {
        case canceled
        case invalidInput
    }
    
    override func main() {
        guard !isCancelled else {
            finish(with: .failure(.canceled))
            return
        }
        
        guard let input = input else {
            finish(with: .failure(.invalidInput))
            return
        }
        
        simulateAsyncNetworkLoadImage(named: input) { [weak self] image in
            if let image = image {
                self?.finish(with: .success(image))
            }else {
                self?.finish(with: .failure(Error.invalidInput))
            }
        }
    }
    override func cancel() {
        cancel(with: .canceled)
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
