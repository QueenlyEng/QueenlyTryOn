//
//  QLoadingOverlayView.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/2/24.
//

import UIKit

class QLoadingOverlayView: UIView {
    
    private let spinnerView = UIView()
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .white.withAlphaComponent(0.6)
        
        spinnerView.frame = .zero
        addSubview(spinnerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        startAnimation()
    }
    
    
    func render(on view: UIView) {
        guard !self.isDescendant(of: view) else { return }
        
        setProgressPath(on: view)
        
        self.frame = view.frame
        view.addSubview(self)
    }
    
    func render(on view: UIView, belowSubview otherSubview: UIView) {
        guard !self.isDescendant(of: view) else { return }
        
        setProgressPath(on: view)
        
        self.frame = view.frame
        view.insertSubview(self, belowSubview: otherSubview)
    }
    
    func render(on view: UIView, aboveSubview otherSubview: UIView) {
        guard !self.isDescendant(of: view) else { return }
        
        setProgressPath(on: view)
        
        self.frame = view.frame
        view.insertSubview(self, aboveSubview: otherSubview)
    }
    
    private func setProgressPath(on view: UIView) {
        let spinnerDimension: CGFloat = 50
        spinnerView.frame = CGRect(x: view.frame.midX - spinnerDimension / 2,
                                   y: view.frame.midY - spinnerDimension / 2,
                                   width: spinnerDimension,
                                   height: spinnerDimension)
        
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(arcCenter: CGPoint(x: spinnerView.frame.size.width / 2.0, y: spinnerView.frame.size.height / 2.0),
                                  radius: (spinnerView.frame.size.width)/2,
                                  startAngle: CGFloat(-0.5 * Double.pi),
                                  endAngle: CGFloat(1.5 * Double.pi), clockwise: true).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = QueenlyTryOn.brandColor.cgColor
        shape.lineWidth = 4
        shape.strokeEnd = 0.5
        
        spinnerView.layer.addSublayer(shape)
    }
    
    private func startAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.0
        rotation.repeatCount = .infinity
        spinnerView.layer.add(rotation, forKey: "spin")
    }
    
}
