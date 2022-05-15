//
//  ImageCache.swift
//  LearnOperation
//
//  Created by brown on 2022/5/15.
//

import Foundation
import UIKit

protocol ImageCache {
    func add(_ image: UIImage, withIdentifier identifier: String)
    func removeImage(withIdentifier identifier: String)
    
    func removeAllImages() -> Bool
    
    func image(withIdentifier identifier: String) -> UIImage?
}

protocol ImageRequestCache: ImageCache {
    func add(_ image: UIImage, for request: URLRequest)
    func removeImage(for request: URLRequest)
    
    func image(for request:URLRequest) -> UIImage?
}
