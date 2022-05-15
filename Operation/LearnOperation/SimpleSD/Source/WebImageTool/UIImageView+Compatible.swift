//
//  UIImageView+Compatible.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import UIKit

typealias CompletionHandler = (DataResponse<UIImage, BFError>)-> Void

extension UIImageView: BrownfengCompatible {}
extension Brownfeng where Base: UIImageView {
    
    var imageDownloader: ImageDownloader? {
        get {
            objc_getAssociatedObject(base, &AssociatedKeys.imageDownloader) as? ImageDownloader
        }
        set(downloader) {
            objc_setAssociatedObject(base, &AssociatedKeys.imageDownloader, downloader, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var sharedImageDownloader: ImageDownloader {
        get {
            if let downloader = objc_getAssociatedObject(UIImageView.self, &AssociatedKeys.sharedImageDownloader) as? ImageDownloader {
                return downloader
            }else {
                return ImageDownloader.default
            }
        }
        set(downloader) {
            objc_setAssociatedObject(UIImageView.self, &AssociatedKeys.sharedImageDownloader, downloader, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var activeRequestReceipt: RequestReceipt? {
        get {
            objc_getAssociatedObject(base, &AssociatedKeys.activeRequestReceipt) as? RequestReceipt
        }
        nonmutating set {
            objc_setAssociatedObject(base, &AssociatedKeys.activeRequestReceipt, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setImage(with url: URL, placeholderImage: UIImage? = nil, completion: CompletionHandler? = nil ) {
        setImage(with: urlRequest(for: url), placeholderImage: placeholderImage, completion: completion)
    }
    
    func setImage(with urlRequest: URLRequest, placeholderImage: UIImage? = nil, completion: CompletionHandler? = nil ) {
        guard !isURLRequestURLEqualToActiveRequestURL(urlRequest) else {
            // 设置的 url 相同 -> 直接返回, 啥也不干
            let dataResponse = DataResponse<UIImage, BFError>(request: nil, response: nil, data: nil, result: .failure(BFError.requestCancelled))

            // 对外回调, 告知这一次设置被取消了. 因为之前已经有相同的 request 正在ing, 它完成会设置图像!!!
            completion?(dataResponse)
            return
        }
        
        cancelImageRequest()
        
        let imageDownloader = imageDownloader ?? UIImageView.bf.sharedImageDownloader
        let imageCache = imageDownloader.imageCache
        if let image = imageCache?.image(for: urlRequest) {
            let response = DataResponse<UIImage, BFError>(request: urlRequest, response: nil, data: nil, result: .success(image))
            // 直接赋值!!! 设置
            base.image = image
            completion?(response)
            return
        }
        
        // 重新构造请求, 重新下载图像
        // 先设置 place holder
        if let placeholderImage = placeholderImage {
            base.image = placeholderImage
        }
        
        let downloadUUID = UUID().uuidString
        
        weak var imageView = base
        let requestReceipt = imageDownloader.download(urlRequest, receiptID: downloadUUID) { response in
            // 异步回调在主线程中 ,这里需要对所有的状态进行判断!!!
            guard
                let strongSelf = imageView?.bf,
                strongSelf.isURLRequestURLEqualToActiveRequestURL(response.request),
                strongSelf.activeRequestReceipt?.receiptID == downloadUUID
            else {
                completion?(response)
                return
            }
            
            if case let .success(image) = response.result {
                imageView?.image = image
            }
            // 置空服务
            strongSelf.activeRequestReceipt = nil
            // 依然回调
            completion?(response)
        }
        
        activeRequestReceipt = requestReceipt
    }
    
    /// Cancels the active download request, if one exists.
    func cancelImageRequest() {
        guard let activeRequestReceipt = activeRequestReceipt else { return }

        // 手动取消cancelRequest, 然后直接将 当前激活的 request回执 = nil
        let imageDownloader = self.imageDownloader ?? UIImageView.bf.sharedImageDownloader
        imageDownloader.cancelRequest(with: activeRequestReceipt)
        self.activeRequestReceipt = nil
    }
    
    
    
    // MARK: - Private
    
    private func urlRequest(for url: URL) -> URLRequest {
        return URLRequest(url: url)
    }
    
    // 判断当前 UIImageView 是否已经绑定了一个请求 -> 也就是正在进行服务
    private func isURLRequestURLEqualToActiveRequestURL(_ urlRequest: URLRequest?) -> Bool{
        if let currentRequestURL = activeRequestReceipt?.request.url,
           let requestURL = urlRequest?.url,
           currentRequestURL == requestURL {
            return true
        }
        return false
    }
    
}


fileprivate enum AssociatedKeys {
   static var imageDownloader = "UIImageView.bf.imageDownloader"
   static var sharedImageDownloader = "UIImageView.bf.sharedImageDownloader"
   static var activeRequestReceipt = "UIImageView.bf.activeRequestReceipt"
}
