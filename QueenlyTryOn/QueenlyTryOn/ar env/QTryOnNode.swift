//
//  QTryOnNode.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/3/24.
//

import UIKit
import ARKit

class QTryOnNode: SCNNode {
    
    let item: QItem
    
    private var cameraNode: SCNNode?
    private var anchorPosition: SCNVector3 = SCNVector3Zero
    private var defaultOffset: CGPoint = .zero
    
    private var cameraPosition: SCNVector3 {
        return cameraNode?.position ?? SCNVector3Zero
    }
    private var cameraOrientation: simd_quatf {
        return cameraNode?.simdOrientation ?? simd_quatf(angle: 0, axis: .zero)
    }
    private var rotationAngles: simd_float3 {
        return cameraNode?.simdEulerAngles ?? .zero
    }
    
    var scaleMultiplier: CGFloat = .zero
    var verticalScaleMultiplier: CGFloat = .zero
    var rotationOffset: CGFloat = .zero
    var positionOffset: CGPoint = .zero
    
    var measurement: QItemARMeasurement = QItemARMeasurement()
    
    var initialNodePositionAtInteraction: SCNVector3? = nil
    var initialNodeGeoAtInteraction: SCNPlane? = nil
    var initialNodeRotationAtInteraction: CGFloat? = nil
    
    init(item: QItem) {
        self.item = item
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        anchorPosition = SCNVector3Zero
        defaultOffset = .zero
        
        scaleMultiplier = .zero
        verticalScaleMultiplier = .zero
        positionOffset = .zero
        rotationOffset = .zero
        
        measurement = QItemARMeasurement()
    }
    
    func config(withCamera cameraNode: SCNNode?,
                anchorPosition: SCNVector3,
                defaultOffset: CGPoint = .zero,
                defaultRotationOffset: CGFloat = .zero) {
        self.cameraNode = cameraNode
        self.anchorPosition = anchorPosition
        self.defaultOffset = defaultOffset
        if defaultRotationOffset != .zero {
            self.rotationOffset = defaultRotationOffset
        }
        update()
    }
    
    func updatePositionOffset(initialPosition: SCNVector3) {
        let positionOffset = SCNVector3(position.x - initialPosition.x,
                                        position.y - initialPosition.y,
                                        position.z - initialPosition.z)
        let origPositionOffset = transformVector(positionOffset, inverse: true)
        self.positionOffset.x += CGFloat(origPositionOffset.x)
        self.positionOffset.y += CGFloat(origPositionOffset.y)
    }
    
    func updateRotationOffset(_ offset: CGFloat) {
        self.rotationOffset = offset
        update()
    }
    
    private func update() {
        let orientation = simd_quatf(angle: Float(rotationOffset), axis: simd_float3(0, 0, 1))
        
        simdOrientation = cameraOrientation * orientation
        
        // transform translation vector to coordinate system of the camera
        let transVector: SCNVector3 = SCNVector3(defaultOffset.x + positionOffset.x,
                                                 defaultOffset.y + positionOffset.y,
                                                 0)
        let transformedTransVector = transformVector(transVector)
        position = SCNVector3(anchorPosition.x + transformedTransVector.x,
                              anchorPosition.y + transformedTransVector.y,
                              anchorPosition.z + transformedTransVector.z)
    }
    
    // MARK: - Math
    private func transformVector(_ vector: SCNVector3, inverse: Bool = false) -> SCNVector3 {
        let axisY = round(cameraOrientation.axis.y * 100) / 100
        var angle = cameraOrientation.angle
        if axisY < 0 {
            angle = cameraOrientation.angle * -1
        }
        
        let normalizedAxis = normalize(simd_float3(0, 1, 0))
        let cosAngle = cos(angle)
        let sinAngle = inverse ? -sin(angle) : sin(angle)
        let oneMinusCos = 1 - cosAngle
        
        let rotationMatrix = matrix_float3x3(
            simd_float3(
                cosAngle + normalizedAxis.x * normalizedAxis.x * oneMinusCos,
                normalizedAxis.x * normalizedAxis.y * oneMinusCos + normalizedAxis.z * sinAngle,
                normalizedAxis.x * normalizedAxis.z * oneMinusCos - normalizedAxis.y * sinAngle
            ),
            
            simd_float3(
                normalizedAxis.x * normalizedAxis.y * oneMinusCos - normalizedAxis.z * sinAngle,
                cosAngle + normalizedAxis.y * normalizedAxis.y * oneMinusCos,
                normalizedAxis.y * normalizedAxis.z * oneMinusCos + normalizedAxis.x * sinAngle
            ),
            
            simd_float3(
                normalizedAxis.x * normalizedAxis.z * oneMinusCos + normalizedAxis.y * sinAngle,
                normalizedAxis.y * normalizedAxis.z * oneMinusCos - normalizedAxis.x * sinAngle,
                cosAngle + normalizedAxis.z * normalizedAxis.z * oneMinusCos
            )
        )
        
        let transformedVector = rotationMatrix * vector.simdFloatVal()
        return SCNVector3(transformedVector.x,
                          transformedVector.y,
                          transformedVector.z)
    }
    
}
