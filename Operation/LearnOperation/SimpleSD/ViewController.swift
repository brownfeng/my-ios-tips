//
//  ViewController.swift
//  SimpleSD
//
//  Created by brown on 2022/5/3.
//

import UIKit


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
        cv.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
    
        return cv
    }()
    
    
    private var viewModel: ViewModel!

    private var dataArray: [Model] = []

    var urls: [(title: String, url: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.collectionView)
        
        self.viewModel = ViewModel(completionHandler: { [weak self] result in
            switch result {
            case .success(let modelArray):
                self?.dataArray.append(contentsOf: modelArray)
                self?.collectionView.reloadData()
            case .failure(let error):
                print("error: \(error)")
            }
        })
        
        self.viewModel.loadModelData()
        
    }
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        let model: Model = self.dataArray[indexPath.row]
    
        cell.titleLabel.text = indexPath.description
        cell.imageView.sd_setImage(urlString: model.imageUrl, indexPath: indexPath)
        return cell
    }

}
