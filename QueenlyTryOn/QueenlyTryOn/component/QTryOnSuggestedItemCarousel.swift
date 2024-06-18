//
//  QTryOnSuggestedItemCarousel.swift
//  
//
//  Created by Mica Morales on 6/10/24.
//

import UIKit

protocol QTryOnSuggestedItemCarouselDelegate: AnyObject {
    func suggestedItemCarousel(_ carousel: QTryOnSuggestedItemCarousel, didSelect item: QItem)
    func suggestedItemCarousel(_ carousel: QTryOnSuggestedItemCarousel, didDeselect item: QItem)
}

class QTryOnSuggestedItemCarousel: UIView {
    
    weak var delegate: QTryOnSuggestedItemCarouselDelegate?
    
    var isExpanded: Bool = false {
        didSet {
            arrowButton.icon = arrowIcon
            widthConstraint?.constant = currentWidth
        }
    }
    
    var maxWidth: CGFloat = .zero {
        didSet {
            widthConstraint?.constant = currentWidth
        }
    }
    var minWidth: CGFloat = .zero {
        didSet {
            widthConstraint?.constant = currentWidth
        }
    }
    
    var currentTryOnIds: Set<String> = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var currentWidth: CGFloat {
        return isExpanded ? maxWidth : minWidth
    }
    
    private let itemManager = QItemManager()
    private let imageHandler = QImageHandler()
    
    private let sectionInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let minimumInteritemSpacing: CGFloat = 4
    private var widthConstraint: NSLayoutConstraint?
    
    private var productIds: [String] = []
    private var items: [QItem] = []
    private var itemIdToImages: [String: UIImage] = [:]
    
    private var arrowIcon: UIImage? {
        return UIImage(systemName: isExpanded ? "chevron.right" : "chevron.left")
    }
            
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    private lazy var arrowButton: QueenlyIconButton = {
        let button = QueenlyIconButton(icon: arrowIcon)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.iconTintColor = .black
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.widthAnchor.constraint(lessThanOrEqualToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(QPhotoCell.self, forCellWithReuseIdentifier: QPhotoCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    init(productIds: [String]) {
        self.productIds = productIds
        super.init(frame: .zero)
        layout()
        fetchItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(productIds: [String]) {
        self.productIds = productIds
        fetchItems()
    }
    
    private func layout() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 10
        alpha = 0.0
        
        addSubview(collectionView)
        addSubview(arrowButton)
        NSLayoutConstraint.activate([
            arrowButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            arrowButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: arrowButton.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
        ])
        
        widthConstraint = widthAnchor.constraint(equalToConstant: currentWidth)
        widthConstraint?.isActive = true
        
        arrowButton.addAction { [weak self] in
            self?.isExpanded.toggle()
        }
    }
    
    private func fetchItems() {
        guard !productIds.isEmpty else { return }
        itemManager.fetchItems(productIds: productIds) { [weak self] items in
            guard let strongSelf = self else { return }
            strongSelf.items = items
            DispatchQueue.main.async {
                for item in items {
                    strongSelf.imageHandler.loadImage(fromUrl: item.imageUrl) { image in
                        strongSelf.itemIdToImages[item.productId] = image
                        strongSelf.collectionView.reloadData()
                    }
                }
                strongSelf.collectionView.reloadData()
                UIView.animate(withDuration: 0.06) {
                    strongSelf.alpha = items.isEmpty ? 0.0 : 1.0
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension QTryOnSuggestedItemCarousel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QPhotoCell.identifier, for: indexPath) as! QPhotoCell
        let item = items[indexPath.row]
        cell.image = itemIdToImages[item.productId]
        cell.showSelectedState = true
        cell.isPhotoSelected = currentTryOnIds.contains(item.productId)
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 8
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension QTryOnSuggestedItemCarousel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let productId = item.productId
        if currentTryOnIds.contains(productId) && currentTryOnIds.count > 1 {
            delegate?.suggestedItemCarousel(self, didDeselect: item)
        } else {
            delegate?.suggestedItemCarousel(self, didSelect: item)
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension QTryOnSuggestedItemCarousel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = frame.size.height - sectionInset.top - sectionInset.bottom
        return CGSize(width: height * 0.85, height: height)
    }
}

