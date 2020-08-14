//
//  SingleTextFieldCollectionCell.swift
//  Messages
//
//  Created by Lê Hoàng Anh on 12/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage

final class SingleTextFieldCollectionCell: UICollectionViewCell {
    
    private let textField = TextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textField)
        textField.tag = 11
        textField.horizontalAnchors == horizontalAnchors + 20
        textField.heightAnchor == 50
        textField.backgroundColor = .subbackground
        textField.cornerRadius = 12
        textField.spacing = 1.1
        textField.leftPadding = 12
        textField.placeholderColor = .subtext
        textField.clearButtonMode = .whileEditing
    }
    
    func setPlaceholder(_ placeholder: String) {
        textField.placeholder = placeholder
    }
    
    func setDelegate(target: UITextFieldDelegate) {
        textField.delegate = target
    }
    
    func setKeyboardType(_ type: UIKeyboardType) {
        textField.keyboardType = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
