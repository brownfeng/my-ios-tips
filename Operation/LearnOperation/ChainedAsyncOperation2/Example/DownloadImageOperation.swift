//
//  File.swift
//  ChainedAsyncOperation2
//
//  Created by brown on 2022/5/3.
//

import Foundation
import UIKit

typealias ImageURL = URL

class DownloadImageOperation: ChainedAsyncResultOperation<ImageURL, UIImage, DownloadImageOperation.Error> {
    enum Error: Swift.Error {
        case canceled
        case invalidURL
        case dataParsingFailed
        case underlying(error: Swift.Error)
    }
    
    private let imageURL: URL
    private var dataTask: URLSessionTask?
    
    init(imageURL: ImageURL) {
        self.imageURL = imageURL
        super.init(input: imageURL)
    }
    
    // 正在执行中被cancel!!!
    override func main() {
        if isCancelled {
            self.finish(with: .failure(.canceled))
            return
        }
        
        dataTask = URLSession.shared.dataTask(with: imageURL, completionHandler: {[weak self] data, response, error in
            if self?.isCancelled ?? true {
                self?.finish(with: .failure(.canceled))
                return
            }
            
            do {
                if let error = error {
                    throw error
                }
                
                if self?.isCancelled ?? true {
                    self?.finish(with: .failure(.canceled))
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    throw Error.dataParsingFailed
                }
                  
                self?.finish(with: .success(image))
            } catch {
                if let error = error as? DownloadImageOperation.Error {
                    self?.finish(with: .failure(error))
                }else {
                    self?.finish(with: .failure(.underlying(error: error)))
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
