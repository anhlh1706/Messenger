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

final class ChatListViewController: ViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let user: User
    private var chats = [Chat]() {
        didSet {
            if oldValue.count > chats.count {
                tableView.reloadData()
            } else {
                tableView.reload(oldValue: oldValue, newValue: chats)
            }
        }
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenForChatList()
    }
    
    override func setupView() {
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
}

// MARK: - Private functions
private extension ChatListViewController {
    
    func listenForChatList() {
        DatabaseManager.shared.getAllChats(fromEmail: user.email) { [weak self] chats in
            guard let self = self else { return }
            self.chats = chats
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
    
    func deleteChat(atIndex index: Int) {
        DatabaseManager.shared.deleteChat(fromUser: user, chatId: chats[index].id) { [weak self] success in
            if !success {
                self?.showAlert(msg: "Some error occured!")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(cell: IconTextTableCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        
        let dateCurrentFormat = DateFormatter.fullStyle().date(from: chat.lastUpdated) ?? Date()
        let formatter: DateFormatter
        if dateCurrentFormat.yesterday == Date().yesterday {
            formatter = DateFormatter.timeOnly()
        } else {
            formatter = DateFormatter.textStyle()
        }
        
        let lastUpdate = formatter.string(from: dateCurrentFormat)
        let sideInfo = chat.lastMessage + "  .  " + lastUpdate
        cell.render(title: chat.partnerName, subTitle: sideInfo, iconUrl: chat.partnerImage)
        cell.iconCornerRadius = 25
        cell.iconSize = CGSize(width: 50, height: 50)
        cell.style = .mediumTitle
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
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive, handler: {_ in
                self.deleteChat(atIndex: indexPath.row)
            })
            
            return UIMenu(title: "", children: [deleteAction])
        }
    }
}

// MARK: - NewChatDelegate
extension ChatListViewController: NewChatDelegate {
    func didSelectPatner(partner: User) {
        if let index = chats.firstIndex(where: { $0.partnerEmail == partner.email }) {
            showChat(chat: chats[index])
        } else {
            let chatVC = ChatViewController(chatId: nil, me: user, partner: partner)
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
}
