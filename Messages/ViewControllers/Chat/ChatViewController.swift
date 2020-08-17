//
//  ChatViewController.swift
//  Messages
//
//  Created by Lê Hoàng Anh on 15/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import MessageKit

struct Message: MessageType {
    let sender: SenderType
    let messageId: String
    let sentDate: Date
    let kind: MessageKind
}

struct Sender: SenderType {
    let senderId: String
    let displayName: String
    let photoURL: String
}

final class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    private let selfSender = Sender(senderId: "1", displayName: "Hoang Anh", photoURL: "")
    
    private let me: User
    private let parner: User
    
    init(me: User, parner: User) {
        self.me = me
        self.parner = parner
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world!")))
        messages.append(Message(sender: selfSender, messageId: "2", sentDate: Date(), kind: .text("Hi, world!")))
        
        title = selfSender.displayName
        view.backgroundColor = .background
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}

extension ChatViewController: MessagesDisplayDelegate {
    
}
