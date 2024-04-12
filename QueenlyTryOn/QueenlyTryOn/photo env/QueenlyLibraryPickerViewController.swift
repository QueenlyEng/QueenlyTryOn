//
//  QueenlyLibraryPickerViewController.swift
//  Queenly
//
//  Created by Mica Morales on 2/15/24.
//  Copyright © 2024 Kathy Zhou. All rights reserved.
//

import UIKit
import Photos

protocol QueenlyLibraryPickerViewControllerDelegate: AnyObject {
    func picker(_ picker: QueenlyLibraryPickerViewController, didPick photo: UIImage)
    func pickerDidSelectAllPhotos(_ picker: QueenlyLibraryPickerViewController)
}

class QueenlyLibraryPickerViewController: QueenlyViewController {
    
    weak var delegate: QueenlyLibraryPickerViewControllerDelegate?
    
    private let assetCollection: PHAssetCollection
    private var images: [UIImage] = []
    private var assets = PHFetchResult<PHAsset>()
    private var imageRequestIdentifiers: [String: PHImageRequestID] = [:]
    private var shouldCancelImageRequests: Bool = false
    private var loadedImageCount: Int = .zero
    
    private let batchSize: Int = 20
    private var currentPointerIndex: Int = 0
    private var isImageRequestsInProgress: Bool = false
    
    private let interitemSpacing: CGFloat = 2
    private let lineSpacing: CGFloat = 2
    private let numItemsPerRow: CGFloat = 3
    
    private var cellDimension: CGSize {
        let width: CGFloat = (view.frame.size.width - (interitemSpacing * (numItemsPerRow - 1))) / numItemsPerRow
        return CGSize(width: width, height: width)
    }
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = interitemSpacing
        layout.minimumLineSpacing = lineSpacing
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(QPhotoCell.self, forCellWithReuseIdentifier: QPhotoCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - Init
    @objc init(assetCollection: PHAssetCollection) {
        self.assetCollection = assetCollection
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
        fetchQueenlyAssets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerView.buttonStyle = .back
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelImageRequests()
    }
    
    // MARK: - Layout
    private func layout() {
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    // MARK: - Action
    private func fetchQueenlyAssets() {
        let cellDimension = self.cellDimension
        let assetCollection = self.assetCollection
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else { return }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let assets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            DispatchQueue.main.async {
                self?.assets = assets
                self?.images = Array(repeating: UIImage(), count: assets.count)
                self?.collectionView.reloadData()
                self?.requestImages(with: cellDimension)
            }
        }
    }
    
    private func requestImages(with dimension: CGSize) {
        isImageRequestsInProgress = true
        let dispatchGroup = DispatchGroup()
        
        let currentEndIndex = min(currentPointerIndex + batchSize, assets.count)
        for index in currentPointerIndex..<currentEndIndex {
            if self.shouldCancelImageRequests { return }
            let asset = assets[index]
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            requestOptions.resizeMode = .exact
            requestOptions.deliveryMode = .highQualityFormat
            
            let imageIndex = index
            dispatchGroup.enter()
            let requestId = PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: dimension.width * 2, height: dimension.height * 2), contentMode: .aspectFill, options: requestOptions) { image, info in
                if let image = image {
                    DispatchQueue.main.async {
                        self.images[imageIndex] = image
                        self.collectionView.reloadData()
                    }
                }
                if self.imageRequestIdentifiers[asset.localIdentifier] != nil {
                    self.imageRequestIdentifiers.removeValue(forKey: asset.localIdentifier)
                    self.loadedImageCount += 1
                    dispatchGroup.leave()
                }
            }
            self.imageRequestIdentifiers.updateValue(requestId, forKey: asset.localIdentifier)
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.currentPointerIndex = currentEndIndex
            self?.isImageRequestsInProgress = false
        }
    }
    
    private  func cancelImageRequests() {
        shouldCancelImageRequests = true
        // Cancel all ongoing image requests
        for (_, requestID) in imageRequestIdentifiers {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        imageRequestIdentifiers.removeAll()
    }
    
    private func loadFullSizeImage(asset: PHAsset, completion: @escaping (_ image: UIImage?) -> ()) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset, targetSize: .zero, contentMode: .aspectFit, options: requestOptions) { image, _ in
            completion(image)
        }
    }
    
    // MARK: - Misc
    override func didTapOnBack() {
        super.didTapOnBack()
        delegate?.pickerDidSelectAllPhotos(self)
    }
}

// MARK: - UICollectionViewDataSource
extension QueenlyLibraryPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QPhotoCell.identifier, for: indexPath) as! QPhotoCell
        cell.image = images[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension QueenlyLibraryPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let asset = assets[index]
        loadFullSizeImage(asset: asset) { image in
            if let image = image {
                self.dismiss(animated: true)
                self.delegate?.picker(self, didPick: image)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == loadedImageCount - (batchSize / 2) &&
            loadedImageCount < assets.count &&
            !isImageRequestsInProgress {
            self.requestImages(with: cellDimension)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension QueenlyLibraryPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellDimension
    }
}

