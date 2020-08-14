//
//  Dictionary.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == Optional<Any> {
    
    func filterNilOrEmptyValue() -> Dictionary {
        
        var filtered = [String: Any]()
        for case let (key, value?) in self where value is String {
            filtered[key] = value
        }
        return filtered
    }
    
    
    func asURLParams() -> String {
        var urlString = "?"
        
        let filtered = filterNilOrEmptyValue()
        
        for (key, value) in filtered {
            if let value = value as? Int {
                urlString += key + "=" + String(value) + "/"
            } else if let value = value as? String {
                urlString += key + "=" + value + "/"
            }
        }
        urlString.removeLast()
        return urlString
    }
}

