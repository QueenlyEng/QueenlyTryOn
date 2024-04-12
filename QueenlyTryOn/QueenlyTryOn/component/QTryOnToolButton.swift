//
//  QTryOnToolButton.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/2/24.
//

import UIKit

class QTryOnToolButton: UIView {
    
    var icon: UIImage? {
        didSet {
            iconButton.icon = icon
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    private let iconDimension: CGSize
    
    private lazy var mainVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, iconButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private lazy var iconButton: QueenlyIconButton = {
        let button = QueenlyIconButton(icon: icon)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.iconTintColor = .white
        button.widthAnchor.constraint(equalToConstant: iconDimension.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: iconDimension.height).isActive = true
        QTryOnStyling.applyShadow(on: button)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        return label
    }()
    
    init(title: String, icon: UIImage?, iconDimension: CGSize) {
        self.title = title
        self.icon = icon
        self.iconDimension = iconDimension
        super.init(frame: .zero)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        QTryOnStyling.applyShadow(on: iconButton)
        QTryOnStyling.applyTryOnTootlTitleStyling(on: titleLabel)
    }
    
    private func layout() {
        addSubview(mainVStack)
        NSLayoutConstraint.activate([
            mainVStack.topAnchor.constraint(equalTo: topAnchor),
            mainVStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func addAction(_ action: Action?) {
        iconButton.addAction(action)
    }
    
}
