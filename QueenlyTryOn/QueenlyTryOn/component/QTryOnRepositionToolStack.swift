//
//  QTryOnRepositionToolStack.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/2/24.
//

import UIKit

class QTryOnRepositionToolStack: UIStackView {
    
    private let arrowDimension: CGSize
    
    private lazy var arrowsHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [arrowLeftButton, arrowRightButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = arrowDimension.height
        return stack
    }()
    
    lazy var arrowUpButton: QueenlyIconButton = {
        let button = QueenlyIconButton(icon: UIImage(systemName: "arrow.up"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.iconTintColor = .white
        button.widthAnchor.constraint(equalToConstant: arrowDimension.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: arrowDimension.height).isActive = true
        return button
    }()
    
    lazy var arrowDownButton: QueenlyIconButton = {
        let button = QueenlyIconButton(icon: UIImage(systemName: "arrow.down"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.iconTintColor = .white
        button.widthAnchor.constraint(equalToConstant: arrowDimension.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: arrowDimension.height).isActive = true
        return button
    }()
    
    lazy var arrowRightButton: QueenlyIconButton = {
        let button = QueenlyIconButton(icon: UIImage(systemName: "arrow.right"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.iconTintColor = .white
        button.widthAnchor.constraint(equalToConstant: arrowDimension.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: arrowDimension.height).isActive = true
        return button
    }()
    
    lazy var arrowLeftButton: QueenlyIconButton = {
        let button = QueenlyIconButton(icon: UIImage(systemName: "arrow.left"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.iconTintColor = .white
        button.widthAnchor.constraint(equalToConstant: arrowDimension.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: arrowDimension.height).isActive = true
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reposition"
        return label
    }()
    
    init(arrowDimension: CGSize) {
        self.arrowDimension = arrowDimension
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        axis = .vertical
        alignment = .center
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = .zero
        
        QTryOnStyling.applyShadow(on: arrowUpButton)
        QTryOnStyling.applyShadow(on: arrowDownButton)
        QTryOnStyling.applyShadow(on: arrowLeftButton)
        QTryOnStyling.applyShadow(on: arrowRightButton)
        QTryOnStyling.applyTryOnTootlTitleStyling(on: titleLabel)
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(arrowUpButton)
        addArrangedSubview(arrowsHStack)
        addArrangedSubview(arrowDownButton)
        
        setCustomSpacing(8, after: titleLabel)
    }
}
