//
//  FlexibleTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class FlexibleTextView: UITextView {
  // limit the height of expansion per intrinsicContentSize
  
  private let minLength: Int
  private let maxLength: Int
  
  public var staticText: String = "" {
    didSet {
      guard !staticText.isEmpty else {
        // Preserve main input
        let tmp = text.isEmpty ? "" : String(text.suffix(from: text.index(text.startIndex, offsetBy: oldValue.count)))
        text = tmp
        placeholderTextView.isHidden = !text.isEmpty
        attributedText = NSAttributedString(string: "test", attributes: [
          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
          NSAttributedString.Key.foregroundColor: UIColor.label,
          NSAttributedString.Key.backgroundColor: UIColor.clear
        ])
        attributedText = NSAttributedString(string: tmp, attributes: [
          NSAttributedString.Key.font: font as Any,
          NSAttributedString.Key.foregroundColor: UIColor.label,
          NSAttributedString.Key.backgroundColor: UIColor.clear
        ])
        return
      }
      let tmp = text.isEmpty ? "" : String(text.suffix(from: text.index(text.startIndex, offsetBy: oldValue.count)))
      text = tmp
      placeholderTextView.isHidden = true
      attributedText =  NSAttributedString(string: staticText, attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .body) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.label,
        NSAttributedString.Key.backgroundColor: UIColor.systemGray2
      ])
      let attrString = NSMutableAttributedString()
      attrString.append(NSAttributedString(string: staticText, attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .body) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.label,
        NSAttributedString.Key.backgroundColor: UIColor.systemGray2
      ]))
      staticText += " "
      attrString.append(NSAttributedString(string: " \(tmp)", attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.label,
        NSAttributedString.Key.backgroundColor: UIColor.clear
      ]))
      attributedText = attrString
    }
  }
  var maxHeight: CGFloat = 0.0
  private let placeholderTextView: UITextView = {
    let tv = UITextView()
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.backgroundColor = .clear
    tv.isScrollEnabled = false
    tv.isUserInteractionEnabled = false
    tv.textColor = UIColor.gray
    return tv
  }()
  var placeholder: String? {
    get {
      return placeholderTextView.text
    }
    set {
      placeholderTextView.text = newValue
    }
  }
  
  init(minLength: Int, maxLength: Int) {
    self.minLength = minLength
    self.maxLength = maxLength
    
    super.init(frame: .zero, textContainer: nil)
    
    delegate = self
    isScrollEnabled = false
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
    NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: UITextView.textDidChangeNotification, object: self)
    placeholderTextView.font = font
    placeholderTextView.addEquallyTo(to: self)
  }
  
  //    override init(frame: CGRect, textContainer: NSTextContainer?) {
  //        super.init(frame: frame, textContainer: textContainer)
  //        delegate = self
  //        isScrollEnabled = false
  //        autoresizingMask = [.flexibleWidth, .flexibleHeight]
  //        NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: UITextView.textDidChangeNotification, object: self)
  //        placeholderTextView.font = font
  //        placeholderTextView.addEquallyTo(to: self)
  ////        addSubview(placeholderTextView)
  ////
  ////        NSLayoutConstraint.activate([
  ////            placeholderTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
  ////            placeholderTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
  ////            placeholderTextView.topAnchor.constraint(equalTo: topAnchor),
  ////            placeholderTextView.bottomAnchor.constraint(equalTo: bottomAnchor),
  ////        ])
  //    }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var text: String! {
    didSet {
      invalidateIntrinsicContentSize()
      placeholderTextView.isHidden = !text.isEmpty
    }
  }
  
  override var font: UIFont? {
    didSet {
      placeholderTextView.font = font
      invalidateIntrinsicContentSize()
    }
  }
  
  override var contentInset: UIEdgeInsets {
    didSet {
      placeholderTextView.contentInset = contentInset
    }
  }
  
  override var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize
    
    if size.height == UIView.noIntrinsicMetric {
      // force layout
      layoutManager.glyphRange(for: textContainer)
      size.height = layoutManager.usedRect(for: textContainer).height + textContainerInset.top + textContainerInset.bottom
    }
    
    if maxHeight > 0.0 && size.height > maxHeight {
      size.height = maxHeight
      
      if !isScrollEnabled {
        isScrollEnabled = true
      }
    } else if isScrollEnabled {
      isScrollEnabled = false
    }
    
    return size
  }
  
  @objc private func textDidChange(_ note: Notification) {
    // needed incase isScrollEnabled is set to true which stops automatically calling invalidateIntrinsicContentSize()
    invalidateIntrinsicContentSize()
    placeholderTextView.isHidden = !text.isEmpty
  }
  
  
}

extension FlexibleTextView: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    let maxCharacters = staticText.count + maxLength
    if range.location > maxCharacters { return false }
    
    guard !staticText.isEmpty else { return true }
    
    let minCharacters = staticText.count
    
    if range.location < minCharacters { return false }
    
    if text.count + minCharacters < minCharacters {
      return false
    }
    return true
  }
}
