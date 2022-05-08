//
//  WebImageOperation.swift
//  ChainedAsyncOperation
//
//  Created by brown on 2022/5/3.
//

import Foundation
import UIKit
 
final class WebImageOperation: AsyncResultOperation<UIImage, WebImageOperation.Error> {
    enum Error: Swift.Error {
        case canceled
        case invalidURL
        case dataParsingFailed
        case underlying(error: Swift.Error)
        
        func isCanceled() -> Bool {
            if case .canceled = self {
                return true
            }
            return false
        }
    }
    
    private let urlString: String
    private var imageDataFileUrl: URL {
        return urlString.getCacheImageFileURL()
    }
    private var dataTask: URLSessionTask?
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    // 正在执行中被cancel!!!
    override func main() {
        if isCancelled {
            self.finish(with: .failure(.canceled))
            return
        }
        
        let imageURL = URL(string: urlString)!
        dataTask = URLSession.shared.dataTask(with: imageURL, completionHandler: {[weak self] data, response, error in
            guard let self = self else {
                return
            }
            if self.isCancelled {
                self.finish(with: .failure(.canceled))
                return
            }
            
            do {
                if let error = error {
                    throw error
                }
                
                if self.isCancelled {
                    self.finish(with: .failure(.canceled))
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    throw Error.dataParsingFailed
                }
                
                let cacheImageURL = self.imageDataFileUrl
                // 将图像写入文件
                try? data.write(to: cacheImageURL)
                
                self.finish(with: .success(image))
            } catch {
                if let error = error as? WebImageOperation.Error {
                    self.finish(with: .failure(error))
                }else {
                    self.finish(with: .failure(.underlying(error: error)))
                }
            }
            
        })
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        cancel(with: .canceled)
    }
}
