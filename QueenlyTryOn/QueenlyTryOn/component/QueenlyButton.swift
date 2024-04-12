//
//  QueenlyButton.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/3/24.
//

import UIKit

typealias Action = (() -> ())

public class QueenlyButton: UIView {
    
    @objc
    public var contentSpacing: CGFloat = 8 {
        didSet {
            mainHStack.spacing = 8
        }
    }
    
    @objc
    public var buttonInset: NSDirectionalEdgeInsets = .zero {
        didSet {
            mainHStack.directionalLayoutMargins = buttonInset
        }
    }
    
    @objc
    public var buttonTintColor: UIColor? = .black {
        didSet {
            textLabel.textColor = buttonTintColor
            iconImageView.tintColor = buttonTintColor
        }
    }
    
    var icon: UIImage? = nil {
        didSet {
            iconImageView.image = icon
            iconImageView.isHidden = icon == nil
        }
    }
    
    var text: String = "" {
        didSet {
            textLabel.text = text
            textLabel.isHidden = text.isEmpty
        }
    }
    
    var adjustsFontSizeToFitWidth: Bool {
        get {
            return textLabel.adjustsFontSizeToFitWidth
        }
        set {
            textLabel.adjustsFontSizeToFitWidth = newValue
        }
    }
    
    private var action: Action?
    
    private var iconWidthConstraint: NSLayoutConstraint?
    private var iconHeightConstraint: NSLayoutConstraint?
    
    private lazy var mainVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mainHStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.clipsToBounds = true
        return stack
    }()
    
    private lazy var mainHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, textLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = buttonInset
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.tintColor = buttonTintColor
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.numberOfLines = 1
        label.textColor = buttonTintColor
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.text = "🪞 Try on this item"
        return label
    }()
    
    // MARK: - Init
    @objc
    public init() {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        addSubview(mainVStack)
        NSLayoutConstraint.activate([
            mainVStack.topAnchor.constraint(equalTo: topAnchor),
            mainVStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        setNeedsLayout()
        layoutIfNeeded()
        
        backgroundColor = .white
        clipsToBounds = true
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
    }
    
    // MARK: - Actions & Misc
    @objc
    public func setTitle(_ text: String, font: UIFont?) {
        self.text = text
        self.textLabel.font = font
    }
    
    @objc
    public func setIcon(_ icon: UIImage?, dimension: CGSize) {
        self.icon = icon
        iconWidthConstraint = iconImageView.widthAnchor.constraint(lessThanOrEqualToConstant: dimension.width)
        iconHeightConstraint = iconImageView.heightAnchor.constraint(lessThanOrEqualToConstant: dimension.height)
        
        iconWidthConstraint?.isActive = true
        iconHeightConstraint?.isActive = true
    }
    
    @objc public
    func forceLeftToRight() {
        for subview in mainHStack.arrangedSubviews {
            subview.removeFromSuperview()
        }
        mainHStack.addArrangedSubview(textLabel)
        mainHStack.addArrangedSubview(iconImageView)
    }
    
    func addAction(_ action: @escaping Action) {
        self.action = action
    }
    
    @objc
    private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        DispatchQueue.main.async { [weak self] in
            self?.action?()
        }
    }
}
