//
//  File.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import Foundation
import UIKit

public struct BrownWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

protocol BrownWrapperCompatible: AnyObject {}

public protocol BrownWrapperCompatibleValue {}

extension BrownWrapperCompatible {
    public var br: BrownWrapper<Self> {
        get {
            return BrownWrapper(self)
        }
        set {}
    }
}

extension BrownWrapperCompatibleValue {
    /// Gets a namespace holder for Kingfisher compatible types.
    public var kf: BrownWrapper<Self> {
        get { return BrownWrapper(self) }
        set { }
    }
}

extension UIImageView: BrownWrapperCompatible {}
