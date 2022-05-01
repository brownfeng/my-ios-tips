//
//  ViewController.swift
//  LearnCustomOperation
//
//  Created by brown on 2022/5/1.
//

import UIKit

class ViewController: UIViewController {

    private let workQueue: OperationQueue = {
        let opq = OperationQueue()
        opq.maxConcurrentOperationCount = 2
        opq.name = "com.webank.queue"
        return opq
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        testCustomOperation()
    }
    
    
    func testCustomOperation() {
        let fileUrl = URL(fileURLWithPath: "..")
        let importOperation = ContentImportOperation(itemProvider: NSItemProvider(contentsOf: fileUrl)!)
        importOperation.completionBlock = {
            // 不论是 cancel or finished 都会调用
            print("Import Completed!!")
        }
        
        let uploadOperation = UploadContentOperation()
        uploadOperation.completionBlock = {
            //
            print("upload Completed!!")
        }
        uploadOperation.addDependency(importOperation)
        
        importOperation.cancel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.workQueue.addOperations([importOperation, uploadOperation], waitUntilFinished: true)
        }
    }
}

class ContentImportOperation: Operation {
    private let itemProvider: NSItemProvider
    
    init(itemProvider: NSItemProvider) {
        self.itemProvider = itemProvider
        super.init()
    }
    
    override func main() {
        guard !isCancelled else {
            print("ImportintOperation Cancelled")
            return
        }
        
        print("custom Thread:\(Thread.current)")
        print("Importing content...")
    }
}

// tips -> 自定义的Operation中, 先判断 main() 函数中, 之前的依赖是否ok了!
final class UploadContentOperation: Operation {
    override func main() {
        // 先判断当前 Operation 的服务
        // 当前Operation 依赖的 Operation, 一定要等依赖的Operation执行完才能自己执行
        guard !dependencies.contains(where: { $0.isCancelled }), !isCancelled else {
            print("UploadingOperation Cancelled")

            return
        }

        print("Uploading content..")
    }
}


