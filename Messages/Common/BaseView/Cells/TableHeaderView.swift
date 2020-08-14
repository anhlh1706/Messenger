//
//  TableHeaderView.swift
//  Base
//
//  Created by Hoàng Anh on 30/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage

class BasicTableHeaderView: UITableViewHeaderFooterView {
    
    fileprivate let titleLabel = UILabel()
    fileprivate let subtitleLabel = UILabel()
    fileprivate var labelsStack: UIStackView!
    fileprivate var stackEdgeAnchors: ConstraintGroup!
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subTitle: String? {
        didSet {
            subtitleLabel.text = subTitle
        }
    }
    
    var style: TextStyle = .normal {
        didSet {
            updateStyle()
        }
    }
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let labels = [titleLabel, subtitleLabel]
        
        labels.forEach { label in
            label.numberOfLines = 0
        }
        
        labelsStack = UIStackView(arrangedSubviews: labels)
        labelsStack.axis = .vertical
        labelsStack.spacing = 4
        contentView.addSubview(labelsStack)
        stackEdgeAnchors = (labelsStack.edgeAnchors == contentView.edgeAnchors + UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18))
        
        titleLabel.textColor = .text
        subtitleLabel.textColor = .subtext
        contentView.backgroundColor = UIColor.background.withAlphaComponent(0.95)
        updateStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        backgroundView?.alpha = 0
    }
    
    private func updateStyle() {
        switch style {
        case .normal:
            titleLabel.font = .systemFont(ofSize: 14)
            subtitleLabel.font = .systemFont(ofSize: 12)
        case .largeTitle:
            titleLabel.font = .systemFont(ofSize: 17)
            subtitleLabel.font = .systemFont(ofSize: 12)
        case .boldTitle:
            titleLabel.font = .boldSystemFont(ofSize: 17)
            subtitleLabel.font = .systemFont(ofSize: 12)
        }
    }
}

final class ActionTableHeaderView: BasicTableHeaderView {
    
    private let actionButton = Button(type: .text(color: .primary))
    
    var actionTitle: String = "" {
        didSet {
            actionButton.setTitle(actionTitle, for: .normal)
            removeConstraint(stackEdgeAnchors.trailing)
            stackEdgeAnchors.trailing.constant = -(AppHelper.estimatedWidth(ofString: actionTitle, withFont: actionButton.titleLabel?.font, spacing: actionButton.spacing) + 15)
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(actionButton)
        actionButton.trailingAnchor == contentView.trailingAnchor - 10
        actionButton.topAnchor == contentView.topAnchor + 2
        actionButton.setTitle("See full", for: .normal)

        removeConstraint(stackEdgeAnchors.trailing)
        stackEdgeAnchors.trailing.constant = -(AppHelper.estimatedWidth(ofString: "See full", withFont: actionButton.titleLabel?.font, spacing: actionButton.spacing) + 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
