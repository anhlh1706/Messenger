//
//  ChatViewController.swift
//  Messages
//
//  Created by Lê Hoàng Anh on 15/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Sender: SenderType {
    let senderId: String
    let displayName: String
    let photoURL: String
}

final class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    
    private let me: User
    private let partner: User
    
    private let meSender: Sender
    private let partnerSender: Sender
    
    private var chatId: String?
    
    init(chatId: String?, me: User, partner: User) {
        self.chatId = chatId
        self.me = me
        self.partner = partner
        meSender = Sender(senderId: me.email, displayName: me.lastName, photoURL: me.profileURLString ?? "")
        partnerSender = Sender(senderId: partner.email, displayName: partner.lastName, photoURL: partner.profileURLString ?? "")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getAllMessages()
    }
}

// MARK: - Private functions
private extension ChatViewController {
    
    func setupView() {
        title = partnerSender.displayName
        view.backgroundColor = .background
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.becomeFirstResponder()
        scrollsToBottomOnKeyboardBeginsEditing = true
    }
    
    func createMessageId() -> String {
        "\(me.emailDirectory)_\(partner.email)_\(DateFormatter.dateTime().string(from: Date()))"
    }
    
    func getAllMessages() {
        if let chatId = chatId {
            DatabaseManager.shared.getAllMessages(ofChatId: chatId) { messages in
                self.messages = messages
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        meSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == meSender.senderId {
            avatarView.sd_setImage(with: URL(string: meSender.photoURL))
        } else {
            avatarView.sd_setImage(with: URL(string: partnerSender.photoURL))
        }
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        
        let message = Message(sender: meSender, messageId: createMessageId(), sentDate: Date(), kind: .text(text))
        DatabaseManager.shared.sendMessage(fromUser: me, toUser: partner, toChatId: chatId, message: message) { [weak self] newChatId in
            guard let self = self else { return }
            if let newChatId = newChatId {
                self.chatId = newChatId
            }
            self.messages.append(message)
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
            inputBar.inputTextView.text = ""
        }
    }
}
