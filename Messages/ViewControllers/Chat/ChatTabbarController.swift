//
//  ChatTabbarController.swift
//  Messages
//
//  Created by Hoàng Anh on 14/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit

final class ChatTabbarController: UITabBarController {
    
    let user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .primary
        tabBar.barTintColor = .background
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        hidesBottomBarWhenPushed = true
        
        let tabBarIconSize = CGSize(width: 30, height: 30)
        
        let chatsVC         = ChatListViewController(user: user)
        let profileVC       = ProfileViewController()
        
        chatsVC.tabBarItem    = UITabBarItem(title: Text.chats, image: UIImage.logo.resizeToFit(size: tabBarIconSize), tag: 0)
        profileVC.tabBarItem   = UITabBarItem(title: Text.profile, image: UIImage.iconUser.resizeToFit(size: tabBarIconSize), tag: 1)
        
        viewControllers = [
            NavigationController(rootViewController: chatsVC),
            NavigationController(rootViewController: profileVC)
        ]
        
        delegate = self
    }
}

// MARK: - UITabBarControllerDelegate
extension ChatTabbarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabBarAnimatedTransitioning()
    }
    
}

final class TabBarAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        destination.alpha = 0.0
        transitionContext.containerView.addSubview(destination)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destination.alpha = 1.0
        }, completion: { transitionContext.completeTransition($0) })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
}
