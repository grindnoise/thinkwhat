//
//  PercentageLabel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class PercentageLabel: UILabel {

    var oldLayer = CAShapeLayer()
    var isSelected = false
    fileprivate var line = Line()
    @IBInspectable public var selectedColor:    UIColor = .gray
    @IBInspectable public var percentageColor:  UIColor = .gray
    var percent: CGFloat = 0 {
        didSet {
            if oldValue != percent {
                layoutSubviews()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
//        initializeSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        initializeSetup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        configureLine()
    }
    
    private func configureLine() {
        layer.sublayers?.remove(object: oldLayer)
        line.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width * percent, height: frame.height))
        line.layer.path = line.path.cgPath
        line.layer.fillColor = isSelected ? selectedColor.cgColor : percentageColor.cgColor
        layer.addSublayer(line.layer)
        oldLayer = line.layer
    }
}
