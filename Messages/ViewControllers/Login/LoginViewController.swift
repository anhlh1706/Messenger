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

final class LoginViewController: UIViewController {
    
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
        setupView()
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
}

// MARK: - Private funtions
private extension LoginViewController {
    
    func setupView() {
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
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
        
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        fbLoginButton.addTarget(self, action: #selector(fbLoginAction), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(ggLoginAction), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerAction), for: .touchUpInside)
        
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
    
    func showConversation() {
        let chatTabbar = ChatTabbarController()
        navigationController?.pushViewController(chatTabbar, animated: true)
        DispatchQueue.main.async {
            self.navigationController?.viewControllers = [chatTabbar]
        }
    }
}

// MARK: - Actions

extension LoginViewController {
    
    // MARK: - Email login
    @objc
    func loginAction() {
        showLoading()
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            self.hideLoading()
            
            guard result != nil, error == nil else {
                self.showAlert(title: "\(Text.error)!", msg: error?.localizedDescription)
                return
            }
            
            self.showConversation()
        }
    }
    
    // MARK: - Facebook login
    @objc
    func fbLoginAction() {
        let loginManager = LoginManager()
        
        if AccessToken.current != nil {
            loginManager.logOut()
        }
        showLoading()
        loginManager.logIn(permissions: ["email", "public_profile"], from: self) { [weak self] (result, error) in
            guard let self = self else { return }
            self.hideLoading()
            guard error == nil else {
                self.showAlert(msg: error?.localizedDescription)
                return
            }
            
            guard let result = result,
                  let token = result.token?.tokenString,
                  !result.isCancelled else {
                return
            }
            self.getFacebookUserInfo(withToken: token)
        }
    }
    
    func getFacebookUserInfo(withToken token: String) {
        let fbRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields" : "email, name"], tokenString: token, version: nil, httpMethod: .get)
        self.showLoading()
        fbRequest.start { (_, result, error) in
            self.hideLoading()
            guard let result = result as? [String: Any], error == nil else { return }
            
            if let name = result["name"] as? String,
               let email = result["email"] as? String {
                var nameParts = name.split(separator: " ")
                
                let firstName = String(nameParts.removeFirst())
                let lastName = nameParts.joined(separator: " ")
                let user = User(email: email, firstName: firstName, lastName: lastName)
                DatabaseManager.shared.insertUserIfNeeded(user: user)
            }
            
            self.showLoading()
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential) { (result, error) in
                self.hideLoading()
                guard result != nil, error == nil else {
                    self.showAlert(title: "\(Text.error)!", msg: error?.localizedDescription)
                    return
                }
                
                self.showConversation()
            }
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
        
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
            return
        }
        
        let userInfo = User(email: email, firstName: firstName, lastName: lastName)
        DatabaseManager.shared.insertUserIfNeeded(user: userInfo)
        
        showLoading()
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] (result, error) in
            self?.hideLoading()
            guard let self = self else { return }
            guard result != nil, error == nil else {
                self.showAlert(title: "", msg: error?.localizedDescription)
                return
            }
            
            self.showConversation()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
    }
}
