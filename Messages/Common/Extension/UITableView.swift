//
//  TableView.swift
//  Base
//
//  Created by Hoàng Anh on 30/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(cell: T.Type) {
        if let nib = T.nib, Bundle.main.path(forResource: T.className, ofType: "nib") != nil {
            register(nib, forCellReuseIdentifier: T.cellId)
        } else {
            register(T.self, forCellReuseIdentifier: T.cellId)
        }
    }
    
    func register<T: UITableViewHeaderFooterView>(view: T.Type) {
        if let nib = T.nib, Bundle.main.path(forResource: T.className, ofType: "nib") != nil {
            register(nib, forHeaderFooterViewReuseIdentifier: T.headerId)
        } else {
            register(T.self, forHeaderFooterViewReuseIdentifier: T.headerId)
        }
    }
    
    func dequeueReusableCell<T>(cell: T.Type = T.self, indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: cell.cellId, for: indexPath) as? T else {
            fatalError("Could not init \(T.className)")
        }
        return cell
    }
    
    func dequeueReusableHeaderFooter<T>(type: T.Type = T.self) -> T where T: UITableViewHeaderFooterView {
        guard let header = dequeueReusableHeaderFooterView(withIdentifier: T.headerId) as? T else {
            fatalError("Could not init \(T.className)")
        }
        return header
    }
}

extension UITableViewCell {
    
    static var cellId: String {
        return className
    }
    
    static var nib: UINib? {
        return UINib(nibName: cellId, bundle: nil)
    }
    
    var tableView: UITableView? {
        var table: UIView? = superview
        while !(table is UITableView) && table != nil {
            table = table?.superview
        }
        return table as? UITableView
    }
    
}

extension UITableViewHeaderFooterView {

    static var headerId: String {
        return className
    }
    
    static var nib: UINib? {
        return UINib(nibName: headerId, bundle: Bundle.main)
    }
}

extension NSObject {
    
    var className: String {
        return type(of: self).className
    }
    
    static var className: String {
        return String.className(self)
    }
}
