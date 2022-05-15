//
//  RequestReceipt.swift
//  LearnOperation
//
//  Created by brown on 2022/5/15.
//

import Foundation

class RequestReceipt {
    public let request: URLRequest
    public let receiptID: String
    
    init(request: URLRequest, receiptID: String) {
        self.request = request
        self.receiptID = receiptID
    }
}
