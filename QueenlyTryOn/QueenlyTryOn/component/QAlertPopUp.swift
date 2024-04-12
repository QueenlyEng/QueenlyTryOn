//
//  QAlertPopUp.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/4/24.
//

import UIKit

enum QAlertType: Int {
    case success, error, custom
}

class QAlertPopUp: QPopUpViewController {
    
    let alertType: QAlertType
    
    var titleText: String = "" {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    var message: String = "" {
        didSet {
            messageLabel.text = message
        }
    }
    
    var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    
    var tintColor: UIColor = QueenlyTryOn.brandColor {
        didSet {
            titleLabel.textColor = tintColor
            messageLabel.textColor = tintColor
            imageView.tintColor = tintColor
        }
    }
    
    var titleFont: UIFont = .systemFont(ofSize: 18, weight: .regular) {
        didSet {
            titleLabel.font = titleFont
        }
    }
    
    var messageFont: UIFont = .systemFont(ofSize: 14, weight: .light) {
        didSet {
            messageLabel.font = messageFont
        }
    }
    private let imageHandler = QImageHandler()
    private let imageDimension: CGSize = CGSize(width: 60, height: 60)
    
    private lazy var alertVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, textVStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.backgroundColor = .white
        stack.layer.masksToBounds = true
        stack.layer.cornerRadius = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 42, bottom: 24, trailing: 42)
        return stack
    }()
    
    private lazy var textVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = titleFont
        label.textColor = tintColor
        label.textAlignment = .center
        label.text = titleText
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = messageFont
        label.textColor = tintColor
        label.textAlignment = .center
        label.text = message
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = tintColor
        imageView.widthAnchor.constraint(equalToConstant: imageDimension.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageDimension.height).isActive = true
        return imageView
    }()
    
    init(title: String,
         message: String,
         type: QAlertType,
         duration: CGFloat) {
        self.titleText = title
        self.message = message
        self.alertType = type
        super.init()
        style()
        addDuration(duration)
    }
    
    init(title: String,
         message: String,
         type: QAlertType,
         duration: CGFloat,
         completion: Action?) {
        self.titleText = title
        self.message = message
        self.alertType = type
        super.init()
        self.completion = completion
        
        style()
        addDuration(duration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Style
    private func style() {
        switch alertType {
        case .success:
            image = imageHandler.image(named: "purple_checkmark_icon")?.withRenderingMode(.alwaysTemplate)
            tintColor = QueenlyTryOn.brandColor
        case .error:
            image = imageHandler.image(named: "warning_icon")?.withRenderingMode(.alwaysTemplate)
            tintColor = .systemRed
        case .custom:
            break
        }
        
        isFillMode = false
        contentInsets = .zero
        config(contentView: alertVStack)
    }
}

