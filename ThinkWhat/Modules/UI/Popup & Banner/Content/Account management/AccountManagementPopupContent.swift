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
  public var actionPublisher = PassthroughSubject<[Action: AccountManagementCell.Mode], Never>()
  
  
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
    tagLabel.placeXCentered(inside: top,
                            topInset: padding*2,
                            bottomInset: -padding*2)
    
    let bottom = UIView.opaque()
    let buttonsStack = UIStackView(arrangedSubviews: [
      confirmButton,
      cancelButton
    ])
    buttonsStack.axis = .vertical
    buttonsStack.spacing = padding*2
    buttonsStack.placeInCenter(of: bottom,
                        topInset: padding*2,
                        bottomInset: padding*2)
    
    let instance = UIStackView(arrangedSubviews: [
      top,
      textView,
      bottom
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    
    return instance
  }()
  private lazy var tagLabel: TagCapsule = {
    var text = ""
    var image: UIImage!
    var color = Constants.UI.Colors.main
    
    switch mode {
    case .Logout:
      text = "account_logout".localized.uppercased()
      image = UIImage(systemName: "rectangle.portrait.and.arrow.forward", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
    case .Delete:
      text = "account_delete".localized.uppercased()
      color = .systemRed
      image = UIImage(systemName: "envelope.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
    case .EmailChange:
      text = "account_email_change".localized.uppercased()
      image = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
    }
    
    return TagCapsule(text: text,
                      padding: padding,
                      textPadding: .init(top: padding, left: 0, bottom: padding, right: padding),
                      color: color,
                      font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!,
                      isShadowed: false,
                      iconCategory: nil,
                      image: image)
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
    
    var text = ""
    
    switch mode {
    case .Logout:
      text = "account_logout_description".localized
    case .Delete:
      text = "account_delete_description".localized
    case .EmailChange:
      text = "account_email_change_description".localized
    }
    
    instance.attributedText = NSAttributedString(string: text,
                                                 attributes: [
                                                  .paragraphStyle: paragraph,
                                                  .font: UIFont(name: Fonts.Rubik.Regular, size: 16) as Any,
                                                  .foregroundColor: UIColor.label
                                                 ])
    instance.isUserInteractionEnabled = false
    
    return instance
  }()
  private lazy var confirmButton: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .capsule
      config.baseBackgroundColor = mode == .Delete ? .systemRed : color
      config.attributedTitle = AttributedString("confirm".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "confirm".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                      .foregroundColor: color as Any
                                                     ]),
                                  for: .normal)
    }
    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 52/188).isActive = true
    opaque.publisher(for: \.bounds)
      .filter { $0 != .zero && opaque.layer.shadowPath?.boundingBox != $0 }
      .sink { [unowned self] in
        opaque.layer.shadowOpacity = 1
        opaque.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? self.color.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
      }
      .store(in: &subscriptions)
    instance.place(inside: opaque)
    
    return opaque
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
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.secondaryLabel as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "cancel".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
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
    
    confirmButton.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 8 : 4
    confirmButton.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
    confirmButton.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? color.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
  }
}

private extension AccountManagementPopupContent {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self)
    
    confirmButton.translatesAutoresizingMaskIntoConstraints = false
    confirmButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  @objc
  func handleTap(sender: UIButton) {
    if sender == confirmButton.getSubview(type: UIButton.self) {
      actionPublisher.send([Action.Confirm: mode])
      actionPublisher.send(completion: .finished)
    } else {
      actionPublisher.send([Action.Cancel: mode])
      actionPublisher.send(completion: .finished)
    }
  }
}

