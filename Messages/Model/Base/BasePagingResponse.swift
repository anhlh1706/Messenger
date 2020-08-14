//
//  BasePagingResponse.swift
//  Base
//
//  Created by Hoàng Anh on 06/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

struct BasePagingResponse<T: Decodable> {
    var code: Int?
    var message: String?
    var data: PagingObject<T>?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case items = "data"
    }
}

struct PagingObject<T: Decodable>: Decodable {
    var currentPage: Int?
    var totalPages: Int?
    var pageSize: Int?
    var totalCount: Int?
    var items: [T]?
    var hasPrevious = false
    var hasNext = false
    
    enum CodingKeys: String, CodingKey {
        case currentPage
        case totalPages
        case pageSize
        case totalCount
        case items
        case hasPrevious
        case hasNext
    }
}
