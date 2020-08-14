//
//  UIAlertController.swift
//  Base
//
//  Created by Hoàng Anh on 30/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit.UIAlertController

extension UIAlertController {
    func addCancelAction() {
        addAction(UIAlertAction(title: Text.cancel, style: .cancel, handler: nil))
    }
    
    func addOkAction(handler: (() -> Void)? = nil) {
        addAction(title: Text.ok, handler: handler)
    }
    
    func addAction(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)?) {
        addAction(UIAlertAction(title: title, style: style, handler: { _ in
            handler?()
        }))
    }
}
