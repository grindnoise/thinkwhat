//
//  PaddingLabel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.02.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

//@IBDesignable
//class PaddingLabel: UILabel {
//
//    @IBInspectable var leftInset: CGFloat = 0
//    @IBInspectable var rightInset: CGFloat = 0
//    @IBInspectable var topInset: CGFloat = 0
//    @IBInspectable var bottomInset: CGFloat = 0
//
//    override func draw(_ rect: CGRect) {
//        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
//        super.drawText(in: rect.inset(by: insets))
//    }
//
//}

@IBDesignable
class InsetLabelDesignable: UILabel {

    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 0
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    var cornerRadiusMultipler: CGFloat = 0

    override func draw(_ rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += leftInset + rightInset
        intrinsicContentSize.height += topInset + bottomInset
        if cornerRadiusMultipler != 0 {
            cornerRadius = intrinsicContentSize.height / cornerRadiusMultipler
        }
        return intrinsicContentSize
    }

}
