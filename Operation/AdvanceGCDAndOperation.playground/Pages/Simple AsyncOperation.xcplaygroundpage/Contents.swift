//: [Previous](@previous)

import Foundation

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

final class FileUploadOperation: AsyncOperation {
    typealias UploadCompletionHandler = (Result<(String, String), FileUploadError>) -> Void
    
    enum FileUploadError: Error {
        case networkError
        case timeoutError
    }
    
    private let fileURL: URL
    private let targetUploadURL: URL
    private var uploadTask: URLSessionTask?
    private var uploadCompletionHandler: UploadCompletionHandler?
    
    init(fileURL: URL, targetUploadURL: URL, uploadCompletionHandler: UploadCompletionHandler? = nil) {
        self.fileURL = fileURL
        self.targetUploadURL = targetUploadURL
        self.uploadCompletionHandler = uploadCompletionHandler
    }
    
    override func main() {
        uploadTask = URLSession.shared.uploadTask(with: URLRequest(url: targetUploadURL), fromFile: fileURL, completionHandler: {[weak self] data, response, error in
            guard let self = self else {
                return
            }
            guard let _ = error else {
                self.uploadCompletionHandler?(.failure(.networkError))
                return
            }
            
            /// ... 处理 response !!!

            self.uploadCompletionHandler?(.success(("fileId", "fileHash")))
            /// 最后调用finish
            self.finish()
        })
    }
    
    override func cancel() {
        uploadTask?.cancel()
        super.cancel()
    }
}

//let imageURL = URL(string: "../")!
//let targetURL = URL(string: "https://www.baidu.com")!
//let imageUploadOperation = FileUploadOperation(fileURL: imageURL , targetUploadURL: targetURL) { result in
//    if case let .success((fileId, fileHash)) = result {
//        print("upload success - fileId: \(fileId), fileHash:\(fileHash)")
//    }else {
//        print("upload failure \(result.mapError{$0} )")
//    }
//}

//: [Next](@next)
