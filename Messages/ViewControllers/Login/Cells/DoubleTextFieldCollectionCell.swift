//
//  DoubleTextFieldCollectionCell.swift
//  Messages
//
//  Created by Lê Hoàng Anh on 12/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage

final class DoubleTextFieldCollectionCell: UICollectionViewCell {
    
    private(set) var firstTextField = TextField()
    private(set) var secondTextField = TextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(firstTextField)
        firstTextField.topAnchor == topAnchor
        firstTextField.horizontalAnchors == horizontalAnchors + 20
        firstTextField.heightAnchor == 50
        
        addSubview(secondTextField)
        secondTextField.topAnchor == firstTextField.bottomAnchor + 10
        secondTextField.horizontalAnchors == horizontalAnchors + 20
        secondTextField.heightAnchor == firstTextField.heightAnchor
        
        [firstTextField, secondTextField].forEach {
            $0.backgroundColor = .subbackground
            $0.cornerRadius = 12
            $0.spacing = 1.1
            $0.leftPadding = 12
            $0.clearButtonMode = .whileEditing
        }
        
        firstTextField.tag = 11
        secondTextField.tag = 12
    }
    
    func setPlaceholder(first: String, second: String) {
        firstTextField.placeholder = first
        secondTextField.placeholder = second
    }
    
    func setDelegate(target: UITextFieldDelegate) {
        firstTextField.delegate = target
        secondTextField.delegate = target
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
