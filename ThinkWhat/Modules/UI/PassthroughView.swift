//
//  PassthroughView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PassthroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        subviews.filter { !$0.isHidden && $0.isUserInteractionEnabled && $0.point(inside: convert(point, to: $0), with: event) }.isEmpty
//        for subview in subviews {
//            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
//                return true
//            }
//        }
//        return false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil //avoid delivering touch events to the container view (self)
        } else {
            return view //the subviews will still receive touch events
        }
    }
}
