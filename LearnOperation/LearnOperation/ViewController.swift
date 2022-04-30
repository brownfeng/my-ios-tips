//
//  ViewController.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import UIKit

private let identifier = "cell"

private let kScreenWidth = UIScreen.main.bounds.width
private let kScreenHeight = UIScreen.main.bounds.height

class ViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: (kScreenWidth - 15) / 2.0, height: 260)
        let cv = UICollectionView(frame: CGRect(x: 5, y: 0, width: kScreenWidth - 10, height: kScreenHeight), collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.scrollsToTop = false
        cv.isPagingEnabled = true
        cv.bounces = true
        cv.dataSource = self
        cv.delegate = self
        
        cv.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
    
        return cv
    }()
    
    private var viewModel: MyViewModel?
    
    private var dataArray: [MyModel] = []
    private var cacheImageMap: [String: UIImage] = [:]
    
    private let operationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.collectionView)
        
        self.viewModel = MyViewModel(success: { [weak self] data in
            self?.dataArray.append(contentsOf: data)
            self?.collectionView.reloadData()
        }, failure: { _ in
            
        })
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        let model: MyModel = self.dataArray[indexPath.row]
        let imageURL = URL(string: model.imageUrl)!
        cell.titleLabel.text = model.title
        
        // 内存缓存 -- 内存会清理
        if let image = cacheImageMap[model.imageUrl] {
            print("使用内存缓存: \(model.title)")
            cell.imageView.image = image
            return cell
        }
        
        // 沙盒缓存
        let cacheImageURL = model.imageUrl.getDownloadURL()
        let diskImage = UIImage(contentsOfFile: cacheImageURL.path)
        if let image = diskImage {
            print("使用磁盘缓存: \(model.title)")
            cell.imageView.image = image
            return cell
        }
        
        print("开始后台下载: \(model.title)")
        // 下载 - 事务
        // 开辟子线程 - 下载
        let bo = BlockOperation {
            print("去下载: \(model.title)")
            // 下载
            let imageData = try! Data(contentsOf: imageURL)
            // 写入diskCache缓存
            try! imageData.write(to: cacheImageURL)
            
            let image = UIImage(data: imageData)
            
            // 更新UI
            OperationQueue.main.addOperation {
                // 缓存内存
                self.cacheImageMap[model.imageUrl] = image
                // 缓存磁盘
                
                
                // 更新UI
                cell.imageView.image = image
            }
        }
            
        self.operationQueue.addOperation(bo)
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.cacheImageMap.removeAll()
    }
}
