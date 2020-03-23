//
//  CameraLoadingIndicator.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CameraLoadingIndicator: UIView {
    
    let cameraPath: CGPath = {
        let cPath = UIBezierPath()
        cPath.move(to: CGPoint(x: 1160.79, y: 442.69))
        cPath.addCurve(to: CGPoint(x: 1044.17, y: 498.04), controlPoint1: CGPoint(x: 1115.72, y: 447.42), controlPoint2: CGPoint(x: 1075.82, y: 466.39))
        cPath.addCurve(to: CGPoint(x: 1028.72, y: 514.92), controlPoint1: CGPoint(x: 1038.32, y: 503.82), controlPoint2: CGPoint(x: 1031.42, y: 511.39))
        cPath.addCurve(to: CGPoint(x: 987.77, y: 624.04), controlPoint1: CGPoint(x: 1003.67, y: 547.32), controlPoint2: CGPoint(x: 989.79, y: 584.29))
        cPath.addLine(to: CGPoint(x: 987.32, y: 633.34))
        cPath.addLine(to: CGPoint(x: 869.12, y: 633.64))
        cPath.addCurve(to: CGPoint(x: 742.67, y: 635.14), controlPoint1: CGPoint(x: 766.22, y: 633.87), controlPoint2: CGPoint(x: 749.87, y: 634.09))
        cPath.addCurve(to: CGPoint(x: 652.67, y: 670.92), controlPoint1: CGPoint(x: 707.64, y: 640.17), controlPoint2: CGPoint(x: 678.39, y: 651.79))
        cPath.addCurve(to: CGPoint(x: 631.07, y: 689.52), controlPoint1: CGPoint(x: 643.07, y: 678.04), controlPoint2: CGPoint(x: 640.22, y: 680.52))
        cPath.addCurve(to: CGPoint(x: 575.04, y: 805.32), controlPoint1: CGPoint(x: 599.57, y: 720.57), controlPoint2: CGPoint(x: 579.84, y: 761.37))
        cPath.addCurve(to: CGPoint(x: 575.04, y: 1408.02), controlPoint1: CGPoint(x: 573.99, y: 815.37), controlPoint2: CGPoint(x: 573.99, y: 1397.82))
        cPath.addCurve(to: CGPoint(x: 587.04, y: 1457.44), controlPoint1: CGPoint(x: 576.69, y: 1423.47), controlPoint2: CGPoint(x: 581.49, y: 1443.27))
        cPath.addCurve(to: CGPoint(x: 614.64, y: 1505.67), controlPoint1: CGPoint(x: 593.34, y: 1473.34), controlPoint2: CGPoint(x: 603.77, y: 1491.57))
        cPath.addCurve(to: CGPoint(x: 645.17, y: 1536.64), controlPoint1: CGPoint(x: 621.47, y: 1514.44), controlPoint2: CGPoint(x: 636.17, y: 1529.37))
        cPath.addCurve(to: CGPoint(x: 696.02, y: 1566.42), controlPoint1: CGPoint(x: 659.87, y: 1548.49), controlPoint2: CGPoint(x: 678.99, y: 1559.67))
        cPath.addCurve(to: CGPoint(x: 745.44, y: 1578.42), controlPoint1: CGPoint(x: 710.19, y: 1571.97), controlPoint2: CGPoint(x: 729.99, y: 1576.77))
        cPath.addCurve(to: CGPoint(x: 1879.89, y: 1578.42), controlPoint1: CGPoint(x: 755.57, y: 1579.47), controlPoint2: CGPoint(x: 1869.77, y: 1579.47))
        cPath.addCurve(to: CGPoint(x: 1929.32, y: 1566.42), controlPoint1: CGPoint(x: 1895.34, y: 1576.77), controlPoint2: CGPoint(x: 1915.14, y: 1571.97))
        cPath.addCurve(to: CGPoint(x: 1977.54, y: 1538.82), controlPoint1: CGPoint(x: 1945.22, y: 1560.12), controlPoint2: CGPoint(x: 1963.44, y: 1549.69))
        cPath.addCurve(to: CGPoint(x: 2008.52, y: 1508.29), controlPoint1: CGPoint(x: 1986.32, y: 1531.99), controlPoint2: CGPoint(x: 2001.24, y: 1517.29))
        cPath.addCurve(to: CGPoint(x: 2038.29, y: 1457.44), controlPoint1: CGPoint(x: 2020.37, y: 1493.59), controlPoint2: CGPoint(x: 2031.54, y: 1474.47))
        cPath.addCurve(to: CGPoint(x: 2050.29, y: 1408.02), controlPoint1: CGPoint(x: 2043.84, y: 1443.27), controlPoint2: CGPoint(x: 2048.64, y: 1423.47))
        cPath.addCurve(to: CGPoint(x: 2050.29, y: 805.32), controlPoint1: CGPoint(x: 2051.34, y: 1397.82), controlPoint2: CGPoint(x: 2051.34, y: 815.37))
        cPath.addCurve(to: CGPoint(x: 1994.27, y: 689.52), controlPoint1: CGPoint(x: 2045.49, y: 761.37), controlPoint2: CGPoint(x: 2025.77, y: 720.57))
        cPath.addCurve(to: CGPoint(x: 1972.67, y: 670.92), controlPoint1: CGPoint(x: 1985.12, y: 680.52), controlPoint2: CGPoint(x: 1982.27, y: 678.04))
        cPath.addCurve(to: CGPoint(x: 1882.67, y: 635.14), controlPoint1: CGPoint(x: 1946.94, y: 651.79), controlPoint2: CGPoint(x: 1917.69, y: 640.17))
        cPath.addCurve(to: CGPoint(x: 1756.22, y: 633.64), controlPoint1: CGPoint(x: 1875.47, y: 634.09), controlPoint2: CGPoint(x: 1859.12, y: 633.87))
        cPath.addLine(to: CGPoint(x: 1638.02, y: 633.34))
        cPath.addLine(to: CGPoint(x: 1637.57, y: 624.04))
        cPath.addCurve(to: CGPoint(x: 1596.62, y: 514.92), controlPoint1: CGPoint(x: 1635.54, y: 584.29), controlPoint2: CGPoint(x: 1621.67, y: 547.32))
        cPath.addCurve(to: CGPoint(x: 1562.04, y: 481.09), controlPoint1: CGPoint(x: 1589.42, y: 505.54), controlPoint2: CGPoint(x: 1571.94, y: 488.44))
        cPath.addCurve(to: CGPoint(x: 1475.04, y: 443.89), controlPoint1: CGPoint(x: 1535.42, y: 461.22), controlPoint2: CGPoint(x: 1509.62, y: 450.12))
        cPath.addCurve(to: CGPoint(x: 1315.67, y: 442.47), controlPoint1: CGPoint(x: 1468.44, y: 442.69), controlPoint2: CGPoint(x: 1456.44, y: 442.54))
        cPath.addCurve(to: CGPoint(x: 1160.79, y: 442.69), controlPoint1: CGPoint(x: 1231.97, y: 442.47), controlPoint2: CGPoint(x: 1162.22, y: 442.54))
        cPath.close()
        return cPath.cgPath
    }()
    
    
    let circlePathLayer = CAShapeLayer()
    let cameraPathLayer = CAShapeLayer()
    let circleRadius: CGFloat = 25.0
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if newValue > 1 {
                circlePathLayer.strokeEnd = 1
            } else if newValue < 0 {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        
        progress = 0
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 4
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = K_COLOR_RED.cgColor//UIColor.white.cgColor
        circlePathLayer.lineCap = .round
        cameraPathLayer.frame = bounds
        //cameraPathLayer.lineWidth = 5
        cameraPathLayer.fillColor = UIColor(white: 1, alpha: 1).cgColor//.clear.cgColor
        //cameraPathLayer.strokeColor = UIColor.white.cgColor
        layer.addSublayer(cameraPathLayer)
        layer.addSublayer(circlePathLayer)
        //strokeCameraPath()
        backgroundColor = UIColor.clear//(white: 1, alpha: 0.1)
    }
    
    func scaledCameraPath() -> CGPath {
        
        let boundingBox = cameraPath.boundingBox
        
        let boundingBoxAspectRatio = boundingBox.width/boundingBox.height
        let viewAspectRatio = self.layer.frame.width/self.layer.frame.height
        
        var scaleFactor: CGFloat = 1.0
        if (boundingBoxAspectRatio > viewAspectRatio) {
            
            // Width is limiting factor
            scaleFactor = self.layer.frame.width/boundingBox.width
        } else {
            // Height is limiting factor
            scaleFactor = self.layer.frame.height/boundingBox.height
        }
        
        scaleFactor /= 1.8
        
        scaleFactor = scaleFactor == 0 ? 1 : scaleFactor
        // Scaling the path ...
        var scaleTransform = CGAffineTransform.identity
        // Scale down the path first
        scaleTransform = scaleTransform.scaledBy(x: scaleFactor, y: scaleFactor);
        // Then translate the path to the upper left corner
        scaleTransform = scaleTransform.translatedBy(x: -boundingBox.minX, y: -boundingBox.minY);
        
        // If you want to be fancy you could also center the path in the view
        // i.e. if you don't want it to stick to the top.
        // It is done by calculating the heigth and width difference and translating
        // half the scaled value of that in both x and y (the scaled side will be 0)
        let scaledSize = boundingBox.size.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        
        let centerOffset = CGSize(width: (self.layer.frame.width-scaledSize.width)/(scaleFactor*2.0), height: (self.layer.frame.height-scaledSize.height)/(scaleFactor*2.0))
        scaleTransform = scaleTransform.translatedBy(x: centerOffset.width, y: centerOffset.height);
        // End of "center in view" transformation code
        
        let scaledPath = cameraPath.copy(using: &scaleTransform)
        return scaledPath!
    }
    
    func strokeCameraPath() {
        
        let boundingBox = cameraPath.boundingBox
        
        let boundingBoxAspectRatio = boundingBox.width/boundingBox.height
        let viewAspectRatio = self.layer.frame.width/self.layer.frame.height
        
        var scaleFactor: CGFloat = 1.0
        if (boundingBoxAspectRatio > viewAspectRatio) {
            
            // Width is limiting factor
            scaleFactor = self.layer.frame.width/boundingBox.width
        } else {
            // Height is limiting factor
            scaleFactor = self.layer.frame.height/boundingBox.height
        }
        
        
        // Scaling the path ...
        var scaleTransform = CGAffineTransform.identity
        // Scale down the path first
        scaleTransform = scaleTransform.scaledBy(x: scaleFactor, y: scaleFactor);
        // Then translate the path to the upper left corner
        scaleTransform = scaleTransform.translatedBy(x: -boundingBox.minX, y: -boundingBox.minY);
        
        // If you want to be fancy you could also center the path in the view
        // i.e. if you don't want it to stick to the top.
        // It is done by calculating the heigth and width difference and translating
        // half the scaled value of that in both x and y (the scaled side will be 0)
        let scaledSize = boundingBox.size.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        
        let centerOffset = CGSize(width: (self.layer.frame.width-scaledSize.width)/(scaleFactor*2.0), height: (self.layer.frame.height-scaledSize.height)/(scaleFactor*2.0))
        scaleTransform = scaleTransform.translatedBy(x: centerOffset.width, y: centerOffset.height);
        // End of "center in view" transformation code
        
        let scaledPath = cameraPath.copy(using: &scaleTransform)
        
        // Create a new shape layer and assign the new path
        let scaledShapeLayer = CAShapeLayer()
        scaledShapeLayer.path = scaledPath
        scaledShapeLayer.strokeColor = UIColor.black.cgColor
        scaledShapeLayer.fillColor = UIColor(white: 1, alpha: 1).cgColor//UIColor(white: 1, alpha: 0.3).cgColor
        scaledShapeLayer.lineWidth = 3.0
        //scaledShapeLayer.lineCap = kCALineCapRound
        scaledShapeLayer.opacity = 1.0
        //scaledShapeLayer.fillColor = UIColor.blue.cgColor
        layer.addSublayer(scaledShapeLayer)
    }
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        let circlePathBounds = circlePathLayer.bounds
        circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
        return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
        cameraPathLayer.frame = bounds
        cameraPathLayer.path = scaledCameraPath()
    }
    
    func reveal() {
        // 1
        backgroundColor = .clear
        progress = 1
        // 2
        circlePathLayer.removeAnimation(forKey: "strokeEnd")
        // 3
        circlePathLayer.removeFromSuperlayer()
        superview?.layer.mask = circlePathLayer
        
        // 1
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
        let radiusInset = finalRadius - circleRadius
        let outerRect = circleFrame().insetBy(dx: -radiusInset, dy: -radiusInset)
        let toPath = UIBezierPath(ovalIn: outerRect).cgPath
        
        // 2
        let fromPath = circlePathLayer.path
        let fromLineWidth = circlePathLayer.lineWidth
        
        //         //3
        //        CATransaction.begin()
        //
        //        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        ////        circlePathLayer.lineWidth = 360//2*finalRadius
        ////        circlePathLayer.path = toPath
        //        circlePathLayer.removeFromSuperlayer()
        //        CATransaction.commit()
        
        // 4
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.fromValue = fromLineWidth
        lineWidthAnimation.toValue = 2*finalRadius
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = fromPath
        pathAnimation.toValue = toPath
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 0.2
        cameraPathLayer.add(opacityAnimation, forKey: nil)
        cameraPathLayer.opacity = 0
        
        // 5
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 0.6
        groupAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        groupAnimation.animations = [pathAnimation, lineWidthAnimation]
        groupAnimation.autoreverses = false
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        circlePathLayer.add(groupAnimation, forKey: "strokeWidth")
        
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension CameraLoadingIndicator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        superview?.layer.mask = nil
    }
}

