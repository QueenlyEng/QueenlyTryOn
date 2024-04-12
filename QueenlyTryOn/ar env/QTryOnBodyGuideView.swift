//
//  QTryOnBodyGuideView.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/4/24.
//

import UIKit

class QTryOnBodyGuideView: UIView {
    
    private let imageHandler = QImageHandler()
    
    private lazy var mainVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [labelVStack, womanIconView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 32
        return stack
    }()
    
    private lazy var labelVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [guideLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.backgroundColor = .black.withAlphaComponent(0.2)
        stack.layer.masksToBounds = true
        stack.layer.cornerRadius = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16)
        return stack
    }()
    
    private lazy var guideLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.text = "Keep your body/\nmirror in the center!"
        return label
    }()
    
    private lazy var womanIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = imageHandler.image(named: "woman_guide_icon")
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
            womanIconView.heightAnchor.constraint(lessThanOrEqualTo: womanIconView.widthAnchor, multiplier: 2.0),
            mainVStack.topAnchor.constraint(equalTo: topAnchor),
            mainVStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    func animate() {
        self.womanIconView.alpha = 0.25
        self.labelVStack.alpha = 0.0
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .repeat]) { [weak self] in
            self?.womanIconView.alpha = 1.0
        }
        UIView.animate(withDuration: 1.0, delay: 0.25) { [weak self] in
            self?.labelVStack.alpha = 1.0
        }
    }
    
}
