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
        cv.bounces = true
        cv.dataSource = self
        cv.delegate = self
        
        cv.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
    
        return cv
    }()
    
    private var viewModel: MyViewModel?
    
    private var dataArray: [MyModel] = []
    
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
        cell.titleLabel.text = model.title
        let url = URL(string: model.imageUrl)!
        cell.imageView.bf.setImage(with: url)
        return cell
    }
}
