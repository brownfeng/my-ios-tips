//
//  ImageProvider.swift
//  OperationPractice
//
//  Created by brown on 2022/5/4.
//

import UIKit

// ImageProvider 负责 loading 和 processing image => 输出 processedImage
// 创建相关的 operations, chains them,
class ImageProvider {
    let queue = OperationQueue()
    var loadedImage: UIImage? // 最后加载的图像
    var completion: ((UIImage?) -> ())?
  
    // 输入是一个 imageNamed
    init(imageName: String) {
        // 1. 加载图像
        let loadOp = ImageLoadOperation(input: imageName)
        // 2. 图像处理
        let tiltShiftOp = TiltShiftOperation()
        // 3. 图像输出 最终结果!!! onResult
        let resultOperation = AsynchronousDependencyResultOperation<UIImage>()

        resultOperation.onResult = { [weak self] result in
            switch result {
            case .success(let image):
                self?.loadedImage = image
                self?.completion?(image)
            case .failure(let error):
                print("imageName: \(imageName), error: \(error)")
            }
           // 结果回调
        }

  
        // 设置依赖 => 创建的一个依赖操作符
        loadOp |> tiltShiftOp |> resultOperation
    
        queue.addOperations([loadOp, tiltShiftOp, resultOperation], waitUntilFinished: false)
    }
  
    // 如果整个服务取消 -> ImageDataProvider
    func cancel() {
        queue.cancelAllOperations()
    }
}

//: `DataSource` is a class that represents the table's datasource and delegate
