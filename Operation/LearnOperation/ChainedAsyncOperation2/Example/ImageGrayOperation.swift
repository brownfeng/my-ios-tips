//
//  ImageGrayOperation.swift
//  ChainedAsyncOperation2
//
//  Created by brown on 2022/5/3.
//

import Foundation
import UIKit

typealias InputImage = UIImage
typealias OutputImage = UIImage

class ImageGrayOperation: ChainedAsyncResultOperation<InputImage, OutputImage, ImageGrayOperation.Error> {
    enum Error: Swift.Error {
        case canceled
        case invalidInput
        case processFailure
    }
    
    private let context = CIContext(options: nil)
    
    
    override func main() {
        guard !isCancelled else {
            finish(with: .failure(.canceled))
            return
        }
        
        guard let input = input else {
            finish(with: .failure(.invalidInput))
            return
        }
        
        let outputImage = grayScale(input: input)
        if let outputImage = outputImage {
            self.finish(with: .success(outputImage))
        } else {
            self.finish(with: .failure(.processFailure))
        }
    }
    
    override func cancel() {
        
        cancel(with: .canceled)
    }
    
    private func grayScale(input: UIImage) -> UIImage? {
        var inputImage = CIImage(image: input)
        
        let filters = inputImage!.autoAdjustmentFilters()

        for filter: CIFilter in filters {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            inputImage =  filter.outputImage
        }
        
        let cgImage = context.createCGImage(inputImage!, from: inputImage!.extent)
        let currentFilter = CIFilter(name: "CIPhotoEffectTonal")
        currentFilter!.setValue(CIImage(image: UIImage(cgImage: cgImage!)), forKey: kCIInputImageKey)

        let output = currentFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        return UIImage(cgImage: cgimg!)
    }
}
