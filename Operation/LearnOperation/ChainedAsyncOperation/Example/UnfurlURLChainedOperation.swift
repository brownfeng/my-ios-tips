//
//  UnfurlURLChainedOperation.swift
//  ChainedAsyncOperation
//
//  Created by brown on 2022/5/3.
//

import Foundation


typealias ShortURL = URL
typealias LongURL = URL
final class UnfurlURLChainedOperation: ChainedAsyncResultOperation<ShortURL, LongURL, UnfurlURLChainedOperation.Error> {
    enum Error: Swift.Error {
        case canceled
        case missingInputURL
        case missingRedirectURL
        case underlying(error: Swift.Error)
    }
    
    private var dataTask: URLSessionTask?
    
    init(shortURL: URL) {
        super.init(input: shortURL)
    }
    
    override func main() {
        guard let input = input else {
            return finish(with: .failure(.missingInputURL))
        }
        
        var request = URLRequest(url: input)
        request.httpMethod = "HEAD"
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: {[weak self] data, response, error in
            if let error = error {
                self?.finish(with: .failure(.underlying(error: error)))
                return
            }
            guard let longURL = response?.url else {
                self?.finish(with: .failure(.missingRedirectURL))
                return
            }
            
            self?.finish(with: .success(longURL))
        })
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        cancel(with: .canceled)
    }
}
