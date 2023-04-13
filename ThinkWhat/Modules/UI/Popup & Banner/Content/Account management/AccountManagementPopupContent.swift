//
//  AccountManagementPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AccountManagementPopupContent: UIView {
  enum Action { case Confirm, Cancel }
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  public var actionPublisher = PassthroughSubject<AccountManagementCell.Mode, Never>()
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`Logic`
  private let mode: AccountManagementCell.Mode
  ///`UI`
  private let padding: CGFloat
  private let color: UIColor
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
    label.placeInCenter(of: top,
                        topInset: padding*2,
                        bottomInset: padding)
    
    let bottom = UIView.opaque()
    let buttonsStack = UIStackView(arrangedSubviews: [
      confirmButton,
      cancelButton
    ])
    buttonsStack.distribution = .fillEqually
    buttonsStack.contentMode = .left
    buttonsStack.axis = .horizontal
    buttonsStack.spacing = 4
    buttonsStack.placeInCenter(of: bottom,
                        topInset: padding,
                        bottomInset: padding)
    
    let instance = UIStackView(arrangedSubviews: [
      top,
      textView,
      bottom
    ])
    instance.axis = .vertical
    instance.spacing = padding
    bottom.translatesAutoresizingMaskIntoConstraints = false
    bottom.heightAnchor.constraint(equalTo: top.heightAnchor).isActive = true
    
    return instance
  }()
  private lazy var label: UIStackView = {
    let label = InsetLabel()
    label.font = UIFont(name: Fonts.Bold, size: 20)//.scaledFont(fontName: Fonts.Semibold, forTextStyle: .title2)
    label.text = mode == .Logout ? "account_logout".localized.uppercased() : "account_delete".localized.uppercased()
    label.textColor = .white
    label.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    let icon = UIImageView(image: UIImage(systemName: mode == .Logout ? "rectangle.portrait.and.arrow.forward" : "trash",
                                          withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
    icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1/1).isActive = true
    icon.tintColor = .white
    icon.contentMode = .center
    
    let opaque = UIView.opaque()
    opaque.widthAnchor.constraint(equalToConstant: padding/2).isActive = true
    
    let instance = UIStackView(arrangedSubviews: [
      opaque,
      icon,
      label
    ])
    instance.translatesAutoresizingMaskIntoConstraints = false
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: label.font)).isActive = true
    instance.axis = .horizontal
    instance.spacing = padding/2
    instance.backgroundColor = color
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    return instance
  }()
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.backgroundColor = .clear
//    instance.textContainerInset = UIEdgeInsets(top: padding*2,
//                                               left: 0,
//                                               bottom: padding*2,
//                                               right: 0)
    let paragraph = NSMutableParagraphStyle()
    if #available(iOS 15.0, *) {
        paragraph.usesDefaultHyphenation = true
    } else {
      paragraph.hyphenationFactor = 1
    }
    paragraph.alignment = .natural
    paragraph.firstLineHeadIndent = padding * 2
    let constraint = instance.heightAnchor.constraint(equalToConstant: 10)
    constraint.isActive = true
    
    observers.append(instance.observe(\.contentSize, options: .new) { [weak self] view, value in
      guard let self = self,
            let height = value.newValue?.height,
            constraint.constant != height
      else { return }
      
      self.setNeedsLayout()
      constraint.constant = height
      self.layoutIfNeeded()
    })
    instance.attributedText = NSAttributedString(string: mode == .Logout ? "account_logout_description".localized : "account_delete_description".localized,
                                                 attributes: [
                                                  .paragraphStyle: paragraph,
                                                  .font: UIFont(name: Fonts.Regular, size: 20) as Any,
                                                  .foregroundColor: UIColor.label
                                                 ])
    
    
    return instance
  }()
  private lazy var confirmButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .small
      config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
      config.baseBackgroundColor = color
      config.attributedTitle = AttributedString("confirm".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "confirm".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                      .foregroundColor: color as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  private lazy var cancelButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.plain()
      config.contentInsets = .uniform(size: 0)
      config.attributedTitle = AttributedString("cancel".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                  .foregroundColor: UIColor.secondaryLabel as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "cancel".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                      .foregroundColor: UIColor.secondaryLabel as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  
  
  
  // MARK: - Deinitialization
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
  init(mode: AccountManagementCell.Mode,
       color: UIColor,
       padding: CGFloat = 8) {
    
    self.mode = mode
    self.color = color
    self.padding = padding
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    let paragraph = NSMutableParagraphStyle()
    if #available(iOS 15.0, *) {
        paragraph.usesDefaultHyphenation = true
    } else {
      paragraph.hyphenationFactor = 1
    }
    paragraph.alignment = .natural
    paragraph.firstLineHeadIndent = padding * 2
    
    textView.attributedText = NSAttributedString(string: mode == .Logout ? "account_logout_description".localized : "account_delete_description".localized,
                                                 attributes: [
                                                  .paragraphStyle: paragraph,
                                                  .font: UIFont(name: Fonts.Regular, size: 20) as Any,
                                                  .foregroundColor: UIColor.label
                                                 ])
  }
}

private extension AccountManagementPopupContent {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self)
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  @objc
  func handleTap(sender: UIButton) {
    if sender == confirmButton {
      actionPublisher.send(mode)
      actionPublisher.send(completion: .finished)
    } else {
      actionPublisher.send(mode)
      actionPublisher.send(completion: .finished)
    }
  }
}

