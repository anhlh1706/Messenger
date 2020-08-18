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
    
    private let user: User
    private var chats = [Chat]()
    
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
        getChatList()
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
        tableView.separatorStyle = .none
        
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
        navigationItem.backBarButtonItem?.tintColor = .text
    }
    
    func getChatList() {
        DatabaseManager.shared.getAllChats(fromEmail: user.email) { [weak self] chats in
            guard let self = self else { return }
            self.chats = chats
            self.tableView.reloadData()
        }
    }
    
    func showChat(chat: Chat) {
        showLoading()
        DatabaseManager.shared.getUser(forEmail: chat.partnerEmail) { [unowned self] partner in
            self.hideLoading()
            if let partner = partner {
                let chatVC = ChatViewController(chatId: chat.id, me: self.user, partner: partner)
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }
}

//MARK: - Actions
private extension ChatListViewController {
    
    @objc
    func didTapCompose() {
        let newChatVC = NewChatViewController(currentEmail: user.email)
        newChatVC.delegate = self
        present(NavigationController(rootViewController: newChatVC), animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(cell: IconTextTableCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        cell.render(title: chat.partnerName, subTitle: chat.lastMessage, iconUrl: chat.partnerImage)
        cell.iconCornerRadius = 25
        cell.iconSize = CGSize(width: 50, height: 50)
        cell.style = .boldTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
}

// MARK: - UITableViewDelegate
extension ChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showChat(chat: chats[indexPath.row])
    }
}

// MARK: - NewChatDelegate
extension ChatListViewController: NewChatDelegate {
    func didSelectPatner(partner: User) {
        let chatVC = ChatViewController(chatId: nil, me: user, partner: partner)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
