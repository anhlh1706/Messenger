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
        let path = fullPath(forFileName: user.profilePictureFileName)
        storage.child(path).putData(data, metadata: nil) { (data, error) in
            self.storage.child(path).downloadURL { (url, error) in
                if let urlStr = url?.absoluteString {
                    DatabaseManager.shared.insertProfileImageURL(urlStr, to: user)
                }
            }
        }
    }
    
    /// Get url to download picture for the path in firebase directory
    func downloadURL(forFileName fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let path = fullPath(forFileName: fileName)
        
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
    
    private func fullPath(forFileName fileName: String) -> String {
        "images/\(fileName)"
    }
}
