//
//  ChatListViewController.swift
//  Messages
//
//  Created by Hoàng Anh on 14/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage
import SDWebImage

final class ChatListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    let user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: - Private functions
private extension ChatListViewController {
    
    func setupView() {
        
        view.addSubview(tableView)
        tableView.edgeAnchors == view.edgeAnchors
        
        title = Text.chats
        view.backgroundColor = .background
        tableView.register(cell: IconTextTableCell.self)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapCompose))
        rightBarButton.style = .done
        rightBarButton.tintColor = .text
        navigationItem.rightBarButtonItem = rightBarButton
        
        let profileImageView = UIImageView(image: .iconUser)
        profileImageView.cornerRadius = 15
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.sizeAnchors == CGSize(width: 30, height: 30)
        if let profileURL = user.profileURLString {
            profileImageView.sd_setImage(with: URL(string: profileURL))
        }
        let leftBarButton = UIBarButtonItem(customView: profileImageView)
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func showChat(atIndex index: Int) {
        let chatVC = ChatViewController()
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc
    func didTapCompose() {
        let newChatVC = NewChatViewController()
        present(NavigationController(rootViewController: newChatVC), animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(cell: IconTextTableCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

// MARK: - UITableViewDelegate
extension ChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showChat(atIndex: indexPath.row)
    }
}
