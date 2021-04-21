//
//  VerticalTextLayer.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class VerticalTextLayer: CATextLayer {
    override open func draw(in ctx: CGContext) {
        let yDiff: CGFloat
        let fontSize: CGFloat
        let height = self.bounds.height
        
        if let attributedString = self.string as? NSAttributedString {
            fontSize = attributedString.size().height
            yDiff = (height-fontSize)/2
        } else {
            fontSize = self.fontSize
            yDiff = (height-fontSize)/2 - fontSize/10
        }
        
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}
