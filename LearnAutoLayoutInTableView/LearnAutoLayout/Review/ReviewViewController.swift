//
//  ReviewViewController.swift
//  LearnAutoLayout
//
//  Created by brown on 2022/4/23.
//

import UIKit

class ReviewViewController: UITableViewController {
    var dataArray: [Review] = [] {
        didSet {
            configure()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Review"
        style()
        layout()
        dataArray = Review.mockData()

    }

    // MARK: - Layout&Style
    
    func style() {
        
    }
    
    func layout() {
        tableView.register(ReviewViewCell.self, forCellReuseIdentifier: ReviewViewCell.identifier)
        tableView.estimatedRowHeight = 80
        
        let headerView = ReviewHeaderView()
        let headerModel = Review(title: "hello world!!!", date: "2022.4.23", memberSince: "从前天到现在", description: "2020年8月26日 当闭包作为一个实际参数传递给一个函数的时候,并且它会在函数返回之后调用我们就说这个闭包逃逸了,当你声明一个接受闭包作为形式参数的函数时,你可以在形式参数前写@escaping来明确...")
        headerView.viewModel = ReviewViewModel(with: headerModel)
        headerView.onSeeMoreDidTap = { [weak tableView] vm in
            vm.isExpanded.toggle()
            tableView?.setNeedsLayout()
            tableView?.layoutIfNeeded()
            tableView?.reloadData()
        }
        // 这里异步配置非常重要!!! 如果没有 异步执行,
        DispatchQueue.main.async {
            self.tableView.setAndLayoutTableHeaderView(header: headerView)
        }
    }

    // MARK: - Configure
    private func configure() {
        self.tableView.reloadData()
    }
    
}

extension ReviewViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewViewCell.identifier, for: indexPath) as! ReviewViewCell
        cell.viewModel = ReviewViewModel(with: dataArray[indexPath.row])
        
        cell.onSeeMoreDidTap = { vm in
            tableView.beginUpdates()
            vm.isExpanded.toggle()

            tableView.endUpdates()
        
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension UITableView {
    //set the tableHeaderView so that the required height can be determined, update the header's frame and set it again
    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        self.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
        header.setNeedsLayout()
        header.layoutIfNeeded()
        header.frame.size =  header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.tableHeaderView = header
    }
}
