//
//  ChatViewController.swift
//  LearnAutoLayout
//
//  Created by brown on 2022/4/23.
//

import UIKit

class ChatViewController: UITableViewController {
    var cache: [Int: CGFloat] = [:]
    var dataArray: [Chat] = [] {
        didSet {
            configure()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat"

        style()
        layout()
        
        dataArray = Chat.mockData()
    }

    // MARK: - Layout&Style
    
    func style() {
        
    }
    
    func layout() {
        tableView.register(ChatViewCell.self, forCellReuseIdentifier: ChatViewCell.identifier)
        tableView.estimatedRowHeight = 80
    }

    // MARK: - Configure
    private func configure() {
        self.tableView.reloadData()
    }
    
}

extension ChatViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatViewCell.identifier, for: indexPath) as! ChatViewCell
        cell.viewModel = ChatViewModel(with: dataArray[indexPath.row])
        
        cell.onSeeMoreDidTap = {[weak self] vm in
            self?.cache.removeValue(forKey: indexPath.row)

            tableView.beginUpdates()
            vm.isExpanded.toggle()
            tableView.endUpdates()
        }
        
        let size = cell.systemLayoutSizeFitting(CGSize(width: self.view.bounds.size.width, height: 0), withHorizontalFittingPriority: UILayoutPriority.fittingSizeLevel, verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
        print("caclulate indexpath height: \(indexPath) size: \(size)")
        self.cache[indexPath.row] = size.height
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = cache[indexPath.row] {
            print("cache hit - height: \(height)")
            return height
        } else {
            print("nocache hit")
            return UITableView.automaticDimension
        }
    }
}

