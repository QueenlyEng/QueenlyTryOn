//
//  QueenlyARTryOnViewController.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/1/24.
//

import UIKit
import ARKit
import Photos

fileprivate enum QPopUpTag: Int {
    case disclaimer, tutorial
}

public class QueenlyARTryOnViewController: QueenlyViewController {
    
    fileprivate let itemManager = QItemManager()
    fileprivate let tryOnUtil = QTryOnUtil()
    fileprivate let arTryOnUtil = QARTryOnUtil()
    
    fileprivate let productTitle: String
    fileprivate let color: String
    fileprivate var item: QItem?
    fileprivate var productIdToNode: [String: QTryOnNode] = [:]
    fileprivate var mainProductId: String {
        return item?.productId ?? ""
    }
    
    fileprivate let bodyTrackingConfig = ARBodyTrackingConfiguration()
    fileprivate let sessionOptions: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
    
    fileprivate var didFetchMeasurements: Bool = false
    
    fileprivate var isProcessingItem: Bool = true
    fileprivate var isSessionSetupComplete: Bool = false
    fileprivate var isProcessingUserBodyData: Bool = false
    fileprivate var userBodyPoints: [QJointName: CGPoint] = [:]
    fileprivate var jointPositions: [ARSkeleton.JointName: SCNVector3] = [:] {
        didSet {
            if !isInteractingWithNode {
                renderItem()
            }
        }
    }
    
    fileprivate let minScaleValue: CGFloat = -30
    fileprivate let maxScaleValue: CGFloat = 40
    fileprivate let posOffsetValue: CGFloat = 0.025
    fileprivate let rotationValue: CGFloat = .pi * 0.01
    
    fileprivate var interactingPositionNode: Any? = nil
    fileprivate var interactingScalingNode: Any? = nil
    fileprivate var interactingRotationNode: Any? = nil
    
    fileprivate var isInteractingWithNode: Bool {
        return interactingPositionNode != nil || interactingScalingNode != nil || interactingRotationNode != nil
    }
    
    fileprivate var userPoseDetectionTimer: Timer?
    
    fileprivate var bodyDetectionTimer: Timer?
    fileprivate var isBodyDetected: Bool {
        return sceneView.session.currentFrame?.detectedBody != nil && jointPositions[.root] != nil
    }
    fileprivate var isBodyGuideShowing: Bool = false {
        didSet {
            bodyGuideView.isHidden = !isBodyGuideShowing
        }
    }
    
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
    
    fileprivate lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.automaticallyUpdatesLighting = true
        return sceneView
    }()
    
    fileprivate lazy var rightToolsVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [leftTiltToolButton, rightTiltToolButton])
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
        let stack = UIStackView(arrangedSubviews: [resetToolButton, resizeToolStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = bottomVerticalToolsSpacing
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins.bottom = bottomVerticalToolsSpacing
        stack.directionalLayoutMargins.leading = edgeToolsSpacing
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
        let scaleMultiplier = productIdToNode[mainProductId]?.scaleMultiplier ?? .zero
        let toolStack = QTryOnResizeToolStack(currentValue: scaleMultiplier,
                                              minScaleValue: minScaleValue,
                                              maxScaleValue: maxScaleValue,
                                              sliderDimension: sliderDimension)
        toolStack.translatesAutoresizingMaskIntoConstraints = false
        return toolStack
    }()
    
    fileprivate lazy var repositionToolStack: QTryOnRepositionToolStack = {
        let toolStack = QTryOnRepositionToolStack(arrowDimension: arrowDimension)
        toolStack.translatesAutoresizingMaskIntoConstraints = false
        toolStack.directionalLayoutMargins.bottom = bottomVerticalToolsSpacing
        toolStack.directionalLayoutMargins.leading = edgeToolsSpacing
        return toolStack
    }()
    
    fileprivate lazy var snapshotButton: QueenlyIconButton = {
        let dimension: CGFloat = min(80, ceil(contentBounds.size.width * 0.18))
        let icon = UIImage(named: "record_icon")?.withRenderingMode(.alwaysTemplate)
        let button = QueenlyIconButton(icon: icon)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.iconTintColor = .white.withAlphaComponent(0.9)
        button.widthAnchor.constraint(equalToConstant: dimension).isActive = true
        button.heightAnchor.constraint(equalToConstant: dimension).isActive = true
        return button
    }()
    
    fileprivate lazy var photoUploadButton: QueenlyIconButton = {
        let width: CGFloat = min(50, ceil(contentBounds.size.width * 0.125))
        let height: CGFloat = min(55, ceil(width * 1.08))
        let button = QueenlyIconButton(icon: imageHandler.image(named: "gallery_icon"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.iconContentMode = .scaleAspectFill
        button.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
        button.heightAnchor.constraint(lessThanOrEqualToConstant: height).isActive = true
        return button
    }()
    
    fileprivate lazy var bodyGuideView: QTryOnBodyGuideView = {
        let guide = QTryOnBodyGuideView()
        guide.translatesAutoresizingMaskIntoConstraints = false
        guide.isHidden = !isBodyGuideShowing
        return guide
    }()
    
    // MARK: - Init
    init(productTitle: String, color: String) {
        self.productTitle = productTitle
        self.color = color
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setup()
        setupButtonActions()
        addGestures()
        processItem()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARBodyTrackingConfiguration.isSupported else {
            renderAlertPopUp(message: "This feature is not supported on this device",
                             type: .error,
                             shouldDismiss: true)
            return
        }
        sceneView.session.run(bodyTrackingConfig, options: sessionOptions)
        sceneView.session.delegate = self
        configLastPhotoFromLibrary()
        runTimers()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bodyDetectionTimer?.invalidate()
        userPoseDetectionTimer?.invalidate()
        sceneView.session.pause()
    }
    
    // MARK: - Set up & Layout
    fileprivate func setup() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        requestCameraVideoAccess { authorized in
            DispatchQueue.main.async { [weak self] in
                if authorized {
                    self?.renderPopUps()
                } else {
                    self?.renderAlertPopUp(title: "Camera access denied!",
                                           message: "Camera is required to use this feature. On your device, go to Settings > \(QueenlyTryOn.account.accountName) and allow acesss to camera.",
                                           type: .error,
                                           duration: 3.0)
                    self?.removeSpinner()
                }
            }
        }
    }
    
    fileprivate func layout() {
        contentView.addSubview(sceneView)
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: contentView.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        renderSpinner()
    }
    
    fileprivate func layoutTools() {
        contentView.addSubview(leftToolsVStack)
        contentView.addSubview(repositionToolStack)
        contentView.addSubview(rightToolsVStack)
        contentView.addSubview(snapshotButton)
        contentView.addSubview(photoUploadButton)
        NSLayoutConstraint.activate([
            rightToolsVStack.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            rightToolsVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            repositionToolStack.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            repositionToolStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            leftToolsVStack.bottomAnchor.constraint(equalTo: repositionToolStack.topAnchor),
            leftToolsVStack.centerXAnchor.constraint(equalTo: repositionToolStack.centerXAnchor),
            
            snapshotButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -bottomVerticalToolsSpacing),
            snapshotButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            photoUploadButton.centerYAnchor.constraint(equalTo: snapshotButton.centerYAnchor),
            photoUploadButton.leadingAnchor.constraint(equalTo: snapshotButton.trailingAnchor, constant: 8),
            photoUploadButton.trailingAnchor.constraint(lessThanOrEqualTo: rightToolsVStack.leadingAnchor, constant: -8)
        ])
        
        layoutBodyGuide()
    }
    
    fileprivate func layoutBodyGuide() {
        sceneView.insertSubview(bodyGuideView, at: 0)
        NSLayoutConstraint.activate([
            bodyGuideView.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            bodyGuideView.widthAnchor.constraint(equalTo: sceneView.widthAnchor, multiplier: 0.4),
            bodyGuideView.topAnchor.constraint(greaterThanOrEqualTo: sceneView.topAnchor, constant: 16),
            bodyGuideView.bottomAnchor.constraint(equalTo: snapshotButton.topAnchor, constant: -32),
        ])
    }
    
    fileprivate func renderPopUps() {
        let maxTutorialRendering = 2
        if UserDefaults.standard.integer(forKey: key.arDisclaimerPopUpNumSeen) < maxTutorialRendering {
            renderDisclaimerPopUp()
        } else if UserDefaults.standard.integer(forKey: key.arTutorialPopUpNumSeen) < maxTutorialRendering {
            renderTutorialPopUp()
        } else if UserDefaults.standard.integer(forKey: key.arGestureTutorialPopUpNumSeen) < maxTutorialRendering {
            renderGestureTutorial()
        } else {
            layoutTools()
        }
    }
    
    fileprivate func renderDisclaimerPopUp() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "\"Virtual try-on\" is here to help you get an idea of how the item will look on you! Fit and fabric might vary in the actual product."
        label.numberOfLines = 0
        
        let popUp = QPopUpViewController(contentView: label)
        let button = QueenlyButton()
        button.buttonTintColor = QueenlyTryOn.brandColor
        button.setTitle("Got it!", font: .systemFont(ofSize: 20, weight: .medium))
        popUp.addButton(button)
        popUp.delegate = self
        popUp.tag = QPopUpTag.disclaimer.rawValue
        popUp.horizontalOffset = 50
        popUp.contentInsets = NSDirectionalEdgeInsets(top: 38, leading: 32, bottom: 32, trailing: 32)
        popUp.actionInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        present(popUp, animated: true)
        
        let numOfSeen = UserDefaults.standard.integer(forKey: key.arDisclaimerPopUpNumSeen)
        UserDefaults.standard.setValue(numOfSeen + 1, forKey: key.arDisclaimerPopUpNumSeen)
    }
    
    fileprivate func renderTutorialPopUp() {
        let iconName = "woman_mirror_icon"
        let message = "Stand in front of a full-length\nmirror for best results!"
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: iconName)
        imageView.widthAnchor.constraint(equalToConstant: 215).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 215).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .black
        label.textAlignment = .center
        label.text = message
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        
        let popUp = QPopUpViewController(contentView: stack)
        let button = QueenlyButton()
        button.buttonTintColor = QueenlyTryOn.brandColor
        button.setTitle("Let's go!", font: .systemFont(ofSize: 20, weight: .medium))
        popUp.addButton(button)
        popUp.delegate = self
        popUp.tag = QPopUpTag.tutorial.rawValue
        popUp.horizontalOffset = 42
        popUp.contentInsets = NSDirectionalEdgeInsets(top: 60, leading: 16, bottom: 8, trailing: 16)
        popUp.actionInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        present(popUp, animated: true)
        
        let numOfSeen = UserDefaults.standard.integer(forKey: key.arTutorialPopUpNumSeen)
        UserDefaults.standard.setValue(numOfSeen + 1, forKey: key.arTutorialPopUpNumSeen)
    }
    
    func renderGestureTutorial() {
        let tutorialView = QTryOnGesturesTutorialOverlayView()
        tutorialView.delegate = self
        tutorialView.render(on: contentView, duration: 3.0, delay: 0.6)
        
        let numOfSeen = UserDefaults.standard.integer(forKey: key.arGestureTutorialPopUpNumSeen)
        UserDefaults.standard.setValue(numOfSeen + 1, forKey: key.arGestureTutorialPopUpNumSeen)
    }
    
    fileprivate func runTimers() {
        runBodyDetectionTimer()
        runUserPoseDetectionTimer()
    }
    
    fileprivate func runUserPoseDetectionTimer() {
        // use vision to process image and calculate the horizontal stretch offset of dress every 10 seconds
        userPoseDetectionTimer = Timer(timeInterval: 10.0, target: self, selector: #selector(processCurrentUserBodyData), userInfo: nil, repeats: true)
        if let timer = userPoseDetectionTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    fileprivate func runBodyDetectionTimer() {
        // check if body is being detected every 2 seconds
        bodyDetectionTimer = Timer(timeInterval: 2.0, target: self, selector: #selector(checkUserBodyDetection), userInfo: nil, repeats: true)
        if let timer = bodyDetectionTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    
    fileprivate func requestCameraVideoAccess(completion: @escaping (_ authorized: Bool) -> ()) {
        let dispatchGroup = DispatchGroup()
        var videoAuthAccess = AVCaptureDevice.authorizationStatus(for: .video)
        if videoAuthAccess == .notDetermined {
            dispatchGroup.enter()
            AVCaptureDevice.requestAccess(for: .video) { videoGranted in
                videoAuthAccess = videoGranted ? .authorized : .denied
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(videoAuthAccess == .authorized)
        }
    }
    
    fileprivate func requestLibraryAccess(completion: @escaping (_ authorized: Bool) -> ()) {
        let authAccess = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch authAccess {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                self?.configLastPhotoFromLibrary()
                completion(status == .authorized)
            }
        default:
            completion(authAccess == .authorized)
        }
    }
    
    fileprivate func configLastPhotoFromLibrary() {
        guard PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized else { return }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if let lastAsset = fetchResult.firstObject {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            
            PHImageManager.default().requestImage(for: lastAsset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions) { (image, _) in
                if let lastImage = image {
                    DispatchQueue.main.async { [weak self] in
                        self?.photoUploadButton.icon = lastImage
                        self?.photoUploadButton.layer.borderWidth = 2
                        self?.photoUploadButton.layer.borderColor = UIColor.white.cgColor
                    }
                }
            }
        }
    }
    
    fileprivate func processItem() {
        var qError: QAPIError? = nil
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        itemManager.fetchItem(productTitle: productTitle) { [weak self] item, error in
            if let item = item {
                self?.item = item
                
                self?.imageHandler.loadImage(fromUrl: item.tryOnImageUrl) { image in
                    if let image = image {
                        let croppedImage = image.cropAlpha()
                        self?.item?.tryOnImage = croppedImage.resultImage
                    }
                    dispatchGroup.leave()
                }
            } else {
                qError = error
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isProcessingItem = false
            if strongSelf.isSessionSetupComplete {
                strongSelf.removeSpinner()
            }
            if let qError = qError, qError.type == .invalidAuthKey {
                strongSelf.renderAlertPopUp(title: qError.type.rawValue,
                                            type: .error)
            }
            
        }
    }
    
    fileprivate func renderItem() {
        guard let item = item,
              let tryOnImage = item.tryOnImage,
              let rootPosition = jointPositions[.root],
              !isBodyGuideShowing,
              !isProcessingItem,
              isSessionSetupComplete else { return }
        
        let hasRenderedNode = productIdToNode[item.productId] != nil
        let itemNode = productIdToNode[item.productId] ?? QTryOnNode(item: item)
        if !hasRenderedNode {
            productIdToNode[item.productId] = itemNode
            sceneView.scene.rootNode.addChildNode(itemNode)
        }
        
        if !didFetchMeasurements {
            arTryOnUtil.fetchARMeasurement(item: item, jointPositions: jointPositions, userBodyPoints: userBodyPoints) { [weak self] measurement, error in
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    if let measurement = measurement {
                        itemNode.measurement = measurement
                        strongSelf.configNode(itemNode, tryOnImage: tryOnImage, rootPosition: rootPosition)
                    }
                }
            }
            didFetchMeasurements = true
        } else {
            configNode(itemNode, tryOnImage: tryOnImage, rootPosition: rootPosition)
        }
    }
    
    fileprivate func configNode(_ node: QTryOnNode, tryOnImage: UIImage, rootPosition: SCNVector3) {
        let item = node.item
        let measurement = node.measurement
        let planeWidth = arTryOnUtil.getItemPlaneWidth(item: item, measurement: measurement, scaleMultiplier: node.scaleMultiplier)
        let planeHeight = arTryOnUtil.getItemPlaneHeight(item: item, measurement: measurement, verticalScaleMultiplier: node.verticalScaleMultiplier)
        let dressGeo = arTryOnUtil.createNodePlane(tryOnImage: tryOnImage, planeWidth: planeWidth, planeHeight: planeHeight)
        node.geometry = dressGeo
        
        let defaultOffset = arTryOnUtil.getDefaultOffset(item: item, measurement: measurement, nodeSize: CGSize(width: planeWidth, height: planeHeight), jointPositions: jointPositions)
        node.config(withCamera: sceneView.pointOfView,
                    anchorPosition: rootPosition,
                    defaultOffset: defaultOffset)
    }
    
    @objc
    fileprivate func processCurrentUserBodyData() {
        guard !isProcessingUserBodyData else { return }
        guard let _ = item?.tryOnImage,
              let userImage = arTryOnUtil.getUserImage(from: sceneView) else { return }
        
        isProcessingUserBodyData = true
        userBodyPoints = [:]
        
        tryOnUtil.detectPose(on: userImage) { [weak self] bodyPoints in
            guard let strongSelf = self else { return }
            strongSelf.userBodyPoints = bodyPoints
            strongSelf.isProcessingUserBodyData = false
            DispatchQueue.main.async {
                strongSelf.didFetchMeasurements = false
            }
        }
    }
    
    @objc
    fileprivate func checkUserBodyDetection() {
        if !isBodyDetected && isSessionSetupComplete {
            if !isBodyGuideShowing {
                jointPositions = [:]
                removeTryOnNodes()
                isBodyGuideShowing = true
                didFetchMeasurements = false
                bodyGuideView.animate()
            }
        } else if isBodyGuideShowing {
            isBodyGuideShowing = false
            processCurrentUserBodyData()
        }
    }
    
    fileprivate func removeTryOnNodes() {
        for (id, node) in productIdToNode {
            node.removeFromParentNode()
            productIdToNode[id] = nil
        }
    }
}

// MARK: - Tools Action
extension QueenlyARTryOnViewController {
    
    fileprivate func setupButtonActions() {
        resetToolButton.addAction { [weak self] in
            self?.onResetButton()
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
        snapshotButton.addAction { [weak self] in
            self?.onSnapshotButton()
        }
        photoUploadButton.addAction { [weak self] in
            self?.onPhotoUploadButton()
        }
    }
    
    fileprivate func resetSession() {
        sceneView.session.pause()
        sceneView.session.run(bodyTrackingConfig, options: sessionOptions)
    }
    
    fileprivate func onResetButton() {
        for node in sceneView.scene.rootNode.childNodes {
            if let tryOnNode = node as? QTryOnNode {
                tryOnNode.reset()
            }
        }
        resizeToolStack.currentValue = .zero
        userBodyPoints = [:]
        didFetchMeasurements = false
        resetSession()
    }
    
    fileprivate func onLeftTiltButton() {
        if let node = productIdToNode[mainProductId] {
            node.rotationOffset += rotationValue
        }
    }
    
    fileprivate func onRightTiltButton() {
        if let node = productIdToNode[mainProductId] {
            node.rotationOffset -= rotationValue
        }
    }
    
    fileprivate func onArrowUpButton() {
        if let node = productIdToNode[mainProductId] {
            node.positionOffset.y += posOffsetValue
        }
    }
    
    fileprivate func onArrowDownButton() {
        if let node = productIdToNode[mainProductId] {
            node.positionOffset.y -= posOffsetValue
        }
    }
    
    fileprivate func onArrowRightButton() {
        if let node = productIdToNode[mainProductId] {
            node.positionOffset.x += posOffsetValue
        }
    }
    
    fileprivate func onArrowLeftButton() {
        if let node = productIdToNode[mainProductId] {
            node.positionOffset.x -= posOffsetValue
        }
    }
    
    fileprivate func onScaleUpButton() {
        if let node = productIdToNode[mainProductId] {
            node.scaleMultiplier = min(node.scaleMultiplier + 1, maxScaleValue)
            resizeToolStack.currentValue = node.scaleMultiplier
        }
    }
    
    fileprivate func onScaleDownButton() {
        if let node = productIdToNode[mainProductId] {
            node.scaleMultiplier = max(node.scaleMultiplier - 1, minScaleValue)
            resizeToolStack.currentValue = node.scaleMultiplier
        }
    }
    
    @objc
    fileprivate func rangeSliderValueDidChange(_ sender: UISlider) {
        if let node = productIdToNode[mainProductId] {
            node.scaleMultiplier = CGFloat(sender.value)
            resizeToolStack.currentValue = node.scaleMultiplier
        }
    }
    
    fileprivate func onSnapshotButton() {
        impactFeedbackGenerator.impactOccurred()
        
        requestLibraryAccess { authorized in
            DispatchQueue.main.async { [weak self] in
                if authorized {
                    self?.saveSnapshot()
                } else {
                    self?.renderAlertPopUp(title: "Library access denied!",
                                           message: "Access to photo library is required to save your photo. On your device, go to Settings > \(QueenlyTryOn.account.accountName) and allow full acesss to Photos.",
                                           type: .error,
                                           duration: 3.0)
                }
            }
        }
        
    }
    
    fileprivate func saveSnapshot() {
        let scale = UIScreen.main.scale
        let screenshotImage = sceneView.screenshot(scale: scale)
        let topHeader = headerView.getTitleView().screenshot(scale: scale)
        let bottomHeader = headerView.getTitleView().screenshot(scale: scale)
        let watermarkRatio: CGFloat = topHeader.size.width / topHeader.size.height
        let watermarkWidth: CGFloat = screenshotImage.size.width * 0.65
        let watermarkHeight: CGFloat = watermarkWidth / watermarkRatio
        UIGraphicsBeginImageContext(screenshotImage.size)
        screenshotImage.draw(in: CGRect(origin: .zero, size: screenshotImage.size))
        UIColor.white.setFill()
        let topRectangle = CGRect(x: 0, y: 0, width: screenshotImage.size.width, height: watermarkHeight + 64)
        let bottomRectangle = CGRect(x: 0, y: screenshotImage.size.height - watermarkHeight - 64, width: screenshotImage.size.width, height: watermarkHeight + 64)
        UIRectFill(topRectangle)
        UIRectFill(bottomRectangle)
        topHeader.draw(in: CGRect(x: screenshotImage.size.width / 2 - watermarkWidth / 2,
                                  y: 32,
                                  width: watermarkWidth,
                                  height: watermarkHeight))
        bottomHeader.draw(in: CGRect(x: screenshotImage.size.width / 2 - watermarkWidth / 2,
                                     y: screenshotImage.size.height - watermarkHeight - 32,
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
                    self?.photoUploadButton.icon = snapshotImage
                } else {
                    self?.renderAlertPopUp(title: "An error occured!", type: .error)
                }
            }
        }
    }
    
    fileprivate func onPhotoUploadButton() {
        guard let item = item else { return }
        
        requestLibraryAccess { authorized in
            DispatchQueue.main.async { [weak self] in
                if authorized {
                    let vc = QTryOnPhotoLandingViewController(item: item)
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self?.renderAlertPopUp(title: "Library access denied!",
                                           message: "Photo library is required to use this feature. On your device, go to Settings > \(QueenlyTryOn.account.accountName) and allow full acesss to Photos.",
                                           type: .error,
                                           duration: 3.0)
                }
            }
        }
        guard PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized else {
            return
        }
    }
}

// MARK: - Gestures
extension QueenlyARTryOnViewController {
    fileprivate func addGestures() {
        contentView.addGestureRecognizer(createPanGesture())
        contentView.addGestureRecognizer(createPinchGesture())
        contentView.addGestureRecognizer(createRotationGesture())
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
    
    fileprivate func nodeInteracting(with gesture: UIGestureRecognizer) -> QTryOnNode? {
        let touchLocation = gesture.location(in: sceneView)
        
        if let hitTestResult = sceneView.hitTest(touchLocation, options: nil).first,
           let tappedNode = hitTestResult.node as? QTryOnNode {
            return tappedNode
        }
        
        return nil
    }
    
    @objc 
    fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let node = nodeInteracting(with: gesture) {
                interactingPositionNode = node
                node.initialNodePositionAtInteraction = node.position
            }
        case .changed:
            if let interactingNode = interactingPositionNode as? QTryOnNode,
               let initialNodePosition = interactingNode.initialNodePositionAtInteraction {
                let translation = gesture.translation(in: sceneView)
                let initialProjectedPoint = sceneView.projectPoint(initialNodePosition)
                let newPoint = CGPoint(x: translation.x + CGFloat(initialProjectedPoint.x),
                                       y: translation.y + CGFloat(initialProjectedPoint.y))
                if let hitTestResult = sceneView.hitTest(newPoint, options: nil).first {
                    interactingNode.position = SCNVector3(hitTestResult.worldCoordinates.x,
                                                          hitTestResult.worldCoordinates.y,
                                                          hitTestResult.worldCoordinates.z)
                } else {
                    interactingNode.position = SCNVector3(initialNodePosition.x + Float(translation.x / 100.0),
                                                          initialNodePosition.y - Float(translation.y / 100.0),
                                                          initialNodePosition.z)
                }
            }
        default:
            if let interactingNode = interactingPositionNode as? QTryOnNode,
               let initialNodePosition = interactingNode.initialNodePositionAtInteraction {
                interactingNode.updatePositionOffset(initialPosition: initialNodePosition)
            }
            interactingPositionNode = nil
        }
    }
    
    @objc 
    fileprivate func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let node = nodeInteracting(with: gesture) {
                interactingScalingNode = node
                node.initialNodeGeoAtInteraction = node.geometry as? SCNPlane
            }
        case .changed:
            if let interactingNode = interactingScalingNode as? QTryOnNode,
               let initialNodeGeo = interactingNode.initialNodeGeoAtInteraction,
               gesture.numberOfTouches >= 2 {
                var planeWidth = initialNodeGeo.width
                var planeHeight = initialNodeGeo.height
                if gesture.direction == .vertical {
                    planeHeight = initialNodeGeo.height * gesture.scale
                } else {
                    planeWidth = initialNodeGeo.width * gesture.scale
                    planeHeight = arTryOnUtil.getItemPlaneHeight(item: interactingNode.item, measurement: interactingNode.measurement, verticalScaleMultiplier: interactingNode.verticalScaleMultiplier)
                }
                let dressGeometry = arTryOnUtil.createNodePlane(tryOnImage: item?.tryOnImage, planeWidth: planeWidth, planeHeight: planeHeight)
                interactingNode.geometry = dressGeometry
            }
        default:
            if let interactingNode = interactingScalingNode as? QTryOnNode,
               let currentNodeGeo = interactingNode.geometry as? SCNPlane,
               let initialNodeGeo = interactingNode.initialNodeGeoAtInteraction {
                interactingNode.scaleMultiplier += (currentNodeGeo.width - initialNodeGeo.width) / arTryOnUtil.scaleValue(of: interactingNode.item)
                interactingNode.verticalScaleMultiplier += (currentNodeGeo.height - initialNodeGeo.height) / arTryOnUtil.scaleValue(of: interactingNode.item)
                resizeToolStack.currentValue = interactingNode.scaleMultiplier
            }
            interactingScalingNode = nil
        }
    }
    
    @objc 
    fileprivate func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let node = nodeInteracting(with: gesture) {
                interactingRotationNode = node
                node.initialNodeRotationAtInteraction = node.rotationOffset
            }
        case .changed:
            if let interactingNode = interactingRotationNode as? QTryOnNode,
               let initialNodeRotation = interactingNode.initialNodeRotationAtInteraction {
                let rotation = -(gesture.rotation) + initialNodeRotation
                interactingNode.updateRotationOffset(rotation)
            }
        default:
            interactingRotationNode = nil
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension QueenlyARTryOnViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - QPopUpViewControllerDelegate
extension QueenlyARTryOnViewController: QPopUpViewControllerDelegate {
    func qPopUpDidDismiss(_ popUp: QPopUpViewController) {
        if popUp.tag == QPopUpTag.disclaimer.rawValue {
            renderTutorialPopUp()
        } else if popUp.tag == QPopUpTag.tutorial.rawValue {
            renderGestureTutorial()
        }
    }
}

// MARK: - QTryOnGesturesTutorialOverlayViewDelegate
extension QueenlyARTryOnViewController: QTryOnGesturesTutorialOverlayViewDelegate {
    func qTryOnGesturesTutorialDidRemove(_ tutorialView: QTryOnGesturesTutorialOverlayView) {
        layoutTools()
    }
}

// MARK: - ARSessionDelegate
extension QueenlyARTryOnViewController: ARSessionDelegate {
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        jointPositions = [:]
        if !isProcessingUserBodyData && (userBodyPoints[.leftShoulder] == nil || userBodyPoints[.rightShoulder] == nil || userBodyPoints[.leftHip] == nil || userBodyPoints[.rightHip] == nil) {
            processCurrentUserBodyData()
        }
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                jointPositions = arTryOnUtil.getJointPositions(bodyAnchor)
            }
        }
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if !isSessionSetupComplete {
            isSessionSetupComplete = true
            if !isProcessingItem {
                removeSpinner()
            }
        }
    }
}
