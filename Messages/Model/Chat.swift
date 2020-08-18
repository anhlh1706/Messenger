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
    let partner: String
    let partnerImage: String
    
    init?(directory: [String: String]) {
        guard let id = directory["chatId"],
            let lastMessage = directory["lastMessage"],
            let lastUpdated = directory["lastUpdated"],
            let partner = directory["partner"],
            let partnerImage = directory["partnerImage"] else {
                return nil
        }
        self.id = id
        self.lastUpdated = lastUpdated
        self.lastMessage = lastMessage
        self.partner = partner
        self.partnerImage = partnerImage
    }
}
