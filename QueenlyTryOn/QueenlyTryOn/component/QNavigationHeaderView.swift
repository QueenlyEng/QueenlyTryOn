//
//  QNavigationHeaderView.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/1/24.
//

import UIKit

enum QueenlyNavButtonStyle: Int {
    case close, back
}

@objc protocol QueenlyNavigationHeaderViewDelegate {
    func onBackButton(in headerView: QNavigationHeaderView)
}

class QNavigationHeaderView: UIView {
    
    let imageHandler = QImageHandler()
    
    @objc weak var delegate: QueenlyNavigationHeaderViewDelegate?
    
    var buttonStyle: QueenlyNavButtonStyle = .close {
        didSet {
            backButton.icon = buttonIcon
        }
    }
    
    private var buttonIcon: UIImage? {
        switch buttonStyle {
        case .close:
            return imageHandler.image(named: "close_icon")
        case .back:
            return imageHandler.image(named: "left_chevron_icon")
        }
    }
    
    private lazy var mainVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleContainerStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .white
        stack.axis = .vertical
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 22, leading: 22, bottom: 22, trailing: 22)
        return stack
    }()
    
    private lazy var mainHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [backButton, titleContainerStack, UIView()])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .white
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = 16
        return stack
    }()
    
    private lazy var backButton: QueenlyIconButton = {
        let button = QueenlyIconButton(icon: buttonIcon)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.iconTintColor = .black
        button.widthAnchor.constraint(lessThanOrEqualToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return button
    }()
    
    private lazy var titleContainerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [partnerLogoView, titleLabel, queenlyLogoView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .white
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return stack
    }()
    
    private lazy var partnerLogoView: UIImageView = {
        let imageSize = getImageSize(QueenlyTryOn.logo, maxHeight: 18)
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = QueenlyTryOn.logo
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.widthAnchor.constraint(lessThanOrEqualToConstant: imageSize.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.text = "in partnership with"
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var queenlyLogoView: UIImageView = {
        let image = imageHandler.image(named: "queenly_logo_text")
        let imageSize = getImageSize(image)
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.widthAnchor.constraint(lessThanOrEqualToConstant: imageSize.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(mainVStack)
        NSLayoutConstraint.activate([
            mainVStack.topAnchor.constraint(equalTo: topAnchor),
            mainVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            backButton.trailingAnchor.constraint(lessThanOrEqualTo: titleContainerStack.leadingAnchor, constant: -16),
        ])
        
        backButton.addAction { [weak self] in
            self?.onBackButton()
        }
    }
    
    private func onBackButton() {
        delegate?.onBackButton(in: self)
    }
    
    private func getImageSize(_ image: UIImage?, maxHeight: CGFloat = 24) -> CGSize {
        if let image = image{
            let ratio: CGFloat = image.size.width / image.size.height
            let newHeight: CGFloat = maxHeight
            return CGSize(width: newHeight * ratio, height: newHeight)
        }
        return .zero
    }
    
    func getTitleView() -> UIView {
        return titleContainerStack
    }
}

