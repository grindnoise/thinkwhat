//
//  InsetTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {
  
  public var rightViewVerticalScaleFactor: CGFloat
  public var insets: UIEdgeInsets {
    didSet {
      guard oldValue != insets else { return }
      
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  init(rightViewVerticalScaleFactor: CGFloat = 1,
       insets: UIEdgeInsets = .zero) {
    self.insets = insets
    self.rightViewVerticalScaleFactor = rightViewVerticalScaleFactor
    
    super.init(frame: .zero)
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
    
    return CGRect(origin: CGPoint(x: bounds.width - (xInset/2 + height), y: yInset/2/*bounds.height - (yInset + height)*/),
                  size: .uniform(size: height))
  }
}
