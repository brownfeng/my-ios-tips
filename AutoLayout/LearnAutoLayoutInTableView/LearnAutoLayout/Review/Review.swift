//
//  Review.swift
//  LearnAutoLayout
//
//  Created by brown on 2022/4/23.
//

import Foundation

struct ReviewViewModel {
    private let model: Review
    
    var title: String {
        return model.title
    }
    var date: String {
        return model.date
    }
    var memberSince: String {
        return model.memberSince
    }
    
    var isExpanded: Bool = false
    
    var description: String {
        return model.description
    }
    
    init(with review: Review) {
        self.model = review
    }
}

struct Review {
    
    let title: String
    let date: String
    let memberSince: String
    let description: String
    
    
    static func mockData() -> [Review] {
        let data1 = (0...2).enumerated().map { _, _ in
            return Review(title: "brownfeng", date: "2022.4.23", memberSince: "还是 另一次不怀好.", description: """
                                当闭包作为一个实际参数传递给一个函数的时候，并且它会在函数返回之后调用我们就说这个闭包逃逸了，当你声明一个接受闭包作为形式参数的函数时，你可以在形式参数前写@escaping来明确闭包是允许逃逸的。
                                
                                闭包可以逃逸的一种方法是被存储在定义与函数外的变量里，比如说，很多函数接受闭包实际参数来作为启动异步任务的回调。函数在启动任务后返回，但是闭包要直到任务完成--闭包需要逃逸，以便于稍后调用
                """)
        }
        
        let data2 = (0...2).enumerated().map { _, _ in
            return Review(title: "brownfeng", date: "2022.4.23", memberSince: "还闭包作为一个实际参数传递给一个函数的时候，并且它会在函数返回之后调用我们就说这个闭包逃逸了，当你声明一个接受闭包作为形式参数的函数时，你可以在形式参数前写@escaping来明确闭包是允许闭包作为一个实际参数传递给一个函数的时候，并且它会在函数返回之后调用我们就说这个闭包逃逸了，当你声明一个接受闭包作为形式参数的函数时，你可以在形式参数前写@escaping来明确闭包是允许.", description: """
                                当闭包作为一个实际参数传递给一个函数的时候，并且它会在函数返回之后调用我们就说这个闭包逃逸了，当你声明一个接受闭包作为形式参数的函数时，你可以在形式参数前写@escaping来明确闭包是允许逃逸的。
                                
                                闭包可以逃逸的一种方法是被存储在定义与函数外的变量里，比如
                """)
        }
        
        let data3 = (0...2).enumerated().map { _, _ in
            return Review(title: "brownfeng", date: "2022.4.23", memberSince: "还闭包作为确闭包是允许.", description: """
                                当闭包作为一个实际参数传递给一个函数的时候，并且它会在函数返回之后调用我们就说这个闭包逃逸了，当你声明一
                """)
        }
        
        let data4 = (0...2).enumerated().map { _, _ in
            return Review(title: "brownfeng", date: "2022.4.23", memberSince: "还闭包作为确闭包是允许.", description: "调用我")
        }
        var initStr: String = "还闭包作为确闭包是允许."
        let data5 = (0...100).enumerated().map { _, _ -> Review in

            initStr += "index"

            let chat = Review(title: "brownfeng", date: "2022.4.23", memberSince: "调用我!!!!!" + initStr , description: initStr)
            return chat
        }

        return data1 + data2 + data3 + data4 + data5
    }
    
}
