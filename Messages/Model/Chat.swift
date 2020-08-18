//
//  Chat.swift
//  Messages
//
//  Created by Hoàng Anh on 18/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

struct Chat {
    let id: String
    let lastMessage: String
    let lastUpdated: String
    let partnerEmail: String
    let partnerImage: String
    let partnerName: String
    
    init?(directory: [String: String]) {
        guard let id = directory["chatId"],
            let lastMessage = directory["lastMessage"],
            let lastUpdated = directory["lastUpdated"],
            let partnerEmail = directory["partnerEmail"],
            let partnerImage = directory["partnerImage"],
            let partnerName = directory["partnerName"] else {
                return nil
        }
        self.id = id
        self.lastUpdated = lastUpdated
        self.lastMessage = lastMessage
        self.partnerEmail = partnerEmail
        self.partnerImage = partnerImage
        self.partnerName = partnerName
    }
}

extension Chat: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
