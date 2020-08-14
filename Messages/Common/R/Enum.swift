//
//  Enum.swift
//  Base
//
//  Created by Lê Hoàng Anh on 02/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import UIKit.UIScreen

enum Screen {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}

enum ErrorCode: Int {
    case parseError             = -1
    case noInternet             = 0
    case success                = 200
    case createdSuccess         = 201
    case deletedSuccess         = 204
    case badRequest             = 400
    case unauthorized           = 401
    case paymentRequired        = 402
    case invalidToken           = 403
    case notFound               = 404
    case userPermisionChange    = 406
    case timedOut               = 408
    case conflictError          = 409
    case preconditionFailed     = 412
    case requestUpdateApp       = 426
    case internetError          = 500
    case systemMaintance        = 503
    case apiError               = 602
}

enum TextStyle {
    case normal, largeTitle, boldTitle
}
