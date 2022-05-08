//
//  ViewModel.swift
//  SimpleSD
//
//  Created by brown on 2022/5/8.
//

import Foundation

struct Model {
    let imageUrl: String
}

class ViewModel {
    typealias CompletionHandler = (_ result: Result<[Model], Swift.Error>) -> Void

    enum Error: Swift.Error {
        case decodeError
    }

    var completionHandler: CompletionHandler?
    
    init(completionHandler: CompletionHandler?) {
        self.completionHandler = completionHandler
    }

    func loadModelData() {
        guard let plist = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
              let contents = try? Data(contentsOf: plist),
              let serial = try? PropertyListSerialization.propertyList(from: contents, format: nil),
              let serialUrls = serial as? [String]
        else {
            print("Something went horribly wrong!")
            completionHandler?(.failure(Error.decodeError))
            return
        }
        
        let models = serialUrls.compactMap(Model.init)
        completionHandler?(.success(models))
    }
}
