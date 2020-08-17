//
//  User.swift
//  Base
//
//  Created by Lê Hoàng Anh on 04/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

struct User: Decodable {
    let email: String
    let firstName: String
    let lastName: String
    var profileURLString: String?
    
    var emailDirectory: String {
        email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
    }
    
    var profilePictureFileName: String {
        "\(emailDirectory)_profile_picture.png"
    }
    
    init(email: String, firstName: String, lastName: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
    
    init?(directory: [String: String]) {
        guard let email = directory["email"],
            let firstName = directory["firstName"],
            let lastName = directory["lastName"] else {
            return nil
        }
        var user = User(email: email, firstName: firstName, lastName: lastName)
        user.profileURLString = directory["profileImage"]
        self = user
    }
}

extension User: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.email == rhs.email
    }
}
