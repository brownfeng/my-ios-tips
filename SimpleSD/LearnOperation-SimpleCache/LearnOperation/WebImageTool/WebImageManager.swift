//
//  WebImageManager.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import UIKit

class WebImageManager {
    typealias CompletionHandler = (_ image: UIImage, _ urlString: String) -> Void
    static let shared: WebImageManager = WebImageManager()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private let workQueue: OperationQueue = {
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = 2
        return oq
    }()
    
    private var imageCacheMap: [String: UIImage] = [:]
    private var downloadOperationMap: [String: Operation] = [:]
    private var handleMap: [String: [CompletionHandler]] = [:] // 多个回调

    private var completionBlock: CompletionHandler? = nil
    
    func cancelDownloadImage(with urlString: String) {
        assert(Thread.current.isMainThread, "必须在主线程调用")
        let operation = downloadOperationMap[urlString]
        operation?.cancel()
        
        downloadOperationMap.removeValue(forKey: urlString)
        
        handleMap.removeValue(forKey: urlString)
    }
    
    func downloadImage(with urlString: String, title: String, completionHandler: @escaping (_ image: UIImage,_ urlString: String) -> Void) {
        assert(Thread.current.isMainThread, "必须在主线程调用")
        
        // 内存缓存获取
        let cacheImage = self.imageCacheMap[urlString]
        if let cacheImage = cacheImage {
            print("图像从内存缓存获取, title\(title)")
            completionHandler(cacheImage, urlString)
            return
        }
        
        // 磁盘缓存获取
        let cacheImageURL = urlString.getDownloadURL()
        let diskCacheImage = UIImage(contentsOfFile: cacheImageURL.path)
        if let diskCacheImage = diskCacheImage {
            print("使用磁盘缓存: \(title)")
            // 磁盘图片, 存入内存缓存
            imageCacheMap[urlString] = diskCacheImage
            completionHandler(diskCacheImage, urlString)
            return
        }
        
        // 是否在下载中
        if let _ = downloadOperationMap[urlString] {
            print("图像正在下载, 让子弹飞一会 \(title)")
            // 缓存 callback
            if var callbackArrays = handleMap[urlString] {
                callbackArrays.append(completionHandler)
            } else {
                let callbackArray = [completionHandler]
                handleMap[urlString] = callbackArray
            }
            return
        }
        
        // 重新下载 -- 自定义 Operation
        
        let downloadOp = WebImageDownloadOperation(urlString: urlString, title: title) {[weak self] data, urlString in
            guard let self = self else {
                return
            }
            let downloadImage = UIImage(data: data)
            if let downloadImage = downloadImage {
                OperationQueue.main.addOperation {
                    self.imageCacheMap[urlString] = downloadImage
                    self.downloadOperationMap.removeValue(forKey: urlString)
                    completionHandler(downloadImage, urlString)
                    
                    if let callbackArray = self.handleMap[urlString] {
                        for callback in callbackArray {
                            callback(downloadImage, urlString)
                        }
                        self.handleMap.removeValue(forKey: urlString)
                    }
                }
            }
        }
        workQueue.addOperation(downloadOp)
        downloadOperationMap[urlString] = downloadOp
    }
    
    // MARK: - Internal
    
    @objc
    private func didReceiveMemoryWarning() {
        print("收到内存警告")
        imageCacheMap.removeAll()
        workQueue.cancelAllOperations()
        downloadOperationMap.removeAll()
        handleMap.removeAll()
    }
}
