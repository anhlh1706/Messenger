//
//  Optional.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Collection {
    
    var isNilOrEmpty: Bool {
        switch self {
        case let collection?:
            return collection.isEmpty
        case nil:
            return true
        }
    }
    
    var isNotNilAndNotEmpty: Bool {
        return !isNilOrEmpty
    }
    
}

extension Optional where Wrapped == String {
    
    var isNilOrEmpty: Bool {
        switch self {
        case let string?:
            return string.isEmpty
        case nil:
            return true
        }
    }
    
    var isNotNilAndNotEmpty: Bool {
        return !isNilOrEmpty
    }
    
}
