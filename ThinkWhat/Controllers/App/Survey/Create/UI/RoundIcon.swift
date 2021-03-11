//
//  Icon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class RoundIcon: UIView {
    
    private let oval: CAShapeLayer
    var icon: SurveyCategoryIcon! {
        didSet {
            addSubview(icon)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1.0/1.0).isActive = true
            icon.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9/1.0).isActive = true
        }
    }
    var color: UIColor = K_COLOR_RED {
        didSet {
            oval.fillColor = color.cgColor
            if icon != nil {
                icon.tagColor = color
            }
        }
    }
    
    override var frame: CGRect{
        didSet{
            setupLayerFrames()
        }
    }
    
    override var bounds: CGRect{
        didSet{
            setupLayerFrames()
        }
    }
    
    override init(frame: CGRect) {
        oval = CAShapeLayer()
        oval.fillColor   = color.cgColor//UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
        
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.layer.insertSublayer(oval, at: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        oval = CAShapeLayer()
        super.init(coder: aDecoder)
    }
    
    func setupLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if oval != nil {
            oval.frame = CGRect(x: 0, y: 0, width:  bounds.width, height:  bounds.height)
            oval.path  = ovalPath(bounds: oval.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    func ovalPath(bounds: CGRect) -> UIBezierPath{
        let ovalPath = UIBezierPath(ovalIn:bounds)
        return ovalPath
    }

}
