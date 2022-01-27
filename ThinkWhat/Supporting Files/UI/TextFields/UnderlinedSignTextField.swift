//
//  UnderlinedSignTextField.swift
//  Burb
//
//  Created by Pavel Bukharov on 13.08.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class UnderlinedSignTextField: UnderlinedTextField {
    
    enum SignState: String {
        case Approved
        case UsernameExists         =   "username_is_busy"
        case UsernameNotFilled      =   "username_is_empty"
        case UsernameIsShort        =   "username_is_short"
        case EmailExists            =   "email_is_busy"
        case EmailIsIncorrect       =   "email_is_empty"
        case PasswordIsShort        =   "password_is_short"
        
        func localizedString() -> String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }

    private var checkSign:      ValidSign!
    private var warningSign:    WarningSign!
    private var lowerTextView:  UITextView!

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
        if checkSign == nil || warningSign == nil || lowerTextView == nil {
            checkSign = ValidSign(frame: CGRect(origin: CGPoint.zero, size: rightViewSize))
            checkSign.isOpaque = false
            checkSign.addEquallyTo(to: rightView!)
            warningSign = WarningSign(frame: CGRect(origin: CGPoint.zero, size: rightViewSize))
            warningSign.isOpaque = false
            warningSign.addEquallyTo(to: rightView!)
            lowerTextView = UITextView(frame: CGRect(origin: CGPoint(x: 0, y: frame.maxY), size: CGSize(width: frame.width, height: 16)))
            lowerTextView.alpha = 0
            lowerTextView.isEditable = false
            lowerTextView.isSelectable = false
            lowerTextView.textColor = .red
            lowerTextView.isScrollEnabled = false
            lowerTextView.textContainerInset = UIEdgeInsets(top: 0,left: -5,bottom: 0,right: 0)
            superview?.addSubview(lowerTextView)
        }
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let width = min(bounds.size.width, rightViewSize.width)
        let height = min(bounds.size.height, rightViewSize.height)
        let rect = CGRect(x: bounds.width - rightViewSize.width, y: bounds.size.height / 2 - height / 2, width: width, height: height)
        
        return rect
    }
    
    public func showSign(state: SignState) {
        switch state {
        case .Approved:
            UIView.animate(withDuration: 0.15, animations: {
                self.warningSign.alpha = 0
                self.lowerTextView.alpha = 0
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.checkSign.alpha = 1
                }
            }
        default:
            UIView.animate(withDuration: 0.15, animations: {
                self.checkSign.alpha = 0
            }) { _ in
                self.lowerTextView.text = state.localizedString()
                UIView.animate(withDuration: 0.15) {
                    self.lowerTextView.alpha = 1
                    self.warningSign.alpha = 1
                }
            }
        }
        
        if rightView?.alpha == 0 {
            UIView.animate(withDuration: 0.2) {
                self.rightView!.alpha = 1
            }
        }
    }
    
    public func hideSign() {
        UIView.animate(withDuration: 0.2) {
            self.rightView!.alpha = 0
            self.lowerTextView.alpha = 0
        }
    }
}
