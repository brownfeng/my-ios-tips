//
//  File.swift
//  ChainedAsyncOperation
//
//  Created by brown on 2022/5/3.
//

import Foundation

final class FetchTitleChainedOperation: ChainedAsyncResultOperation<URL, String, FetchTitleChainedOperation.Error> {
    enum Error: Swift.Error {
        case cancel
        case dataParsingFailed
        case missingInputURL
        case missingPageTitle
        case underlying(error: Swift.Error)
    }
    
    private var dataTask: URLSessionTask?
    
    override final public func main() {
        guard let input = input else {
            return finish(with: .failure(.missingInputURL))
        }
        
        var request = URLRequest(url: input)
        request.httpMethod = "GET"
        
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            do {
                if let error = error {
                    throw error
                }
                
                guard let data = data, let html = String(data: data, encoding: .utf8) else {
                    throw Error.dataParsingFailed
                }
                
                guard let pageTitle = self.pageTitle(for: html) else {
                    throw Error.missingPageTitle
                }
                
                self.finish(with: .success(pageTitle))
            }catch {
                if let error = error as? Error {
                    self.finish(with: .failure(error))
                } else {
                    self.finish(with: .failure(.underlying(error: error)))
                }
            }
        })
        dataTask?.resume()
    }
    
    private func pageTitle(for html: String) -> String? {
        guard let rangeFrom = html.range(of: "<title>")?.upperBound else {return nil}
        guard let rangeTo = html[rangeFrom...].range(of: "</title>")?.lowerBound else {
            return nil
        }
        return String(html[rangeFrom..<rangeTo])
    }
    
    override final func cancel() {
        dataTask?.cancel()
        cancel(with: .cancel)
    }
}
