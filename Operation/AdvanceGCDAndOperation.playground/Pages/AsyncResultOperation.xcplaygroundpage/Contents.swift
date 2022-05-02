//: [Previous](@previous)

import PlaygroundSupport
import UIKit
PlaygroundPage.current.needsIndefiniteExecution = true

final class ImageDownloadOperation: AsyncResultOperation<UIImage, ImageDownloadOperation.Error> {
    enum Error: Swift.Error {
        case canceled
        case dataError
        case underlying(error: Swift.Error)
    }
    
    private let imageURL: URL
    private var dataTask: URLSessionTask?
    
    init(imageURL: URL) {
        self.imageURL = imageURL
    }
    
    override func main() {
        let request = URLRequest(url: imageURL)
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, _, error in
            
            guard self?.isCancelled == false else {
                // 注意这里不需要主动回调 !!!! self?.finish(with: .failure(.canceled))
                return
            }
            
            if let error = error {
                self?.finish(with: .failure(Error.underlying(error: error)))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                self?.finish(with: .failure(.dataError))
                return
            }
            
            self?.finish(with: .success(image))
        })
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel(with: .canceled)
    }
}

let url = URL(string: "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2255216145,2300317876&fm=27&gp=0.jpg")!
let imageDonwloadOperation = ImageDownloadOperation(imageURL: url)
imageDonwloadOperation.onResult = { result in
    if case let .success(image) = result {
        DispatchQueue.main.async {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
            imageView.image = image
            PlaygroundPage.current.liveView = imageView
        }
    } else {
        print("\(result.mapError { $0 })")
    }
}
    
let operationQueue = OperationQueue()
operationQueue.addOperation(imageDonwloadOperation)
//imageDonwloadOperation.cancel()


//: [Next](@next)
