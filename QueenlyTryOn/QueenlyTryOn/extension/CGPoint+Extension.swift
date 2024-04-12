//
//  CGPoint+Extension.swift
//  QueenlyTryOnTestApp
//
//  Created by Mica Morales on 4/4/24.
//

import Foundation

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return sqrt(
            pow(x - point.x, 2) +
            pow(y - point.y, 2)
        )
    }
    
    func midPoint(with point: CGPoint) -> CGPoint {
        return CGPoint(x: (x + point.x) / 2,
                       y: (y + point.y) / 2)
    }
    
    func translate(on newBounds: CGRect) -> CGPoint {
        return CGPoint(x: x - newBounds.origin.x,
                       y: y - newBounds.origin.y)
    }
}
