//
//  Line.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

class Line {
  var path = UIBezierPath()
  var layer = CAShapeLayer()
  
  public func animateStrokeEnd(duration: TimeInterval,
                               delegate: CAAnimationDelegate,
                               completion: Closure?) {
    
    layer.add(Animations.get(property: .StrokeEnd,
                             fromValue: 0,
                             toValue: 1,
                             duration: 0.4,
                             timingFunction: .easeOut,
                             delegate: delegate,
                             completionBlocks: completion),
              forKey: nil)
  }
}

