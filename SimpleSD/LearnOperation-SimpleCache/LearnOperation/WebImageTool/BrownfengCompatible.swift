//
//  BrownfengCompatible.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import Foundation
import UIKit

public struct Brownfeng<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol BrownfengCompatible {
    associatedtype CompatibleType
    
    static var bf: CompatibleType.Type { get }
    var bf: CompatibleType { get }
}

public extension BrownfengCompatible {
    
    static var bf: Brownfeng<Self>.Type {
        get { return Brownfeng<Self>.self }
    }
    
    var bf: Brownfeng<Self> {
        get { return Brownfeng(self) }
    }
}


