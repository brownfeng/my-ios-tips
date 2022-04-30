//
//  MyCollectionViewCell.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import Foundation
import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "MyCollectionViewCell"
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "千王之王"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - layout
    func setupUI() {
        backgroundColor = .white
        addSubview(imageView)
        addSubview(titleLabel)
    }
    
    override func updateConstraints() {
        // your own code
        super.updateConstraints()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // your own code
        self.imageView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 200)
        self.titleLabel.frame = CGRect(x: 0, y: imageView.frame.maxY, width: contentView.bounds.width, height: 30)
    }
}
