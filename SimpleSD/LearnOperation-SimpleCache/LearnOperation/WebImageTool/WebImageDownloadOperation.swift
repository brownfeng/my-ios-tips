//
//  WebImageDownloadOperation.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import Foundation

class WebImageDownloadOperation: Operation {
    typealias DownloadCallback = (_ data: Data, _ urlString: String) -> Void

    private let title: String
    private let urlString: String
    
    private let completionHandler: DownloadCallback

    private let workQueue = DispatchQueue(label: "async.operation.queue")
    private let lock = NSRecursiveLock()

    private var _executing = false
    private var _finished = false

    override var isExecuting: Bool {
        get {
            lock.lock()
            let wasExecuting = _executing
            lock.unlock()
            return wasExecuting
        }
        
        set {
            if isExecuting != newValue {
                willChangeValue(forKey: "isExecuting")
                lock.lock()
                _executing = newValue
                lock.unlock()
                didChangeValue(forKey: "isExecuting")
            }
        }
    }

    override var isFinished: Bool {
        get {
            lock.lock()
            let wasFinished = _finished
            lock.unlock()
            return wasFinished
        }
        
        set {
            if isFinished != newValue {
                willChangeValue(forKey: "isFinished")
                lock.lock()
                _finished = newValue
                lock.unlock()
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    override func cancel() {
        print("取消服务")
        super.cancel()
    }

    override var isAsynchronous: Bool {
        return true
    }

    override func start() {
        if isCancelled {
            print("取消下载 \(self.title)")
            isFinished = true
            return
        }
        isExecuting = true
        Thread.sleep(forTimeInterval: 2)

        let url = URL(string: self.urlString)
        guard let url = url else {
            self.done()
            return
        }
        
        let data = try? Data(contentsOf: url)

        if isCancelled {
            print("取消下载 \(self.title)")
            isFinished = true
            return
        }
        
        if let data = data {
            print("下载完成: \(self.title)")
            try? data.write(to: self.urlString.getDownloadURL())
            self.done()
            // 只有真实成功的回调
            completionHandler(data, self.urlString)
            return
        }else {
            print("图像下载失败!!! \(self.title)")
        }
    }
    
    private func done() {
        self.isExecuting = false
        self.isFinished = true
    }
    
    init(urlString: String, title: String, completionHandler: @escaping DownloadCallback) {
        self.urlString = urlString
        self.title = title
        self.completionHandler = completionHandler
    }

}
