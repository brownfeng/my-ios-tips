//
//  ReviewViewCell.swift
//  LearnAutoLayout
//
//  Created by brown on 2022/4/23.
//

import UIKit

class ReviewViewCell: UITableViewCell {
    static let identifier: String = "ReviewViewCell"
    
    var viewModel: ReviewViewModel? {
        didSet {
            configure()
        }
    }
    
    var onSeeMoreDidTap: (( _ viewModel: inout ReviewViewModel) -> Void)?

    private let bgView: UIView = {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false

        bgView.backgroundColor = .systemPink
        return bgView
    }()
    
    private let mainStackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 10
        st.distribution = .fill
        st.alignment = .fill
        return st
    }()
    
    private let bottomStackView: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.spacing = 10
        st.distribution = .fill
        st.alignment = .fill
        return st
    }()
    
    private var userNameLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.numberOfLines = 0
        lb.textColor = .black
        lb.font = UIFont.systemFont(ofSize: 16)
        return lb
    }()
    
    private let memberSinceLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.numberOfLines = 0
        lb.textColor = .lightText
        lb.font = UIFont.systemFont(ofSize: 14)
        return lb
    }()
    
    private let descLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.numberOfLines = 0
        lb.textColor = .black
        lb.font = UIFont.systemFont(ofSize: 16)
        return lb
    }()
    
    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.numberOfLines = 0
        lb.textColor = .lightText
        lb.font = UIFont.systemFont(ofSize: 14)
        return lb
    }()
    
    private lazy var seeMoreButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.addTarget(self, action: #selector(handleSeeMoreButtonTapped(_:)), for: .touchUpInside)
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    private var isSeeLess = true
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        contentView.addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10)
        
        bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

//        bgView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -40).isActive = true
        bgView.addSubview(mainStackView)
        
        mainStackView.fillSuperview()
        
        mainStackView.addArrangedSubview(userNameLabel)
        userNameLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        mainStackView.addArrangedSubview(memberSinceLabel)
//        memberSinceLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        mainStackView.addArrangedSubview(descLabel)
        
        mainStackView.addArrangedSubview(bottomStackView)
        bottomStackView.addArrangedSubview({
            let spacer = UIView()
            spacer.widthAnchor.constraint(equalToConstant: 5).isActive = true
            return spacer
        }())
        bottomStackView.addArrangedSubview(dateLabel)
        bottomStackView.addArrangedSubview({
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
            return spacer
        }())

        bottomStackView.addArrangedSubview(seeMoreButton)
        bottomStackView.addArrangedSubview({
            let spacer = UIView()
            spacer.widthAnchor.constraint(equalToConstant: 5).isActive = true
            return spacer
        }())
        bottomStackView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        

    }
    
    func configure() {
        guard let viewModel = viewModel else {
            return
        }
        
        self.userNameLabel.text = viewModel.title
        self.memberSinceLabel.text = viewModel.memberSince
        self.descLabel.text = viewModel.description
        self.dateLabel.text = viewModel.date
        
        self.isSeeLess = viewModel.isExpanded
        self.descLabel.numberOfLines = self.isSeeLess ? 0 : 3
        self.seeMoreButton.setTitle(self.isSeeLess ? "See less" : "See more", for: .normal)
        
    }

    @objc
    private func handleSeeMoreButtonTapped(_ sender: UIButton) {
        self.isSeeLess.toggle()
        self.descLabel.numberOfLines = self.isSeeLess ? 0 : 3
        self.descLabel.layoutIfNeeded()
        self.seeMoreButton.setTitle(self.isSeeLess ? "See less" : "See more", for: .normal)

        if var viewModel = viewModel {
            self.onSeeMoreDidTap?(&viewModel)
        }
    }

}
