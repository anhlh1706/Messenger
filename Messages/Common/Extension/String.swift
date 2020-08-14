//
//  String.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import UIKit.UIApplication

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var isEmptyStr: Bool {
        return trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty
    }
    
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    var isBackspace: Bool {
        let char = cString(using: String.Encoding.utf8)!
        return strcmp(char, "\\b") == -92
    }
    
    var standardlized: String {
        return components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty }).joined(separator: " ")
    }
    
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func prefix(maxLength: Int) -> String {
        return String(prefix(maxLength))
    }
    
    func suffix(maxLength: Int) -> String {
        return String(suffix(maxLength))
    }
    
    func formatPhoneNumber() -> String {
        if isEmpty { return "" }
        
        let cleanPhoneNumber = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "+X (XXX) XXX - XXXX"
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func capitalizedFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    func toDate(withFormat format: String = "MM/dd/yyyy") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func isValidPhoneNumber() -> Bool {
        let phoneRegex = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
        return range(of: phoneRegex, options: .regularExpression) != nil
    }
    
    func makePhoneCall() {
        if isValidPhoneNumber() {
            if let url = URL(string: "tel://\(onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
    
    var removedColon: String {
        return replacingOccurrences(of: ",", with: "")
    }
    
    var removedSpaces: String {
        return split(separator: " ").joined()
    }
    
    func toDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
    
    func numberOnly() -> String {
        return filter("01234567890".contains)
    }
}
