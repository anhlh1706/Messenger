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
    
    private let me: User
    private let partner: User
    
    private let meSender: Sender
    private let partnerSender: Sender
    
    init(me: User, partner: User) {
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
        
        messages.append(Message(sender: meSender, messageId: "1", sentDate: Date(), kind: .text("Hello world!")))
        messages.append(Message(sender: partnerSender, messageId: "2", sentDate: Date(), kind: .text("Hi, world!")))
        
        title = partnerSender.displayName
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
        meSender
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
