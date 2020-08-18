//
//  Message.swift
//  Messages
//
//  Created by Hoàng Anh on 18/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType {
    let sender: SenderType
    let messageId: String
    let sentDate: Date
    let kind: MessageKind
    
    init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
    
    init?(directory: [String: String]) {
        guard let messageId = directory["messageId"],
            let senderEmail = directory["senderEmail"],
            let content = directory["content"],
            // let type = directory["type"],
            let name = directory["name"],
            let sentDateStr = directory["sentDate"],
            let photoUrl = directory["photoUrl"] else {
                return nil
        }
        let sender = Sender(senderId: senderEmail, displayName: name, photoURL: photoUrl)
        let sentDate = DateFormatter.fullStyle().date(from: sentDateStr) ?? Date()
        
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = .text(content)
    }
}
