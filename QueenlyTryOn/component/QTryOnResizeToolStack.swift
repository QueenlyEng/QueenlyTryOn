//
//  QTryOnResizeToolStack.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/2/24.
//

import UIKit

class QTryOnResizeToolStack: UIStackView {
    
    var currentValue: CGFloat {
        didSet {
            scaleSlider.setValue(Float(currentValue), animated: true)
        }
    }
    var minScaleValue: CGFloat
    var maxScaleValue: CGFloat
    
    private let sliderDimension: CGSize
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reposition"
        QTryOnStyling.applyTryOnTootlTitleStyling(on: label)
        return label
    }()
    
    lazy var scaleSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.transform = slider.transform.rotated(by: CGFloat(-0.5 * Float.pi))
        slider.value = Float(currentValue)
        slider.maximumValue = Float(maxScaleValue)
        slider.minimumValue = Float(minScaleValue)
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .white
        slider.widthAnchor.constraint(equalToConstant: sliderDimension.width).isActive = true
        slider.heightAnchor.constraint(equalToConstant: sliderDimension.height).isActive = true
        return slider
    }()
    
    lazy var scaleUpButton: QueenlyIconButton = {
        let button = QueenlyIconButton(icon: UIImage(named: "plus_circle_icon"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.iconTintColor = .white
        button.widthAnchor.constraint(equalToConstant: 26).isActive = true
        button.heightAnchor.constraint(equalToConstant: 26).isActive = true
        return button
    }()
    
    lazy var scaleDownButton: QueenlyIconButton = {
        let button = QueenlyIconButton(icon: UIImage(named: "minus_circle_icon"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.iconTintColor = .white
        button.widthAnchor.constraint(equalToConstant: 26).isActive = true
        button.heightAnchor.constraint(equalToConstant: 26).isActive = true
        return button
    }()
    
    init(currentValue: CGFloat, 
         minScaleValue: CGFloat,
         maxScaleValue: CGFloat,
         sliderDimension: CGSize) {
        self.currentValue = currentValue
        self.minScaleValue = minScaleValue
        self.maxScaleValue = maxScaleValue
        self.sliderDimension = sliderDimension
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        axis = .vertical
        alignment = .center
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = .zero
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(scaleUpButton)
        addArrangedSubview(scaleSlider)
        addArrangedSubview(scaleDownButton)
        
        setCustomSpacing(8, after: titleLabel)
    }
    
}
