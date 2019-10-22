//
//  ProgressCirle.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ProgressCirle: UIView {
    
    let circlePathLayer = CAShapeLayer()
    var circleRadius: CGFloat!
//    let label: UILabel
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            print(newValue)
            if newValue > 1 {
                circlePathLayer.strokeEnd = 1
                circlePathLayer.strokeColor = K_COLOR_RED.withAlphaComponent(1).cgColor
//                label.text = "100%"
            } else if newValue < 0 {
                circlePathLayer.strokeEnd = 0
                circlePathLayer.strokeColor = K_COLOR_RED.withAlphaComponent(0).cgColor
//                label.text = "0%"
            } else {
                circlePathLayer.strokeEnd = newValue
                circlePathLayer.strokeColor = K_COLOR_RED.withAlphaComponent(newValue).cgColor
//                label.text = "\(Int(newValue * 100))%"
            }
        }
    }
    override init(frame: CGRect) {
        
//        self.label = UILabel()
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
//        self.label = UILabel()
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        progress = 0
        circlePathLayer.frame = bounds
        circleRadius = frame.size.height / 2.5
        circlePathLayer.lineWidth = 2
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.lineCap = .round
        layer.addSublayer(circlePathLayer)
//        label.frame = bounds
//        label.textAlignment = .center
//        label.font = UIFont(name: "OpenSans-Semibold", size: 9)
//        addSubview(label)
    }
    
    
    func circlePath() -> UIBezierPath {
        let radius = frame.size.height / 2.5
        return UIBezierPath(arcCenter: CGPoint(x: radius + 4, y: radius + 4), radius: radius, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(3*Double.pi/2), clockwise: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
}

