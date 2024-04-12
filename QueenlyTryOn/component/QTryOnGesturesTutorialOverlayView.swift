//
//  QTryOnGesturesTutorialOverlayView.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/5/24.
//

import UIKit

protocol QTryOnGesturesTutorialOverlayViewDelegate: AnyObject {
    func qTryOnGesturesTutorialDidRemove(_ tutorialView: QTryOnGesturesTutorialOverlayView)
}

class QTryOnGesturesTutorialOverlayView: UIView {
    
    weak var delegate: QTryOnGesturesTutorialOverlayViewDelegate?
    
    private let imageHandler = QImageHandler()
    private var timer: Timer?
    
    private lazy var mainHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [UIView(), mainVStack, UIView()])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        return stack
    }()
    
    private lazy var mainVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pinchRowView, dragRowView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 64
        return stack
    }()
    
    private lazy var pinchRowView: UIView = {
        return createRowTutorial(iconName: "pinch_icon",
                                 text: "Pinch to resize\nand rotate",
                                 imageRotationAngle: 35.0 * .pi / 180.0)
    }()
    
    private lazy var dragRowView: UIView = {
        return createRowTutorial(iconName: "drag_icon",
                                 text: "Drag and drop\nto move")
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        backgroundColor = .black.withAlphaComponent(0.4)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        addSubview(mainHStack)
        NSLayoutConstraint.activate([
            mainHStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainHStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 64),
            mainHStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -64),
        ])
        
    }
    
    private func createRowTutorial(iconName: String,
                                   text: String,
                                   imageRotationAngle: CGFloat = .zero) -> UIView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = imageHandler.image(named: iconName)
        imageView.transform = CGAffineTransform(rotationAngle: imageRotationAngle)
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = text
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 32
        return stack
    }
    
    // MARK: - Actions
    func render(on view: UIView, duration: CGFloat, delay: CGFloat = 0.0) {
        alpha = 0.0
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(duration + delay), target: self, selector: #selector(removeOverlay), userInfo: nil, repeats: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            UIView.animate(withDuration: 0.4) {
                self?.alpha = 1
            }
        }
    }
    
    @objc
    private func removeOverlay() {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.4) {
                self?.alpha = 0
            } completion: { isCompleted in
                self?.timer?.invalidate()
                self?.removeFromSuperview()
            }
        }
        delegate?.qTryOnGesturesTutorialDidRemove(self)
    }
    
    @objc 
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        removeOverlay()
    }
}
