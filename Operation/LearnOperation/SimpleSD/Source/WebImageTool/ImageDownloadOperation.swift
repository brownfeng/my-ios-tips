//
//  File.swift
//  LearnOperation
//
//  Created by brown on 2022/5/15.
//

import Foundation
import UIKit

class ImageDownloadOperation: BaseAsyncOperation {
    public private(set) var request: URLRequest
    public private(set) var completion: CompletionHandler
    
    init(request: URLRequest, completion:@escaping CompletionHandler) {
        self.request = request
        self.completion = completion
    }
    
    override open func main() {
        /// Use a dispatch after 模拟 long-running task.
        URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            guard let self = self else {
                return
            }
            defer {
                self.finish()
            }
            guard let data = data, let response = response as? HTTPURLResponse else {
                let dataResponse = DataResponse<UIImage, BFError>(request: self.request, response: nil, data: nil, result: .failure(BFError.networkError))
                self.completion(dataResponse)
                return
            }
            
            if let image = UIImage(data: data, scale: UIScreen.main.scale) {
                let dataResponse = DataResponse<UIImage, BFError>(request: self.request, response: response, data: data, result: .success(image))
                self.completion(dataResponse)
                return
            } else {
                let dataResponse = DataResponse<UIImage, BFError>(request: self.request, response: response, data: data, result: .failure(BFError.invalidImageData(data: data)))
                self.completion(dataResponse)
                return
            }
        }.resume()
    }
    
}
