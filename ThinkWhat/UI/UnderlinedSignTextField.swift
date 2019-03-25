//
//  UnderlinedSignTextField.swift
//  Burb
//
//  Created by Pavel Bukharov on 13.08.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class UnderlinedSignTextField: UnderlinedTextField {

    private var sign: ValidSign!
    private var signSize = CGSize(width: 32, height: 32) {
        didSet {
            layoutSubviews()
        }
    }
    
    private var rightViewSize: CGSize {
        return CGSize(
            width: signSize.width,
            height: signSize.height)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if rightView == nil {
            rightViewMode = .always
            rightView = UIView()
            rightView?.frame = rightViewRect(forBounds: frame)
        }
        if sign == nil {
            sign = ValidSign(frame: CGRect(origin: CGPoint.zero, size: rightViewSize))
            sign.isOpaque = false
            sign.addEquallyTo(to: rightView!)
        }
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let width = min(bounds.size.width, rightViewSize.width)
        let height = min(bounds.size.height, rightViewSize.height)
        let rect = CGRect(x: bounds.width - rightViewSize.width, y: bounds.size.height / 2 - height / 2, width: width, height: height)
        
        return rect
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
