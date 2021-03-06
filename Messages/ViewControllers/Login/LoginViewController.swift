//
//  LoginViewController.swift
//  Messages
//
//  Created by Hoàng Anh on 12/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

final class LoginViewController: ViewController {
    
    deinit {
        if animator.state == .active {
            animator.stopAnimation(true)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Elements
    private let logo = UIImageView(image: .logo)
    
    private let emailField = TextField(backgroundColor: .subbackground)
    private let passwordField = TextField(backgroundColor: .subbackground)
    
    private let loginButton = Button(type: .contained(rounder: 12, color: .primary), title: Text.login)
    private let fbLoginButton = Button(type: .outlined(rounder: 12, color: .text), title: Text.loginWithFacebook)
    private let googleLoginButton = Button(type: .outlined(rounder: 12, color: .text), title: Text.loginWithGoogle)
    private let registerButton = Button(type: .contained(rounder: 12, color: .subbackground), title: Text.register)
     
    private lazy var textFields = [emailField, passwordField]
    private lazy var buttons = [loginButton, fbLoginButton, googleLoginButton, registerButton]
    
    // MARK: - Properties
    private let animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear)
    
    // MARK: - View lyfeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emailField.roundCorners(cornerRadius: 12, corners: [.topLeft, .topRight])
        passwordField.roundCorners(cornerRadius: 12, corners: [.bottomLeft, .bottomRight])
    }
    
    override func setupView() {
        // MARK: - Setup view position
        let logoSize: CGSize = UIDevice.isIphone8 ? .init(width: 140, height: 140) : .init(width: 180, height: 180)
        let logoTopSpacing: CGFloat = UIDevice.isIphoneXSeries ? 80 : 50
        
        view.addSubview(logo)
        logo.topAnchor == view.topAnchor + logoTopSpacing
        logo.sizeAnchors == logoSize
        logo.centerXAnchor == view.centerXAnchor
        
        view.addSubview(emailField)
        emailField.topAnchor == logo.bottomAnchor + 20
        emailField.horizontalAnchors == view.horizontalAnchors + 20
        emailField.heightAnchor == 50
        
        view.addSubview(passwordField)
        passwordField.topAnchor == emailField.bottomAnchor + 3
        passwordField.horizontalAnchors == view.horizontalAnchors + 20
        passwordField.heightAnchor == 50
        
        view.addSubview(loginButton)
        loginButton.topAnchor == passwordField.bottomAnchor + 20
        loginButton.horizontalAnchors == view.horizontalAnchors + 20
        loginButton.heightAnchor == 50
        
        view.addSubview(fbLoginButton)
        fbLoginButton.topAnchor == loginButton.bottomAnchor + 20
        fbLoginButton.horizontalAnchors == view.horizontalAnchors + 20
        fbLoginButton.heightAnchor == loginButton.heightAnchor
        
        view.addSubview(googleLoginButton)
        googleLoginButton.topAnchor == fbLoginButton.bottomAnchor + 5
        googleLoginButton.horizontalAnchors == view.horizontalAnchors + 20
        googleLoginButton.heightAnchor == loginButton.heightAnchor
        
        view.addSubview(registerButton)
        registerButton.topAnchor == googleLoginButton.bottomAnchor + 20
        registerButton.horizontalAnchors == view.horizontalAnchors + 20
        registerButton.heightAnchor == 50
        
        // MARK: - Setup view properties
        view.backgroundColor = .background
        
        logo.contentMode = .scaleAspectFit
        
        emailField.placeholder = Text.username
        passwordField.placeholder = Text.password
        passwordField.isSecureTextEntry = true
        
        textFields.forEach {
            $0.spacing = 1.3
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.clearButtonMode = .whileEditing
            $0.delegate = self
            $0.leftPadding = 12
            $0.addTarget(self, action: #selector(updateLoginButtonState), for: .editingChanged)
        }
        
        buttons.forEach { $0.spacing = 1.5 }
        
        registerButton.setTitleColor(.text, for: .normal)
        
        fbLoginButton.setImage(.iconFacebook, for: .normal)
        fbLoginButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: view.width - 87)
        fbLoginButton.imageView?.contentMode = .scaleAspectFit
        fbLoginButton.tintColor = .text
        
        googleLoginButton.setImage(.iconGoogle, for: .normal)
        googleLoginButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: view.width - 87)
        googleLoginButton.imageView?.contentMode = .scaleAspectFit
        googleLoginButton.tintColor = .text
        
        updateLoginButtonState()
        
        animator.pausesOnCompletion = true
        animator.addAnimations {
            self.logo.transform = CGAffineTransform(translationX: 0, y: -60).scaledBy(x: 0.5, y: 0.5)
            
            let transform = CGAffineTransform(translationX: 0, y: -90)
            self.textFields.forEach { $0.transform = transform }
            self.buttons.forEach { $0.transform = transform }
        }
    }
    
    override func setupInteraction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
                
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        fbLoginButton.addTarget(self, action: #selector(fbLoginAction), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(ggLoginAction), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerAction), for: .touchUpInside)
    }
}

// MARK: - Private funtions
private extension LoginViewController {
    
    @objc
    func updateLoginButtonState() {
        loginButton.isEnabled = textFields.allSatisfy({ !$0.text.isNilOrEmpty })
    }
    
    @objc
    func hideKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        animator.isReversed = true
        animator.startAnimation()
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        animator.isReversed = false
        animator.startAnimation()
    }
    
    func showConversation(user: User) {
        let chatTabbar = ChatTabbarController(user: user)
        navigationController?.pushViewController(chatTabbar, animated: true)
        DispatchQueue.main.async {
            self.navigationController?.viewControllers = [chatTabbar]
        }
    }
    
    func handlerLogin(user: User?, error: Error?) {
        guard error == nil else {
            showAlert(title: "\(Text.error)!", msg: error?.localizedDescription)
            return
        }
        if let user = user {
            showConversation(user: user)
        }
    }
}

// MARK: - Actions

extension LoginViewController {
    
    // MARK: - Email login
    @objc
    func loginAction() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        showLoading()
        UserManager.shared.loginEmail(email, password: password) { [weak self] (user, error) in
            guard let self = self else { return }
            self.hideLoading()
            self.handlerLogin(user: user, error: error)
        }
    }
    
    // MARK: - Facebook login
    @objc
    func fbLoginAction() {
        showLoading()
        UserManager.shared.loginFacebook(in: self) { [weak self] (user, error) in
            guard let self = self else { return }
            self.hideLoading()
            self.handlerLogin(user: user, error: error)
        }
    }
    
    // MARK: - Google login
    @objc
    func ggLoginAction() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    // MARK: - Register
    @objc
    func registerAction() {
        present(RegisterViewController(), animated: true)
    }
    
    func uploadProfilePicture(ofUser user: User) {
        guard let urlStr = user.profileURLString else { return }
        guard let url = URL(string: urlStr) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let imageData = data {
                StorageManager.shared.uploadProfilePicture(with: imageData, user: user)
            }
        }.resume()
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            textField.resignFirstResponder()
            loginAction()
        default:
            break
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - GIDSignInDelegate
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            print(error.localizedDescription)
            return
        }
        UserManager.shared.loginGoogle(signIn: signIn, googleUser: user) { [weak self] (user, error) in
            guard let self = self else { return }
            self.hideLoading()
            self.handlerLogin(user: user, error: error)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
    }
}
