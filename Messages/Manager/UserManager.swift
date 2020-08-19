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
    var userEmail: String? {
        FirebaseAuth.Auth.auth().currentUser?.email
    }
    
    static let shared = UserManager()
    
    var isLogedIn: Bool {
        FirebaseAuth.Auth.auth().currentUser != nil
    }
    
    init() {
        
    }
    
    // MARK: - Email login
    func loginEmail(_ email: String, password: String, completion: @escaping (User?, Error?) -> Void) {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
                
            guard let email = result?.user.email, error == nil else {
                completion(nil, error)
                return
            }
            DatabaseManager.shared.getUser(forEmail: email) { user in
                self.user = user
                completion(user, nil)
            }
        }
    }
    
    // MARK: - Facebook login
    func loginFacebook(in vc: UIViewController, completion: @escaping (User?, Error?) -> Void) {
        let loginManager = LoginManager()
        
        if AccessToken.current != nil {
            loginManager.logOut()
        }
        loginManager.logIn(permissions: ["email", "public_profile"], from: vc) { [weak self] (result, error) in
            guard let self = self else { return }
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            /// Check if user cancels login session
            guard let result = result,
                  let token = result.token?.tokenString,
                  !result.isCancelled else {
                completion(nil, nil)
                return
            }
            self.getFacebookUserInfo(withToken: token) { (user, error) in
                completion(user, error)
            }
        }
    }
    
    /// Get user info from facebook then upload to firebase
    private func getFacebookUserInfo(withToken token: String, completion: @escaping (User?, Error?) -> Void) {
        let fbRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields" : "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        fbRequest.start { [weak self] (_, result, error) in
            guard let self = self else { return }
            guard let result = result as? [String: Any], error == nil else {
                completion(nil, error)
                return
            }
            
            /// Get user profile from facebook
            guard let firstName = result["first_name"] as? String,
                let lastName = result["last_name"] as? String,
                let email = result["email"] as? String else {
                completion(nil, error)
                    return
            }
            var user = User(email: email, firstName: firstName, lastName: lastName)
            
            /// Get profile image url from facebook
            if let picture = result["picture"] as? [String: Any?],
                let pictureData = picture["data"] as? [String: Any?],
                let pictureUrlStr = pictureData["url"] as? String {
                user.profileURLString = pictureUrlStr
                self.uploadProfilePicture(ofUser: user)
            }
            DatabaseManager.shared.insertUserIfNeeded(user: user)
            
            /// Sign in to firebase
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential) { (result, error) in
                guard result != nil, error == nil else {
                    completion(nil, error)
                    return
                }
                self.user = user
                completion(user, nil)
            }
        }
    }
    
    // MARK: - Google login
    func loginGoogle(signIn: GIDSignIn!, googleUser: GIDGoogleUser, completion: @escaping (User?, Error?) -> Void) {
        guard let email = googleUser.profile.email,
              let firstName = googleUser.profile.givenName,
              let lastName = googleUser.profile.familyName else {
            completion(nil, nil)
            return
        }
        
        var userInfo = User(email: email, firstName: firstName, lastName: lastName)
        DatabaseManager.shared.insertUserIfNeeded(user: userInfo)
        
        if googleUser.profile.hasImage {
            if let url = googleUser.profile.imageURL(withDimension: 300) {
                userInfo.profileURLString = url.absoluteString
                uploadProfilePicture(ofUser: userInfo)
            }
        }
        
        guard let authentication = googleUser.authentication else {
            completion(nil, nil)
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential) { (result, error) in
            guard result != nil, error == nil else {
                completion(nil, error)
                return
            }
            self.user = userInfo
            completion(userInfo, nil)
        }
    }
    
    /// Download profile image from facebook and upload to firebase
    func uploadProfilePicture(ofUser user: User) {
        guard let urlStr = user.profileURLString else { return }
        guard let url = URL(string: urlStr) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let imageData = data {
                StorageManager.shared.uploadProfilePicture(with: imageData, user: user)
            }
        }.resume()
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
