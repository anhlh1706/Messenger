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
    
    private let database = Database.database().reference()
    
    func checkEmailIsExists(email: String, completion: @escaping ((Bool) -> Void)) {
        FirebaseAuth.Auth.auth().fetchSignInMethods(forEmail: email) { (providers, _) in
            completion(providers.isNilOrEmpty)
        }
    }
    
    func getUser(forEmail email: String, completion: @escaping (User?) -> Void) {
        usersDirectory.observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [[String: String]] {
                if let userDirectory = value.first(where: { $0["email"]?.lowercased() == email.lowercased() }) {
                    completion(User(directory: userDirectory))
                    return
                }
            }
            completion(nil)
        })
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
            if var value = snapshot.value as? [[String: String]] {
                value.append(newElement)
                self.usersDirectory.setValue(value)
            } else {
                self.usersDirectory.setValue([newElement])
            }
        })
        
    }
    
    func insertProfileImageURL(_ urlStr: String, to user: User) {
        usersDirectory.observeSingleEvent(of: .value, with: { snapshot in
            if var value = snapshot.value as? [[String: String]],
                let userIndex = value.firstIndex(where: { $0["email"] == user.email }) {
                value[userIndex]["profileImage"] = urlStr
                self.usersDirectory.setValue(value)
            }
        })
    }
    
    func insertUserIfNeeded(user: User) {
        checkEmailIsExists(email: user.email) { [weak self] available in
            if available {
                self?.insertUser(user)
            }
        }
    }
    
    func getUsers(filterEmail email: String = "", completion: @escaping ([User]) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion([])
                return
            }
            if email.isEmpty {
                completion(value.compactMap { User(directory: $0) })
            } else {
                let filteredValue = value.filter { $0["email"]?.lowercased().contains(email.lowercased()) ?? false }
                completion(filteredValue.compactMap { User(directory: $0) })
            }
        })
    }
}
