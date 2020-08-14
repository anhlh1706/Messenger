//
//  BaseListResponse.swift
//  Base
//
//  Created by Hoàng Anh on 06/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

struct BaseListResponse<T: Decodable>: Decodable {
    var code: Int?
    var message: String?
    var items: [T]?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case items = "data"
    }
}
