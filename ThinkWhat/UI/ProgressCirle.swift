//
//  ProgressCirle.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ProgressCirle: UIView {
    
    var circlePathLayer: CAShapeLayer?
    var innerCirclePathLayer: CAShapeLayer?
    var label: UILabel?
    var circleRadius: CGFloat!
    var innerCircleRadius: CGFloat!
    var progress: CGFloat {
        didSet {
            if progress != oldValue {
                self.setProgress()
            }
        }
    }
    var color: UIColor?
    override init(frame: CGRect) {
        progress = 1
        label = UILabel(frame: frame)
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        progress = 1
        label = UILabel()
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        circlePathLayer = CAShapeLayer()
        innerCirclePathLayer = CAShapeLayer()
        innerCirclePathLayer?.frame = bounds
        innerCircleRadius = frame.size.height / 4.5
        innerCirclePathLayer?.fillColor = UIColor.white.cgColor
        circlePathLayer?.frame = bounds
        circleRadius = frame.size.height / 2
        circlePathLayer?.fillColor = UIColor(red:1.00, green: 0.72, blue:0.22, alpha:1.0).cgColor//K_COLOR_RED.withAlphaComponent(0.5).cgColor
        label?.textAlignment = .center
        label?.frame.size = CGSize(width: innerCircleRadius * 10.5, height: innerCircleRadius * 10.5)
        label?.font = UIFont(name: "OpenSans-Light", size: 15)
        label?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label?.textColor = .darkGray
        label?.adjustsFontSizeToFitWidth = true
        label?.layer.zPosition = 5
        label?.minimumScaleFactor = 0.3
        layer.addSublayer(circlePathLayer!)
        layer.addSublayer(innerCirclePathLayer!)
        label?.layoutCentered(in: self, multiplier: 0.4)
    }
    
    
    func circlePath() -> UIBezierPath {
        let angle = ((progress) / 100) * 360 - 90
        let radius = frame.size.height / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat(-Double.pi/2), endAngle: Float(angle).degreesToRadians, clockwise: true)
        path.addLine(to: CGPoint(x: radius, y: radius))
        path.close()
        return path
    }
    
    func innerCirclePath() -> UIBezierPath {
        let angle = ((progress) / 100) * 360 - 90
        let radius = frame.size.height / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: innerCircleRadius, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(3*Double.pi/2), clockwise: true)
        return path
    }
    
    private func setProgress() {
        setNeedsLayout()
        layoutIfNeeded()
        circlePathLayer?.frame = bounds
        circlePathLayer?.path = circlePath().cgPath
//        circlePathLayer.fillColor = color == nil ? UIColor.lightGray.cgColor : color!.cgColor
        innerCirclePathLayer?.frame = bounds
        innerCirclePathLayer?.path = innerCirclePath().cgPath
        label?.text = "\(Int(progress))"
    }
    
    deinit {
//        print("deinit Circle")
    }
}

//
////
////  ProgressCirle.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 22.10.2019.
////  Copyright © 2019 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class ProgressCirle: UIView {
//
//    let circlePathLayer = CAShapeLayer()
//    let innerCirclePathLayer = CAShapeLayer()
//    let label: UILabel
//    var circleRadius: CGFloat!
//    var innerCircleRadius: CGFloat!
//    var progress: CGFloat {
//        didSet {
//            if progress != oldValue {
//                setProgress()
//                //self.layoutSubviews()
//            }
//        }
//    }
//    private var isViewReady = false
//    var color: UIColor?
//    override init(frame: CGRect) {
//        progress = 1
//        label = UILabel(frame: frame)
//        super.init(frame: frame)
//        configure()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        progress = 1
//        label = UILabel()
//        super.init(coder: aDecoder)
//        configure()
//    }
//
//    func configure() {
//
//        innerCirclePathLayer.frame = bounds
//        innerCircleRadius = frame.size.height / 4.5
//        innerCirclePathLayer.fillColor = UIColor.white.cgColor
//        circlePathLayer.frame = bounds
//        circleRadius = frame.size.height / 2
//        circlePathLayer.fillColor = UIColor(red:1.00, green: 0.72, blue:0.22, alpha:1.0).cgColor//K_COLOR_RED.withAlphaComponent(0.5).cgColor
//        //        circlePathLayer.path = circlePath().cgPath
//        //        innerCirclePathLayer.path = innerCirclePath().cgPath
//        //        circlePathLayer.fillColor = color == nil ? UIColor.lightGray.cgColor : color!.cgColor
//        label.textAlignment = .center
//        label.frame.size = CGSize(width: innerCircleRadius * 10.5, height: innerCircleRadius * 10.5)
//
//        label.font = UIFont(name: "OpenSans-Light", size: 15)
//        //        label.backgroundColor = .black
//        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
//        label.textColor = .darkGray
//        label.adjustsFontSizeToFitWidth = true
//        label.layer.zPosition = 5
//        label.minimumScaleFactor = 0.3
//        layer.addSublayer(circlePathLayer)
//        layer.addSublayer(innerCirclePathLayer)
//        label.layoutCentered(in: self, multiplier: 0.4)
//    }
//
//
//    func circlePath() -> UIBezierPath {
//        let angle = ((progress) / 100) * 360 - 90
//        let radius = frame.size.height / 2
//        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat(-Double.pi/2), endAngle: Float(angle).degreesToRadians, clockwise: true)
//        path.addLine(to: CGPoint(x: radius, y: radius))
//        path.close()
//        return path
//    }
//
//    func innerCirclePath() -> UIBezierPath {
//        let angle = ((progress) / 100) * 360 - 90
//        let radius = frame.size.height / 2
//        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: innerCircleRadius, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(3*Double.pi/2), clockwise: true)
//        return path
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        label.text = "\(Int(progress))"
//    }
//
//    private func setProgress() {
//        circlePathLayer.frame = bounds
//        circlePathLayer.path = circlePath().cgPath
//        innerCirclePathLayer.frame = bounds
//        innerCirclePathLayer.path = innerCirclePath().cgPath
//    }
//}
