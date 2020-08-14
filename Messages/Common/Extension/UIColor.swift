//
//  UIColor.swift
//  Base
//
//  Created by Hoàng Anh on 30/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
    
    convenience init(hex: Int) {
        let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00ff00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000ff) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIColor {
    static let text = UIColor(named: "text")!
    static let subtext = UIColor(named: "subtext")!
    static let background = UIColor(named: "background")!
    static let subbackground = UIColor(named: "subbackground")!
    static let primary = UIColor(named: "primary")!
    static let textPlaceholder = UIColor(named: "textPlaceholder")!
}
