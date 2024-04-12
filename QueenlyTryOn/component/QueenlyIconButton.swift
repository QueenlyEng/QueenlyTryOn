//
//  QueenlyIconButton.swift
//  Queenly
//
//  Created by Micaella Morales on 9/28/23.
//  Copyright © 2023 Kathy Zhou. All rights reserved.
//

import UIKit

class QueenlyIconButton: UIView {
    
    @objc var icon: UIImage? {
        didSet {
            setUpImage()
        }
    }
    
    @objc var iconContentMode: UIView.ContentMode = .scaleAspectFit {
        didSet {
            iconImageView.contentMode = iconContentMode
        }
    }
    
    @objc var iconInset: NSDirectionalEdgeInsets = .zero {
        didSet {
            topConstraint?.constant = iconInset.top
            bottomConstraint?.constant = -iconInset.bottom
            leadingConstraint?.constant = iconInset.leading
            trailingConstraint?.constant = -iconInset.trailing
        }
    }
    
    @objc var iconTintColor: UIColor? {
        didSet {
            setUpImage()
        }
    }
    
    @objc var iconDisabledColor: UIColor = .gray
    
    @objc var showDisabledState: Bool = false {
        didSet {
            setUpImage()
        }
    }
    
    private var action: Action?
    
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = iconContentMode
        imageView.isUserInteractionEnabled = false
        imageView.image = icon
        return imageView
    }()
    
    @objc init(icon: UIImage?) {
        self.icon = icon
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(iconImageView)
        topConstraint = iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: iconInset.top)
        bottomConstraint = iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -iconInset.bottom)
        leadingConstraint = iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: iconInset.leading)
        trailingConstraint = iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -iconInset.trailing)
        
        topConstraint?.isActive = true
        bottomConstraint?.isActive = true
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = true        
    }
    
    private func setUpImage() {
        if showDisabledState {
            iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = iconDisabledColor
        } else {
            if let iconTintColor = iconTintColor {
                iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = iconTintColor
            } else {
                iconImageView.image = icon?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func addAction(_ action: Action?) {
        self.action = action
    }
    
    @objc
    private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        action?()
    }
}
