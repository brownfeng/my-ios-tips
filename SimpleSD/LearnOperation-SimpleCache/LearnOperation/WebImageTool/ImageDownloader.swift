//
//  ImageDownloader.swift
//  LearnOperation
//
//  Created by brown on 2022/5/15.
//

import Foundation
import UIKit


class ImageDownloader {
    public static let `default` = ImageDownloader()

    public let imageCache: ImageRequestCache? = nil

    private let workQueue: OperationQueue = {
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = 2
        let name = String(format: "com.brownfeng.imagedownloader.workqueue-%08x%08x", arc4random(), arc4random())
        oq.name = name
        return oq
    }()
    private let syncQueue: DispatchQueue = {
        let name = String(format: "com.brownfeng.imagedownloader.syncqueue-%08x%08x", arc4random(), arc4random())
        return DispatchQueue(label: name)
    }()
   
    private let session: URLSession = {
        return URLSession.shared
    }()
    
    var responseHandlers: [String: ResponseHandler] = [:]

    // 主线程中访问
    func download(_ urlRequest: URLRequest, receiptID: String = UUID().uuidString, completion: CompletionHandler? = nil) -> RequestReceipt? {
        
        syncQueue.sync {
            // 1. Append the completion handler to a pre-existing request if it already exists
            
            let urlID = ImageDownloader.urlIdentifier(for: urlRequest)
            if let responseHandler = responseHandlers[urlID] {
                responseHandler.operations.append((receiptID: receiptID, completion: completion))
                return
            }
            
            // 2. Create the new request!!!
            let handlerID = UUID().uuidString

            let newDownloadOperation = ImageDownloadOperation(request: urlRequest) { response in
                // Early out if the request has changed out from under us
                // 在回调结果时, handler 请求的handler 已经退出了
                guard
                    let handler = self.safelyFetchResponseHandler(withURLIdentifier: urlID),
                    handler.handlerID == handlerID,
                    let responseHandler = self.safelyRemoveResponseHandler(withURLIdentifier: urlID)
                else {
                    return
                }
                
                switch response.result {
                case .success(let image):
                    for (_, completion) in responseHandler.operations {
                        if let request = response.request {
                           self.imageCache?.add(image, for: request)
                            DispatchQueue.main.async {
                                completion?(response)
                            }
                       }
                    }
                case .failure:
                    for (_,  completion) in responseHandler.operations {
                        DispatchQueue.main.async {
                            completion?(response)
                        }
                    }
                }
            }

            // 3. Store the response handler for use when the request completes
            let responseHandler = ResponseHandler(downloadOperation: newDownloadOperation,
                                                  handlerID: handlerID,
                                                  receiptID: receiptID,
                                                  completion: completion)
            self.responseHandlers[urlID] = responseHandler
            
            // 4. start request operation
            self.workQueue.addOperation(newDownloadOperation)
        }
        
        return RequestReceipt(request: urlRequest, receiptID: receiptID)
    }
    
    func cancelRequest(with requestReceipt: RequestReceipt) {
        // imageDownloader 同步取消
        syncQueue.sync {
            let urlID = ImageDownloader.urlIdentifier(for: requestReceipt.request)
            // 每一个urlID 会关联一个 responseHandler
            guard let responseHandler = self.responseHandlers[urlID] else { return }
            let index = responseHandler.operations.firstIndex {
                $0.receiptID == requestReceipt.receiptID
            }

            if let index = index {
                let operation = responseHandler.operations.remove(at: index)

                let response: DataResponse<UIImage, BFError> = {
                    let urlRequest = requestReceipt.request
                    let error = BFError.requestCancelled
                    
                    return DataResponse<UIImage, BFError>(request: urlRequest, response: nil, data: nil, result: .failure(error))
                }()
                DispatchQueue.main.async {
                    operation.completion?(response)
                }
            }

            if responseHandler.operations.isEmpty {
                responseHandler.downloadOperation.cancel()
                self.responseHandlers.removeValue(forKey: urlID)
            }
        }
    }
    
    static func urlIdentifier(for urlRequest: URLRequest) -> String {
        return urlRequest.url?.absoluteString ?? ""
    }
}

extension ImageDownloader {
    final class ResponseHandler {
        let urlID: String
        let handlerID: String
        let downloadOperation: ImageDownloadOperation
        var operations: [(receiptID: String, completion: CompletionHandler?)]

        init(downloadOperation: ImageDownloadOperation,
             handlerID: String,
             receiptID: String,
             completion: CompletionHandler?) {
            self.downloadOperation = downloadOperation
            self.urlID = ImageDownloader.urlIdentifier(for: downloadOperation.request)
            self.handlerID = handlerID
            self.operations = [(receiptID: receiptID,  completion: completion)]
        }
    }
}

extension ImageDownloader {
    // MARK: Internal - Thread-Safe Request Methods

    func safelyFetchResponseHandler(withURLIdentifier urlIdentifier: String) -> ResponseHandler? {
        var responseHandler: ResponseHandler?

        syncQueue.sync {
            responseHandler = self.responseHandlers[urlIdentifier]
        }
        return responseHandler
    }
    
    
    func safelyRemoveResponseHandler(withURLIdentifier identifier: String) -> ResponseHandler? {
        var responseHandler: ResponseHandler?
        syncQueue.sync {
            responseHandler = self.responseHandlers.removeValue(forKey: identifier)
        }

        return responseHandler
    }
}
