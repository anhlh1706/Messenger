//
//  NewChatViewController.swift
//  Messages
//
//  Created by Lê Hoàng Anh on 15/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage

protocol NewChatDelegate: AnyObject {
    func didSelectPatner(partner: User)
}

final class NewChatViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchBar = UISearchBar()
    
    private var users = [User]()
    private var filteredUsers = [User]() {
        didSet {
            tableView.reload(oldValue: oldValue, newValue: filteredUsers)
        }
    }
    private let currentEmail: String
    
    weak var delegate: NewChatDelegate?
    
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        search(email: "")
    }
}

// MARK: - Private functions
private extension NewChatViewController {
    
    func setupView() {
        view.addSubview(tableView)
        tableView.edgeAnchors == view.edgeAnchors
        
        view.backgroundColor = .background
        
        tableView.register(cell: IconTextTableCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        searchBar.delegate = self
        searchBar.placeholder = Text.search
        searchBar.tintColor = .text
        
        let rightBarButton = UIBarButtonItem(title: Text.cancel, style: .plain, target: self, action: #selector(dismissSelf))
        rightBarButton.tintColor = .text
        navigationItem.rightBarButtonItem = rightBarButton
        navigationController?.navigationBar.topItem?.titleView = searchBar
        searchBar.becomeFirstResponder()
    }
    
    func search(email: String) {
        if users.isEmpty {
            DatabaseManager.shared.getAllUsers { users in
                self.users = users.filter { $0.email != self.currentEmail }
                self.filteredUsers = self.users
            }
        } else {
            if email.isEmpty {
                filteredUsers = users
            } else {
                filteredUsers = users.filter { $0.email.lowercased().contains(email.lowercased()) }
            }
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
        filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = filteredUsers[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(cell: IconTextTableCell.self, indexPath: indexPath)
        cell.render(title: user.email, subTitle: user.firstName, iconUrl: user.profileURLString)
        cell.iconCornerRadius = 20
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewChatViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        delegate?.didSelectPatner(partner: filteredUsers[indexPath.row])
    }
}
