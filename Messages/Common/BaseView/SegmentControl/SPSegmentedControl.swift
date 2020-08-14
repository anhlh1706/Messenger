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

@objc protocol SPSegmentControlCellStyleDelegate {
    
    @objc optional func selectedState(segmentControlCell: SPSegmentedControlCell, forIndex index: Int)
    
    @objc optional func normalState(segmentControlCell: SPSegmentedControlCell, forIndex index: Int)
}

@objc protocol SPSegmentControlDelegate {
    
    @objc optional func indicatorViewRelativPosition(position: CGFloat, onSegmentControl segmentControl: SPSegmentedControl)
}

class SPSegmentedControl: UIControl {
    
    var indicatorView: UIView = UIView()
    var cells: [SPSegmentedControlCell] = []
    var styleDelegate: SPSegmentControlCellStyleDelegate?
    var delegate: SPSegmentControlDelegate?
    var defaultSelectedIndex: Int = 0
    var isUpdateToNearestIndexWhenDrag: Bool = true
    
    var selectedIndex: Int = 0 {
        didSet {
            if selectedIndex < 0 {
                selectedIndex = 0
            }
            if selectedIndex >= cells.count {
                selectedIndex = cells.count - 1
            }
            updateSelectedIndex()
        }
    }
    
    var isScrollEnabled: Bool = true {
        didSet {
            panGestureRecognizer.isEnabled = isScrollEnabled
        }
    }
    
    var isSwipeEnabled: Bool = true {
        didSet {
            leftSwipeGestureRecognizer.isEnabled = isSwipeEnabled
            rightSwipeGestureRecognizer.isEnabled = isSwipeEnabled
        }
    }
    
    var roundedRelativeFactor: CGFloat = 0.5 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    fileprivate var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
    fileprivate var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
    
    fileprivate var initialIndicatorViewFrame: CGRect?
    fileprivate var oldNearestIndex: Int!
    
    init() {
        super.init(frame: CGRect.zero)
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
    
    func add(cell: SPSegmentedControlCell) {
        cell.isUserInteractionEnabled = false
        cells.append(cell)
        addSubview(cell)
        selectedIndex = defaultSelectedIndex
    }
    
    func add(cells: [SPSegmentedControlCell]) {
        for cell in cells {
            cell.isUserInteractionEnabled = false
            self.cells.append(cell)
            addSubview(cell)
            selectedIndex = defaultSelectedIndex
        }
    }
    
    private func commonInit() {
        indicatorView.backgroundColor = .primary
        addSubview(indicatorView)
        indicatorView.cornerRadius = 1.5
    }
    
    private func updateSelectedIndex(animated: Bool = false) {
        if styleDelegate != nil {
            for (index, cell) in cells.enumerated() {
                styleDelegate?.normalState?(segmentControlCell: cell, forIndex: index)
            }
            styleDelegate?.selectedState?(segmentControlCell: cells[selectedIndex], forIndex: selectedIndex)
        }
        
        SPAnimationSpring.animate(
            0.35,
            animations: {
                let cellFrame = self.cells[self.selectedIndex].frame
                
                let indicatorFrame = CGRect(x: cellFrame.origin.x, y: cellFrame.maxY - 14, width: 30, height: 3)
                
                self.indicatorView.frame = indicatorFrame
        }, delay: 0,
           spring: 1,
           velocity: 0.8,
           options: [.curveEaseOut]
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if cells.isEmpty {
            return
        }
        
        let cellWidth = frame.width / CGFloat(cells.count)
        
        for (index, cell) in cells.enumerated() {
            cell.frame = CGRect.init(
                x: cellWidth * CGFloat(index),
                y: 0,
                width: cellWidth,
                height: frame.height
            )
        }
        updateSelectedIndex(animated: true)
    }
    
    fileprivate func nearestIndexToPoint(point: CGPoint) -> Int {
        var distances = [CGFloat]()
        
        for cell in cells {
            distances.append(
                abs(point.x - cell.center.x)
            )
        }
        return Int(distances.firstIndex(of: distances.min()!)!)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        var calculatedIndex: Int?
        for (index, cell) in cells.enumerated() {
            if cell.frame.contains(location) {
                calculatedIndex = index
            }
        }
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        return false
    }
}

extension SPSegmentedControl: UIGestureRecognizerDelegate {
    
    @objc func pan(_ gestureRecognizer: UIPanGestureRecognizer!) {
        switch gestureRecognizer.state {
        case .began:
            initialIndicatorViewFrame = indicatorView.frame
            oldNearestIndex = nearestIndexToPoint(point: indicatorView.center)
        case .changed:
            var frame = initialIndicatorViewFrame!
            frame.origin.x += gestureRecognizer.translation(in: self).x
            indicatorView.frame = frame
            if indicatorView.frame.origin.x < 0 {
                indicatorView.frame.origin.x = 0
            }
            if indicatorView.frame.origin.x + indicatorView.frame.width > frame.width {
                indicatorView.frame.origin.x = frame.width - indicatorView.frame.width
            }
            
            if isUpdateToNearestIndexWhenDrag {
                let nearestIndex = nearestIndexToPoint(point: indicatorView.center)
                if (oldNearestIndex != nearestIndex) && (styleDelegate != nil) {
                    oldNearestIndex = nearestIndexToPoint(point: indicatorView.center)
                    for (index, cell) in cells.enumerated() {
                        styleDelegate?.normalState?(segmentControlCell: cell, forIndex: index)
                    }
                    styleDelegate?.selectedState?(segmentControlCell: cells[nearestIndex], forIndex: nearestIndex)
                }
            }
            delegate?.indicatorViewRelativPosition?(
                position: indicatorView.frame.origin.x,
                onSegmentControl: self
            )
        case .ended, .failed, .cancelled:
            let translation = gestureRecognizer.translation(in: self).x
            if abs(translation) > (frame.width / CGFloat(cells.count) * 0.08) {
                if selectedIndex == nearestIndexToPoint(point: indicatorView.center) {
                    if translation > 0 {
                        selectedIndex += 1
                    } else {
                        selectedIndex += 1
                    }
                } else {
                    selectedIndex = nearestIndexToPoint(point: indicatorView.center)
                }
            } else {
                selectedIndex = nearestIndexToPoint(point: indicatorView.center)
            }
        default:
            break
        }
    }
    
    @objc func leftSwipe(_ gestureRecognizer: UISwipeGestureRecognizer!) {
        switch gestureRecognizer.state {
        case.ended:
            selectedIndex -= 1
        default:
            break
        }
    }
    
    @objc func rightSwipe(_ gestureRecognizer: UISwipeGestureRecognizer!) {
        switch gestureRecognizer.state {
        case.ended:
            selectedIndex += 1
        default:
            break
        }
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            return indicatorView.frame.contains(gestureRecognizer.location(in: self))
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
