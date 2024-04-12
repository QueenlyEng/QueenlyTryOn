//
//  QueenlyTryOnButton.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/1/24.
//

import UIKit

public class QueenlyTryOnButton: QueenlyButton {
    
    weak var presentingVC: UIViewController?
    
    @objc
    public weak var delegate: QueenlyTryOnDelegate?
    
    var productTitle: String
    var color: String
    
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
        layer.cornerRadius = frame.size.height / 2
    }
    
    @objc private func openARTryOn() {
        let vc = QueenlyARTryOnViewController(productTitle: productTitle, color: color)
        vc.delegate = delegate
        let navVC = UINavigationController(rootViewController: vc)
        presentingVC?.present(navVC, animated: true)
    }
    
}
