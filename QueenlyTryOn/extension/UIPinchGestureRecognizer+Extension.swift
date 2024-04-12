//
//  UIPinchGestureRecognizer+Extension.swift
//  QueenlyTryOnTestApp
//
//  Created by Mica Morales on 4/5/24.
//

import UIKit

enum PinchDirection: Int {
    case vertical, horizontal, unknown
}

extension UIPinchGestureRecognizer {
    
    var direction: PinchDirection {
        guard numberOfTouches >= 2 else { return .unknown }
        
        let A = location(ofTouch: 0, in: view)
        let B = location(ofTouch: 1, in: view)

        let xD = abs( A.x - B.x )
        let yD = abs( A.y - B.y )
        if yD > xD {
            return .vertical
        } else {
            return .horizontal
        }
    }
    
}
