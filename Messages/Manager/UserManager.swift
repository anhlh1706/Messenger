//
//  UserManager.swift
//  Messages
//
//  Created by Hoàng Anh on 18/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

final class UserManager {
    
    var user: User?
    var currentEmail: String? {
        FirebaseAuth.Auth.auth().currentUser?.email
    }
    
    static let shared = UserManager()
    
    var isLogedIn: Bool {
        FirebaseAuth.Auth.auth().currentUser != nil
    }
    
    init() {
        
    }
    
    func login(user: User) {
        self.user = user
    }
    
    func logout() {
        user = nil
        do {
            try FirebaseAuth.Auth.auth().signOut()
            FBSDKLoginKit.LoginManager().logOut()
            GIDSignIn.sharedInstance()?.signOut()
            AppHelper.showLogin()
        } catch {
            AppHelper.visibleViewController?.showAlert(msg: error.localizedDescription)
        }
    }
}
