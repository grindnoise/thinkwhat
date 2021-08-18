//
//  ButtonWithImage.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class ButtonWithImage: UIButton {
    var roundedFrame: Bool = true
    var borderedFrame: CAShapeLayer? {
        didSet {
            if borderedFrame != nil {
                if oldValue != nil {
                    oldValue?.removeFromSuperlayer()
                }
                layer.insertSublayer(borderedFrame!, at: 0)
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 35), bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)!)
        }
    }
    
    override var bounds: CGRect {
        didSet {
            let borderLayer = CAShapeLayer()
            borderLayer.strokeColor = UIColor.blue.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            let borderPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/4)
            borderLayer.path = borderPath.cgPath
            borderLayer.lineWidth = 1.75
            borderedFrame = borderLayer
        }
    }
}
