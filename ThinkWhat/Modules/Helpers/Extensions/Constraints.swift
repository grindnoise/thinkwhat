//
//  Constraints.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    /**
     Returns a new constraint designated by `multiplier`. Original constraint is deactivated
     - parameter multiplier: constraint multiplier.
     - parameter duration: time interval to animate.
     */
    func setMultiplierWithFade(_ multiplier:CGFloat, duration: Double = 0) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        UIView.animate(withDuration: duration, animations: {
            (self.firstItem as? UIView)?.alpha = 0
        }, completion: {
            _ in
            NSLayoutConstraint.deactivate([self])
            NSLayoutConstraint.activate([newConstraint])
        })
        
//        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
//            (self.firstItem as? UIView)?.alpha = 1
//        }, completion: nil)
        
        return newConstraint
    }
    
    func getMultipliedConstraint(_ multiplier:CGFloat, duration: Double = 0) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        return newConstraint
    }
}
