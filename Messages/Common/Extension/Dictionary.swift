//
//  Dictionary.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == Optional<Any> {
    
    func asURLParams() -> String {
        var urlString = "?"
        
        for (key, value) in filter({ $0.value != nil }) {
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

