//
//  QTryOnPhotoResultViewController.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/4/24.
//

import UIKit
import Photos

class QTryOnPhotoResultViewController: QueenlyViewController {
    
    var moreTryOnProductIds: [String] = []
    
    fileprivate let tryOnUtil = QTryOnUtil()
    fileprivate let photoTryOnUtil = QPhotoTryOnUtil()
    
    fileprivate let userImage: UIImage
    
    fileprivate var currentTryOnSet: QTryOnSet = QTryOnSet()
    fileprivate var productIdToObj: [String: QTryOnObject] = [:]
    fileprivate var lastProductId: String {
        return currentTryOnSet.lastAddedItem?.productId ?? ""
    }
    
    fileprivate var isProcessingItem: Bool = true
    fileprivate var userBodyPoints: [QJointName: CGPoint] = [:]
    fileprivate var itemBodyPoints: [QJointName: CGPoint] = [:]
    
    fileprivate var minScaleValue: CGFloat {
        return photoTryOnUtil.minScaleValue
    }
    fileprivate var maxScaleValue: CGFloat {
        return photoTryOnUtil.maxScaleValue
    }
    fileprivate var scaleValue: CGFloat {
        return photoTryOnUtil.scaleValue
    }
    fileprivate var posOffsetValue: CGFloat {
        return photoTryOnUtil.posOffsetValue
    }
    fileprivate var rotationValue: CGFloat {
        return photoTryOnUtil.rotationValue
    }
    
    fileprivate var interactingPositionObject: Any? = nil
    fileprivate var interactingScalingObject: Any? = nil
    fileprivate var interactingRotationObject: Any? = nil
    
    fileprivate let edgeToolsSpacing: CGFloat = 10
    fileprivate let bottomVerticalToolsSpacing: CGFloat = 20
    
    fileprivate let defaultIconWidth: CGFloat = 36
    fileprivate var iconDimension: CGSize {
        let dimension = min(defaultIconWidth, ceil(contentBounds.size.height * 0.045))
        return CGSize(width: dimension, height: dimension)
    }
    
    fileprivate let defaultArrowWidth: CGFloat = 34
    fileprivate var arrowDimension: CGSize {
        let dimension = min(defaultArrowWidth, ceil(contentBounds.size.height * 0.04))
        return CGSize(width: dimension, height: dimension)
    }
    
    fileprivate var sliderDimension: CGSize {
        let dimension = contentBounds.size.height * 0.2
        return CGSize(width: dimension, height: dimension)
    }
    
    fileprivate lazy var rightToolsVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mirrorFlipToolButton, leftTiltToolButton, rightTiltToolButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = bottomVerticalToolsSpacing
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins.bottom = bottomVerticalToolsSpacing
        stack.directionalLayoutMargins.trailing = edgeToolsSpacing
        return stack
    }()
    
    fileprivate lazy var mirrorFlipToolButton: QTryOnToolButton = {
        let button = QTryOnToolButton(title: "Mirror flip",
                                      icon:  imageHandler.image(named: "mirror_icon"),
                                      iconDimension: iconDimension)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var leftTiltToolButton: QTryOnToolButton = {
        let button = QTryOnToolButton(title: "Tilt left",
                                      icon:  imageHandler.image(named: "rotate_left_icon"),
                                      iconDimension: iconDimension)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var rightTiltToolButton: QTryOnToolButton = {
        let button = QTryOnToolButton(title: "Tilt right",
                                      icon:  imageHandler.image(named: "rotate_right_icon"),
                                      iconDimension: iconDimension)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var leftToolsVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [resetToolButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = bottomVerticalToolsSpacing
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins.bottom = bottomVerticalToolsSpacing
        return stack
    }()
    
    fileprivate lazy var resetToolButton: QTryOnToolButton = {
        let button = QTryOnToolButton(title: "Reset all",
                                      icon:  imageHandler.image(named: "reset_icon"),
                                      iconDimension: iconDimension)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var resizeToolStack: QTryOnResizeToolStack = {
        let scaleMultiplier = productIdToObj[lastProductId]?.scaleMultiplier ?? .zero
        let toolStack = QTryOnResizeToolStack(currentValue: scaleMultiplier,
                                              minScaleValue: minScaleValue,
                                              maxScaleValue: maxScaleValue,
                                              sliderDimension: sliderDimension)
        toolStack.translatesAutoresizingMaskIntoConstraints = false
        toolStack.directionalLayoutMargins.bottom = bottomVerticalToolsSpacing
        return toolStack
    }()
    
    fileprivate lazy var repositionToolStack: QTryOnRepositionToolStack = {
        let toolStack = QTryOnRepositionToolStack(arrowDimension: arrowDimension)
        toolStack.translatesAutoresizingMaskIntoConstraints = false
        toolStack.directionalLayoutMargins.bottom = bottomVerticalToolsSpacing
        toolStack.directionalLayoutMargins.leading = edgeToolsSpacing
        return toolStack
    }()
    
    fileprivate lazy var savePhotoButton: QueenlyButton = {
        let button = QueenlyButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = QueenlyTryOn.brandColor
        button.setTitle("Save Photo", font: .systemFont(ofSize: 16, weight: .medium))
        button.setIcon(imageHandler.image(named: "download_icon"), dimension: CGSize(width: 18, height: 18))
        button.buttonTintColor = .white
        button.contentSpacing = 10
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.widthAnchor.constraint(equalToConstant: contentBounds.size.width * 0.8).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    fileprivate lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = userImage
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    fileprivate lazy var suggestedItemsCarousel: QTryOnSuggestedItemCarousel = {
        let carousel = QTryOnSuggestedItemCarousel(productIds: moreTryOnProductIds)
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.currentTryOnIds = currentTryOnSet.allProductIds
        carousel.minWidth = view.frame.size.width * 0.6
        carousel.maxWidth = view.frame.size.width * 0.9
        carousel.delegate = self
        return carousel
    }()
    
    // MARK: - Init
    init(tryOnSet: QTryOnSet, userImage: UIImage) {
        self.currentTryOnSet = tryOnSet
        self.userImage = userImage
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setupButtonActions()
        processItem()
    }
    
    // MARK: - Layout
    fileprivate func layout() {
        contentView.addSubview(userImageView)
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        renderSpinner()
    }
    
    fileprivate func layoutTools() {
        contentView.addSubview(leftToolsVStack)
        contentView.addSubview(repositionToolStack)
        contentView.addSubview(resizeToolStack)
        contentView.addSubview(rightToolsVStack)
        contentView.addSubview(savePhotoButton)
        contentView.addSubview(suggestedItemsCarousel)
        NSLayoutConstraint.activate([
            suggestedItemsCarousel.heightAnchor.constraint(equalToConstant: 100),
            suggestedItemsCarousel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            suggestedItemsCarousel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            rightToolsVStack.bottomAnchor.constraint(equalTo: savePhotoButton.topAnchor),
            rightToolsVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            resizeToolStack.bottomAnchor.constraint(equalTo: savePhotoButton.topAnchor),
            resizeToolStack.scaleSlider.centerXAnchor.constraint(equalTo: repositionToolStack.arrowUpButton.centerXAnchor),
            
            repositionToolStack.bottomAnchor.constraint(equalTo: resizeToolStack.topAnchor),
            repositionToolStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            leftToolsVStack.bottomAnchor.constraint(equalTo: repositionToolStack.topAnchor),
            leftToolsVStack.centerXAnchor.constraint(equalTo: resizeToolStack.centerXAnchor),
            
            savePhotoButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -bottomVerticalToolsSpacing),
            savePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    
    fileprivate func processItem() {
        tryOnUtil.detectPose(on: userImage) { bodyPoints in
            DispatchQueue.main.async {
                for (jointName, point) in bodyPoints {
                    self.userBodyPoints[jointName] = self.userImage.convertPoint(point, to: self.userImageView)
                }
                self.renderItems()
                self.layoutTools()
            }
        }
    }
    
    fileprivate func renderItems() {
        for i in 0..<currentTryOnSet.allItems.count {
            let item = currentTryOnSet.allItems[i]
            if productIdToObj[item.productId] == nil {
                renderItem(item, at: i)
            }
        }
    }
    
    fileprivate func renderItem(_ item: QItem, at viewIndex: Int) {
        guard let tryOnImage = item.tryOnImage else { return }
        
        let hasRenderedObj = productIdToObj[item.productId] != nil
        let itemObj = productIdToObj[item.productId] ?? QTryOnObject(item: item)
        if !hasRenderedObj {
            addGestures(on: itemObj)
            productIdToObj[item.productId] = itemObj
            userImageView.insertSubview(itemObj, at: viewIndex)
        }
        
        photoTryOnUtil.fetchPhotoMeasurement(item: item, userBodyPoints: userBodyPoints) { [weak self] measurement, error in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                if let measurement = measurement {
                    itemObj.measurement = measurement
                    let itemWidth: CGFloat = measurement.width
                    let itemHeight: CGFloat = measurement.height
                    let defaultSize = CGSize(width: itemWidth, height: itemHeight)
                    let defaultPosition = CGPoint(x: measurement.x, y: measurement.y)
                    itemObj.configDefault(image: tryOnImage,
                                          position: defaultPosition,
                                          size: defaultSize)
                } else {
                    let dressRatio = tryOnImage.size.width / tryOnImage.size.height
                    let width = strongSelf.userImageView.frame.size.width * 0.5
                    let height = width / dressRatio
                    let defaultSize = CGSize(width: width, height: height)
                    let measurement = QItemPhotoMeasurement(width: width,
                                                            height: height,
                                                            x: strongSelf.userImageView.frame.midX - defaultSize.width / 2,
                                                            y: strongSelf.userImageView.frame.midY - defaultSize.height / 2)
                    itemObj.measurement = measurement
                    itemObj.configDefault(image: tryOnImage,
                                          position: CGPoint(x: measurement.x, y: measurement.y),
                                          size: defaultSize)
                    strongSelf.renderAlertPopUp(title: "No body detected!",
                                                message: "Please try with a different photo. Make sure your whole body is showing for a better fit.",
                                                type: .error,
                                                duration: 3.0)
                }
                strongSelf.removeSpinner()
            }
        }
    }
    
    fileprivate func createTryOnObject(item: QItem) -> QTryOnObject {
        let object = QTryOnObject(item: item)
        object.contentMode = .scaleToFill
        object.isUserInteractionEnabled = true
        return object
    }
    
    fileprivate func removeTryOnObjects() {
        for (id, obj) in productIdToObj {
            if !currentTryOnSet.allProductIds.contains(id) {
                obj.removeFromSuperview()
                productIdToObj[id] = nil
            }
        }
    }
}

// MARK: - Tools Action
extension QTryOnPhotoResultViewController {
    
    fileprivate func setupButtonActions() {
        resetToolButton.addAction { [weak self] in
            self?.onResetButton()
        }
        mirrorFlipToolButton.addAction { [weak self] in
            self?.onMirrorFlipButton()
        }
        leftTiltToolButton.addAction { [weak self] in
            self?.onLeftTiltButton()
        }
        rightTiltToolButton.addAction { [weak self] in
            self?.onRightTiltButton()
        }
        repositionToolStack.arrowUpButton.addAction { [weak self] in
            self?.onArrowUpButton()
        }
        repositionToolStack.arrowDownButton.addAction { [weak self] in
            self?.onArrowDownButton()
        }
        repositionToolStack.arrowLeftButton.addAction { [weak self] in
            self?.onArrowLeftButton()
        }
        repositionToolStack.arrowRightButton.addAction { [weak self] in
            self?.onArrowRightButton()
        }
        resizeToolStack.scaleUpButton.addAction { [weak self] in
            self?.onScaleUpButton()
        }
        resizeToolStack.scaleDownButton.addAction { [weak self] in
            self?.onScaleDownButton()
        }
        resizeToolStack.scaleSlider.addTarget(self, action: #selector(rangeSliderValueDidChange(_:)), for: .valueChanged)
        savePhotoButton.addAction { [weak self] in
            self?.onSavePhotoButton()
        }
    }
    
    fileprivate func onResetButton() {
        for (_, obj) in productIdToObj {
            obj.reset()
            obj.setToDefault()
        }
        resizeToolStack.currentValue = .zero
    }
    
    fileprivate func onMirrorFlipButton() {
        if let obj = productIdToObj[lastProductId] {
            obj.isMirrored.toggle()
            obj.updateImage()
        }
    }
    
    fileprivate func onLeftTiltButton() {
        if let obj = productIdToObj[lastProductId] {
            obj.rotationOffset += rotationValue
            obj.updateImage()
        }
    }
    
    fileprivate func onRightTiltButton() {
        if let obj = productIdToObj[lastProductId] {
            obj.rotationOffset -= rotationValue
            obj.updateImage()
        }
    }
    
    fileprivate func onArrowUpButton() {
        if let obj = productIdToObj[lastProductId] {
            obj.positionOffset.y += posOffsetValue
            updatePosition(of: obj)
        }
    }
    
    fileprivate func onArrowDownButton() {
        if let obj = productIdToObj[lastProductId] {
            obj.positionOffset.y -= posOffsetValue
            updatePosition(of: obj)
        }
    }
    
    fileprivate func onArrowRightButton() {
        if let obj = productIdToObj[lastProductId] {
            obj.positionOffset.x += posOffsetValue
            updatePosition(of: obj)
        }
    }
    
    fileprivate func onArrowLeftButton() {
        if let obj = productIdToObj[lastProductId] {
            obj.positionOffset.x -= posOffsetValue
            updatePosition(of: obj)
        }
    }
    
    fileprivate func updatePosition(of obj: QTryOnObject) {
        obj.updatePosition(x: obj.defaultPosition.x + obj.positionOffset.x,
                           y: obj.defaultPosition.y - obj.positionOffset.y)
    }
    
    fileprivate func onScaleUpButton() {
        if let obj = productIdToObj[lastProductId] {
            obj.scaleMultiplier = min(obj.scaleMultiplier + 1, maxScaleValue)
            resizeToolStack.currentValue = obj.scaleMultiplier
            updateSize(of: obj)
        }
    }
    
    fileprivate func onScaleDownButton() {
        if let obj = productIdToObj[lastProductId] {
            obj.scaleMultiplier = max(obj.scaleMultiplier - 1, minScaleValue)
            resizeToolStack.currentValue = obj.scaleMultiplier
            updateSize(of: obj)
        }
    }
    
    fileprivate func setScaleSlider(_ newValue: CGFloat? = nil) {
        if let obj = productIdToObj[lastProductId] {
            if let newValue = newValue {
                obj.scaleMultiplier = newValue
                updateSize(of: obj)
            } else {
                resizeToolStack.currentValue = obj.scaleMultiplier
            }
        }
    }
    
    @objc
    fileprivate func rangeSliderValueDidChange(_ sender: UISlider) {
        setScaleSlider(CGFloat(sender.value))
    }
    
    fileprivate func updateSize(of obj: QTryOnObject) {
        let height = photoTryOnUtil.getItemPhotoHeight(item: obj.item, measurement: obj.measurement, verticalScaleMultiplier: obj.verticalScaleMultiplier)
        obj.updateSize(width: obj.defaultSize.width + (scaleValue * obj.scaleMultiplier),
                       height: height)
        resizeToolStack.currentValue = obj.scaleMultiplier
    }
    
    fileprivate func onSavePhotoButton() {
        impactFeedbackGenerator.impactOccurred()
        let scale = UIScreen.main.scale
        let screenshotImage = userImageView.screenshot(scale: scale).cropAlpha().resultImage
        let topHeader = headerView.getTitleView().screenshot(scale: scale)
        let bottomHeader = headerView.getTitleView().screenshot(scale: scale)
        let watermarkRatio: CGFloat = topHeader.size.width / topHeader.size.height
        let watermarkWidth: CGFloat = screenshotImage.size.width * 0.65
        let watermarkHeight: CGFloat = watermarkWidth / watermarkRatio
        let borderHeight: CGFloat = watermarkHeight + 64
        
        let ratio: CGFloat = screenshotImage.size.width / screenshotImage.size.height
        let newWidth: CGFloat = 1290
        let newHeight: CGFloat = newWidth / ratio
        let screenshotSize = CGSize(width: newWidth,
                                    height: newHeight + (borderHeight * 2))
        
        UIGraphicsBeginImageContext(screenshotSize)
        screenshotImage.draw(in: CGRect(origin: CGPoint(x: 0, y: borderHeight), size: CGSize(width: newWidth, height: newHeight)))
        UIColor.white.setFill()
        let topRectangle = CGRect(x: 0, y: 0, width: screenshotSize.width, height: borderHeight)
        let bottomRectangle = CGRect(x: 0, y: screenshotSize.height - borderHeight, width: screenshotSize.width, height: borderHeight)
        UIRectFill(topRectangle)
        UIRectFill(bottomRectangle)
        topHeader.draw(in: CGRect(x: screenshotSize.width / 2 - watermarkWidth / 2,
                                  y: borderHeight / 2 - watermarkHeight / 2,
                                  width: watermarkWidth,
                                  height: watermarkHeight))
        bottomHeader.draw(in: CGRect(x: screenshotSize.width / 2 - watermarkWidth / 2,
                                     y: screenshotSize.height - (watermarkHeight / 2) - (borderHeight / 2),
                                     width: watermarkWidth,
                                     height: watermarkHeight))
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext() ?? screenshotImage
        UIGraphicsEndImageContext()
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: snapshotImage)
        }) { success, _ in
            DispatchQueue.main.async { [weak self] in
                if success {
                    self?.renderAlertPopUp(title: "Photo saved", type: .success)
                } else {
                    self?.renderAlertPopUp(title: "An error occured!", type: .error)
                }
            }
        }
    }
    
}

// MARK: - Gestures
extension QTryOnPhotoResultViewController {
    fileprivate func addGestures(on object: UIView) {
        object.addGestureRecognizer(createPanGesture())
        object.addGestureRecognizer(createPinchGesture())
        object.addGestureRecognizer(createRotationGesture())
    }
    
    fileprivate func createPanGesture() -> UIPanGestureRecognizer {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        return panGesture
    }
    
    fileprivate func createPinchGesture() -> UIPinchGestureRecognizer {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        return pinchGesture
    }
    
    fileprivate func createRotationGesture() -> UIRotationGestureRecognizer {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        rotationGesture.delegate = self
        return rotationGesture
    }
    
    fileprivate func objectInteracting(with gesture: UIGestureRecognizer) -> QTryOnObject? {
        if let tappedView = gesture.view as? QTryOnObject {
            return tappedView
        }
        return nil
    }
    
    @objc
    fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let object = objectInteracting(with: gesture) {
                interactingPositionObject = object
                object.initialPositionAtInteraction = object.position
            }
        case .changed:
            if let interactingObject = interactingPositionObject as? QTryOnObject,
               let initialPosition = interactingObject.initialPositionAtInteraction {
                let translation = gesture.translation(in: contentView)
                interactingObject.updatePosition(x: initialPosition.x + translation.x,
                                                 y: initialPosition.y + translation.y)
            }
        default:
            if let interactingObject = interactingPositionObject as? QTryOnObject,
               let initialPosition = interactingObject.initialPositionAtInteraction {
                interactingObject.positionOffset.x += (interactingObject.position.x - initialPosition.x)
                interactingObject.positionOffset.y -= (interactingObject.position.y - initialPosition.y)
            }
            interactingPositionObject = nil
        }
    }
    
    @objc
    fileprivate func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let object = objectInteracting(with: gesture) {
                interactingScalingObject = object
                object.initialSizeAtInteraction = object.size
            }
        case .changed:
            if let interactingObject = interactingScalingObject as? QTryOnObject,
               let initialObjectSize = interactingObject.initialSizeAtInteraction,
               gesture.numberOfTouches >= 2 {
                var newWidth = initialObjectSize.width
                var newHeight = initialObjectSize.height
                if gesture.direction == .vertical {
                    newHeight = initialObjectSize.height * gesture.scale
                } else {
                    newWidth = initialObjectSize.width * gesture.scale
                    newHeight = photoTryOnUtil.getItemPhotoHeight(item: interactingObject.item, measurement: interactingObject.measurement, verticalScaleMultiplier: interactingObject.verticalScaleMultiplier)
                    
                    
                }
                interactingObject.updateSize(width: newWidth,
                                             height: newHeight)
            }
        default:
            if let interactingObject = interactingScalingObject as? QTryOnObject,
               let initialObjectSize = interactingObject.initialSizeAtInteraction {
                interactingObject.scaleMultiplier += (interactingObject.size.width - initialObjectSize.width) / scaleValue
                interactingObject.verticalScaleMultiplier += (interactingObject.size.height - initialObjectSize.height) / scaleValue
                resizeToolStack.currentValue = interactingObject.scaleMultiplier
            }
            interactingScalingObject = nil
        }
    }
    
    @objc
    fileprivate func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let object = objectInteracting(with: gesture) {
                interactingRotationObject = object
                object.initialRotationAtInteraction = object.rotationOffset
            }
        case .changed:
            if let interactingObject = interactingRotationObject as? QTryOnObject,
               let initialObjectRotation = interactingObject.initialRotationAtInteraction {
                let rotation = gesture.rotation - CGFloat(initialObjectRotation)
                interactingObject.rotationOffset = -rotation
                interactingObject.updateImage()
            }
        default:
            interactingRotationObject = nil
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension QTryOnPhotoResultViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - QTryOnSuggestedItemCarouselDelegate
extension QTryOnPhotoResultViewController: QTryOnSuggestedItemCarouselDelegate {
    func suggestedItemCarousel(_ carousel: QTryOnSuggestedItemCarousel, didSelect item: QItem) {
        if !currentTryOnSet.allProductIds.contains(item.productId) {
            var item = item
            renderSpinner()
            imageHandler.loadImage(fromUrl: item.tryOnImageUrl) { [weak self] image in
                DispatchQueue.main.async {
                    if let image = image {
                        let croppedImage = image.cropAlpha()
                        item.tryOnImage = croppedImage.resultImage
                        self?.currentTryOnSet.addItem(item)
                        self?.removeSpinner()
                        self?.didUpdateCurrentTryOnSet()
                    }
                }
            }
        }
    }
    
    func suggestedItemCarousel(_ carousel: QTryOnSuggestedItemCarousel, didDeselect item: QItem) {
        currentTryOnSet.removeItem(item)
        didUpdateCurrentTryOnSet()
    }
    
    func didUpdateCurrentTryOnSet() {
        removeTryOnObjects()
        renderItems()
        setScaleSlider()
        suggestedItemsCarousel.currentTryOnIds = currentTryOnSet.allProductIds
    }
}
