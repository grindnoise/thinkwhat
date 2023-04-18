//
//  SignInView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SignInView: UIView {
  
  // MARK: - Public properties
  ///**UI**
  public private(set) lazy var logoIcon: Icon = {
  let instance = Icon(category: .Logo, scaleMultiplicator: 1, iconColor: Colors.Logo.Flame.rawValue)
  instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
  
  return instance
}()
  public private(set) lazy var stack: UIStackView = {
    let top = UIView.opaque()
    logoIcon.placeInCenter(of: top,
                           topInset: 0,
                           bottomInset: 0)
    let buttonView = UIView.opaque()
    loginButton.placeInCenter(of: buttonView,
                           topInset: 0,
                           bottomInset: 0)
    let instance = UIStackView(arrangedSubviews: [
      top,
      UIView.verticalSpacer(padding*5),
      loginContainer,
      passwordContainer,
//      UIView.verticalSpacer(padding),
      buttonView,
      label,
      logos,
      signupButton,
      forgotButton
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    
    return instance
  }()
  public private(set) lazy var loginContainer: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      UIView.horizontalSpacer(padding),
      loginTextField,
      UIView.horizontalSpacer(padding)
    ])
    instance.axis = .horizontal
    instance.spacing = 0
    let bgLayer = CAShapeLayer()
    bgLayer.name = "background"
    bgLayer.backgroundColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    let fgLayer = CAShapeLayer()
    fgLayer.name = "foreground"
    fgLayer.opacity = 0
    fgLayer.backgroundColor = Colors.Logo.Flame.rawValue.withAlphaComponent(0.2).cgColor
    instance.layer.insertSublayer(bgLayer, at: 0)
    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.publisher(for: \.bounds)
      .sink {
        bgLayer.frame = $0
        bgLayer.cornerRadius = $0.width*0.025
        fgLayer.frame = $0
        fgLayer.cornerRadius = $0.width*0.025
      }
      .store(in: &subscriptions)
    let opaque = UIView.opaque()
    opaque.addEquallyTo(to: instance)
    opaque.isUserInteractionEnabled = true
    opaque.accessibilityIdentifier = "login"
    opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    return instance
  }()
  public private(set) lazy var loginTextField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.backgroundColor = .clear
    instance.tintColor = Colors.main
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
    instance.clipsToBounds = false
    
    let bgLayer = CAShapeLayer()
    bgLayer.backgroundColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    let fgLayer = CAShapeLayer()
    fgLayer.name = "foreground"
    fgLayer.opacity = 0
    fgLayer.backgroundColor = Colors.Logo.Flame.rawValue.withAlphaComponent(0.1).cgColor
    instance.layer.insertSublayer(bgLayer, at: 0)
    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.attributedPlaceholder = NSAttributedString(string: "usernameTF".localized,
                                                        attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                        ])
    
    return instance
  }()
  public private(set) lazy var passwordContainer: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      UIView.horizontalSpacer(padding),
      passwordTextField,
      UIView.horizontalSpacer(padding)
    ])
    instance.axis = .horizontal
    instance.spacing = 0
    let bgLayer = CAShapeLayer()
    bgLayer.name = "background"
    bgLayer.backgroundColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    let fgLayer = CAShapeLayer()
    fgLayer.name = "foreground"
    fgLayer.opacity = 0
    fgLayer.backgroundColor = Colors.Logo.Flame.rawValue.withAlphaComponent(0.2).cgColor
    instance.layer.insertSublayer(bgLayer, at: 0)
    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.publisher(for: \.bounds)
      .sink {
        bgLayer.frame = $0
        bgLayer.cornerRadius = $0.width*0.025
        fgLayer.frame = $0
        fgLayer.cornerRadius = $0.width*0.025
      }
      .store(in: &subscriptions)
    let opaque = UIView.opaque()
    opaque.addEquallyTo(to: instance)
    opaque.isUserInteractionEnabled = true
    opaque.accessibilityIdentifier = "password"
    opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    return instance
  }()
  public private(set) lazy var passwordTextField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.backgroundColor = .clear
    instance.isSecureTextEntry = true
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
    instance.clipsToBounds = false
    instance.tintColor = Colors.main
    instance.attributedPlaceholder = NSAttributedString(string: "passwordTF".localized,
                                                        attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                        ])
    
    return instance
  }()
  public private(set) lazy var loginButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.buttonTapped(_:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .small
      config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
      config.baseBackgroundColor = Colors.Logo.Flame.rawValue
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.attributedTitle = AttributedString("loginButton".localized.uppercased(),
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.width * 0.025 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "loginButton".localized.uppercased(),
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  public private(set) lazy var label: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 0
    instance.textAlignment = .center
    instance.text = "providerLabel".localized
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
    
    return instance
  }()
  public private(set) lazy var google: GoogleLogo = {
    let instance = GoogleLogo()
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.isOpaque = false
    
    return instance
  }()
  public private(set) lazy var vk: VKLogo = {
    let instance = VKLogo()
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.isOpaque = false
    
    return instance
  }()
  public private(set) lazy var logos: UIView = {
    let instance = UIView.opaque()
    let stack = UIStackView(arrangedSubviews: [
      google,
    ])
    if let countryCode = UserDefaults.App.countryByIP {
      if countryCode == "RU" {
        stack.addArrangedSubview(vk)
      }
    }
    stack.axis = .horizontal
    stack.placeInCenter(of: instance,
                        topInset: 0,
                        bottomInset: 0)
    
    return instance
  }()
  public private(set) lazy var signupButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.buttonTapped(_:)),
                       for: .touchUpInside)
    instance.setAttributedTitle(NSAttributedString(string: "signupButton".localized,
                                                   attributes: [
                                                    .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .subheadline) as Any,
                                                    .foregroundColor: Colors.main as Any
                                                   ]),
                                for: .normal)
    
    return instance
  }()
  public private(set) lazy var forgotButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.buttonTapped(_:)),
                       for: .touchUpInside)
    instance.setAttributedTitle(NSAttributedString(string: "forgotLabel".localized,
                                                   attributes: [
                                                    .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .subheadline) as Any,
                                                    .foregroundColor: Colors.main as Any
                                                   ]),
                                for: .normal)
    
    return instance
  }()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  
  
  
  // MARK: - Public properties
  weak var viewInput: SignInViewInput? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
    }
  }
  
  
  
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
}

extension SignInView: SignInControllerOutput {
  
}

private extension SignInView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    
//    stack.placeCentered(inside: self, withMultiplier: 0.75)
//    setNeedsLayout()
//    layoutIfNeeded()
    
    addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    loginTextField.translatesAutoresizingMaskIntoConstraints = false
    passwordTextField.translatesAutoresizingMaskIntoConstraints = false
    logoIcon.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35).isActive = true
    loginTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6).isActive = true
    passwordTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6).isActive = true
    loginTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: loginTextField.font!) + padding*2).isActive = true
    passwordTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: passwordTextField.font!) + padding*2).isActive = true
    stack.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
    stack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
    google.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
  }
  
  @objc
  func handleTap(_ sender: UITapGestureRecognizer) {
    
    if sender.view?.accessibilityIdentifier == "password",
       let foreground = passwordContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first,
       let background = passwordContainer.layer.sublayers?.filter({ $0.name == "background" }).first,
       !passwordTextField.isFirstResponder {
      
      Animations.unmaskLayerCircled(layer: foreground,
                                    location: sender.location(ofTouch: 0, in: passwordContainer),
                                    duration: 0.4,
                                    opacityDurationMultiplier: 1,
                                    delegate: self) { [unowned self] in self.passwordTextField.becomeFirstResponder() }
      background.add(Animations.get(property: .Opacity, fromValue: 1, toValue: 0, duration: 0.3, delegate: nil), forKey: nil)
      background.opacity = 0
      passwordTextField.becomeFirstResponder()
    } else if sender.view?.accessibilityIdentifier == "login",
              let foreground = loginContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first,
              let background = loginContainer.layer.sublayers?.filter({ $0.name == "background" }).first,
              !loginTextField.isFirstResponder {
      loginTextField.becomeFirstResponder()
      
      Animations.unmaskLayerCircled(layer: foreground,
                                    location: sender.location(ofTouch: 0, in: passwordContainer),
                                    duration: 0.4,
                                    opacityDurationMultiplier: 1,
                                    delegate: self) { [unowned self] in self.loginTextField.becomeFirstResponder() }
      background.add(Animations.get(property: .Opacity, fromValue: 1, toValue: 0, duration: 0.3, delegate: nil), forKey: nil)
      background.opacity = 0
    } else if sender.view?.accessibilityIdentifier == "recognizer" {
      sender.view?.removeFromSuperview()
      endEditing(true)
    } 
  }
  
  @objc
  func buttonTapped(_ sender: UIButton) {
    guard let username = loginTextField.text,
          let password = loginTextField.text
    else { return }
    
    if sender === loginButton {
      if username.isEmpty {
        loginTextField.showSign(state: .UsernameNotFilled)
      } else if password.isEmpty {
        passwordTextField.showSign(state: .UsernameNotFilled)
      } else {
        viewInput?.mailLogin(username: username, password: password)
      }
    }
  }
}

extension SignInView: UITextFieldDelegate {
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField else { return true }
    
    textField.hideSign()
    
    getSubview(type: UIView.self, identifier: "recognizer")?.removeFromSuperview()
    
    if textField === loginTextField,
       let background = loginContainer.layer.sublayers?.filter({ $0.name == "background" }).first,
       let layer = loginContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first {
      
      Animations.unmaskLayerCircled(unmask: false,
                                    layer: layer,
                                    location: CGPoint(x: loginContainer.bounds.midX, y: loginContainer.bounds.midY),
                                    duration: 0.2,
                                    opacityDurationMultiplier: 1,
                                    delegate: self) { layer.opacity = 0 }
      background.add(Animations.get(property: .Opacity, fromValue: 0, toValue: 1, duration: 0.2, delegate: nil), forKey: nil)
      background.opacity = 1
    } else if textField === passwordTextField,
              let background = passwordContainer.layer.sublayers?.filter({ $0.name == "background" }).first,
              let layer = passwordContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first {
      
      Animations.unmaskLayerCircled(unmask: false,
                                    layer: layer,
                                    location: CGPoint(x: loginContainer.bounds.midX, y: loginContainer.bounds.midY),
                                    duration: 0.2,
                                    opacityDurationMultiplier: 1,
                                    delegate: self) { layer.opacity = 0 }
      background.add(Animations.get(property: .Opacity, fromValue: 0, toValue: 1, duration: 0.2, delegate: nil), forKey: nil)
      background.opacity = 1
    }
    return true
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField else { return true }
    
    textField.hideSign()
    let opaque = UIView.opaque()
    opaque.accessibilityIdentifier = "recognizer"
    opaque.isUserInteractionEnabled = true
    opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
    opaque.place(inside: self)
    
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    
    return true
  }
}

extension SignInView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    }
  }
}
