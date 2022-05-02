//: [Previous](@previous)

import Foundation


/*:
 Dependency Cancelled!!!
 
 */
final class UploadFileOperation: Operation {
    override func main() {
        guard !dependencies.contains(where: { $0.isCancelled }), !isCancelled else {
            return
        }

        print("Upload File..")
    }
}

//: [Next](@next)
