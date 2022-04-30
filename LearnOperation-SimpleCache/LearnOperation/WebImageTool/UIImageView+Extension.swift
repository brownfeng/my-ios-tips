//
//  UIImageView+Extension.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import UIKit

public extension UIImageView {
    private enum AssociatedKeys {
        static var cacheUrlString = "cacheUrlStringKey"
        static var titleString = "titleStringKey"
    }
    
    // 必须在主线程调用
    func setImage(with urlString: String, title: String, indexPath: IndexPath) {
        assert(Thread.current.isMainThread, "必须在主线程调用")
        if let cacheUrlString = self.cacheUrlString, cacheUrlString == urlString {
            print("两次下载地址一样, 没必要重复下载")
            return
        }
        
        if let cacheUrlString = self.cacheUrlString {
            print("取消之前的下载操作: \(cacheUrlString), urlString:\(urlString) title: \(title),indexPath: \(indexPath)")
            WebImageManager.shared.cancelDownloadImage(with: cacheUrlString)
        }
        
        self.cacheUrlString = urlString
        self.titleString = title
        self.image = nil
        
        WebImageManager.shared.downloadImage(with: urlString, title: title) {[weak self] image, urlString in
            guard let self = self else {
                return
            }
            // 下载完成以后, 需要置空
            self.cacheUrlString = nil
            self.titleString = nil
            self.image = image
        }
        
    }
    
    private(set) var cacheUrlString: String? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.cacheUrlString, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.cacheUrlString) as? String
        }
    }
    
    private(set) var titleString: String? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.titleString, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.titleString) as? String
        }
    }
}
