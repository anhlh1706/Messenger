//
//  DateFormatter.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static func customFormat(_ format: String) -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        
        return dateformatter
    }
    
    static func timeOnly() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        
        return dateformatter
    }
    
    static func dateOnly() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        return dateformatter
    }
    
    static func dateTime() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateformatter
    }
    
    static func dateOnlySlash() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        
        return dateformatter
    }
    
    static func fullStyle() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-DD hh:mm:ss.sTZD"
        
        return dateformatter
    }
    
    static func textStyle() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMM dd hh:mm a"
        
        return dateformatter
    }
    
}
