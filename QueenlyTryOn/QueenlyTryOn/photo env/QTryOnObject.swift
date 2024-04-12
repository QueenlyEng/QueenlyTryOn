//
//  QTryOnObject.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/5/24.
//

import UIKit

class QTryOnObject: UIImageView {
    
    let item: QItem
    
    var position: CGPoint {
        return frame.origin
    }
    
    var size: CGSize {
        return frame.size
    }
    
    var scaleMultiplier: CGFloat = .zero
    var verticalScaleMultiplier: CGFloat = .zero
    var positionOffset: CGPoint = .zero
    var rotationOffset: CGFloat = .zero
    var isMirrored: Bool = false {
        didSet {
            
        }
    }
    
    var measurement: QItemPhotoMeasurement = QItemPhotoMeasurement()
    
    var initialPositionAtInteraction: CGPoint? = nil
    var initialSizeAtInteraction: CGSize? = nil
    var initialRotationAtInteraction: CGFloat? = nil
    
    var defaultPosition: CGPoint = .zero
    var defaultSize: CGSize = .zero
    var defaultRotation: CGFloat = .zero
    var defaultImage: UIImage? = nil
    var mirroredImage: UIImage? = nil
    
    var minWidth: CGFloat {
        return defaultSize.width * 0.4
    }
    var maxWidth: CGFloat {
        return defaultSize.width * 4
    }
    
    init(item: QItem) {
        self.item = item
        super.init(frame: .zero)
        contentMode = .scaleToFill
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        scaleMultiplier = .zero
        verticalScaleMultiplier = .zero
        positionOffset = .zero
        rotationOffset = .zero
        isMirrored = false
    }
    
    func updatePosition(x: CGFloat, y: CGFloat) {
        frame.origin.x = x
        frame.origin.y = y
    }
    
    func updateSize(width: CGFloat, height: CGFloat) {
        frame.size.width = min(maxWidth, max(minWidth, width))
        frame.size.height = height
    }
    
    func updateImage() {
        let rotatingImage = isMirrored ? mirroredImage : defaultImage
        image = rotatingImage?.rotated(by: -rotationOffset)
    }
    
    func configDefault(image: UIImage?, position: CGPoint, size: CGSize, rotation: CGFloat = .zero) {
        self.image = image
        defaultImage = image
        mirroredImage = image?.flippedHorizontally()
        defaultPosition = position
        defaultSize = size
        defaultRotation = rotation
        setToDefault()
    }
    
    func setToDefault() {
        frame = CGRect(origin: defaultPosition, size: defaultSize)
        image = defaultImage
    }
}
