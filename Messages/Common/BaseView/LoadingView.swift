/// Bym

import UIKit
import Anchorage

final class LoadingView: UIView {
    
    enum Style {
        case dark, clear
    }
    
    private let boundView = UIView()
    private let indicator = UIActivityIndicatorView()
    private let title = Label()
    
    init(text: String = Text.loading, style: Style = .clear) {
        super.init(frame: .zero)
        
        addSubview(boundView)
        boundView.centerAnchors == centerAnchors
        boundView.sizeAnchors == CGSize(width: 90, height: 90)
        boundView.cornerRadius = 20
        
        boundView.addSubview(indicator)
        indicator.centerYAnchor == boundView.centerYAnchor - 12
        indicator.centerXAnchor == boundView.centerXAnchor
        indicator.startAnimating()
        
        boundView.addSubview(title)
        title.centerXAnchor == boundView.centerXAnchor
        title.topAnchor == indicator.bottomAnchor + 10
        title.font = .systemFont(ofSize: 15)
        title.text = text
        
        switch style {
        case .dark:
            backgroundColor = UIColor.black.withAlphaComponent(0.4)
            title.textColor = .white
            indicator.color = .white
            indicator.style = .medium
            boundView.backgroundColor = .clear
        case .clear:
            backgroundColor = .clear
            title.textColor = .text
            indicator.color = .text
            indicator.style = .medium
            boundView.backgroundColor = UIColor.subbackground.withAlphaComponent(0.95)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
