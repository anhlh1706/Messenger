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
        imv.sizeAnchors == CGSize(width: 200, height: 200)
        imv.centerAnchors == view.safeAreaLayoutGuide.centerAnchors
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        excuteDisappear()
    }
    
    func excuteDisappear() {
        sleep(1)
        UIView.animate(withDuration: 0.5) {
            self.imv.transform = CGAffineTransform(scaleX: 50, y: 50)
        }
        let rootVC: UIViewController
        if FirebaseAuth.Auth.auth().currentUser == nil {
            rootVC = NavigationController(rootViewController: LoginViewController())
        } else {
            rootVC = ChatTabbarController()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            AppDelegate.shared.window?.rootViewController = rootVC
        }
        return
    }
}
