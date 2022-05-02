//: [Previous](@previous)

import Foundation

/*:
 Serial/Concurrent Queue ==> lock Queue
 */

// serialQueue 作为 lockQueue
class MyTestTask {
    // 保护 _isCancelled 状态
    private(set) var lockQueue: DispatchQueue = DispatchQueue(label: "com.brownfeng.lockQueue")
    
    private var _isCancelled: Bool = false
    
    // 线程安全的API
    var isCancelled: Bool {
        get {
            lockQueue.sync {
                _isCancelled
            }
        }
        
        set {
            lockQueue.sync {
                _isCancelled = newValue
            }
        }
    }
}

/// serialQueue 保护 Array
class SafetyArray<T> {
    var array = [T]()
    let serialQueue = DispatchQueue(label: "com.queue.serial")

    var last: T? {
        var result: T?
        self.serialQueue.sync {
            result = self.array.last
        }
        return result
    }

    func append(_ newElement: T) {
        self.serialQueue.async() {
            self.array.append(newElement)
        }
    }
}

/*:
 使用 Concurrent + barrier write, 类似 读写锁
 
 - int pthread_rwlock_rdlock(pthread_rwlock_t *rwlock);
 - int pthread_rwlock_wrlock(pthread_rwlock_t *rwlock);
 - int pthread_rwlock_unlock(pthread_rwlock_t *rwlock);
 */
class MyTestTask2 {

    // 保护 _isCancelled 状态
    private(set) var lockQueue: DispatchQueue = DispatchQueue(label: "com.brownfeng.lockQueue", attributes: .concurrent)
    
    private var _isCancelled: Bool = false
    
    // 线程安全的API
    var isCancelled: Bool {
        get {
            lockQueue.sync {
                _isCancelled
            }
        }
        
        set {
            // barrier write
            lockQueue.sync(flags: [.barrier]) {
                _isCancelled = newValue
            }
        }
    }
}

// 性能更好!
// 使用 Concurrent + barrier write 保护 array
class Safety2Array<T> {
    var array = [T]()
    let concurrentQueue = DispatchQueue(label: "com.queue.concurrent", attributes: .concurrent)

    var last: T? {
        var result: T?
        self.concurrentQueue.sync {
            result = self.array.last
        }
        return result
    }

    func append(_ newElement: T) {
        self.concurrentQueue.async(flags: .barrier) {
            self.array.append(newElement)
        }
    }
}


//: [Next](@next)
