//
//  InsetTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {

    var insets: UIEdgeInsets = UIEdgeInsets.zero {// UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 20) {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
}
