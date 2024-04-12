//
//  QPhotoTryOnUtil.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/5/24.
//

import UIKit

struct QPhotoTryOnUtil {
    
    private let api = QAPI()
    
    let minScaleValue: CGFloat = -50
    let maxScaleValue: CGFloat = 50
    let scaleValue: CGFloat = 5
    let posOffsetValue: CGFloat = 2
    let rotationValue: CGFloat = .pi * 0.01
    
    private func parseItemPhotoMeasurementJSON(_ data: Data?) -> (measurement: QItemPhotoMeasurement?, error: QAPIError?) {
        guard let data = data else { return (nil, nil) }
        do {
            let decoder = JSONDecoder()
            let itemMeasurement = try decoder.decode(QItemPhotoMeasurement.self, from: data)
            return (itemMeasurement, nil)
        } catch {
            return (nil, api.parseError(data))
        }
    }
    
    func fetchPhotoMeasurement(item: QItem,
                               userBodyPoints: [QJointName: CGPoint],
                               completion: @escaping (_ measurement: QItemPhotoMeasurement?, _ error: QAPIError?) -> ()) {
        
        guard let leftShoulder = userBodyPoints[.leftShoulder],
              let rightShoulder = userBodyPoints[.rightShoulder],
              let root = userBodyPoints[.root] else {
            completion(nil, nil)
            return
        }
        let shoulderWidth = leftShoulder.distance(from: rightShoulder)
        
        var hipWidth: CGFloat = .zero
        var torsoLength: CGFloat = .zero
        var legLength: CGFloat = .zero
        var fullBodyLength: CGFloat = .zero
        
        if let rightHip = userBodyPoints[.rightHip],
           let leftHip = userBodyPoints[.leftHip],
           let ankle = userBodyPoints[.rightAnkle] ?? userBodyPoints[.leftAnkle] {
            hipWidth = rightHip.distance(from: leftHip)
            torsoLength = rightShoulder.distance(from: rightHip)
            legLength = rightHip.distance(from: ankle)
            fullBodyLength = rightShoulder.distance(from: ankle)
        }
        let urlString = "https://us-central1-queenly-alpha.cloudfunctions.net/publicvto-photopositioningdata?styleTags=\(item.styleTagsToEncodedJSON())&neckline=\(item.neckline)&sleeveLength=\(item.sleeveLength)&waistPosition=\(item.waistPosition)&shoulderWidth=\(shoulderWidth)&hipWidth=\(hipWidth)&torsoLength=\(torsoLength)&legLength=\(legLength)&fullBodyLength=\(fullBodyLength)&rightShoulderY=\(rightShoulder.y)&rootX=\(root.x)&rootY=\(root.y)"
        api.loadData(fromUrlString: urlString) { data in
            let res = parseItemPhotoMeasurementJSON(data)
            completion(res.measurement, res.error)
        }
    }
    
    func getItemPhotoHeight(item: QItem,
                            measurement: QItemPhotoMeasurement,
                            verticalScaleMultiplier: CGFloat) -> CGFloat {
        return measurement.height + (scaleValue * verticalScaleMultiplier)
    }
}
