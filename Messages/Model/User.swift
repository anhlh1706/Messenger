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
    
    var emailDirectory: String {
        email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
    }
    
    var profilePictureFileName: String {
        "\(emailDirectory)_profile_picture.png"
    }
}

