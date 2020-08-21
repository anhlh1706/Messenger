//
//  StorageManager.swift
//  Messages
//
//  Created by Lê Hoàng Anh on 15/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    func uploadProfilePicture(with data: Data, user: User) {
        let path = profileImagePath(fileName: user.profilePictureFileName)
        storage.child(path).putData(data, metadata: nil) { (data, error) in
            self.storage.child(path).downloadURL { (url, error) in
                if let urlStr = url?.absoluteString {
                    DatabaseManager.shared.insertProfileImageURL(urlStr, to: user)
                }
            }
        }
    }
    
    func uploadMessagePhoto(with data: Data, messageId: String, completion: @escaping (Result<String, Error>) -> Void) {
        storage.child(photoMessagePath(msgId: messageId)).putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }

            self.storage.child(self.photoMessagePath(msgId: messageId)).downloadURL(completion: { url, error in
                guard let url = url else {
                    if let error = error {
                        completion(.failure(error))
                    }
                    return
                }
                completion(.success(url.absoluteString))
            })
        })
    }
    
    func uploadMessageVideo(withFileURL fileURL: URL, messageId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let videoData = try? Data(contentsOf: fileURL) else {
            return
        }
        storage.child(videoMessagePath(msgId: messageId)).putData(videoData, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            self.storage.child(self.videoMessagePath(msgId: messageId)).downloadURL { (url, error) in
                guard let url = url else {
                    if let error = error {
                        completion(.failure(error))
                    }
                    return
                }
                completion(.success(url.absoluteString))
            }
        }
    }
    
    /// Get url to download picture for the path in firebase directory
    func downloadURL(forFileName fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let path = profileImagePath(fileName: fileName)
        
        let reference = storage.child(path)
        reference.downloadURL { (url, error) in
            guard let url = url else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            completion(.success(url))
        }
    }
    
    private func profileImagePath(fileName: String) -> String {
        "images/\(fileName)"
    }
    
    private func photoMessagePath(msgId: String) -> String {
        "message_images/\(msgId).png"
    }
    
    private func videoMessagePath(msgId: String) -> String {
        "message_videos/\(msgId).mov"
    }
}
