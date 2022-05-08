//
//  File.swift
//  SimpleSD
//
//  Created by brown on 2022/5/8.
//

import UIKit
import CommonCrypto

// 全局的
fileprivate var cacheImageMap: [String: UIImage] = [:]

internal extension UIImageView {
    func sd_setImage(urlString: String, indexPath: IndexPath) {
        assert(Thread.current.isMainThread, "必须在主线程调用")

        if let cachedUrl = self.cachedImageUrlString, cachedUrl == urlString {
            debugPrint("indePath:\(indexPath) - 两个图像一样, 没必要重新下载")
            return
        }
        
        if let cachedUrl = self.cachedImageUrlString, cachedUrl != urlString {
            print("indePath:\(indexPath) - 取消之前的下载操作: \(cachedUrl), urlString:\(urlString)")
            WebImageManager.shared.cancelOperation(with: cachedUrl)
        }
        
        // 非常重要
        // TableView Cell 的复用兼容逻辑!!!
        image = nil
        // 记录正在下载的 UrlString
        cachedImageUrlString = urlString
        
        WebImageManager.shared.loadImage(with: urlString, indexPath: indexPath) {[weak self] result in
            debugPrint("indePath:\(indexPath) - UIImageView Extension result:\(result)")

            guard let self = self else {
                return
            }
            
            /*
             非常重要!!! -- 异步请求结果回调的时, 判断状态并更新UI!!!
             1. urlString 持有的是当前下载的对象
             2. self.cachedImageUrlString 可能在网络请求下载过程中变化了!!!
             
             这里的 self == Cell 可能已经在新的 下载任务状态了!!!
             传统的方法这里的回调结果中, 也可以用 indexpath 来绑定这里的结果!!!
             */
            
            if let _ = result.error {
                return
            }
            
            if self.cachedImageUrlString == urlString {
                guard case let .success(image) = result else {
                    return
                }
                
                self.cachedImageUrlString = nil
                self.image = image
            }
        }
    }
    
    private enum AssociatedKeys {
        static var cachedImageUrlString = "cachedImageUrlString"
    }
    
    private(set) var cachedImageUrlString: String? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.cachedImageUrlString, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.cachedImageUrlString) as? String
        }
    }
}


extension String {
    func getCacheImageFileURL() -> URL {
        let fileManager = FileManager.default
        let cacheURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cacheDir = cacheURL.appendingPathComponent("ImageDiskPath", isDirectory: true)
        let isExist = fileManager.fileExists(atPath: cacheDir.path)
        if !isExist {
            do {
                try fileManager.createDirectory(atPath: cacheDir.path, withIntermediateDirectories: true, attributes:nil)
            } catch {
                print("cannot create folders \(error)")
            }
        }
        
        return cacheDir.appendingPathComponent(md5, isDirectory: false)
    }

    /// 原生md5
    public var md5: String {
        guard let data = data(using: .utf8) else {
            return self
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

        #if swift(>=5.0)

        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }

        #else

        _ = data.withUnsafeBytes { bytes in
            CC_MD5(bytes, CC_LONG(data.count), &digest)
        }

        #endif

        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
