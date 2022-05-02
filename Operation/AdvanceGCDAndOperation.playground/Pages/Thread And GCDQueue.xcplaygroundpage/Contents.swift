//: [Previous](@previous)

/*:

 Main Thread vs background Thread
 
 - UI 操作必须在 MainThread => runloop
 - 子线程与耗时操作:
    - IO操作: 网络IO, 文件IO
    - CPU耗时: 音视频软件编解码, 序列化反序列化, 文本压缩, 图像编解码, 大量布局计算...
  
 Thread vs GCD Queue
 
 - Thread: 执行事务 Task
 - GCD Queue: Task 调度
    - serialQueue
        - Execute Task one after the other
        - make sure one task is 100% completed and then begins the next task
        - 当我们强烈需要任务有一定顺序时使用, 例如
            - [bg: 图像下载 -> 图像存储 -> 图像读取] -> (UI)图像展示
        - 被当做简单的 lockQueue 使用
    - concurrentQueue
        - 无法预测 task order of excution
        - 执行非常快 -> 依赖底层的线程池中可用线程
        - TaskB 不依赖 TaskA执行结束
        - 通常来说, 多个Task 被添加到 Queue 的顺序不重要, 因为与调度顺序无关
        - 更好的 lockQueue 使用

 Data Condition and Data Race
 
 - 安全: 多个线程同一时间读取一个共同的资源, 常见的同一个对象的某个属性(只要不涉及到写)
 - 危险: 同一时刻, 一个或多个线程读, 一个或多个写同一个对象的某个属性!!!
    - multi thread -> access shared resource(modify, write)
 
 */
print("...")
//: [Next](@next)
