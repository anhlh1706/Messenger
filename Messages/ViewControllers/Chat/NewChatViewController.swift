//
//  NewChatViewController.swift
//  Messages
//
//  Created by Lê Hoàng Anh on 15/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage

final class NewChatViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        view.addSubview(tableView)
        tableView.edgeAnchors == view.edgeAnchors
        tableView.tableFooterView = UIView()
        tableView.register(cell: IconTextTableCell.self)
        
        searchBar.delegate = self
        searchBar.placeholder = "Found an user"
        
        let rightBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissSelf))
        rightBarButton.tintColor = .text
        navigationItem.rightBarButtonItem = rightBarButton
        navigationController?.navigationBar.topItem?.titleView = searchBar
        searchBar.becomeFirstResponder()
    }
    
    @objc
    func dismissSelf() {
        dismiss(animated: true)
    }
}

extension NewChatViewController: UISearchBarDelegate {
    
}
