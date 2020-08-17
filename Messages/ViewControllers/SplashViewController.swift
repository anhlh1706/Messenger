//
//  SplashViewController.swift
//  Messages
//
//  Created by Hoàng Anh on 14/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage
import FirebaseAuth

final class SplashViewController: UIViewController {

    let imv = UIImageView(image: .logo)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        view.addSubview(imv)
        let logoSize: CGSize = UIDevice.isIphone8 ? .init(width: 140, height: 140) : .init(width: 180, height: 180)
        imv.sizeAnchors == logoSize
        imv.centerAnchors == view.safeAreaLayoutGuide.centerAnchors
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        excuteDisappear()
    }
    
    func excuteDisappear() {
        var rootVC: UIViewController = NavigationController(rootViewController: LoginViewController())
        if FirebaseAuth.Auth.auth().currentUser != nil {
            if let email = UserDefaults.standard.string(forKey: kCurrentUserEmail) {
                DatabaseManager.shared.getUser(forEmail: email) { user in
                    if let user = user {
                        rootVC = ChatTabbarController(user: user)
                    } else {
                        rootVC = NavigationController(rootViewController: LoginViewController())
                    }
                    self.animation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        AppDelegate.shared.window?.rootViewController = rootVC
                    }
                }
                return
            }
        }
        animation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            AppDelegate.shared.window?.rootViewController = rootVC
        }
        return
    }
    
    func animation() {
        let isLogedIn = FirebaseAuth.Auth.auth().currentUser != nil
        let targetTopSpacing: CGFloat = UIDevice.isIphoneXSeries ? 80 : 50
        let currentTopSpacing = imv.frame.origin.y
        let transform = targetTopSpacing - currentTopSpacing
        UIView.animate(withDuration: 0.5) {
            self.imv.transform = CGAffineTransform(translationX: 0, y: transform)
            if isLogedIn {
                self.imv.alpha = 0
            }
        }
    }
}
