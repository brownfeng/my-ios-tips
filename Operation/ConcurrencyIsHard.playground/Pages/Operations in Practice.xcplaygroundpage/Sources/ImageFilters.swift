/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

public class TiltShiftOperation: Operation {
    public var inputImage: UIImage?
    public var outputImage: UIImage?

    //  可能拥有一个依赖!!!
    override public func main() {
        if let dependencyImageProvider = dependencies
            .filter({ $0 is FilterDataProvider })
            .first as? FilterDataProvider,
            inputImage == .none
        {
            inputImage = dependencyImageProvider.outputImage
        }

        outputImage = tiltShift(image: inputImage)
    }
}

// 输出结果也可能是拥有一个依赖
public class ImageOutputOperation: Operation {
    public var inputImage: UIImage?
    public var completion: ((UIImage?) -> ())?

    override public func main() {
        guard let completion = completion else { return }
        if let dependencyImageProvider = dependencies
            .filter({ $0 is FilterDataProvider })
            .first as? FilterDataProvider,
            inputImage == .none
        {
            inputImage = dependencyImageProvider.outputImage
        }

        completion(inputImage)
    }
}

public protocol FilterDataProvider {
    var outputImage: UIImage? { get }
}

// 扩展
extension ImageLoadOperation: FilterDataProvider {}

extension TiltShiftOperation: FilterDataProvider {}

precedencegroup Chainable {
    associativity: left
}

infix operator |>: Chainable

// 符号的扩展!!!
public extension Operation {
    static func |>(lhs: Operation, rhs: Operation) -> Operation {
        rhs.addDependency(lhs)
        return rhs
    }
}
