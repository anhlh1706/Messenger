//
//  Config.swift
//  Base
//
//  Created by Lê Hoàng Anh on 04/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

final class Config {
    
    let baseUrl: String
    
    static let shared = Config()
    
    private init() {
        guard
            let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let config = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("Can not get Info.plist data")
        }
        baseUrl = config["BaseAPIUrl"] as! String
    }
}
