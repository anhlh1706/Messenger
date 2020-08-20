//
//  Message.swift
//  Messages
//
//  Created by Hoàng Anh on 18/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation

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
            let type = directory["type"],
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
        
        if type == "photo" {
            guard let imageUrl = URL(string: content) else {
                return nil
            }
            
            let media = Media(url: imageUrl,
                              image: nil,
                              placeholderImage: .iconGallery,
                              size: CGSize(width: 300, height: 300))
            kind = .photo(media)
        }
        else if type == "video" {
            guard let videoUrl = URL(string: content),
                let placeHolder = UIImage(systemName: "play.circle.fill") else {
                    return nil
            }
            
            let media = Media(url: videoUrl,
                              image: nil,
                              placeholderImage: placeHolder,
                              size: CGSize(width: 300, height: 300))
            kind = .video(media)
        }
        else if type == "location" {
            let locationComponents = content.components(separatedBy: ",")
            guard let longitude = Double(locationComponents[0]),
                let latitude = Double(locationComponents[1]) else {
                return nil
            }
            print("Rendering location; long=\(longitude) | lat=\(latitude)")
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                    size: CGSize(width: 300, height: 300))
            kind = .location(location)
        }
        else {
            kind = .text(content)
        }
    }
}

extension MessageKind {
    var description: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "custom"
        }
    }
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
}
