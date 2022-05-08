//
//  WebImageManager.swift
//  SimpleSD
//
//  Created by brown on 2022/5/8.
//

import Foundation
import UIKit

class WebImageManager {
    typealias CompletionHandler = (Result<UIImage, Error>) -> Void
    typealias CancelToken = String
    
    static let shared = WebImageManager()
    
    private var imageCacheMap: [String: UIImage] = [:]
    private var imageOperationMap: [String: WebImageOperation] = [:]
//    private var callbackHandlerArrayMap: [String: [CompletionHandler]] = [:]

    private let workQueue: OperationQueue = {
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = 2
        oq.name = "com.webImageManager.OpertaionQueue"
        return oq
    }()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - API

    @discardableResult
    public func loadImage(with urlString: String, indexPath: IndexPath, completionHandler: @escaping CompletionHandler) -> CancelToken {
        let token = urlString
//        if let memCachedImage = imageCacheMap[urlString] {
//            debugPrint("indePath:\(indexPath), use mem cache")
//            completionHandler(.success(memCachedImage))
//            return token
//        }
//
//        let cacheImageURL = urlString.getCacheImageFileURL()
//        let diskImage = UIImage(contentsOfFile: cacheImageURL.path)
//        if let diskImage = diskImage {
//            debugPrint("indePath:\(indexPath), use disk cache")
//            imageCacheMap[urlString] = diskImage
//            completionHandler(.success(diskImage))
//            return token
//        }
        
        let imageOperation = WebImageOperation(urlString: urlString)
        imageOperation.onResult = { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case let .success(image):
                    // 2. 写入 disk 缓存
                    // 主线程写入缓存
                    self.imageCacheMap[token] = image
                    // 移除downloading
                    self.imageOperationMap.removeValue(forKey: token)
                    completionHandler(.success(image))
                /// 如果拥有同时在下的在这里缓存
                case .failure(let error):
                    completionHandler(.failure(error))
                    break
                }
            }
        }
        debugPrint("indePath:\(indexPath), 添加启动新的 operation: \(urlString)")
        workQueue.addOperation(imageOperation)
        imageOperationMap[token] = imageOperation
        return token
    }
    
    public func cancelOperation(with token: CancelToken) {
        assert(Thread.current.isMainThread, "必须在主线程调用")
        let operation = imageOperationMap[token]
        operation?.cancel()
        imageOperationMap.removeValue(forKey: token)
//        callbackHandlerArrayMap.removeValue(forKey: token)
    }
    
    // MARK: - Internal

    @objc
    private func didReceiveMemoryWarning() {
        print("收到内存警告")
//        imageCacheMap.removeAll()
//        workQueue.cancelAllOperations()
//        imageOperationMap.removeAll()
//        handleMap.removeAll()
    }
}
