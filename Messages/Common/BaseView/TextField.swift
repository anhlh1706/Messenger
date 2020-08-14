//
//  TextField.swift
//  Messages
//
//  Created by Hoàng Anh on 12/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit

final class TextField: UITextField {
    
    @IBInspectable
    var leftPadding: CGFloat = 0 {
        didSet {
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: leftPadding, height: 0))
            leftViewMode = .always
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    init(placeholder: String?) {
        super.init(frame: .zero)
        setup()
        self.placeholder = placeholder
    }
    
    @IBInspectable var localizePlaceholder: String = "" {
        didSet {
            placeholder = localizePlaceholder.localized
        }
    }
    
    @IBInspectable
    var spacing: Float = 0.0 {
        didSet {
            setAttributedText()
            setAttributedPlaceholder()
        }
    }
    
    @objc func didChangeText() {
        setAttributedText()
    }
    
    override var placeholder: String? {
        didSet {
            setAttributedPlaceholder()
        }
    }
    
    var placeholderColor: UIColor? = nil {
        didSet {
            setAttributedPlaceholder()
        }
    }
    
    private func setup() {
        placeholderColor = .textPlaceholder
        addTarget(self, action: #selector(didChangeText), for: .editingChanged)
    }
    
    private func setAttributedText() {
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: spacing,
            .foregroundColor: textColor as Any,
            .font: font as Any
        ]
        
        attributedText = NSAttributedString(string: text ?? "", attributes: attributes)
    }
    
    private func setAttributedPlaceholder() {
        var attributes: [NSAttributedString.Key: Any] = [
            .kern: spacing,
            .font: font as Any
        ]
        
        if let color = placeholderColor {
            attributes[.foregroundColor] = color
        }
        
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: attributes)
    }
    
}
