//
//  ButtonTableCell.swift
//  Base
//
//  Created by Hoàng Anh on 04/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage

class ButtonTableCell: UITableViewCell {
    
    enum SizeMode {
        case exactly(CGSize)
        case edge(height: CGFloat)
    }
    
    fileprivate var button: Button
    fileprivate var buttonSize: ConstraintPair!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        button = Button(type: .text(color: .text))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    func setTitle(_ title: String?, for state: UIButton.State = .normal, color: UIColor? = nil) {
        if let color = color {
            button.setTitleColor(color, for: .normal)
        }
        button.setTitle(title, for: state)
    }
    
    func setSpacing(_ spacing: Float) {
        button.spacing = spacing
    }
    
    var isUnderlined = false {
        didSet {
            button.isUnderlined = isUnderlined
        }
    }
    
    func setSizeMode(_ sizeMode: SizeMode, rounder: CGFloat? = nil) {
        let round: CGFloat
        switch sizeMode {
        case .exactly(let size):
            if let buttonSize = buttonSize {
                buttonSize.first.constant = size.width
                buttonSize.second.constant = size.height
            } else {
                buttonSize = (button.sizeAnchors == size)
            }
            round = rounder ?? size.height / 2
        case .edge(let height):
            if let buttonSize = buttonSize {
                buttonSize.first.constant = Screen.width - 40
                buttonSize.second.constant = height
            } else {
                buttonSize = (button.sizeAnchors == CGSize(width: Screen.width - 40, height: height))
            }
            round = rounder ?? height / 2
        }
        button.cornerRadius = round
    }
    
    func setTarget(target: Any?, action: Selector) {
        button.addTarget(target, action: action, for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class TextButtonTableCell: ButtonTableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        button = Button(type: .text(color: .primary))
        addSubview(button)
        button.centerAnchors == centerAnchors
        button.verticalAnchors == verticalAnchors + 8
        setSizeMode(.edge(height: 50))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class OutlinedButtonTableCell: ButtonTableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        button = Button(type: .outlined(rounder: 25, color: .primary))
        addSubview(button)
        button.centerAnchors == centerAnchors
        button.verticalAnchors == verticalAnchors + 8
        setSizeMode(.edge(height: 50))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ContainedButtonTableCell: ButtonTableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        button = Button(type: .contained(rounder: 25, color: .primary))
        addSubview(button)
        button.centerAnchors == centerAnchors
        button.verticalAnchors == verticalAnchors + 8
        setSizeMode(.edge(height: 50))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
