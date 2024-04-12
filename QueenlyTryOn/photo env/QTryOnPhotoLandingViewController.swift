//
//  QTryOnPhotoLandingViewController.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/2/24.
//

import UIKit
import PhotosUI

class QTryOnPhotoLandingViewController: QueenlyViewController {
    
    private let item: QItem
    private let albumName = "\(QueenlyTryOn.account.accountName) Try On"
    private var albumAssetCollection: PHAssetCollection? = nil
    private var selectedImageAssetIdentifier: String?
    private var isPhotoSelectedFromQueenly: Bool = false
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private lazy var contentVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pickerVStack, UIView(), imageTipHStack, tipLabelHStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.backgroundColor = .white
        stack.spacing = 32
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top:32, leading: 0, bottom: 16, trailing: 0)
        return stack
    }()
    
    private lazy var pickerVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [uploadIconButton, uploadPickerButton, queenlyAlbumPickerButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()
    
    private lazy var uploadIconButton: QueenlyIconButton = {
        let dimension: CGFloat = view.frame.size.width * 0.3
        let inset: CGFloat = dimension * 0.35
        let button = QueenlyIconButton(icon: imageHandler.image(named: "gallery_icon"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = QueenlyTryOn.brandColor
        button.iconTintColor = .white
        button.iconInset = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        button.clipsToBounds = true
        button.layer.cornerRadius = dimension / 2
        button.widthAnchor.constraint(equalToConstant: dimension).isActive = true
        button.heightAnchor.constraint(equalToConstant: dimension).isActive = true
        return button
    }()
    
    private lazy var uploadPickerButton: QueenlyButton = {
        let button = QueenlyButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = QueenlyTryOn.brandColor
        button.setTitle("Upload a photo", font:  .systemFont(ofSize: 16, weight: .bold))
        button.buttonTintColor = .white
        button.adjustsFontSizeToFitWidth = true
        button.buttonInset = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        button.contentSpacing = 4
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.6).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private lazy var queenlyAlbumPickerButton: QueenlyButton = {
        let button = QueenlyButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Open recent try-on photos", font:  .systemFont(ofSize: 16, weight: .regular))
        button.setIcon(UIImage(named: "search_history_icon")?.withRenderingMode(.alwaysTemplate), dimension: CGSize(width: 18, height: 18))
        button.buttonTintColor = QueenlyTryOn.brandColor
        button.adjustsFontSizeToFitWidth = true
        button.buttonInset = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        button.contentSpacing = 4
        button.forceLeftToRight()
        button.isHidden = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2
        button.layer.borderColor = QueenlyTryOn.brandColor.cgColor
        button.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.6).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private lazy var imageTipHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [womanStandingTipVStack, womanSittingTipVStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }()
    
    private lazy var womanStandingTipVStack: UIStackView = {
        return createImageTipsVStack(iconName: "woman_standing_icon", 
                                     iconColor: QueenlyTryOn.brandColor,
                                     text: "Do",
                                     textIconName: "check_circle_fill_icon")
    }()
    
    private lazy var womanSittingTipVStack: UIStackView = {
        return createImageTipsVStack(iconName: "woman_sitting_icon", 
                                     text: "Don't",
                                     textIconName: "cross_circle_fill_icon")
    }()
    
    private lazy var tipLabelHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tipsLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top:0, leading: 32, bottom: 42, trailing: 32)
        return stack
    }()
    
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Pose standing up, facing the camera.\nWear form fitting clothes, tank tops and shorts would be ideal."
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    // MARK: - Init
    init(item: QItem) {
        self.item = item
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        setupButtonActions()
        if let assetCollection = fetchAssetCollectionForAlbum(albumName) {
            self.albumAssetCollection = assetCollection
            self.queenlyAlbumPickerButton.isHidden = false
            self.contentVStack.directionalLayoutMargins.top = 16
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Layout
    private func layout(){
        contentView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        scrollView.addSubview(contentVStack)
        NSLayoutConstraint.activate([            
            contentVStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentVStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentVStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentVStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentVStack.heightAnchor.constraint(greaterThanOrEqualToConstant: view.frame.size.height - 150),
        ])
    }
    
    private func createImageTipsVStack(iconName: String, 
                                       iconColor: UIColor = .black,
                                       text: String,
                                       textIconName: String) -> UIStackView {
        let ratio: CGFloat = 500 / 700
        let width: CGFloat = view.frame.size.width / 2
        let height: CGFloat = width / ratio
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: iconName)
        
        let imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: width)
        let imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: height)
        imageWidthConstraint.priority = .defaultLow
        imageWidthConstraint.isActive = true
        imageHeightConstraint.isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.text = text
        
        let textImageView = UIImageView()
        textImageView.translatesAutoresizingMaskIntoConstraints = false
        textImageView.contentMode = .scaleAspectFit
        textImageView.image = UIImage(named: textIconName)?.withRenderingMode(.alwaysTemplate)
        textImageView.tintColor = iconColor
        textImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        textImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let textHStack = UIStackView(arrangedSubviews: [textImageView, label])
        textHStack.translatesAutoresizingMaskIntoConstraints = false
        textHStack.axis = .horizontal
        textHStack.alignment = .center
        textHStack.spacing = 8
        
        let vStack = UIStackView(arrangedSubviews: [imageView, textHStack])
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 16
        
        return vStack
    }
    
    // MARK: - Photos
    
    private func openTryOnResults(with image: UIImage?) {
        guard let image = image else {
            renderAlertPopUp(title: "Image failed to load!",
                             message: "Please check your file format or try selecting a different photo.",
                             type: .error)
            return
        }
        
        if !isPhotoSelectedFromQueenly {
            saveToQueenlyAlbum(image)
        }
        let vc = QTryOnPhotoResultViewController(item: item, userImage: image)
        navigationController?.pushViewController(vc, animated: true)
        //        let vc = TryOnPhotoUploadResultViewController(dress: dress,
        //                                                      userImage: image,
        //                                                      dressImage: dressImage)
        //        vc.delegate = delegate
        //        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func loadImageData(fromProvider provider: NSItemProvider,
                               completion: @escaping (_ data: Data?) -> ()) {
        let supportedRepresentations = [UTType.rawImage.identifier,
                                        UTType.tiff.identifier,
                                        UTType.bmp.identifier,
                                        UTType.png.identifier,
                                        UTType.jpeg.identifier,
                                        UTType.webP.identifier,
        ]
        
        for representation in supportedRepresentations {
            if provider.hasRepresentationConforming(toTypeIdentifier: representation) {
                provider.loadDataRepresentation(forTypeIdentifier: representation) { (data, err) in
                    completion(data)
                    return
                }
            }
        }
    }
    
    private func saveToQueenlyAlbum(_ image: UIImage) {
        let albumName = albumName
        
        // Find or create the album
        if let assetCollection = self.albumAssetCollection {
            self.savePhoto(image, assetCollection: assetCollection)
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }) { success, _ in
                guard success else { return }
                if let assetCollection = self.fetchAssetCollectionForAlbum(albumName) {
                    self.albumAssetCollection = assetCollection
                    self.savePhoto(image, assetCollection: assetCollection)
                }
            }
        }
    }
    
    private func savePhoto(_ image: UIImage, assetCollection: PHAssetCollection) {
        guard let identifier = selectedImageAssetIdentifier else { return }
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", identifier)
        let result = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        
        // Check first if photo is not in the album yet
        let assetFound: Bool = result.firstObject != nil
        
        if !assetFound {
            guard let asset = fetchAsset(with: identifier) else { return }
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCollectionChangeRequest(for: assetCollection)
                request?.addAssets([asset] as NSFastEnumeration)
            }
        }
    }
    
    private func fetchAsset(with identifier: String) -> PHAsset? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", identifier)
        return PHAsset.fetchAssets(with: fetchOptions).firstObject
    }
    
    private func fetchAssetCollectionForAlbum(_ albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
}

// MARK: - Action
extension QTryOnPhotoLandingViewController {
    
    fileprivate func setupButtonActions() {
        uploadIconButton.addAction { [weak self] in
            self?.openPHPicker()
        }
        uploadPickerButton.addAction { [weak self] in
            self?.openPHPicker()
        }
        queenlyAlbumPickerButton.addAction { [weak self] in
            self?.openQueenlyAlbum()
        }
    }
    
    fileprivate func openQueenlyAlbum() {
        if let queenlyAlbumAssetCollection = albumAssetCollection {
            isPhotoSelectedFromQueenly = true
            let vc = QueenlyLibraryPickerViewController(assetCollection: queenlyAlbumAssetCollection)
            vc.delegate = self
            present(vc, animated: true)
        } else {
            openPHPicker()
        }
    }
    
    fileprivate func openPHPicker() {
        selectedImageAssetIdentifier = nil
        isPhotoSelectedFromQueenly = false
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        DispatchQueue.main.async { [weak self] in
            self?.present(picker, animated: true, completion: nil)
        }
    }
    
}

// MARK: - PHPickerViewControllerDelegate
extension QTryOnPhotoLandingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let result = results.first {
            let provider = result.itemProvider
            selectedImageAssetIdentifier = result.assetIdentifier
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        self?.openTryOnResults(with: image as? UIImage)
                    }
                }
            } else {
                loadImageData(fromProvider: provider) { [weak self] data in
                    var image: UIImage? = nil
                    if let data = data {
                        image = UIImage(data: data)
                    }
                    DispatchQueue.main.async {
                        self?.openTryOnResults(with: image)
                    }
                }
            }
        }
    }
}

// MARK: - QueenlyLibraryPickerViewControllerDelegate
extension QTryOnPhotoLandingViewController: QueenlyLibraryPickerViewControllerDelegate {
    func picker(_ picker: QueenlyLibraryPickerViewController, didPick photo: UIImage) {
        openTryOnResults(with: photo)
    }
    
    func pickerDidSelectAllPhotos(_ picker: QueenlyLibraryPickerViewController) {
        openPHPicker()
    }
}
