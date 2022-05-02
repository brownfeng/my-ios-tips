//: [Previous](@previous)

import UIKit
import CoreImage

/*:
 Simple Chained Operation
 
 - 需要通过 Operation 的 dependencies API 获取所有依赖的Operation
 - dependencies 获取关键 OutPut
 - dependencies 判断cancel, 完成链式取消
 */
protocol ChainedOperationOutputProviding {
    var output: Any? { get }
}

// 异步数据保证结果!!!
extension AsyncResultOperation: ChainedOperationOutputProviding {
    var output: Any? { try? result?.get() }
}

class ImageFilterOperation: Operation {
    let context = CIContext(options: nil)
    var processedImage: UIImage?
    
    override func main() {
        guard !isCancelled else { return }
        
        // 根据依赖判断是否需要链式取消!!
        let dependencyImage = self.dependencies
            .compactMap { $0 as? ChainedOperationOutputProviding }
            .first
        
        if let output = dependencyImage?.output, let image = output as? UIImage {
            guard !isCancelled else { return }
            self.processedImage = self.grayScale(input: image)
        }
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


//: [Next](@next)
