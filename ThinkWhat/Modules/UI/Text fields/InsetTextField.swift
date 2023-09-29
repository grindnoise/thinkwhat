//
//  InsetTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {
  
  public var rightViewVerticalScaleFactor: CGFloat = 1
  public var insets: UIEdgeInsets = UIEdgeInsets.zero {// UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 20) {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  init(rightViewVerticalScaleFactor: CGFloat = 1) {
    super.init(frame: .zero)
    
    self.rightViewVerticalScaleFactor = rightViewVerticalScaleFactor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
  
  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    let xInset: CGFloat = insets.right
    let yInset: CGFloat = bounds.height - bounds.height/rightViewVerticalScaleFactor
    let height = bounds.height - xInset
    
    return CGRect(origin: CGPoint(x: bounds.width - (xInset + height), y: bounds.height - (yInset + height)),
                  size: .uniform(size: height))
  }
}
