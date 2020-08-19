//
//  Database.swift
//  Messages
//
//  Created by Hoàng Anh on 14/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private lazy var usersDirectory = database.child("users")
    private lazy var chatsDirectory = database.child("chats")
    private lazy var messagesDirectory = database.child("messages")
    
    private let database = Database.database().reference()
    
    func checkEmailIsExists(email: String, completion: @escaping ((Bool) -> Void)) {
        FirebaseAuth.Auth.auth().fetchSignInMethods(forEmail: email) { (providers, _) in
            completion(providers.isNilOrEmpty)
        }
    }
    
    func insertProfileImageURL(_ urlStr: String, to user: User) {
        usersDirectory.child(user.emailDirectory).observeSingleEvent(of: .value, with: { snapshot in
            if var value = snapshot.value as? [String: String] {
                value["profileImage"] = urlStr
                self.usersDirectory.child(user.emailDirectory).setValue(value)
            }
        })
    }
    
    func directory(forEmail email: String) -> String {
        email.lowercased().replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "-")
    }
}

// MARK: - Users
extension DatabaseManager {
    
    func insertUserIfNeeded(user: User) {
        checkEmailIsExists(email: user.email) { [weak self] available in
            if available {
                self?.insertUser(user)
            }
        }
    }
    
    func insertUser(_ user: User) {
        var newElement = [
            "email": user.email,
            "firstName": user.firstName,
            "lastName": user.lastName
        ]
        if let url = user.profileURLString {
            newElement["profileImage"] = url
        }
        usersDirectory.observeSingleEvent(of: .value, with: { snapshot in
            if var value = snapshot.value as? [String: [String: Any]] {
                value[user.emailDirectory] = newElement
                self.usersDirectory.setValue(value)
            } else {
                self.usersDirectory.setValue([user.emailDirectory: newElement])
            }
        })
    }
    
    func getUser(forEmail email: String, completion: @escaping (User?) -> Void) {
        usersDirectory.child(directory(forEmail: email)).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String: String] {
                completion(User(directory: value))
            } else {
                completion(nil)
            }
        })
    }
    
    func getAllUsers(completion: @escaping ([User]) -> Void) {
        usersDirectory.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: [String: String]] {
                completion(value.compactMap { User(directory: $0.value) })
                return
            }
            completion([])
        }
    }
}

// MARK: - Messages
extension DatabaseManager {
    
    /*
     chats: {
        emailDirectory: {
            [
                chatId: String,
                lastMessage: String,
                lastUpdated: String,
            ]
        },
        someMailDirectory: {
            [
                chatId: String,
                lastMessage: String,
                lastUpdated: String,
            ]
        }
     },
     messages: {
        chatId: {
            [
                messageId: String,
                senderEmail: String,
                content: String,
                type: String,
                sentDate: String,
            ]
        }
     }
     */
    
    func sendMessage(fromUser: User, toUser: User, toChatId chatId: String?, message: Message, completion: @escaping (String?) -> Void) {
        let senderEmail = fromUser.email
        let receiverEmail = toUser.email
        
        var content = ""
        switch message.kind {
        case .text(let text):
            content = text
        default:
            break
        }
        
        let dateString = DateFormatter.fullStyle().string(from: Date())
        let messageData = [
            "messageId": message.messageId,
            "senderEmail": fromUser.email,
            "content": content,
            "name": message.sender.displayName,
            "photoUrl": fromUser.profileURLString ?? "",
            "type": message.kind.description,
            "sentDate": dateString
        ]
        
        if let chatId = chatId {
            let newChatData = [
                "lastMessage": content,
                "lastUpdated": dateString
            ]
            addMessage(toChatId: chatId, messageData: messageData)
            updateChats(ofUserEmail: senderEmail, chatId: chatId, data: newChatData)
            updateChats(ofUserEmail: receiverEmail, chatId: chatId, data: newChatData)
            
            completion(nil)
        } else {
            let newChatId = directory(forEmail: senderEmail) + "-" + directory(forEmail: receiverEmail)
            let newChat = [
                "chatId": newChatId,
                "lastMessage": content,
                "lastUpdated": dateString,
            ]
            var newSelfChat = newChat
            newSelfChat["partnerEmail"] = receiverEmail
            newSelfChat["partnerImage"] = toUser.profileURLString ?? ""
            newSelfChat["partnerName"] = toUser.fullName
            
            var newPartnerChat  = newChat
            newPartnerChat["partnerEmail"] = senderEmail
            newPartnerChat["partnerImage"] = fromUser.profileURLString ?? ""
            newPartnerChat["partnerName"] = fromUser.fullName
            
            addChat(toEmail: senderEmail, chatValue: newSelfChat)
            addChat(toEmail: receiverEmail, chatValue: newPartnerChat)
            
            addMessage(toChatId: newChatId, messageData: messageData)
            completion(newChatId)
        }
    }
    
    func getAllChats(fromEmail email: String, completion: @escaping ([Chat]) -> Void) {
        chatsDirectory.child(directory(forEmail: email)).observe(.value) { snapshot in
            if let value = snapshot.value as? [[String: String]] {
                completion(value.compactMap { Chat(directory: $0) }.sorted(by: { (left, right) -> Bool in
                    left.lastUpdated > right.lastUpdated
                }))
            } else {
                completion([])
            }
        }
    }
    
    func listenToNewMessage(ofEmail email: String, completion: @escaping ([Chat]) -> Void) {
        chatsDirectory.child(directory(forEmail: email)).observe(.childChanged) { snapshot in
            if let value = snapshot.value as? [[String: String]] {
                completion(value.compactMap { Chat(directory: $0) }.sorted(by: { (left, right) -> Bool in
                    left.lastUpdated < right.lastUpdated
                }))
            } else {
                completion([])
            }
        }
    }
    
    func getAllMessages(ofChatId chatId: String, completion: @escaping ([Message]) -> Void) {
        messagesDirectory.child(chatId).observe(.value) { snapshot in
            if let value = snapshot.value as? [[String: String]] {
                completion(value.compactMap { Message(directory: $0) })
            } else {
                completion([])
            }
        }
    }
    
    private func addChat(toEmail email: String, chatValue: [String: String]) {
        chatsDirectory.child(directory(forEmail: email)).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            if var value = snapshot.value as? [[String: String]] {
                value.append(chatValue)
                self.chatsDirectory.child(self.directory(forEmail: email)).setValue(value)
            } else {
                self.chatsDirectory.child(self.directory(forEmail: email)).setValue([chatValue])
            }
        }
    }
    
    private func addMessage(toChatId chatId: String, messageData: [String: String]) {
        messagesDirectory.child(chatId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            if var value = snapshot.value as? [[String: String]] {
                value.append(messageData)
                self.messagesDirectory.child(chatId).setValue(value)
            } else {
                self.messagesDirectory.child(chatId).setValue([messageData])
            }
        }
    }
    
    private func updateChats(ofUserEmail email: String, chatId: String, data: [String: String]) {
        chatsDirectory.child(directory(forEmail: email)).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            if var value = snapshot.value as? [[String: String]], let index = value.firstIndex(where: { $0["chatId"] == chatId }) {
                value[index]["lastMessage"] = data["lastMessage"]
                value[index]["lastUpdated"] = data["lastUpdated"]
                self.chatsDirectory.child(self.directory(forEmail: email)).setValue(value)
            }
        }
    }
}
