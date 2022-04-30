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
        cv.bounds = true
        cv.dataSource = self
        cv.delegate = self
        
        cv.register(<#T##cellClass: AnyClass?##AnyClass?#>, forCellWithReuseIdentifier: <#T##String#>)
    
        return cv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

