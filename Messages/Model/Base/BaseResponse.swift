//
//  BaseResponse.swift
//  Base
//
//  Created by Hoàng Anh on 06/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

struct BaseResponse<T: Decodable> {
    
    var code: Int?
    var message: String?
    var item: T?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case item = "data"
    }
}
