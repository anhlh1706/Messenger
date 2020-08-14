//
//  AppDelegate.swift
//  Messages
//
//  Created by Hoàng Anh on 12/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as? AppDelegate ?? AppDelegate()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        start()
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
        
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func start() {
        window?.rootViewController = NavigationController(rootViewController: SplashViewController())
        window?.makeKeyAndVisible()
    }
}

extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            AppHelper.visibleViewController?.showAlert(title: Text.error, msg: error.localizedDescription)
            return
        }
        
        guard let authen = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authen.idToken,
                                                       accessToken: authen.accessToken)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
    }
}
