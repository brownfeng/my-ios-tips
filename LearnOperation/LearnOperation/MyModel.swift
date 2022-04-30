//
//  MyModel.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import Foundation
import UIKit
import CommonCrypto


struct MyModel {
    let imageUrl: String
    let title: String
}

extension String {
    func getDownloadURL() -> URL {
     
        let fileManager = FileManager.default
        let cacheURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cacheDir = cacheURL.appendingPathComponent("LGDiskPath", isDirectory: true)
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
