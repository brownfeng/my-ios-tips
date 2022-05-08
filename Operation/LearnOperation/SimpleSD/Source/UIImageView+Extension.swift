//
//  File.swift
//  SimpleSD
//
//  Created by brown on 2022/5/8.
//

import UIKit
import CommonCrypto

// 全局的
var cacheImageMap: [String: UIImage] = [:]

internal extension UIImageView {
    func sd_setImage(urlString: String, indexPath: IndexPath) {
        let url = URL(string: urlString)!
        
        if let memCachedImage = cacheImageMap[urlString] {
            debugPrint("indePath:\(indexPath), use mem cache")
            image = memCachedImage
            return
        }
        
        let cacheImageURL = urlString.getCacheImageFileURL()
        let diskImage = UIImage(contentsOfFile: cacheImageURL.path)
        if let image = diskImage {
            debugPrint("indePath:\(indexPath), use disk cache")

            self.image = image
            // 写入内存缓存
            cacheImageMap[urlString] = image
            return
        }
        
        image = nil
        DispatchQueue.global().async {
            let imageData = try! Data(contentsOf: url)
            try! imageData.write(to: cacheImageURL)
            let image = UIImage(data: imageData)

            DispatchQueue.main.async {
                //主线程写入缓存
                cacheImageMap[urlString] = image
                debugPrint("indePath:\(indexPath), use net image")

                self.image = image
            }
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
