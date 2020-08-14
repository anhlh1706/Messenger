//
//  Image.swift
//  Base
//
//  Created by Lê Hoàng Anh on 02/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import UIKit.UIImage

extension UIImage {
    static let logo = UIImage(named: "logo")!
    static let iconBack = UIImage(named: "icnBack")!.withRenderingMode(.alwaysTemplate)
    static let iconX = UIImage(named: "iconX")!.withRenderingMode(.alwaysTemplate)
    static let userPlaceholder = UIImage(systemName: "person.circle")!
    static let iconUser = UIImage(named: "iconUser")!
    static let iconFacebook = UIImage(named: "iconFacebook")!.withRenderingMode(.alwaysTemplate)
}

