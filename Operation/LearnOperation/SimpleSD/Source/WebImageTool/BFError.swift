//
//  BFError.swift
//  LearnOperation
//
//  Created by brown on 2022/5/15.
//

import Foundation

enum BFError: Error {
    case requestCancelled
    case invalidURL(url: URL)
    case invalidImageData(data: Data)
    case networkError
}
