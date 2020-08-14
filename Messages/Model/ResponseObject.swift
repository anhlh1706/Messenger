//
//  ResponseObject.swift
//  Base
//
//  Created by Lê Hoàng Anh on 04/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

final class ResponseObject: NSObject {
    var errorCode: Int = -1
    var httpCode: Int?
    var item: Decodable?
    var data: Data?
    var message: String?
    var responseDict = [String: Any]()
}
