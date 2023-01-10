//
//  FlexibleTextView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

//protocol AccessoryInputTextFieldDelegate: AnyObject {
//  func onSendEvent(_: String)
//  func onAnonSendEvent(username: String, text: String)
//}

final class AccessoryInputTextField: UITextField {
  
  override var text: String? {
    didSet {
      guard let text = text,
            text.isEmpty
      else { return }
      
      textView.text = ""
    }
  }
  
  // MARK: - Public properties
  //Publishers
  public let messagePublisher = PassthroughSubject<String, Never>()
  public let messageAnonPublisher = PassthroughSubject<[String: String], Never>()
  //UI
  public var placeholderText: String
  public var textViewFont: UIFont
  public var staticText: String = "" {
    didSet {
      textView.staticText = staticText
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let minLength: Int
  private let maxLength: Int
//  private weak var customDelegate: AccessoryInputTextFieldDelegate?
  private var isAnon = false
  //UI
  private lazy var accessoryInputView: ZeroSizedIntrisicContentView = {
    let instance = ZeroSizedIntrisicContentView()
    instance.autoresizingMask = .flexibleHeight
    instance.addSubview(textView)
    instance.addSubview(sendButton)
    
    textView.translatesAutoresizingMaskIntoConstraints = false
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    sendButton.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
    sendButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
    
    if isAnon {
      instance.addSubview(usernameTextView)
      usernameTextView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        usernameTextView.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
        usernameTextView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.5),
        //                usernameTextView.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
        usernameTextView.topAnchor.constraint(equalTo: instance.topAnchor,constant: 8),
        textView.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
        textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: 0),
        textView.topAnchor.constraint(equalTo: usernameTextView.bottomAnchor,constant: 8),
        textView.bottomAnchor.constraint(equalTo: instance.layoutMarginsGuide.bottomAnchor, constant: -8),
        sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0),
        sendButton.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
        sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
      ])
    } else {
      NSLayoutConstraint.activate([
        textView.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
        textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: 0),
        textView.topAnchor.constraint(equalTo: instance.topAnchor,constant: 8),
        textView.bottomAnchor.constraint(equalTo: instance.layoutMarginsGuide.bottomAnchor, constant: -8),
        sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0),
        sendButton.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
        sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
      ])
    }
    
    
    return instance
  }()
  private lazy var sendButton: UIButton = {
    let instance = UIButton(type: .system)
    instance.isEnabled = true
    instance.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(font: textViewFont, scale: .large)), for: .normal)
    instance.tintColor = .systemBlue
    instance.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    instance.addTarget(self, action: #selector(self.handleSend), for: .touchUpInside)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var textView: FlexibleTextView = {
    let instance = FlexibleTextView(minLength: minLength, maxLength: maxLength)
    instance.placeholder = "add_comment".localized
    instance.accessibilityIdentifier = "textView"
    instance.font = textViewFont
    instance.maxHeight = 80
    instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: 8, bottom: instance.contentInset.bottom, right: 8)
    
    observers.append(instance.observe(\FlexibleTextView.bounds, options: .new) { view, change in
      guard let value = change.newValue else { return }
      view.cornerRadius = value.width * 0.05
    })
    
    return instance
  }()
  private lazy var usernameTextView: FlexibleTextView = {
    let instance = FlexibleTextView(minLength: 3, maxLength: 20)
    instance.placeholder = "pseudonym_placeholder".localized
    instance.accessibilityIdentifier = "usernameTextView"
    instance.text = "pseudonym".localized
    instance.font = textViewFont
    instance.maxHeight = 80
    instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: 8, bottom: instance.contentInset.bottom, right: 8)
    
    observers.append(instance.observe(\FlexibleTextView.bounds, options: .new) { view, change in
      guard let value = change.newValue else { return }
      view.cornerRadius = value.height/2
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
  
  init(placeholder: String = "", font: UIFont, //delegate: AccessoryInputTextFieldDelegate,
       minLength: Int = .zero,
       maxLength: Int = .max,
       isAnon: Bool = false) {
    self.maxLength = maxLength
    self.minLength = minLength
//    self.customDelegate = delegate
    self.placeholderText = placeholder
    self.textViewFont = font
    self.isAnon = isAnon
    super.init(frame: .zero)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private methods
  private func setupUI() {
    let instance = UIInputView(frame: .zero, inputViewStyle: .keyboard)
    instance.allowsSelfSizing = true
    inputAccessoryView = instance
    instance.addSubview(accessoryInputView)
    accessoryInputView.translatesAutoresizingMaskIntoConstraints = false
    instance.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      accessoryInputView.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
      accessoryInputView.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
      accessoryInputView.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
      instance.topAnchor.constraint(equalTo: accessoryInputView.topAnchor)
    ])
  }
  
  @objc
  private func handleSend() {
    switch isAnon {
    case true:
      guard usernameTextView.text.count > ModelProperties.shared.anonMinLength else {
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                              text: "add_pseudonym",
                                                              tintColor: .systemOrange),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 1)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
        return
      }
      
      guard textView.text.count >= minLength else {
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                              text: "minimum_characters_needed".localized + "\(minLength)",
                                                              tintColor: .systemOrange),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 1)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
        return
      }
      
      messageAnonPublisher.send([usernameTextView.text: textView.text])
    case false:
      guard textView.text.count >= minLength else {
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                              text: "minimum_characters_needed".localized + "\(minLength)",
                                                              tintColor: .systemOrange),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 1)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
        return
      }
      
      messagePublisher.send(textView.text)
    }
      textView.resignFirstResponder()
    
//    if isAnon, usernameTextView.text.count < ModelProperties.shared.anonMinLength {
//      showBanner(bannerDelegate: self, text: "add_pseudonym".localized, content: UIImageView(image: UIImage(systemName: "exclamationmark.icloud.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemOrange.withAlphaComponent(1), shadowed: false)
//      return
//    }
    
//    guard textView.text.count >= minLength else {
//      showBanner(bannerDelegate: self, text: "minimum_characters_needed".localized + "\(minLength)", content: UIImageView(image: UIImage(systemName: "exclamationmark.icloud.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemOrange.withAlphaComponent(1), shadowed: false)
//      return
//    }
    
//    textView.resignFirstResponder()
//    if isAnon {
//      customDelegate?.onAnonSendEvent(username: usernameTextView.text, text: textView.text)
//    } else {
//      customDelegate?.onSendEvent(textView.text)
//    }
  }
  
  // MARK: - Public methods
  //    public func forceResignFirstResponder() {
  //        textView.resignFirstResponder()
  //    }
  
  // MARK: - Overriden methods
  override func becomeFirstResponder() -> Bool {
    super.becomeFirstResponder()
    
    textView.becomeFirstResponder()
    
    return true
  }
  
  override func resignFirstResponder() -> Bool {
    super.resignFirstResponder()
    
    textView.resignFirstResponder()
    
    return true
  }
}

class ZeroSizedIntrisicContentView: UIView {
  
  // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
  // actual value is not important
  
  override var intrinsicContentSize: CGSize {
    return CGSize.zero
  }
}
