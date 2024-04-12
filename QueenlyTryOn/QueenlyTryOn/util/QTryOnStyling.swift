//
//  QueenlyTryOnToolTitleStyling.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/2/24.
//

import UIKit

struct QTryOnStyling {
    static func applyTryOnTootlTitleStyling(on label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        applyShadow(on: label)
    }
    
    static func applyShadow(on view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        view.layer.shadowRadius = 4
    }
}
