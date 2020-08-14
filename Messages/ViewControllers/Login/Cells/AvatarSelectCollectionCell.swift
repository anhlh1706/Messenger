//
//  AvatarSelectCollectionCell.swift
//  Messages
//
//  Created by Hoàng Anh on 13/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import Anchorage

final class AvatarSelectCollectionCell: UICollectionViewCell {
    
    let imageView = UIImageView(image: .userPlaceholder)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.topAnchor == topAnchor
        imageView.centerXAnchor == centerXAnchor
        imageView.sizeAnchors == CGSize(width: 180, height: 180)
        imageView.cornerRadius = 5
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .subtext
        imageView.contentMode = .scaleAspectFill
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    func setTarget(_ target: Any, action: Selector) {
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIPickerControllerDelegate
extension AvatarSelectCollectionCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            let imageSize = CGSize(width: 250, height: 250)
            imageView.image = pickedImage.scaleToFit(size: imageSize)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
