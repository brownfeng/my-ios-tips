import PlaygroundSupport
//: [⬅ Chaining Operations](@previous)
/*:
 ## [NS]Operations in Practice
 
 You've seen how powerful `Operation` is, but not really seen it fix a real-world problem.
 
 This playground page demonstrates how you can use `Operation` to load and filter images for display in a table view, whilst maintaining the smooth scroll effect you expect from table views.
 
 This is a common problem, and comes from the fact that if you attempt expensive operations synchronously, you'll block the main queue (thread). Since this is used for rendering the UI, you cause your app to become unresponsive - temporarily freezing.
 
 The solution is to move data loading off into the background, which can be achieved easily with `Operation`.
 
 */
import UIKit

let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 720))
tableView.register(ImageCell.self, forCellReuseIdentifier: "ImageCell")
PlaygroundPage.current.liveView = tableView
tableView.rowHeight = 250

//: `ImageProvider` is a class that is responsible for loading and processing an image. It creates the relevant operations, chains them together, pops them on a queue and then ensures that the output is passed back appropriately
// ImageProvider 负责 loading 和 processing image => 输出 processedImage
// 创建相关的 operations, chains them,
class ImageProvider {
    let queue = OperationQueue()
    var loadedImage: UIImage? // 最后加载的图像
    var completion: ((UIImage?) -> ())?
  
    // 输入是一个 imageNamed
    init(imageName: String) {
        // 1. 加载图像
        let loadOp = ImageLoadOperation()
        // 2. 图像处理
        let tiltShiftOp = TiltShiftOperation()
        // 3. 图像输出 最终结果!!! onResult
        let outputOp = ImageOutputOperation()
    
        loadOp.inputName = imageName
        // 最终的输出
        outputOp.completion = { [unowned self] image in
            self.loadedImage = image
            self.completion?(image) // 结果回调
        }
  
        // 设置依赖 => 创建的一个依赖操作符
        loadOp |> tiltShiftOp |> outputOp
    
        queue.addOperations([loadOp, tiltShiftOp, outputOp], waitUntilFinished: false)
    }
  
    // 如果整个服务取消 -> ImageDataProvider
    func cancel() {
        queue.cancelAllOperations()
    }
}

//: `DataSource` is a class that represents the table's datasource and delegate
// tableView 的数据源
class DataSource: NSObject {
    var imageNames = [String]()
    var imageProviders = [IndexPath: ImageProvider]() // 每个 cell 对应一个 ImageProvider
}

//: Possibly the simplest implementation of `UITableViewDataSource`:
// tableview.dataSource
extension DataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageNames.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
    }
}

// 在 cell will 出现的时候!!!
// 这里其实有些线程安全的问题
extension DataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ImageCell {
            // 如果 indexPath 已经拥有 provider
            // 1. 预加载的
            // 2. 非预加载的
            if let provider = imageProviders[indexPath] {
                if let image = provider.loadedImage { // imageProvider 可以缓存
                    cell.transitionToImage(image: image)
                    // mainQueue 移除 imageProviders -> 工作已经完全做完
                    imageProviders.removeValue(forKey: indexPath)
                } else {
                    // prefetch 的服务
                    // imageProvider 还没有执行完成 -> 可能绑定了新的 completion
                    // 但是 cell 可能不是  indexPath 那个cell!!!
                    // 可能是预加载的服务
                    provider.completion = { [unowned self] image in
                        // cell 绑定问题
                        cell.transitionToImage(image: image)
                        // 在 provider 中处理 -> 线程安全问题?
                        // 应该在主线程操作
                        self.imageProviders.removeValue(forKey: indexPath)
                    }
                }
            } else {
                // 根据 indexPath 绑定一个 imageProvider
                let provider = ImageProvider(imageName: imageNames[indexPath.row])
                // 同时设置 completionHandler
                provider.completion = { [unowned self] image in
                    cell.transitionToImage(image: image)
                    // 在 provider 中处理 -> 线程安全问题?
                    // 应该在主线程操作
                    self.imageProviders.removeValue(forKey: indexPath)
                }
                
                // mainThread! 绑定 imageProviders 和 indexPath 绑定
                imageProviders[indexPath] = provider
            }
        }
    }
  
    // 将 cell 设置回去了
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 展示结束 -> 取消服务
        if let cell = cell as? ImageCell {
            cell.transitionToImage(image: .none)
        }
        if let provider = imageProviders[indexPath] {
            provider.cancel()
            imageProviders.removeValue(forKey: indexPath)
        }
    }
}

// 拥有预加载服务
extension DataSource: UITableViewDataSourcePrefetching {
    // 预加载服务
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // 预加载的 indexPath
        for indexPath in indexPaths {
            // 创建服务!!! 但是没有设置 completion
            let provider = ImageProvider(imageName: imageNames[indexPath.row])
            imageProviders[indexPath] = provider
        }
    }
  
    // 取消服务
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let provider = imageProviders[indexPath] {
                provider.cancel()
                imageProviders.removeValue(forKey: indexPath)
            }
        }
    }
}

//: Create a datasource and provide a list of images to display
let ds = DataSource()
ds.imageNames = ["dark_road_small.jpg", "train_day.jpg", "train_dusk.jpg", "train_night.jpg", "dark_road_small.jpg", "train_day.jpg", "train_dusk.jpg", "train_night.jpg", "dark_road_small.jpg", "train_day.jpg", "train_dusk.jpg", "train_night.jpg", "dark_road_small.jpg", "train_day.jpg", "train_dusk.jpg", "train_night.jpg"]

tableView.dataSource = ds
tableView.delegate = ds
tableView.prefetchDataSource = ds

/*:
 - note:
 This implementation for a table view is not complete, but instead meant to demonstrate how you can use `Operation` to improve the scrolling performance.
 
 [➡ Grand Central Dispatch](@next)
 */
