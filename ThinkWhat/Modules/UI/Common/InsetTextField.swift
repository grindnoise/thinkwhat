//
//  InsetTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {

    var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 20) {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
