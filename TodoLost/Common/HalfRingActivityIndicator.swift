//
//  HalfRingActivityIndicator.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 06.07.2023.
//

import UIKit

class HalfRingActivityIndicator: UIView {
    
    private let shapeLayer = CAShapeLayer()
    private let animationKey = "rotationAnimation"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShapeLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShapeLayer()
    }
    
    private func setupShapeLayer() {
        let lineWidth: CGFloat = 4.0
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = Colors.blue?.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineCap = .round
        shapeLayer.strokeStart = 0.3
        shapeLayer.strokeEnd = 0.9
        
        let path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: CGFloat.pi / 2,
            clockwise: true
        )
        
        shapeLayer.path = path.cgPath
        
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.frame = bounds
        setupShapeLayer()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        startAnimating()
    }
    
    func startAnimating() {
        isHidden = false
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.repeatCount = .infinity
        shapeLayer.add(animation, forKey: animationKey)
    }
    
    func stopAnimating() {
        isHidden = true
        shapeLayer.removeAnimation(forKey: animationKey)
    }
}
