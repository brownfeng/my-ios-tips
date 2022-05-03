//
//  ViewController.swift
//  ChainedAsyncOperation
//
//  Created by brown on 2022/5/3.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        test()
        
    }

    func test() {
        let queue = OperationQueue()
        let unfurlOperation = UnfurlURLChainedOperation(shortURL: URL(string: "https://bit.ly/33UDb5L")!)
        unfurlOperation.onResult = { print($0) }
        
//        let fetchTitleOperation = FetchTitleChainedOperation(input: URL(string: "https://www.baidu.com")!)
        let fetchTitleOperation = FetchTitleChainedOperation(input: nil)

        fetchTitleOperation.onResult = { print($0) }

        fetchTitleOperation.addDependency(unfurlOperation)
        queue.addOperations([unfurlOperation, fetchTitleOperation], waitUntilFinished: false)
    
    }

}

