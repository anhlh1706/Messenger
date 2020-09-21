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
        let priceFormatter = NumberFormatter()
        priceFormatter.locale = Locale(identifier: "en_US") // jp: "zh_CN"
        priceFormatter.numberStyle = .currency
        return priceFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
    
    func numberStr() -> String {
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .decimal
        return priceFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
