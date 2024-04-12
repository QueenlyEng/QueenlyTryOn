//
//  ARTryOnUtil.swift
//  Queenly
//
//  Created by Mica Morales on 3/28/24.
//  Copyright © 2024 Kathy Zhou. All rights reserved.
//

import UIKit
import ARKit

struct QARTryOnUtil {
    
    private let api = QAPI()
    
    private func parseItemARMeasurementJSON(_ data: Data?) -> (measurement: QItemARMeasurement?, error: QAPIError?) {
        guard let data = data else { return (nil, nil) }
        do {
            let decoder = JSONDecoder()
            let itemMeasurement = try decoder.decode(QItemARMeasurement.self, from: data)
            return (itemMeasurement, nil)
        } catch {
            return (nil, api.parseError(data))
        }
    }
    
    func fetchARMeasurement(item: QItem,
                            jointPositions: [ARSkeleton.JointName: SCNVector3],
                            userBodyPoints: [QJointName: CGPoint],
                            completion: @escaping (_ measurement: QItemARMeasurement?, _ error: QAPIError?) -> ()) {
        var shoulderDistance: CGFloat = .zero
        var torsoLength: CGFloat = .zero
        if let leftShoulderPosition = jointPositions[.leftShoulder],
           let rightShoulderPosition = jointPositions[.rightShoulder] {
            shoulderDistance = leftShoulderPosition.distance(from: rightShoulderPosition)
            if let rootPosition = jointPositions[.root] {
                let midShoulderPosition = leftShoulderPosition.midPoint(with: rightShoulderPosition)
                torsoLength = midShoulderPosition.distance(from: rootPosition)
            }
        }
        
        var currShoulderWidth: CGFloat = .zero
        var currHipWidth: CGFloat = .zero
        if let leftShoulderPoint = userBodyPoints[.leftShoulder], let rightShoulderPoint = userBodyPoints[.rightShoulder],
           let leftHipPoint = userBodyPoints[.leftHip], let rightHipPoint = userBodyPoints[.rightHip] {
            currShoulderWidth = leftShoulderPoint.distance(from: rightShoulderPoint)
            currHipWidth = leftHipPoint.distance(from: rightHipPoint)
        }
        let urlString = "https://us-central1-queenly-alpha.cloudfunctions.net/publicvto-arpositioningdata?styleTags=\(item.styleTagsToEncodedJSON())&neckline=\(item.neckline)&sleeveLength=\(item.sleeveLength)&waistPosition=\(item.waistPosition)&shoulderDistance=\(shoulderDistance)&torsoLength=\(torsoLength)&currShoulderWidth=\(currShoulderWidth)&currHipWidth=\(currHipWidth)"
        api.loadData(fromUrlString: urlString) { data in
            let res = parseItemARMeasurementJSON(data)
            completion(res.measurement, res.error)
        }
    }
    
    func getJointPositions(_ bodyAnchor: ARBodyAnchor) -> [ARSkeleton.JointName: SCNVector3] {
        let skeleton = bodyAnchor.skeleton
        
        var jointPositions: [ARSkeleton.JointName: SCNVector3] = [:]
        
        // Update the position of the character anchor's position.
        let bodyTransform = bodyAnchor.transform
        let rootPosition = SCNVector3(bodyTransform.columns.3.x,
                                      bodyTransform.columns.3.y,
                                      bodyTransform.columns.3.z)
        jointPositions[.root] = rootPosition
        
        let jointNames: [ARSkeleton.JointName] = [
            ARSkeleton.JointName(rawValue: "head_joint"),
            ARSkeleton.JointName(rawValue: "chin_joint"),
            ARSkeleton.JointName(rawValue: "right_shoulder_1_joint"),
            ARSkeleton.JointName(rawValue: "right_arm_joint"),
            ARSkeleton.JointName(rawValue: "right_forearm_joint"),
            ARSkeleton.JointName(rawValue: "right_hand_joint"),
            ARSkeleton.JointName(rawValue: "right_handMidEnd_joint"),
            ARSkeleton.JointName(rawValue: "right_leg_joint"),
            ARSkeleton.JointName(rawValue: "right_foot_joint"),
            ARSkeleton.JointName(rawValue: "left_shoulder_1_joint"),
            ARSkeleton.JointName(rawValue: "left_arm_joint"),
            ARSkeleton.JointName(rawValue: "left_forearm_joint"),
            ARSkeleton.JointName(rawValue: "left_hand_joint"),
            ARSkeleton.JointName(rawValue: "left_handMidEnd_joint"),
            ARSkeleton.JointName(rawValue: "left_leg_joint"),
            ARSkeleton.JointName(rawValue: "left_foot_joint"),
            ARSkeleton.JointName(rawValue: "hips_joint"),
            ARSkeleton.JointName(rawValue: "spine_2_joint"),
            ARSkeleton.JointName(rawValue: "spine_3_joint"),
            ARSkeleton.JointName(rawValue: "spine_4_joint"),
            ARSkeleton.JointName(rawValue: "spine_7_joint"),
            ARSkeleton.JointName(rawValue: "right_toes_joint"),
            ARSkeleton.JointName(rawValue: "left_toes_joint")
        ]
        for jointName in jointNames {
            if let transform = skeleton.modelTransform(for: jointName) {
                let position: SCNVector3 = SCNVector3(bodyTransform.columns.3.x + transform.columns.3.x,
                                                      bodyTransform.columns.3.y + transform.columns.3.y,
                                                      bodyTransform.columns.3.z + transform.columns.3.z)
                jointPositions[jointName] = position
            }
        }
        return jointPositions
    }
    
    func createNodePlane(tryOnImage: UIImage?, planeWidth: CGFloat, planeHeight: CGFloat) -> SCNPlane {
        guard let image = tryOnImage else { return SCNPlane() }
        
        let material = SCNMaterial()
        material.diffuse.contents = image
        
        let geometry = SCNPlane(width: planeWidth, height: planeHeight)
        geometry.materials = [material]
        
        return geometry
    }
    
    // MARK: - Positioning
    func getDefaultOffset(item: QItem,
                          measurement: QItemARMeasurement,
                          nodeSize: CGSize,
                          jointPositions: [ARSkeleton.JointName: SCNVector3]) -> CGPoint {
        guard let rootPosition = jointPositions[.root],
              let itemRefPoint = jointPositions[ARSkeleton.JointName(rawValue: measurement.itemRefJointName)] else { return .zero }
        
        let itemMinRefY = CGFloat(itemRefPoint.y) + measurement.itemYRefOffset
        
        let dressRootPositionMinY = CGFloat(rootPosition.y) + (nodeSize.height / 2)
        let dressYOffset = abs(dressRootPositionMinY - itemMinRefY)
        let centerYOffset = dressRootPositionMinY < itemMinRefY ? dressYOffset : dressYOffset * -1
        
        return CGPoint(x: .zero,
                       y: centerYOffset)
    }
    
    // MARK: - Sizing
    func getItemPlaneWidth(item: QItem,
                           measurement: QItemARMeasurement,
                           scaleMultiplier: CGFloat = .zero) -> CGFloat {
        return measurement.width + (scaleValue(of: item) * scaleMultiplier)
    }
    
    func getItemPlaneHeight(item: QItem,
                            measurement: QItemARMeasurement,
                            verticalScaleMultiplier: CGFloat) -> CGFloat {
        return measurement.height + (scaleValue(of: item) * verticalScaleMultiplier)
    }
    
    func scaleValue(of item: QItem) -> CGFloat {
        if let tryOnImage = item.tryOnImage {
            return max(0.005, min(0.5, tryOnImage.size.width * 0.00005))
        }
        return 0.005
    }
    
    // MARK: - Others
    func getUserImage(from sceneView: ARSCNView) -> UIImage? {
        let session = sceneView.session
        guard let currentFrame = session.currentFrame else { return nil }
        return UIImage(pixelBuffer: currentFrame.capturedImage, scale: 1.0, orientation: .right)?.resized(to: sceneView.frame.size)
    }
    
}
