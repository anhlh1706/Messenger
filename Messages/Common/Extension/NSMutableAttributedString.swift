//
//  NSMutableAttributedString.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import UIKit.UIImage

extension NSMutableAttributedString {
    
    convenience init(string: String, image: UIImage?) {
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.appendImage(image)
        self.init(attributedString: attributedString)
    }
    
    func appendString(_ string: String, attributes: [NSAttributedString.Key: Any]? = nil) {
        if let attributes = attributes {
            append(NSAttributedString(string: string, attributes: attributes))
        } else {
            append(NSAttributedString(string: string))
        }
    }
    
    func appendImage(_ image: UIImage?) {
        guard let image = image else { return }
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image

        let imageString = NSAttributedString(attachment: imageAttachment)
        append(imageString)
    }
}
