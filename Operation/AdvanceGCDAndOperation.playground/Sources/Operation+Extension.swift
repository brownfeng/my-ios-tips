import Foundation
public extension Operation {
    
    // 增加一个 KVO, 用来监听 Operation 关键State
    @discardableResult func observeStateChanges() -> [NSKeyValueObservation] {
        let keyPaths: [KeyPath<Operation, Bool>] = [
            \Operation.isExecuting,
            \Operation.isCancelled,
            \Operation.isFinished
        ]

        // 多个 keypaths 主动添加 observe 方法! 监听
        return keyPaths.map { keyPath in
            observe(keyPath, options: .new) { (_, value) in
                print("- \(keyPath._kvcKeyPathString!) is now \(value.newValue!)")
            }
        }
    }
}
