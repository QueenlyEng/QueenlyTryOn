//
//  QTryOnUtil.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/3/24.
//

import UIKit
import Vision

struct QTryOnUtil {
    
    // MARK: - Pose detection
    func detectPose(on image: UIImage,
                    with jointsGroup: VNHumanBodyPoseObservation.JointsGroupName = .all,
                    completion: @escaping (_ bodyPoints: [QJointName: CGPoint]) -> ()) {
        var allBodyPoints: [QJointName: CGPoint] = [:]
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        detectBodyPose(on: image, with: jointsGroup) { bodyPoints in
            bodyPoints.forEach { allBodyPoints[$0.key] = $0.value }
            if jointsGroup == .all {
                detectHandPose(on: image,
                               leftWrist: allBodyPoints[.leftWrist],
                               rightWrist: allBodyPoints[.rightWrist]) { handPoints in
                    handPoints.forEach { allBodyPoints[$0.key] = $0.value }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(allBodyPoints)
        }
    }
    
    private func detectBodyPose(on image: UIImage,
                                with jointsGroup: VNHumanBodyPoseObservation.JointsGroupName = .all,
                                completion: @escaping (_ bodyPoints: [QJointName: CGPoint]) -> ()) {
        var bodyPoints: [QJointName: CGPoint] = [:]
        
        // track up to 2 human body points
        var firstBodyPoints: [QJointName: CGPoint] = [:]
        var secondBodyPoints: [QJointName: CGPoint] = [:]
        
        guard let cgImage = image.cgImage else {
            completion(bodyPoints)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNDetectHumanBodyPoseRequest { request, error in
            if let observations = request.results as? [VNHumanBodyPoseObservation] {
                observations.forEach { observation in
                    guard let recognizedPoints = try? observation.recognizedPoints(jointsGroup) else {
                        completion(bodyPoints)
                        return
                    }
                    
                    for torsoJointName in observation.availableJointNames {
                        if let point = recognizedPoints[torsoJointName], point.confidence > 0 {
                            let qJointName = qJointName(fromBodyJointName: torsoJointName)
                            let imagePoint = visionToImagePoint(point, image: image)
                            
                            if firstBodyPoints[qJointName] == nil {
                                firstBodyPoints[qJointName] = imagePoint
                            } else if secondBodyPoints[qJointName] == nil {
                                secondBodyPoints[qJointName] = imagePoint
                            }
                        }
                    }
                    
                }
                
                let leftShoulder1 = firstBodyPoints[.leftShoulder]
                let rightShoulder1 = firstBodyPoints[.rightShoulder]
                let leftShoulder2 = secondBodyPoints[.leftShoulder]
                let rightShoulder2 = secondBodyPoints[.rightShoulder]
                
                var root1 = firstBodyPoints[.root]
                if let leftShoulder1 = leftShoulder1,
                   let rightShoulder1 = rightShoulder1,
                   root1 == nil {
                    root1 = leftShoulder1.midPoint(with: rightShoulder1)
                }
                
                var root2 = secondBodyPoints[.root]
                if let leftShoulder2 = leftShoulder2,
                   let rightShoulder2 = rightShoulder2,
                   root2 == nil {
                    root2 = leftShoulder2.midPoint(with: rightShoulder2)
                }
                
                // check for the points closest to the center and with bigger dimensions
                if root1 == nil && root2 != nil {
                    bodyPoints = secondBodyPoints
                } else if let root1 = root1,
                          let root2 = root2 {
                    let centerX = image.size.width / 2
                    
                    let root1DistanceFromCenter = abs(root1.x - centerX)
                    let root2DistanceFromCenter = abs(root2.x - centerX)
                    
                    if let ref1Width = getBiggestWidth(from: firstBodyPoints),
                       let ref2Width = getBiggestWidth(from: secondBodyPoints) {
                        if root2DistanceFromCenter < root1DistanceFromCenter {
                            if ref2Width > ref1Width || root1.x < image.size.width * 0.35 {
                                bodyPoints = secondBodyPoints
                            } else {
                                bodyPoints = firstBodyPoints
                            }
                        } else {
                            if ref1Width > ref2Width || root2.x < image.size.width * 0.35 {
                                bodyPoints = firstBodyPoints
                            } else {
                                bodyPoints = secondBodyPoints
                            }
                        }
                    } else {
                        bodyPoints = root1DistanceFromCenter < root2DistanceFromCenter ? firstBodyPoints : secondBodyPoints
                    }
                } else {
                    bodyPoints = firstBodyPoints
                }
                completion(bodyPoints)
            } else {
                completion(bodyPoints)
            }
        }
        
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform human body pose detection request: \(error).")
            completion(bodyPoints)
        }
    }
    
    private func detectHandPose(on image: UIImage,
                                leftWrist: CGPoint?,
                                rightWrist: CGPoint?,
                                completion: @escaping (_ handPoints: [QJointName: CGPoint]) -> ()) {
        let leftWristRefPoint = leftWrist ?? CGPoint(x: image.size.width, y: image.size.height / 2)
        let rightWristRefPoint = rightWrist ?? CGPoint(x: 0, y: image.size.height / 2)
        
        var handPoints: [QJointName: CGPoint] = [:]
        
        guard let cgImage = image.cgImage else {
            completion(handPoints)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNDetectHumanHandPoseRequest { request, error in
            if let observations = request.results as? [VNHumanHandPoseObservation] {
                observations.forEach { observation in
                    guard let recognizedPoints = try? observation.recognizedPoints(.all) else {
                        completion(handPoints)
                        return
                    }
                    
                    let handJointNames: [VNHumanHandPoseObservation.JointName] = [
                        .indexTip,
                        .indexMCP,
                        .middleTip,
                        .middleMCP
                    ]
                    
                    // Check if points should be in the left hand or rightHand
                    var isDefaultRightHand: Bool = true
                    if let wristPoint = recognizedPoints[.wrist], wristPoint.confidence > .zero {
                        let imagePoint = visionToImagePoint(wristPoint, image: image)
                        let leftDistance = leftWristRefPoint.distance(from: imagePoint)
                        let rightDistance = rightWristRefPoint.distance(from: imagePoint)
                        isDefaultRightHand = rightDistance < leftDistance
                    }
                    
                    for handJointName in handJointNames {
                        if let point = recognizedPoints[handJointName], point.confidence > 0 {
                            let imagePoint = visionToImagePoint(point, image: image)
                            let qJointName = qJointName(fromHandJointName: handJointName, rightHand: isDefaultRightHand)
                            handPoints[qJointName] = imagePoint
                        }
                    }
                }
                completion(handPoints)
            } else {
                completion(handPoints)
            }
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform human body pose detection request: \(error).")
            completion(handPoints)
        }
    }
    
    private func getBiggestWidth(from points: [QJointName: CGPoint]) -> CGFloat? {
        var distances: [CGFloat] = []
        if let leftShoulder = points[.leftShoulder],
           let rightShoulder = points[.rightShoulder] {
            distances.append(leftShoulder.distance(from: rightShoulder))
        }
        
        if let leftHip = points[.leftHip],
           let rightHip = points[.rightHip] {
            distances.append(leftHip.distance(from: rightHip))
        }
        
        if let leftKnee = points[.leftKnee],
           let rightKnee = points[.rightKnee] {
            distances.append(leftKnee.distance(from: rightKnee))
        }
        
        if let leftAnkle = points[.leftAnkle],
           let rightAnkle = points[.rightAnkle] {
            distances.append(leftAnkle.distance(from: rightAnkle))
        }
        
        return distances.max()
    }
    
    func qJointName(fromHandJointName visionHandJointName: VNHumanHandPoseObservation.JointName, rightHand: Bool) -> QJointName {
        switch visionHandJointName {
        case .indexTip:
            return rightHand ? .rightIndexTipFinger : .leftIndexTipFinger
        case .indexMCP:
            return rightHand ? .rightIndexMCPFinger : .leftIndexMCPFinger
        case .middleTip:
            return rightHand ? .rightMiddleTipFinger : .leftMiddleTipFinger
        case .middleMCP:
            return rightHand ? .rightMiddleMCPFinger : .leftMiddleMCPFinger
        default:
            return .unknown
        }
    }
    
    func qJointName(fromBodyJointName visionBodyJointName: VNHumanBodyPoseObservation.JointName) -> QJointName {
        switch visionBodyJointName {
        case .nose:
            return .nose
        case .neck:
            return .neck
        case .rightEye:
            return .rightEye
        case .rightEar:
            return .rightEar
        case .rightShoulder:
            return .rightShoulder
        case .rightElbow:
            return .rightElbow
        case .rightWrist:
            return .rightWrist
        case .rightHip:
            return .rightHip
        case .rightKnee:
            return .rightKnee
        case .rightAnkle:
            return .rightAnkle
        case .root:
            return .root
        case .leftAnkle:
            return .leftAnkle
        case .leftKnee:
            return .leftKnee
        case .leftHip:
            return .leftHip
        case .leftWrist:
            return .leftWrist
        case .leftElbow:
            return .leftElbow
        case .leftShoulder:
            return .leftShoulder
        case .leftEar:
            return .leftEar
        case .leftEye:
            return .leftEye
        default:
            return .unknown
        }
    }
    
    func qJointRawValue(_ jointName: QJointName) -> String {
        switch jointName {
        case .nose:
            return "nose"
        case .neck:
            return "neck"
        case .rightEye:
            return "right_eye"
        case .rightEar:
            return "right_ear"
        case .rightShoulder:
            return "right_shoulder"
        case .rightElbow:
            return "right_elbow"
        case .rightWrist:
            return "right_wrist"
        case .rightIndexTipFinger:
            return "right_index_finger"
        case .rightIndexMCPFinger:
            return "right_index_mcp_finger"
        case .rightMiddleTipFinger:
            return "right_middle_finger"
        case .rightMiddleMCPFinger:
            return "right_middle_mcp_finger"
        case .rightHip:
            return "right_hip"
        case .rightKnee:
            return "right_knee"
        case .rightAnkle:
            return "right_ankle"
        case .root:
            return "root"
        case .leftAnkle:
            return "left_ankle"
        case .leftKnee:
            return "left_knee"
        case .leftHip:
            return "left_hip"
        case .leftMiddleMCPFinger:
            return "left_middle_mcp_finger"
        case .leftMiddleTipFinger:
            return "left_middle_finger"
        case .leftIndexTipFinger:
            return "left_index_finger"
        case .leftIndexMCPFinger:
            return "left_index_mcp_finger"
        case .leftWrist:
            return "left_wrist"
        case .leftElbow:
            return "left_elbow"
        case .leftShoulder:
            return "left_shoulder"
        case .leftEar:
            return "left_ear"
        case .leftEye:
            return "left_eye"
        case .unknown:
            return "unknown"
        }
    }
    
    func visionToImagePoint(_ point: VNRecognizedPoint, image: UIImage) -> CGPoint {
        let imagePoint = VNImagePointForNormalizedPoint(point.location,
                                                        Int(image.size.width),
                                                        Int(image.size.height))
        
        // Invert y-coordinate to match UIKit's coordinate system
        let invertedY = image.size.height - imagePoint.y
        return CGPoint(x: imagePoint.x, y: invertedY)
    }
}
