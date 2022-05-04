//
//  ImageCell.swift
//  OperationPractice
//
//  Created by brown on 2022/5/4.
//

import UIKit

public class ImageCell: UITableViewCell {
    public var fullImage: UIImage? {
        didSet {
            fullImageView?.image = fullImage
        }
    }
    public var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .green
        
        return label
    }()
  
    // 动态加载图像
    public func transitionToImage(image: UIImage?) {
        OperationQueue.main.addOperation {
            if image == nil {
                self.fullImageView?.alpha = 0
            } else {
                // 图像存在, 渐变
                self.fullImageView?.image = image
                UIView.animate(withDuration: 0.4) {
                    self.fullImageView?.alpha = 1
                }
            }
        }
    }
  
    var fullImageView: UIImageView?
  
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
  
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
  
    func sharedInit() {
        fullImageView = UIImageView(image: fullImage)
    
        guard let fullImageView = fullImageView else { return }
        addSubview(fullImageView)
        
        addSubview(label)
    
        fullImageView.contentMode = .scaleAspectFit
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        fullImageView.clipsToBounds = true
    
        NSLayoutConstraint.activate([
            fullImageView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -30),
            fullImageView.topAnchor.constraint(equalTo: topAnchor),
            fullImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            fullImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            label.topAnchor.constraint(equalTo: fullImageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
