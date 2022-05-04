//
//  TiltShiftOperation.swift
//  OperationPractice
//
//  Created by brown on 2022/5/4.
//

import Foundation
import UIKit
import Accelerate

//: The same filtering operation you saw before. The `main()` method now attempts to find an input image in its dependencies if the `inputImage` property hasn't already been set.
typealias InputImage = UIImage
typealias OutputImage = UIImage


class TiltShiftOperation: ChainedAsynchronousResultOperation<InputImage, OutputImage> {
    
    enum Error: Swift.Error {
        case tiltShiftError
    }
    
    override func execute(_ input: InputImage) {
        guard let outputImage = tiltShift(image: input) else {
            self.finish(with: .failure(Error.tiltShiftError))
            return
        }
        
        self.finish(with: .success(outputImage))
    }
    
    private func tiltShift(image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        sleep(1)

        // 获取 mask
        let mask = topAndBottomGradient(size: image.size)

        // 增加高斯模糊
        return image.applyBlur(radius: 6, maskImage: mask)
    }

    // 异步任务
    private func tiltShiftAsync(image: UIImage?, callback: @escaping (UIImage?) -> ()) {
        OperationQueue().addOperation {
            let result = self.tiltShift(image: image)
            callback(result)
        }
    }
    
    private func topAndBottomGradient(size: CGSize, clearLocations: [CGFloat] = [0.35, 0.65], innerIntensity: CGFloat = 0.5) -> UIImage {
      
      let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)

      let colors = [
        .white,
        UIColor(white: innerIntensity, alpha: 1.0),
        .black,
        UIColor(white: innerIntensity, alpha: 1.0),
        .white
        ].map { $0.cgColor }
      let colorLocations : [CGFloat] = [0, clearLocations[0], (clearLocations[0] + clearLocations[1]) / 2.0, clearLocations[1], 1]
      
      let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceGray(), colors: colors as CFArray, locations: colorLocations)
      
      let startPoint = CGPoint(x: 0, y: 0)
      let endPoint = CGPoint(x: 0, y: size.height)
      
      context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions())
      let cgImage = context!.makeImage()
      
      return UIImage(cgImage: cgImage!)

    }



}

private extension UIImage {
    // 改造image
    func applyBlur(radius: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
        // Check pre-conditions.
        if size.width < 1 || size.height < 1 {
            print("*** error: invalid size: \(size.width) x \(size.height). Both dimensions must be >= 1: \(self)")
            return nil
        }
        if self.cgImage == nil {
            print("*** error: image must be backed by a CGImage: \(self)")
            return nil
        }
        if maskImage != nil, maskImage!.cgImage == nil {
            print("*** error: maskImage must be backed by a CGImage: \(String(describing: maskImage))")
            return nil
        }
    
        let ulpOfOne = CGFloat.ulpOfOne
        let screenScale = UIScreen.main.scale
        let imageRect = CGRect(origin: .zero, size: size)
        var effectImage = self
    
        let hasBlur = radius > ulpOfOne
    
        if hasBlur {
            // 内置的图像 vImage_apllyBlur 服务
            func createEffectBuffer(context: CGContext) -> vImage_Buffer {
                let data = context.data
                let width = vImagePixelCount(context.width)
                let height = vImagePixelCount(context.height)
                let rowBytes = context.bytesPerRow
        
                return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
            }
      
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectInContext = UIGraphicsGetCurrentContext()!
      
            effectInContext.scaleBy(x: 1.0, y: -1.0)
            effectInContext.translateBy(x: 0, y: -size.height)
            effectInContext.draw(self.cgImage!, in: imageRect)
      
            var effectInBuffer = createEffectBuffer(context: effectInContext)
      
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectOutContext = UIGraphicsGetCurrentContext()!
      
            var effectOutBuffer = createEffectBuffer(context: effectOutContext)
      
            if hasBlur {
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //
        
                let inputRadius = radius * screenScale
                var radius = UInt32(floor(Double(inputRadius * 0.75 * sqrt(2.0 * .pi) + 0.5)))
                if radius % 2 != 1 {
                    radius += 1 // force radius to be odd so that the three box-blur methodology works.
                }
        
                let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)
        
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
            }
      
            effectImage = UIGraphicsGetImageFromCurrentImageContext()!
      
            UIGraphicsEndImageContext()
            UIGraphicsEndImageContext()
        }
    
        // Set up output context.
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        let outputContext = UIGraphicsGetCurrentContext()
        outputContext!.scaleBy(x: 1.0, y: -1.0)
        outputContext!.translateBy(x: 0, y: -size.height)
    
        // Draw base image.
        outputContext!.draw(self.cgImage!, in: imageRect)
    
        // Draw effect image.
        if hasBlur {
            outputContext!.saveGState()
            if let image = maskImage {
                let effectCGImage = effectImage.cgImage!.masking(image.cgImage!)
                if let effectCGImage = effectCGImage {
                    effectImage = UIImage(cgImage: effectCGImage)
                }
            }
            outputContext!.draw(effectImage.cgImage!, in: imageRect)
            outputContext!.restoreGState()
        }
    
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return outputImage
    }
}

