//
//  QPopUpViewController.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/4/24.
//

import UIKit

protocol QPopUpViewControllerDelegate: AnyObject {
    func qPopUpDidDismiss(_ popUp: QPopUpViewController)
}

class QPopUpViewController: UIViewController {
    
    weak var delegate: QPopUpViewControllerDelegate?
    
    var tag: Int = .zero
    
    var buttonAxis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            buttonStack.axis = buttonAxis
        }
    }
    
    var contentInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 32, leading: 32, bottom: 16, trailing: 32) {
        didSet {
            contentVStack.directionalLayoutMargins = contentInsets
        }
    }
    
    var actionInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8) {
        didSet {
            buttonStack.directionalLayoutMargins = actionInsets
        }
    }
    
    var isFillMode: Bool = true {
        didSet {
            leftSpacer.isHidden = isFillMode
            rightSpacer.isHidden = isFillMode
        }
    }
    
    var horizontalOffset: CGFloat = 32 {
        didSet {
            containerHStack.directionalLayoutMargins.leading = horizontalOffset
            containerHStack.directionalLayoutMargins.trailing = horizontalOffset
        }
    }
    
    var buttons: [QueenlyButton] = []
    var completion: Action?
    
    private let imageDimension: CGSize = CGSize(width: 60, height: 60)    
    private var timer: Timer?
    
    private lazy var containerHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [leftSpacer, mainVStack, rightSpacer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: horizontalOffset, bottom: 0, trailing: horizontalOffset)
        return stack
    }()
    
    lazy var mainVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [contentVStack, buttonStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.backgroundColor = .white
        stack.layer.masksToBounds = true
        stack.layer.cornerRadius = 12
        return stack
    }()
    
    lazy var contentVStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = contentInsets
        return stack
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = buttonAxis
        stack.addTopBorder()
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = actionInsets
        return stack
    }()
    
    lazy var leftSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = isFillMode
        return view
    }()
    
    lazy var rightSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = isFillMode
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        style()
        layout()
    }
    
    init(contentView: UIView) {
        super.init(nibName: nil, bundle: nil)
        contentVStack.addArrangedSubview(contentView)
        style()
        layout()
    }
    
    func config(contentView: UIView) {
        contentVStack.addArrangedSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    // MARK: - Style & Layout
    private func style() {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = .black.withAlphaComponent(0.1)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    private func layout() {
        view.addSubview(containerHStack)
        NSLayoutConstraint.activate([
            containerHStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerHStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerHStack.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Actions
    func addButton(_ button: QueenlyButton, action: Action? = nil) {
        button.tag = buttons.count
        button.addAction {
            self.dismissPopUp()
            action?()
        }
        buttons.append(button)
        buttonStack.addArrangedSubview(button)
    }
    
    @objc
    func addDuration(_ duration: CGFloat) {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(duration), target: self, selector: #selector(dismissPopUp), userInfo: nil, repeats: false)
    }
    
    @objc 
    private func dismissPopUp() {
        dismiss(animated: true) {
            if let completion = self.completion {
                completion()
            }
        }
        delegate?.qPopUpDidDismiss(self)
    }
    
    @objc 
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        dismissPopUp()
    }
}

