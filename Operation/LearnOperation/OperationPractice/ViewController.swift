//
//  ViewController.swift
//  OperationPractice
//
//  Created by brown on 2022/5/4.
//

import UIKit

class ViewController: UIViewController {
    var imageNames = [String]()
    var imageProviders = [IndexPath: ImageProvider]() // 每个 cell 对应一个 ImageProvider
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ImageCell.self, forCellReuseIdentifier: "ImageCell")
        tableView.rowHeight = 250
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        // Do any additional setup after loading the view.
        imageNames = ["dark_road_small.jpg", "train_day.jpg", "train_dusk.jpg", "train_night.jpg", "dark_road_small.jpg", "train_day.jpg", "train_dusk.jpg", "train_night.jpg", "dark_road_small.jpg", "train_day.jpg", "train_dusk.jpg", "train_night.jpg", "dark_road_small.jpg", "train_day.jpg", "train_dusk.jpg", "train_night.jpg"]

        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.bounds
    }


}

//: Possibly the simplest implementation of `UITableViewDataSource`:
// tableview.dataSource
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageNames.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.label.text = "\(indexPath)"
        return cell
    }
    
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
extension ViewController: UITableViewDataSourcePrefetching {
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

