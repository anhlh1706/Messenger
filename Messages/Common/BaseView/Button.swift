//
//  Button.swift
//  Base
//
//  Created by Hoàng Anh on 30/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit

final class Button: UIButton {
    
    @IBInspectable var localizeTitle: String = "" {
        didSet {
            setTitle(localizeTitle.localized, for: .normal)
        }
    }
    
    @IBInspectable
    var spacing: Float = 0.0 {
        didSet {
            setTitle(currentTitle, for: .normal)
        }
    }
    
    @IBInspectable
    var isUnderlined: Bool = false {
        didSet {
            setTitle(currentTitle, for: .normal)
        }
    }
    
    enum _Type {
        case contained(rounder: CGFloat = 3, color: UIColor = .primary)
        case outlined(rounder: CGFloat = 3, color: UIColor = .primary)
        case text(color: UIColor = .primary)
    }
    
    let type: _Type
    
    init(type: _Type, title: String = "", font: UIFont = .boldSystemFont(ofSize: 16)) {
        self.type = type
        super.init(frame: .zero)
        titleLabel?.font = font
        
        switch type {
        case let .contained(rounder, color):
            setTitleColor(.white, for: .normal)
            backgroundColor = color
            cornerRadius = rounder
        case let .outlined(rounder, color):
            setTitleColor(color, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = color.cgColor
            cornerRadius = rounder
        case .text(let color):
            setTitleColor(color, for: .normal)
        }
        setTitle(title, for: .normal)
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        
        var attributes: [NSAttributedString.Key: Any] = [
            .kern: spacing,
            .foregroundColor: titleColor(for: .normal) as Any,
            .font: titleLabel?.font as Any
        ]
        if isUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        let attributedString = NSAttributedString(string: currentTitle ?? "", attributes: attributes)
        setAttributedTitle(attributedString, for: state)
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        setTitle(currentTitle, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        type = .contained(rounder: 5, color: .primary)
        super.init(coder: aDecoder)
    }
    
}

extension Button {
    
    override var isEnabled: Bool {
        didSet {
            let backgroundColor: UIColor
            let titleColor: UIColor
            
            if isEnabled {
                backgroundColor = .primary
                titleColor = .white
            } else {
                backgroundColor = .subbackground
                titleColor = .subtext
            }
            setTitleColor(titleColor, for: .normal)
            self.backgroundColor = backgroundColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch type {
        case .outlined(_, let color):
            layer.borderColor = color.cgColor
        default:
            break
        }
    }
}
