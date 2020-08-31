//
//  ChatViewController.swift
//  Messages
//
//  Created by Lê Hoàng Anh on 15/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AVKit
import CoreLocation

struct Sender: SenderType {
    let senderId: String
    let displayName: String
    let photoURL: String
}

final class ChatViewController: MessagesViewController {
    
    private var messages = [Message]() {
        didSet {
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToBottom(animated: !oldValue.isEmpty)
        }
    }
    
    private let me: User
    private let partner: User
    
    private let meSender: Sender
    private let partnerSender: Sender
    
    private var chatId: String?
    
    private let locationManager = CLLocationManager()
    
    init(chatId: String?, me: User, partner: User) {
        self.chatId = chatId
        self.me = me
        self.partner = partner
        meSender = Sender(senderId: me.email, displayName: me.lastName, photoURL: me.profileURLString ?? "")
        partnerSender = Sender(senderId: partner.email, displayName: partner.lastName, photoURL: partner.profileURLString ?? "")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        listenToMessages()
        setupInputButtons()
        navigationController?.navigationBar.tintColor = .text
        locationManager.delegate = self
    }
}

// MARK: - Private functions
private extension ChatViewController {
    
    func setupView() {
        title = partner.fullName
        view.backgroundColor = .background
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.becomeFirstResponder()
        scrollsToBottomOnKeyboardBeginsEditing = true
    }
    
    func setupInputButtons() {
        let location = InputBarButtonItem()
        let camera = InputBarButtonItem()
        let gallery = InputBarButtonItem()
        let blank = InputBarButtonItem()
        blank.setSize(CGSize(width: 10, height: 10), animated: false)
        [location, camera, gallery].forEach {
            $0.setSize(CGSize(width: 36, height: 36), animated: false)
            $0.tintColor = .subtext
        }
        location.setImage(.iconLocation, for: .normal)
        camera.setImage(.iconCamera, for: .normal)
        gallery.setImage(.iconGallery, for: .normal)
        
        location.onTouchUpInside { _ in
            self.handlerShareLocation()
        }
        camera.onTouchUpInside { _ in
            self.showPickerImage(sourceType: .camera)
        }
        gallery.onTouchUpInside { _ in
            self.showPickerImage(sourceType: .photoLibrary)
        }
        messageInputBar.inputTextView.backgroundColor = .subbackground
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 2)
        messageInputBar.inputTextView.cornerRadius = 10
        messageInputBar.setLeftStackViewWidthConstant(to: 115, animated: false)
        messageInputBar.setStackViewItems([location, camera, gallery, blank], forStack: .left, animated: false)
    }
    
    func createMessageId() -> String {
        "\(me.emailDirectory)_\(partner.email)_\(DateFormatter.dateTime().string(from: Date()))"
    }
    
    func listenToMessages() {
        if let chatId = chatId {
            DatabaseManager.shared.getAllMessages(ofChatId: chatId) { messages in
                self.messages = messages
            }
        }
    }
    
    func sendMessage(message: Message) {
        DatabaseManager.shared.sendMessage(fromUser: me, toUser: partner, toChatId: chatId, message: message) { chatID in
            if let newChatId = chatID {
                self.chatId = newChatId
                self.listenToMessages()
            }
            self.messageInputBar.inputTextView.text = ""
        }
    }
    
    func showPickerImage(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        switch sourceType {
        case .camera:
            picker.sourceType = .camera
        default:
            picker.sourceType = sourceType
            picker.mediaTypes = ["public.movie", "public.image"]
            picker.videoQuality = .typeMedium
        }
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func handlerShareLocation() {
        PermissionManager.checkForLocation(locationManager) { [weak self] available in
            if available {
                self?.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func processUploadImage(withImageData imageData: Data) {
        let msgId = createMessageId()
        showLoading(in: view)
        StorageManager.shared.uploadMessagePhoto(with: imageData, messageId: createMessageId()) { [weak self] result in
            guard let self = self else { return }
            self.hideLoading(for: self.view)
            
            switch result {
            case .success(let url):
                let media = Media(url: URL(string: url),
                                  image: nil,
                                  placeholderImage: UIImage(),
                                  size: .zero)
                let message = Message(sender: self.meSender, messageId: msgId, sentDate: Date(), kind: .photo(media))
                self.sendMessage(message: message)
            case .failure(let error):
                self.showAlert(title: Text.error, msg: error.localizedDescription)
            }
        }
    }
    
    func processUploadVideo(videoURL: URL) {
        let msgId = createMessageId()
        StorageManager.shared.uploadMessageVideo(withFileURL: videoURL, messageId: msgId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let urlStr):
                let media = Media(url: URL(string: urlStr), image: nil, placeholderImage: UIImage(), size: .zero)
                let message = Message(sender: self.meSender, messageId: msgId, sentDate: Date(), kind: .video(media))
                self.sendMessage(message: message)
            case .failure(let error):
                self.showAlert(title: Text.error, msg: error.localizedDescription)
            }
        }
    }
    
    func playVideo(withUrl url: URL) {
        let vc = AVPlayerViewController()
        vc.player = AVPlayer(url: url)
        present(vc, animated: true)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.editedImage] as? UIImage, let imageData =  image.pngData() {
            processUploadImage(withImageData: imageData)
        } else if let videoUrl = info[.mediaURL] as? URL {
            processUploadVideo(videoURL: videoUrl)
        }
    }
}

// MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.section]

        switch message.kind {
        case .photo:
            break
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            playVideo(withUrl: videoUrl)
        default:
            break
        }
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        meSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == meSender.senderId {
            avatarView.sd_setImage(with: URL(string: meSender.photoURL))
        } else {
            avatarView.sd_setImage(with: URL(string: partnerSender.photoURL))
        }
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        
        let message = Message(sender: meSender, messageId: createMessageId(), sentDate: Date(), kind: .text(text))
        sendMessage(message: message)
    }
}

// MARK: - CLLocationManagerDelegate
extension ChatViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.startUpdatingLocation()
    }
}
