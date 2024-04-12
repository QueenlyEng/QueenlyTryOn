//
//  SCNVector3+Extension.swift
//  QueenlyTryOnTestApp
//
//  Created by Mica Morales on 4/3/24.
//

import Foundation
import ARKit

extension SCNVector3 {
    func distance(from p2: SCNVector3) -> CGFloat {
        return CGFloat(sqrt(
            pow(x - p2.x, 2) +
            pow(y - p2.y, 2) +
            pow(z - p2.z, 2)
        ))
    }
    
    func midPoint(with p2: SCNVector3) -> SCNVector3 {
        return SCNVector3((x + p2.x) / 2,
                          (y + p2.y) / 2,
                          (z + p2.z) / 2)
    }
    
    func simdFloatVal() -> simd_float3 {
        return simd_float3(x, y, z)
    }
}
