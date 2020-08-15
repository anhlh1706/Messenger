//
//  ProfileViewController.swift
//  Messages
//
//  Created by Hoàng Anh on 14/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

private enum DataSource: Int, CaseIterable {
    case signOut
    
    var title: String {
        switch self {
        case .signOut:
            return Text.signOut
        }
    }
}

final class ProfileViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let dataSource = DataSource.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - Private functions
private extension ProfileViewController {
    
    func setupView() {
        view.addSubview(tableView)
        tableView.edgeAnchors == view.edgeAnchors
        
        title = Text.profile
        view.backgroundColor = .background
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell: IconTextTableCell.self)
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(cell: IconTextTableCell.self, indexPath: indexPath)
        cell.iconSize = .zero
        cell.render(title: dataSource[indexPath.row].title)
        cell.style = .boldTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch dataSource[indexPath.row] {
        case .signOut:
            do {
                try FirebaseAuth.Auth.auth().signOut()
                FBSDKLoginKit.LoginManager().logOut()
                GIDSignIn.sharedInstance()?.signOut()
                AppHelper.showLogin()
            } catch {
                showAlert(msg: error.localizedDescription)
            }
        }
    }
}
