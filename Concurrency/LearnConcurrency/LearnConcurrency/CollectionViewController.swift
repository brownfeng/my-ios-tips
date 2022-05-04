//
//  CollectionViewController.swift
//  LearnConcurrency
//
//  Created by brown on 2022/5/4.
//

import UIKit

final class CollectionViewController: UICollectionViewController {
    private let cellSpacing: CGFloat = 5
    private let columns: CGFloat = 3

    private var cellSize: CGFloat?
    private var urls: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "normal")


        guard let plist = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
              let contents = try? Data(contentsOf: plist),
              let serial = try? PropertyListSerialization.propertyList(from: contents, format: nil),
              let serialUrls = serial as? [String]
        else {
            print("Something went horribly wrong!")
            return
        }

        urls = serialUrls.compactMap { URL(string: $0) }
    }

    private func downloadWithURLSession(at indexPath: IndexPath) {
        URLSession.shared.dataTask(with: urls[indexPath.item]) {[weak self] data, response, error in
            guard let self = self, let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                // cell 在 indexPath位置可能不显示, 这里返回的就是nil !!!!
                if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCell {
                    cell.display(image: image)
                }
            }
        }.resume()
    }
}

// MARK: - Data source

extension CollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "normal", for: indexPath) as! PhotoCell

        cell.display(image: nil)
        downloadWithURLSession(at: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cellSize == nil {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (columns * cellSpacing - 1)
            cellSize = (view.frame.size.width - emptySpace) / columns
        }

        return CGSize(width: cellSize!, height: cellSize!)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}
