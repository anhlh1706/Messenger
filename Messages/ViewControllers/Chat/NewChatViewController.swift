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
    
    var users = [User]() {
        didSet {
            let insertIndexes = users.enumerated().filter { repo -> Bool in
                !oldValue.contains(where: { $0 == repo.element })
            }
            let removeIndexes = oldValue.enumerated().filter { repo -> Bool in
                !users.contains(where: { $0 == repo.element })
            }
            let indexPathsInsert = insertIndexes.map { IndexPath(row: $0.offset, section: 0) }
            let indexPathsDelete = removeIndexes.map { IndexPath(row: $0.offset, section: 0) }
            
            tableView.beginUpdates()
            tableView.insertRows(at: indexPathsInsert, with: .bottom)
            tableView.deleteRows(at: indexPathsDelete, with: .top)
            tableView.endUpdates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        view.addSubview(tableView)
        tableView.edgeAnchors == view.edgeAnchors
        tableView.tableFooterView = UIView()
        tableView.register(cell: IconTextTableCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        
        let rightBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissSelf))
        rightBarButton.tintColor = .text
        navigationItem.rightBarButtonItem = rightBarButton
        navigationController?.navigationBar.topItem?.titleView = searchBar
        searchBar.becomeFirstResponder()
        search(email: "")
    }
    
    func search(email: String) {
        DatabaseManager.shared.getUsers(filterEmail: email) { users in
            self.users = users
        }
    }
    
    @objc
    func dismissSelf() {
        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension NewChatViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(email: searchText)
    }
}

// MARK: - UITableViewDataSource
extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(cell: IconTextTableCell.self, indexPath: indexPath)
        cell.render(title: user.email, subTitle: user.firstName, iconUrl: user.profileURLString)
        return cell
    }
    
    
}
