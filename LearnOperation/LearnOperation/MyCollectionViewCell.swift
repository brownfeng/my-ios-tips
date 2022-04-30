//
//  MyCollectionViewCell.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import Foundation
import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "千王之王"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private let moneyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .orange
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "1000"
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
        addSubview(moneyLabel)
    }
    
    override func updateConstraints() {
        // your own code
        super.updateConstraints()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // your own code
        self.imageView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 200)
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: <#T##Double#>, height: <#T##Double#>)
    }
}
