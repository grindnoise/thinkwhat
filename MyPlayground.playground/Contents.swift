//
//  ProgressCirle.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

extension Float {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}

//
//  ProgressCirle.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//
extension UIImage {
    
    func circularImage(size: CGSize?, frameColor: UIColor) -> UIImage {
        let newSize = size ?? self.size
        
        let minEdge = min(newSize.height, newSize.width)
        let size = CGSize(width: minEdge, height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
        
        let offset = size.height * 0.04
        
        if frameColor != .clear {
            let outerPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
            outerPath.lineWidth = offset * 2.5
            frameColor.setStroke()
            outerPath.stroke()
            
            let innerFrame = CGRect(origin: CGPoint(x: CGPoint.zero.x + offset , y: CGPoint.zero.y + offset), size: CGSize(width: size.width - offset * 2, height: size.height - offset * 2))
            let innerPath = UIBezierPath(ovalIn: innerFrame)
            innerPath.lineWidth = offset * 0.7
            UIColor.white.setStroke()
            innerPath.stroke()
        }
        
        context!.setBlendMode(.copy)
        context!.setFillColor(UIColor.clear.cgColor)
        
        let imageSize = size
        
        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: imageSize))
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: imageSize))
        rectPath.append(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()
        
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
    
}


var image = UIImage(named: "user")!
let circularImage     = image.circularImage(size: CGSize(width: 200, height: 200), frameColor: .blue)
