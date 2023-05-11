//
//  UserInfoCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 06.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserInfoCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard let userprofile = userprofile else { return }

//      defer {
//        setupTextView(textView)
//      }
//      setupUI()
      
      setupUI()
    }
  }
  ///**UI**
  public var padding: CGFloat = 8
  public var insets: UIEdgeInsets?
  public var color: UIColor = Colors.System.Red.rawValue {
    didSet {
      textView.tintColor = color
      
      guard let toolBar = textView.inputAccessoryView as? UIToolbar else { return }
      
      toolBar.tintColor = color
    }
  }
  ///**Publishers**
  public private(set) var descriptionPublisher = PassthroughSubject<String, Never>()
  ///**Logic**
  ///`true` - animated
  @Published public private(set) var boundsPublisher: Bool?
  @Published public private(set) var scrollPublisher: CGPoint?
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var isAnimationEnabled = false
  ///**UI**
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      disclosureLabel,
      textView
    ])
    instance.axis = .vertical
    instance.spacing = padding
    
    return instance
  }()
//  private lazy var background: UIView = {
//    let instance = UIView()
//    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//
//    stack.place(inside: instance,
//                insets: .uniform(size: padding),
//                bottomPriority: .defaultLow)
//
//    return instance
//  }()
  private lazy var disclosureLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.text = "userprofile_about".localized.uppercased()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    
    let heightConstraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
    heightConstraint.identifier = "height"
    heightConstraint.priority = .defaultHigh
    heightConstraint.isActive = true
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard let self = self,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var textView: UITextView = {
    let instance = UITextView()
//    instance.backgroundColor = .quaternarySystemFill
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    instance.textContainerInset = UIEdgeInsets(top: 8,
                                               left: 0,
                                               bottom: 8,
                                               right: 0)
    let constraint = instance.heightAnchor.constraint(equalToConstant: 10)
    constraint.isActive = true
    
    if !userprofile.isCurrent {
      let paragraph = NSMutableParagraphStyle()
      if #available(iOS 15.0, *) {
        paragraph.usesDefaultHyphenation = true
      } else {
        paragraph.hyphenationFactor = 1
      }
      paragraph.alignment = .natural
      paragraph.firstLineHeadIndent = padding * 2
      instance.attributedText = NSAttributedString(string: userprofile.description.isEmpty ? "-" : userprofile.description,
                                                   attributes: attributes())
    } else {
      instance.delegate = self
      instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
      instance.text = userprofile.description
    }
    instance.backgroundColor = userprofile.isCurrent ? Colors.textField(color: .white, traitCollection: traitCollection) : .clear
    instance.isUserInteractionEnabled = userprofile.isCurrent ? true : false
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
    toolBar.isTranslucent = true
    toolBar.accessibilityIdentifier = "toolBar"
    toolBar.backgroundColor = .tertiarySystemBackground
    toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    toolBar.superview?.backgroundColor = .tertiarySystemBackground
    let doneButton = UIBarButtonItem(title: "ok".localized, style: .done, target: nil, action: #selector(self.hideKeyboard))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolBar.items = [space, doneButton]
    toolBar.barStyle = .default
    toolBar.tintColor = color
    instance.inputAccessoryView = toolBar
    
    observers.append(instance.observe(\.contentSize, options: .new) { [weak self] view, value in
      guard let self = self,
            let height = value.newValue?.height,
            constraint.constant != height
      else { return }
      
      guard self.isAnimationEnabled else {
        self.setNeedsLayout()
        constraint.constant = max(height, 40)
        self.layoutIfNeeded()
        self.boundsPublisher = self.isAnimationEnabled
        
        return
      }
      
      UIView.animate(withDuration: 0.3) {[weak self]  in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        constraint.constant = max(height, 40)
        self.layoutIfNeeded()
        self.boundsPublisher = self.isAnimationEnabled
      }
    })
    
    return instance
  }()
  
  
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
//    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    textView.backgroundColor = userprofile.isCurrent ? Colors.textField(color: .white, traitCollection: traitCollection) : .clear
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    descriptionPublisher = PassthroughSubject<String, Never>()
  }
  
  
  // MARK: - Public methods
  public func setInsets(_ insets: UIEdgeInsets) {
    self.insets = insets
    
    setupUI()
  }
  
  public func setPadding(_ padding: CGFloat) {
    self.insets = .zero
    self.padding = padding
    
    setupUI()
  }
}

private extension UserInfoCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    
    stack.place(inside: self,
                     insets: insets ?? .uniform(size: padding),
                     bottomPriority: .defaultLow)
//
//    background.removeFromSuperview()
//
//    guard insets != .zero else {
//      background.place(inside: self,
//                       insets: .uniform(size: padding),
//                       bottomPriority: .defaultLow)
//      return
//    }
//
//    background.place(inside: self,
//                     insets: insets,
//                     bottomPriority: .defaultLow)
  }
  
  func attributes() -> [NSAttributedString.Key: Any] {
    let font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
    let paragraphStyle = NSMutableParagraphStyle()
    if #available(iOS 15.0, *) {
      paragraphStyle.usesDefaultHyphenation = true
    } else {
      paragraphStyle.hyphenationFactor = 1
    }
    return [
      .font: font as Any,
      .foregroundColor: UIColor.label,
      .paragraphStyle: paragraphStyle
    ]
  }
  
  @objc
  func hideKeyboard() {
    endEditing(true)
  }

//  private func setupTextView(_ textView: UITextView) {
//    switch mode {
//    case .ReadOnly:
//      let paragraph = NSMutableParagraphStyle()
//      if #available(iOS 15.0, *) {
//        paragraph.usesDefaultHyphenation = true
//      } else {
//        paragraph.hyphenationFactor = 1
//      }
//      paragraph.alignment = .natural
//      paragraph.firstLineHeadIndent = padding * 2
//      textView.attributedText = NSAttributedString(string: userprofile.description,
//                                                   attributes: attributes())
//      textView.backgroundColor = .clear
//    case .Write:
//      textView.backgroundColor = .secondarySystemFill//traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//      textView.delegate = self
//      textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
//      textView.text = userprofile.description
//    }
//    textView.isUserInteractionEnabled = mode == .Write ? true : false
//  }
}

extension UserInfoCell: UITextViewDelegate {
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    self.isAnimationEnabled = true
    scrollPublisher = disclosureLabel.convert(disclosureLabel.frame.origin, to: self)
    
    return true
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      let currentText = textView.text ?? ""
      guard let stringRange = Range(range, in: currentText) else { return false }
      let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
    
      return updatedText.count <= ModelProperties.shared.userprofileDescriptionMaxLength
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    guard let text = textView.text else { return }
    
    descriptionPublisher.send(text)
  }
}

