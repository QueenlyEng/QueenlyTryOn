//
//  QueenlyTryOnButton.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/1/24.
//

import UIKit

@objc
public enum QueenlyTryOnButtonStyle: Int {
    case capsule, rounded, none
}

public class QueenlyTryOnButton: QueenlyButton {
    
    weak var presentingVC: UIViewController?
    
    @objc
    public weak var delegate: QueenlyTryOnDelegate?
    
    @objc 
    public var buttonStyle: QueenlyTryOnButtonStyle = .capsule {
        didSet {
            setButtonStyle()
        }
    }
    
    var productTitle: String
    var color: String
    
    private let api = QAPI()
    
    // MARK: - Init
    @objc 
    public init(productTitle: String, color: String?, presentingVC: UIViewController) {
        self.productTitle = productTitle
        self.presentingVC = presentingVC
        self.color = color ?? ""
        super.init()
        addAction(openARTryOn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setButtonStyle()
    }
    
    @objc private func openARTryOn() {
        let vc = QueenlyARTryOnViewController(productTitle: productTitle, color: color)
        vc.delegate = delegate
        let navVC = UINavigationController(rootViewController: vc)
        presentingVC?.present(navVC, animated: true)
        api.logSession(productTitle: productTitle, actionType: .tryOnButtonTapped)
    }
    
    private func setButtonStyle() {
        switch buttonStyle {
        case .capsule:
            layer.cornerRadius = frame.size.height / 2
        case .rounded:
            layer.cornerRadius = 10
        case .none:
            layer.cornerRadius = 0
        }
    }
    
}
