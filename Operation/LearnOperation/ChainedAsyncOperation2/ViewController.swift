//
//  ViewController.swift
//  ChainedAsyncOperation2
//
//  Created by brown on 2022/5/3.
//

import UIKit

class ViewController: UIViewController {
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        view.addSubview(iv)
        return iv
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageView.frame = self.view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        test()
    }

    func test() {
        let queue = OperationQueue()
        let url = URL(string: "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2255216145,2300317876&fm=27&gp=0.jpg")!
        let downloadOperation = DownloadImageOperation(imageURL: url)
        downloadOperation.onResult = { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            case .failure(let error):
                print(error)
            }
        }
        
        let imageGrayOperation = ImageGrayOperation()
        imageGrayOperation.onResult = { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            case .failure(let error):
                print(error)
            }
        }
        imageGrayOperation.addDependency(downloadOperation)
        
        queue.addOperations([downloadOperation, imageGrayOperation], waitUntilFinished: false)
    }
}

