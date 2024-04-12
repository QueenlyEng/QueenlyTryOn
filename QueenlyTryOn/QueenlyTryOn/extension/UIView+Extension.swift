//
//  UIView+Extension.swift
//  QueenlyTryOnTestApp
//
//  Created by Mica Morales on 4/3/24.
//

import UIKit

extension UIView {
    func addBottomBorder(color: UIColor = UIColor(red: 0.31, green: 0.31, blue: 0.31, alpha: 0.70),
                         borderWidth: CGFloat = 1.0) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(border)
        NSLayoutConstraint.activate([
            border.heightAnchor.constraint(equalToConstant: (borderWidth / UIScreen.main.nativeScale)),
            border.bottomAnchor.constraint(equalTo: bottomAnchor),
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func addTopBorder(color: UIColor = UIColor(red: 0.31, green: 0.31, blue: 0.31, alpha: 0.70),
                      borderWidth: CGFloat = 1.0) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(border)
        NSLayoutConstraint.activate([
            border.heightAnchor.constraint(equalToConstant: (borderWidth / UIScreen.main.nativeScale)),
            border.topAnchor.constraint(equalTo: topAnchor),
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func screenshot(scale: CGFloat = 1.0) -> UIImage {
        let screenshot = UIGraphicsImageRenderer(bounds: bounds).image { _ in
            drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
        }
        return screenshot.resized(to: CGSize(width: bounds.size.width * scale,
                                             height: bounds.size.height * scale))
    }
}
