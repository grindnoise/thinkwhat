//
//  UnderlinedSignTextField.swift
//  Burb
//
//  Created by Pavel Bukharov on 13.08.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class UnderlinedSignTextField: UnderlinedTextField {

//    public var isWarning = false {
//        didSet {
//            if isWarning != oldValue {
//                if isWarning {
//                    checkSign.alpha = 0
//                    warningSign.alpha = 1
//                } else {
//                    checkSign.alpha = 1
//                    warningSign.alpha = 0
//                }
//            }
//        }
//    }
    private var checkSign:      ValidSign!
    private var warningSign:    WarningSign!
    
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
            self.rightView?.alpha = 0
        }
        if checkSign == nil || warningSign == nil {
            checkSign = ValidSign(frame: CGRect(origin: CGPoint.zero, size: rightViewSize))
            checkSign.isOpaque = false
            checkSign.addEquallyTo(to: rightView!)
            warningSign = WarningSign(frame: CGRect(origin: CGPoint.zero, size: rightViewSize))
            warningSign.isOpaque = false
            warningSign.addEquallyTo(to: rightView!)
        }
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let width = min(bounds.size.width, rightViewSize.width)
        let height = min(bounds.size.height, rightViewSize.height)
        let rect = CGRect(x: bounds.width - rightViewSize.width, y: bounds.size.height / 2 - height / 2, width: width, height: height)
        
        return rect
    }
    
    public func showSign(isWarning: Bool) {
        if isWarning {
            UIView.animate(withDuration: 0.15, animations: {
                self.checkSign.alpha = 0
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.warningSign.alpha = 1
                }
            }
        } else {
            UIView.animate(withDuration: 0.15, animations: {
                self.checkSign.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.warningSign.alpha = 0
                }
            }
        }
        if rightView?.alpha == 0 {
            UIView.animate(withDuration: 0.2) {
                self.rightView!.alpha = 1
            }
        }
    }
    
    public func hideSign(isWarning: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.rightView!.alpha = 0
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
