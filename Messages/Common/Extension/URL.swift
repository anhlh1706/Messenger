//
//  URL.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

extension URL {
    
    func getQueryDictionary() -> [String: Any] {
        guard let query = query else { return [:] }
        
        let queryArray = query.split(separator: "&").map(String.init)
        
        var parametersDict: [String: String] = [:]
        for queryParameter in queryArray {
            
            let keyValueArray = queryParameter.split{ $0 == "=" }
            let key = String(keyValueArray.first!).removingPercentEncoding!
            let value = String(keyValueArray.last!).removingPercentEncoding!
            parametersDict.updateValue(value, forKey: key)
        }
        return parametersDict
    }
    
}
