//
//  ViewController.swift
//  LearnAsyncOperation
//
//  Created by brown on 2022/5/1.
//

import UIKit

class ViewController: UIViewController {
    private let workQueue: OperationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let operation = AsyncOperation()
        workQueue.addOperations([operation], waitUntilFinished: true)
        print("Operations finished")
    }
}

