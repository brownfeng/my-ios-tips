//
//  File.swift
//  LearnAsyncOperation
//
//  Created by brown on 2022/5/1.
//

import Foundation

class FileUploadOperation: AsyncOperation {
    private let fileURL: URL
    private let targetUploadURL: URL
    private var uploadTask: URLSessionTask?
    
    init(fileURL: URL, targetUploadURL: URL) {
        self.fileURL = fileURL
        self.targetUploadURL = targetUploadURL
    }
    
    override func main() {
        let request = URLRequest(url: targetUploadURL)
        uploadTask = URLSession.shared.uploadTask(with: request, fromFile: fileURL, completionHandler: { data, response, error in
            /// Handle the response
            /// ...
            /// call finish
            self.finish()
        })
    }
    
    override func cancel() {
        uploadTask?.cancel()
        super.cancel()
    }
}
