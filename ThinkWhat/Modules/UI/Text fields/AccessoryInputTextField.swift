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
  public private(set) var staticText: String = "" {
    didSet {
      textView.staticText = staticText
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let userprofile: Userprofile
  ///**UI**
  private let color: UIColor
  private let minLength: Int
  private let maxLength: Int
  private var isBannerOnScreen = false
//  private weak var customDelegate: AccessoryInputTextFieldDelegate?
  private var isAnon = false
  //UI
  private lazy var accessoryInputView: ZeroSizedIntrisicContentView = {
    let instance = ZeroSizedIntrisicContentView()
    instance.autoresizingMask = .flexibleHeight
    instance.addSubview(textView)
    instance.addSubview(sendButton)
    let avatar = Avatar(userprofile: userprofile)
    instance.addSubview(avatar)
    
    textView.translatesAutoresizingMaskIntoConstraints = false
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    avatar.translatesAutoresizingMaskIntoConstraints = false
    sendButton.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
    sendButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
    
    if isAnon {
      instance.addSubview(usernameTextView)
      usernameTextView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        avatar.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: textViewFont) + 16),
        avatar.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
//        avatar.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
        avatar.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
        usernameTextView.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 8),
        usernameTextView.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
//        usernameTextView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.5),
        //                usernameTextView.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
        usernameTextView.topAnchor.constraint(equalTo: instance.topAnchor,constant: 8),
        textView.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 8),
        textView.topAnchor.constraint(equalTo: usernameTextView.bottomAnchor,constant: 8),
        textView.bottomAnchor.constraint(equalTo: instance.layoutMarginsGuide.bottomAnchor, constant: -8),
        sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0),
        sendButton.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
        sendButton.heightAnchor.constraint(equalTo: avatar.heightAnchor),
        sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
//        sendButton.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
      ])
    } else {
      
      NSLayoutConstraint.activate([
        avatar.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: textViewFont) + 16),
        avatar.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
//        avatar.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
        avatar.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
        textView.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 8),
        textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: 0),
        textView.topAnchor.constraint(equalTo: instance.topAnchor,constant: 8),
        textView.bottomAnchor.constraint(equalTo: instance.layoutMarginsGuide.bottomAnchor, constant: -8),
        sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0),
        sendButton.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
        sendButton.heightAnchor.constraint(equalTo: avatar.heightAnchor),
        sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
//        sendButton.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
      ])
    }
    
    
    return instance
  }()
  private lazy var sendButton: UIButton = {
    let instance = UIButton(type: .system)
    instance.isEnabled = true
    instance.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(font: textViewFont, scale: .large)), for: .normal)
    instance.tintColor = color
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
    instance.tintColor = color
    instance.maxHeight = 80
//    instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: 0, bottom: instance.contentInset.bottom, right: 0)
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.025 }
      .store(in: &subscriptions)

    return instance
  }()
  private lazy var usernameTextView: FlexibleTextView = {
    let instance = FlexibleTextView(minLength: 3, maxLength: 20)
    instance.placeholder = "pseudonym_placeholder".localized
    instance.accessibilityIdentifier = "usernameTextView"
    instance.text = !UserDefaults.Profile.pseudonym.isNil ? UserDefaults.Profile.pseudonym! : "pseudonym".localized + String(describing: Int.random(in: 1..<1000))
    instance.font = textViewFont
    instance.maxHeight = 80
    instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: 8, bottom: instance.contentInset.bottom, right: 8)
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.025 }
      .store(in: &subscriptions)
    instance.text.publisher
      .filter { !$0.isEmpty }
      .sink { UserDefaults.Profile.pseudonym = $0 }
      .store(in: &subscriptions)
    
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
  
  init(userprofile: Userprofile = Userprofile.anonymous,
       placeholder: String = "",
       color: UIColor = .systemBlue,
       font: UIFont, //delegate: AccessoryInputTextFieldDelegate,
       minLength: Int = .zero,
       maxLength: Int = .max,
       isAnon: Bool = false) {
    
    self.userprofile = userprofile
    self.color = color
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
    if isAnon {
      guard usernameTextView.text.count >= ModelProperties.shared.anonMinLength else {
        if !isBannerOnScreen {
          isBannerOnScreen = true
          let banner = NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                                                                text: "add_pseudonym",
                                                                tintColor: .systemRed),
                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                 isModal: false,
                                 isShadowed: false,
                                 useContentViewHeight: true,
                                 shouldDismissAfter: 1)
          banner.layer.zPosition = .greatestFiniteMagnitude
          banner.didDisappearPublisher
            .sink { [weak self] _ in
              guard let self = self else { return }
              
              self.isBannerOnScreen = false
              banner.removeFromSuperview()
            }
            .store(in: &self.subscriptions)
        }
        
        return
      }
    }
    
    let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard text.count >= minLength else {
      if !isBannerOnScreen {
        isBannerOnScreen = true
        let banner = NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                                                              text: "minimum_characters_needed".localized + "\(minLength)",
                                                              tintColor: .systemRed),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               isShadowed: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 1)
        banner.layer.zPosition = .greatestFiniteMagnitude
        banner.didDisappearPublisher
          .sink { [weak self] _ in
            guard let self = self else { return }
            
            self.isBannerOnScreen = false
            banner.removeFromSuperview()
          }
          .store(in: &self.subscriptions)
      }
      
      return
    }
    
    
    isAnon ? { messageAnonPublisher.send([usernameTextView.text: text]) }() : { messagePublisher.send(text) }()
    textView.resignFirstResponder()
  }
  
  // MARK: - Public methods
  public func setStaticText(_ text: String) {
    staticText = text
  }
  
  public func erase() {
    text = ""
    textView.text = ""
    staticText = ""
    usernameTextView.text = ""
  }
  
  /// Clears static text and leaves existing input
  public func eraseResponder() {
    staticText = ""
  }
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
