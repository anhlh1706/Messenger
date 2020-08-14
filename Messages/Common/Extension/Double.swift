//
//  Double.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation

extension Double {
    func currencyStr() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSize = 3
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        return "$" + (numberFormatter.string(from: self as NSNumber) ?? "0.00")
    }
    
    func currency() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSize = 3
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        return (numberFormatter.string(from: self as NSNumber) ?? "0.00")
    }
}
