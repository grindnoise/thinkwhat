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
        case InvalidHyperlink       =   "invalid_url_error"
        case BirthDateIsEmpty       =   "birthdate_is_empty"
        
        func localizedString() -> String {
            return self.rawValue.localized.firstUppercased
        }
    }
    
    public var isShowingSign = false
    public var customRightView: UIView? {
        didSet {
            guard !rightView.isNil else {
                oldValue?.removeFromSuperview()
//                clearButtonMode = .always
                return
            }
            rightView!.subviews.filter({ $0 == oldValue }).first?.removeFromSuperview()
            customRightView?.addEquallyTo(to: rightView!)//, multiplier: 1.25)
        }
    }
    public var isShowingSpinner = false {
        didSet {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
                if self.isShowingSpinner {
                    if self.spinner.isNil {
                        self.spinner = UIActivityIndicatorView(frame: self.rightView!.frame)
                        self.spinner?.color = self.color
                        self.spinner?.addEquallyTo(to: self.rightView!)
                        self.spinner?.alpha = 0
                    }
                    self.spinner?.alpha = 1
                    self.spinner?.startAnimating()
                    self.rightView?.subviews.filter{ $0.isKind(of: Icon.self) }.forEach{ $0.transform = CGAffineTransform(scaleX: 0, y: 0)}
                } else {
                    self.spinner?.alpha = 0
                    self.rightView?.subviews.filter{ $0.isKind(of: Icon.self) }.forEach{ $0.transform = CGAffineTransform(scaleX: 1, y: 1)}
                }
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    if !self.isShowingSpinner {
                        self.spinner?.stopAnimating()
//                        self.spinner?.removeFromSuperview()
                    }
                }
            }
        }
    }
    private var checkSign:      Icon!
    private var warningSign:    Icon!
    private var lowerTextView:  UITextView!
    private var spinner: UIActivityIndicatorView?
    private var lowerTextFieldTopConstant: CGFloat = 0

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

    var color: UIColor = Constants.UI.Colors.main {
        didSet {
            guard warningSign != nil, checkSign != nil, lowerTextView != nil else { return }
            UIView.animate(withDuration: 0.3) {
                self.lowerTextView.textColor = self.color
//                self.spinner.color = self.color
            }
            let fillColorAnim   = Animations.get(property: .FillColor,
                                                 fromValue: oldValue.cgColor as Any,
                                                 toValue: color.cgColor as Any,
                                                 duration: 0.3,
                                                 delay: 0,
                                                 repeatCount: 0,
                                                 autoreverses: false,
                                                 timingFunction: CAMediaTimingFunctionName.easeIn,
                                                 delegate: nil,
                                                 isRemovedOnCompletion: false)
            warningSign.icon.add(fillColorAnim, forKey: nil)
            checkSign.icon.add(fillColorAnim, forKey: nil)
        }
    }
    
//    override var text: String? {
//        didSet {
//            if text != nil, text!.isEmpty {
//                UIView.animate(withDuration: 0.2) {
//
//                }
//            }
//        }
//    }
//    init(lowerTextFieldTopConstant: CGFloat = 0) {
//        self.lowerTextFieldTopConstant = lowerTextFieldTopConstant
//        super.init(frame: .zero)
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        super.init(frame: .zero)
////        fatalError("init(coder:) has not been implemented")
//    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard rightView.isNil else { return }
        rightViewMode = .always
        rightView = UIView()
        rightView?.frame = rightViewRect(forBounds: frame)
        
      guard checkSign.isNil || warningSign.isNil || lowerTextView.isNil else  { return }
      
      checkSign = Icon()
      checkSign.iconColor = .systemGreen
      checkSign.category = .Success
      checkSign.alpha = 0
      checkSign.backgroundColor = .clear
      checkSign.addEquallyTo(to: rightView!)
      warningSign = Icon()
      warningSign.iconColor = .systemRed//Colors.main
      warningSign.category = .Caution
      warningSign.backgroundColor = .clear
      warningSign.alpha = 0
      warningSign.addEquallyTo(to: rightView!)
      lowerTextView = UITextView()
      lowerTextView.alpha = 0
      lowerTextView.isEditable = false
      lowerTextView.isSelectable = false
      lowerTextView.textColor = color
        lowerTextView.isScrollEnabled = false
        lowerTextView.textContainerInset = UIEdgeInsets(top: 0,
                                                        left: -5,
                                                        bottom: 0,
                                                        right: 0)
        superview?.addSubview(lowerTextView)
        lowerTextView.translatesAutoresizingMaskIntoConstraints = false
        lowerTextView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        lowerTextView.topAnchor.constraint(equalTo: bottomAnchor, constant: lowerTextFieldTopConstant).isActive = true
        lowerTextView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lowerTextView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lowerTextView.backgroundColor = .clear
        ///Add custom view
        guard !customRightView.isNil else { return }
        customRightView?.addEquallyTo(to: rightView!,
                                      multiplier: 1.25)
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let width = min(bounds.size.width, rightViewSize.width)
        let height = min(bounds.size.height, rightViewSize.height)
        let rect = CGRect(x: bounds.width - rightViewSize.width,
                          y: bounds.size.height / 2 - height / 2,
                          width: width,
                          height: height)
        return rect
    }
    
    public func showSign(state: SignState) {
        isShowingSign = true
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
        case .InvalidHyperlink:
            UIView.animate(withDuration: 0.15) {
                self.lowerTextView.text = state.rawValue.localized
                self.lowerTextView.alpha = 1
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
        
//        if rightView?.alpha == 0 {
//            UIView.animate(withDuration: 0.2) {
//                self.rightView!.alpha = 1
//            }
//        }
    }
    
    public func hideSign() {
        isShowingSign = false
        UIView.animate(withDuration: 0.2) {
            self.checkSign.alpha = 0
            self.warningSign.alpha = 0
            self.lowerTextView.alpha = 0
        }
    }
}
