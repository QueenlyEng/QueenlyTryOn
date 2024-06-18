//
//  QPhotoCell.swift
//  Queenly
//
//  Created by Mica Morales on 2/15/24.
//  Copyright © 2024 Kathy Zhou. All rights reserved.
//

import UIKit

class QPhotoCell: UICollectionViewCell {
    
    static let identifier = "QPhotoCell"
    
    var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    
    var isPhotoSelected: Bool = false {
        didSet {
            styleSelectState()
        }
    }
    
    var showSelectedState: Bool = false {
        didSet {
            styleSelectState()
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    private func styleSelectState() {
        let selectedStyle = showSelectedState && isPhotoSelected
        contentView.layer.borderWidth = selectedStyle ? 2 : 0
        contentView.layer.borderColor = selectedStyle ? QueenlyTryOn.brandColor.cgColor : UIColor.clear.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
        isPhotoSelected = false
        showSelectedState = false
    }
}
