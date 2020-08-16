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
    
    private let database = Database.database().reference()
    
    func checkEmailIsExists(email: String, completion: @escaping ((Bool) -> Void)) {
        FirebaseAuth.Auth.auth().fetchSignInMethods(forEmail: email) { (providers, _) in
            completion(providers.isNilOrEmpty)
        }
    }
    
    func insertUser(_ user: User, completion: @escaping (Bool) -> Void) {
        database.child(user.emailDirectory).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ]) { (error, _) in
            completion(error == nil)
        }
    }
    
    func insertUserIfNeeded(user: User, completion: @escaping (Bool) -> Void) {
        checkEmailIsExists(email: user.email) { [weak self] available in
            if available {
                self?.insertUser(user, completion: { success in
                    completion(success)
                })
            }
        }
    }
}