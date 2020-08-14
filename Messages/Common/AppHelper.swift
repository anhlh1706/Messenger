//
//  AppHelper.swift
//  Base
//
//  Created by Hoàng Anh on 30/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import UIKit.UIViewController
import CoreHaptics

final class AppHelper {
    
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    static var visibleViewController: UIViewController? {
        let rootViewController: UIViewController? = AppDelegate.shared.window?.rootViewController
        return AppHelper.getVisibleViewController(from: rootViewController!)
    }
    
    private static func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        if vc is UINavigationController {
            return AppHelper.getVisibleViewController(from: ((vc as? UINavigationController)?.visibleViewController)!)
        } else if vc is UITabBarController {
            return AppHelper.getVisibleViewController(from: ((vc as? UITabBarController)?.selectedViewController)!)
        } else {
            if vc.presentedViewController != nil {
                return AppHelper.getVisibleViewController(from: vc.presentedViewController!)
            } else {
                return vc
            }
        }
    }
    
    static func showLogin() {
        guard let window = AppDelegate.shared.window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            UIView.setAnimationsEnabled(false)
            AppDelegate.shared.window?.rootViewController = NavigationController(rootViewController: LoginViewController())
            UIView.setAnimationsEnabled(true)
        })
    }
    
    class func showAlert(title: String? = nil, msg: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        UIImpactFeedbackGenerator().impactOccurred()
        DispatchQueue.main.async {
            visibleViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    class func estimatedWidth(ofString string: String, withFont font: UIFont?, spacing: Float? = nil) -> CGFloat {
        let label = Label()
        if let spacing = spacing {
            label.spacing = spacing
        }
        label.text = string
        label.font = font
        label.sizeToFit()
        return label.frame.width
    }
    
    class func estimatedHeight(ofString string: String, withFont font: UIFont, spacing: Float? = nil, lineWidth: CGFloat) -> CGFloat {
        let label = Label(frame: CGRect(x: 0, y: 0, width: lineWidth, height: 2000))
        label.numberOfLines = 0
        if let spacing = spacing {
            label.spacing = spacing
        }
        label.text = string
        label.font = font
        label.sizeToFit()
        return label.frame.height
    }
    
    class func checkStringIsEmpty(_ stringNeedCheck: String) -> Bool {
        if (stringNeedCheck.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count ) == 0 {
            return true
        }
        return false
    }
    
    class var hapticsAvailable: Bool {
        if #available(iOS 13.0, *) {
            return CHHapticEngine.capabilitiesForHardware().supportsHaptics
        } else {
            return false
        }
    }
}
