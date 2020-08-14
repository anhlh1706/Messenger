//
//  RegisterViewController.swift
//  Messages
//
//  Created by Lê Hoàng Anh on 12/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage
import FirebaseAuth

final class RegisterViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    private let emailTitle = Label(text: Text.email, textAlignment: .center)
    private let nameTitle = Label(text: Text.name, textAlignment: .center)
    private let passwordTitle = Label(text: Text.password, textAlignment: .center)
    private let avatarTitle = Label(text: Text.avatar, textAlignment: .center)
    
    private let backButton = Button(type: .contained(rounder: 18, color: .subbackground))
    private let nextButton = Button(type: .contained(rounder: 12, color: .subbackground), title: Text.next)
    
    private lazy var titleLabels = [emailTitle, nameTitle, passwordTitle, avatarTitle]
    
    // MARK: - Properties
    
    private var email = ""
    private var firstName = ""
    private var lastName = ""
    private var password = ""
    private var comfirmPassword = ""
    private var profileImage: UIImage = .userPlaceholder
    
    var isEmailValidate: Bool {
        email.isValidEmail()
    }
    
    var isNameValidate: Bool {
        [firstName, lastName].allSatisfy({ !$0.isEmpty })
    }
    
    var isPasswordValidate: Bool {
        (password == comfirmPassword) && password.count > 5
    }
    
    private let states = State.allCases
    
    private var currentStepIndex = 0 {
        didSet {
            updateTitlesState()
            updateButtonState()
            updateCollectionViewState()
        }
    }
    
    private var isTryToDismiss = false {
        didSet {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
                self?.isTryToDismiss = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - Private functions
private extension RegisterViewController {
    
    func setupView() {
        // MARK: - Setup view position
        
        view.addSubview(backButton)
        backButton.topAnchor == view.safeAreaLayoutGuide.topAnchor + 20
        backButton.leadingAnchor == view.leadingAnchor + 15
        backButton.sizeAnchors == CGSize(width: 36, height: 36)
        
        view.addSubview(collectionView)
        collectionView.topAnchor == view.safeAreaLayoutGuide.topAnchor + 80
        collectionView.sizeAnchors == CGSize(width: view.width, height: 180)
        
        view.addSubview(emailTitle)
        emailTitle.bottomAnchor == collectionView.topAnchor - 20
        emailTitle.horizontalAnchors == view.horizontalAnchors
        
        view.addSubview(nameTitle)
        nameTitle.topAnchor == emailTitle.topAnchor + 80
        nameTitle.horizontalAnchors == view.horizontalAnchors
        
        view.addSubview(passwordTitle)
        passwordTitle.topAnchor == nameTitle.topAnchor + 80
        passwordTitle.horizontalAnchors == view.horizontalAnchors
        
        view.addSubview(avatarTitle)
        avatarTitle.topAnchor == passwordTitle.topAnchor + 80
        avatarTitle.horizontalAnchors == view.horizontalAnchors
        
        view.addSubview(nextButton)
        nextButton.horizontalAnchors == view.horizontalAnchors + 20
        nextButton.topAnchor == collectionView.bottomAnchor - 100
        nextButton.heightAnchor == 50
        
        // MARK: - Setup view properties
        
        updateTitlesState()
        
        titleLabels.forEach {
            $0.font = .systemFont(ofSize: 20, weight: .medium)
            $0.textColor = .text
            $0.spacing = 1.2
        }
        
        collectionView.backgroundColor = .background
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cell: SingleTextFieldCollectionCell.self)
        collectionView.register(cell: DoubleTextFieldCollectionCell.self)
        collectionView.register(cell: AvatarSelectCollectionCell.self)
        collectionView.isScrollEnabled = false
        layout.scrollDirection = .horizontal
        
        backButton.alpha = 0
        backButton.tintColor = .subtext
        backButton.setImage(.iconBack, for: .normal)
        
        backButton.addTarget(self, action: #selector(backStep), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        nextButton.spacing = 1.5
        nextButton.isEnabled = false
        
        view.backgroundColor = .background
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: .endEditing))
        
        if !UIDevice.isIphoneXSeries {
            configCloseButton()
        }
        presentationController?.delegate = self
    }
    
    func updateTitlesState() {
        let transformY = CGFloat(currentStepIndex * -80)
        UIView.animate(withDuration: 0.15) {
            for (index, label) in self.titleLabels.enumerated() {
                label.alpha = self.currentStepIndex == index ? 1 : 0
                label.transform = CGAffineTransform(translationX: 0, y: transformY)
            }
        }
    }
    
    func updateButtonState() {
        let transformY: CGFloat
        var buttonTitle = Text.next
        switch states[currentStepIndex] {
        case .email:
            transformY = 0
            nextButton.isEnabled = isEmailValidate
        case .name:
            transformY = 60
            nextButton.isEnabled = isNameValidate
        case .password:
            transformY = 60
            nextButton.isEnabled = isPasswordValidate
        case .avatar:
            transformY = 120
            nextButton.isEnabled = true
            buttonTitle = Text.finish
        }
        nextButton.setTitle(buttonTitle, for: .normal)
        UIView.animate(withDuration: 0.2) {
            self.nextButton.transform = CGAffineTransform(translationX: 0, y: transformY)
        }
        backButton.alpha = currentStepIndex == 0 ? 0 : 1
    }
    
    func updateCollectionViewState() {
        collectionView.scrollToItem(at: IndexPath(item: currentStepIndex, section: 0), at: .left, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.collectionView.cellForItem(at: IndexPath(item: self.currentStepIndex, section: 0))?.viewWithTag(11)?.becomeFirstResponder()
        })
    }
    
    func configCloseButton() {
        let closeButton = UIButton()
        closeButton.tintColor = .text
        closeButton.setImage(.iconX, for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.topAnchor == view.safeAreaLayoutGuide.topAnchor + 10
        closeButton.trailingAnchor == view.trailingAnchor - 15
        closeButton.sizeAnchors == CGSize(width: 26, height: 26)
    }
}

// MARK: - Actions
private extension RegisterViewController {
    
    @objc
    func backStep() {
        currentStepIndex -= 1
    }
    
    @objc
    func nextAction() {
        switch states[currentStepIndex] {
        case .email:
            checkEmailIsExist()
        case .name:
            currentStepIndex += 1
        case .password:
            currentStepIndex += 1
            view.endEditing(false)
        case .avatar:
            registerAction()
        }
    }
    
    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func registerAction() {
        showLoading()
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            self.hideLoading()
            
            guard error == nil, result != nil else {
                self.showAlert(title: "\(Text.error)!", msg: error?.localizedDescription)
                return
            }
            let user = User(email: self.email, firstName: self.firstName, lastName: self.lastName)
            DatabaseManager.shared.insertUser(user)
            self.showAlert(msg: "\(Text.successfully)!") {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc
    func showAlertPickImage() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(title: Text.fromLibrary) {
            self.showPicker(sourceType: .photoLibrary)
        }
        
        alert.addAction(title: Text.takeNewPicture) {
            self.showPicker(sourceType: .camera)
        }
        
        alert.addCancelAction()
        
        present(alert, animated: true, completion: nil)
    }
    
    func showPicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func checkEmailIsExist() {
        showLoading(in: view)
        view.endEditing(false)
        DatabaseManager.shared.checkEmailIsExists(email: email) { [weak self] available in
            guard let self = self else { return }
            self.hideLoading(for: self.view)
            if available {
                self.currentStepIndex += 1
            } else {
                self.showAlert(msg: "\(Text.alreadyExistsEmailMsg)") {
                    let emailField = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))?.viewWithTag(11)
                    emailField?.becomeFirstResponder()
                }
            }
        }
    }
}

// MARK: - UIPickerControllerDelegate
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            let imageSize = CGSize(width: 250, height: 250)
            profileImage = pickedImage.scaleToFit(size: imageSize)
            if let itemIndex = State.allCases.firstIndex(of: .avatar) {
                collectionView.reloadItems(at: [IndexPath(item: itemIndex, section: 0)])
            }
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        switch State.allCases[currentStepIndex] {
        case .email:
            email = newText
        case .name:
            if textField.tag == 11 {
                firstName = newText
            } else if textField.tag == 12 {
                lastName = newText
            }
        case .password:
            if textField.tag == 11 {
                password = newText
            } else if textField.tag == 12 {
                comfirmPassword = newText
            }
        case .avatar:
            break
        }
        updateButtonState()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 11 && textField.superview?.viewWithTag(12) != nil {
            textField.superview?.viewWithTag(12)?.becomeFirstResponder()
        } else {
            if nextButton.isEnabled {
                nextAction()
            }
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch states[currentStepIndex] {
        case .email:
            email = ""
        case .name:
            if textField.tag == 11 {
                firstName = ""
            } else if textField.tag == 12 {
                lastName = ""
            }
        case .password:
            if textField.tag == 11 {
                password = ""
            } else if textField.tag == 12 {
                comfirmPassword = ""
            }
        case .avatar:
            break
        }
        updateButtonState()
        return true
    }
}

// MARK: - UICollectionView Configuration
extension RegisterViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return states.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch states[indexPath.item] {
        case .email:
            return createEmailCell(for: indexPath)
        case .name:
            return createNameCell(for: indexPath)
        case .password:
            return createPasswordCell(for: indexPath)
        case .avatar:
            return createAvatarCell(for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

// MARK: - Cells
private extension RegisterViewController {
    
    func createEmailCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: SingleTextFieldCollectionCell.self, indexPath: indexPath)
        cell.setPlaceholder(Text.email)
        cell.setDelegate(target: self)
        cell.setKeyboardType(.emailAddress)
        return cell
    }
    
    func createNameCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: DoubleTextFieldCollectionCell.self, indexPath: indexPath)
        cell.setPlaceholder(first: Text.firstName, second: Text.lastName)
        cell.setDelegate(target: self)
        return cell
    }
    
    func createPasswordCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: DoubleTextFieldCollectionCell.self, indexPath: indexPath)
        cell.setPlaceholder(first: Text.password, second: Text.confirmPassword)
        cell.setDelegate(target: self)
        return cell
    }
    
    func createAvatarCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: AvatarSelectCollectionCell.self, indexPath: indexPath)
        cell.setTarget(self, action: #selector(showAlertPickImage))
        cell.setImage(profileImage)
        return cell
    }
}

// MARK: - Presentation Delegate
extension RegisterViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return currentStepIndex == 0 ? true : false
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if isTryToDismiss {
            close()
        } else {
            isTryToDismiss = true
        }
    }
    
}

private extension RegisterViewController {
    enum State: String, CaseIterable {
        case email, name, password, avatar
    }
}
