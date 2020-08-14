// The MIT License (MIT)
// Copyright © 2016 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

class SPSegmentedControlCell: UIView {
    
    var imageView = UIImageView()
    var label = Label()
    
    var layout: SPSegmentedControlCellLayout = .onlyText {
        didSet {
            layoutIfNeeded()
        }
    }
    
    var iconRelativeScaleFactor: CGFloat = 0.5
    var spaceBetweenImageAndLabelRelativeFactor: CGFloat = 0.044 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    init(layout: SPSegmentedControlCellLayout) {
        super.init(frame: CGRect.zero)
        self.layout = layout
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        label.font = .systemFont(ofSize: 14)
        label.spacing = 0.83
        label.text = ""
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        addSubview(label)
        
        imageView.backgroundColor = UIColor.clear
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect.zero
        imageView.frame = CGRect.zero
        switch layout {
        case .onlyImage:
            let sideSize = min(frame.width, frame.height) * iconRelativeScaleFactor
            imageView.frame = CGRect.init(
                x: 0, y: 0,
                width: sideSize,
                height: sideSize
            )
            imageView.center = CGPoint.init(
                x: frame.width / 2,
                y: frame.height / 2
            )
        case .onlyText:
            label.frame = bounds
        case .textWithImage:
            label.sizeToFit()
            let sideSize = min(frame.width, frame.height) * iconRelativeScaleFactor
            imageView.frame = CGRect.init(
                x: 0, y: 0,
                width: sideSize,
                height: sideSize
            )
            let space: CGFloat = frame.width * spaceBetweenImageAndLabelRelativeFactor
            let elementsWidth: CGFloat = imageView.frame.width + space + label.frame.width
            let leftEdge = (frame.width - elementsWidth) / 2
            let centeringHeight = frame.height / 2
            imageView.center = CGPoint.init(
                x: leftEdge + imageView.frame.width / 2,
                y: centeringHeight
            )
            label.center = CGPoint.init(
                x: leftEdge + imageView.frame.width + space + label.frame.width / 2,
                y: centeringHeight
            )
        default:
            break
        }
    }
}

enum SPSegmentedControlCellLayout {
    case emptyData
    case onlyText
    case onlyImage
    case textWithImage
}
