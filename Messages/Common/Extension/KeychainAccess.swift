//
//  KeychainAccess.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import KeychainAccess

extension Keychain {
    
    func setOrRemove(_ value: String?, key: String) {
        if let value = value {
            try! set(value, key: key)
        } else {
            try! remove(key)
        }
    }
    
    func setOrRemove(_ value: Int?, key: String) {
        if let value = value {
            try! set(String(value), key: key)
        } else {
            try! remove(key)
        }
    }
    
    func getValue(_ key: String) -> String? {
        return try! get(key)
    }
    
    func getInt(_ key: String) -> Int? {
        if let value = try! get(key) {
            return Int(value)
        }
        return nil
    }
}
