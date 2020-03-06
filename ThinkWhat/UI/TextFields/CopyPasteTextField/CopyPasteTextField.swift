//
//  CopyPasteTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class CopyPasteTextField: UITextField {

    private var copyPasteSign: CopyPasteSign!
    private var signSize = CGSize.zero {//(width: 32, height: 32) {
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
        if signSize == .zero {
            signSize = CGSize(width: frame.height, height: frame.height)
        }
        
        super.layoutSubviews()
        if rightView == nil {
            rightViewMode = .always
            rightView = UIView()
            rightView?.frame = rightViewRect(forBounds: frame)
            self.rightView?.alpha = 0
            leftViewMode  = .always
            leftView = UIView()
            leftView?.frame = leftViewRect(forBounds: frame)
            self.leftView?.alpha = 0
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(CopyPasteTextField.copyPasteTapped))
            rightView?.addGestureRecognizer(recognizer)
        }
        if copyPasteSign == nil  {
            copyPasteSign = CopyPasteSign(frame: CGRect(origin: CGPoint.zero, size: rightViewSize))
            copyPasteSign.isOpaque = false
            copyPasteSign.addEquallyTo(to: rightView!)
        }
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let width = min(bounds.size.width, rightViewSize.width)
        let height = min(bounds.size.height, rightViewSize.height)
        let rect = CGRect(x: bounds.width - rightViewSize.width, y: bounds.size.height / 2 - height / 2, width: width, height: height)
        
        return rect
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let width = min(bounds.size.width, rightViewSize.width)
        let height = min(bounds.size.height, rightViewSize.height)
        let rect = CGRect(x: 0, y: bounds.size.height / 2 - height / 2, width: width, height: height)
        
        return rect
    }
    
    override func becomeFirstResponder() -> Bool {
        toggleSignVisibility(activate: true)
        super.becomeFirstResponder()
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        toggleSignVisibility(activate: false)
        super.resignFirstResponder()
        return true
    }
    
    public func toggleSignVisibility(activate: Bool = true) {
        UIView.animate(withDuration: 0.2) {
            self.rightView!.alpha = activate ? 1 : 0
        }
    }
    
    @objc fileprivate func copyPasteTapped() {
        let pasteboardString: String? = UIPasteboard.general.string
        if let theString = pasteboardString {
            text = theString
        }
    }
    
}
