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

        if let _ = self.cachedImageUrlString, cachedImageUrlString == urlString {
            debugPrint("indePath:\(indexPath), 两个图像一样, 没必要重新下载")
            return
        }

        // 两个图不一样!!! 先取消旧的下载
        if let cachedImageUrlString = self.cachedImageUrlString {
            print("取消之前的下载操作: \(cachedImageUrlString), urlString:\(urlString), indexPath: \(indexPath)")
            WebImageManager.shared.cancelOperation(with: cachedImageUrlString)
        }
        
        image = nil
        self.cachedImageUrlString = urlString
        
        WebImageManager.shared.loadImage(with: urlString, indexPath: indexPath) {[weak self] result in
            // 这里非常重要!!! 因为 UIImageView 可能设置成nil了
            guard let self = self else {
                return
            }
            
            guard case let .success((image, urlString)) = result else {
                // 请求被取消了!! 或者失败了! 这里不管了
//                self?.image = nil
                self.cachedImageUrlString = nil
                return
            }
            
            debugPrint("请求回调的时候: indexPath:\(indexPath) urlString: \(urlString), downloadingUrlString: \(self.cachedImageUrlString ?? "")")
            self.image = image
            self.cachedImageUrlString = nil
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
