//
//  NewAccountView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewAccountView: UIView {
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private var isCorrect = false
  private var isMailFilled = false {
    didSet {
      if isMailFilled {
        mailTextField.showSign(state: .Approved)
        if isPwdFilled && isMailFilled && isLoginFilled {
          isCorrect = true
        }
      } else {
        isCorrect = false
      }
    }
  }
  private weak var content: EmailVerificationPopupContent?
  private var isPwdFilled = false {
    didSet {
      if isPwdFilled {
        passwordTextField.showSign(state: .Approved)
        if isPwdFilled && isMailFilled && isLoginFilled {
          isCorrect = true
        }
      } else {
        isCorrect = false
      }
      
    }
  }
  private var isLoginFilled = false {
    didSet {
      if isLoginFilled {
        loginTextField.showSign(state: .Approved)
        if isPwdFilled && isMailFilled && isLoginFilled {
          isCorrect = true
        }
      } else {
        isCorrect = false
      }
    }
  }
  
  
  // MARK: - Public properties
  weak var viewInput: NewAccountViewInput? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
    }
  }
  ///**Publishers**
  public var mailChecker = PassthroughSubject<String, Never>()
  public var nameChecker = PassthroughSubject<String, Never>()
  ///**UI**
  public private(set) lazy var logoText: LogoText = { LogoText() }()
  public private(set) lazy var logoIcon: Logo = {
    let instance = Logo()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.layer.masksToBounds = false
    instance.layer.shadowColor = Colors.main.cgColor
    instance.layer.shadowOffset = .zero
    instance.layer.shadowRadius = padding
    instance.layer.shadowOpacity = 0.5
    
    return instance
  }()
  public private(set) lazy var stack: UIStackView = {
    let top = UIView.opaque()
    logoIcon.placeInCenter(of: top,
                           topInset: 0,
                           bottomInset: 0)
    let spacer = UIView.opaque()
    logoText.placeInCenter(of: spacer,
                           topInset: 20,
                           bottomInset: 0)
    let buttonView = UIView.opaque()
    loginButton.placeInCenter(of: buttonView,
                              topInset: 0,
                              bottomInset: 0)
    
    let instance = UIStackView(arrangedSubviews: [
      top,
      spacer,
      UIView.verticalSpacer(0),
      //      UIView.verticalSpacer(padding),
      loginContainer,
      mailContainer,
      passwordContainer,
      //      UIView.verticalSpacer(padding),
      buttonView,
      UIView.verticalSpacer(padding),
      UIView.verticalSpacer(padding),
      UIView.verticalSpacer(padding),
      UIView.verticalSpacer(padding),
      UIView.verticalSpacer(padding),
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    instance.addGestureRecognizer(getTapRecogizer())
    
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
    bgLayer.backgroundColor = UIColor.secondarySystemFill.cgColor//(traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    //    let fgLayer = CAShapeLayer()
    //    fgLayer.name = "foreground"
    //    fgLayer.opacity = 0
    //    fgLayer.backgroundColor = UIColor.systemBackground.blended(withFraction: traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.2,
    //                                                               of: traitCollection.userInterfaceStyle == .dark ? .white : Colors.main).cgColor
    instance.layer.insertSublayer(bgLayer, at: 0)
    //    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.publisher(for: \.bounds)
      .sink {
        bgLayer.frame = $0
        bgLayer.cornerRadius = $0.width*0.025
        //        fgLayer.frame = $0
        //        fgLayer.cornerRadius = $0.width*0.025
      }
      .store(in: &subscriptions)
    //    let opaque = UIView.opaque()
    //    opaque.addEquallyTo(to: instance)
    //    opaque.isUserInteractionEnabled = true
    //    opaque.accessibilityIdentifier = "login"
    //    opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    return instance
  }()
  public private(set) lazy var loginTextField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.backgroundColor = .clear
    instance.tintColor = Colors.main
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.clipsToBounds = false
    instance.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
    
    let bgLayer = CAShapeLayer()
    bgLayer.backgroundColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    //    let fgLayer = CAShapeLayer()
    //    fgLayer.name = "foreground"
    //    fgLayer.opacity = 0
    //    fgLayer.backgroundColor = Colors.main.withAlphaComponent(0.1).cgColor
    instance.layer.insertSublayer(bgLayer, at: 0)
    //    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.attributedPlaceholder = NSAttributedString(string: "usernameTF".localized,
                                                        attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any
                                                        ])
    
    return instance
  }()
  public private(set) lazy var mailContainer: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      UIView.horizontalSpacer(padding),
      mailTextField,
      UIView.horizontalSpacer(padding)
    ])
    instance.axis = .horizontal
    instance.spacing = 0
    let bgLayer = CAShapeLayer()
    bgLayer.name = "background"
    bgLayer.backgroundColor = UIColor.secondarySystemFill.cgColor//(traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    //    let fgLayer = CAShapeLayer()
    //    fgLayer.name = "foreground"
    //    fgLayer.opacity = 0
    //    //    fgLayer.backgroundColor = Colors.Logo.Flame.rawValue.withAlphaComponent(0.2).cgColor
    //    fgLayer.backgroundColor = UIColor.systemBackground.blended(withFraction: traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.2,
    //                                                               of: traitCollection.userInterfaceStyle == .dark ? .white : Colors.main).cgColor
    instance.layer.insertSublayer(bgLayer, at: 0)
    //    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.publisher(for: \.bounds)
      .sink {
        bgLayer.frame = $0
        bgLayer.cornerRadius = $0.width*0.025
        //        fgLayer.frame = $0
        //        fgLayer.cornerRadius = $0.width*0.025
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  public private(set) lazy var mailTextField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.keyboardType = .emailAddress
    instance.backgroundColor = .clear
    instance.tintColor = Colors.main
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.clipsToBounds = false
    instance.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
    
    let bgLayer = CAShapeLayer()
    bgLayer.backgroundColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    //    let fgLayer = CAShapeLayer()
    //    fgLayer.name = "foreground"
    //    fgLayer.opacity = 0
    //    fgLayer.backgroundColor = Colors.main.withAlphaComponent(0.1).cgColor
    instance.layer.insertSublayer(bgLayer, at: 0)
    //    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.attributedPlaceholder = NSAttributedString(string: "mailTF".localized,
                                                        attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any
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
    bgLayer.backgroundColor = UIColor.secondarySystemFill.cgColor//(traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    //    let fgLayer = CAShapeLayer()
    //    fgLayer.name = "foreground"
    //    fgLayer.opacity = 0
    //    fgLayer.backgroundColor = UIColor.systemBackground.blended(withFraction: traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.2,
    //                                                               of: traitCollection.userInterfaceStyle == .dark ? .white : Colors.main).cgColor
    instance.layer.insertSublayer(bgLayer, at: 0)
    //    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.publisher(for: \.bounds)
      .sink {
        bgLayer.frame = $0
        bgLayer.cornerRadius = $0.width*0.025
        //        fgLayer.frame = $0
        //        fgLayer.cornerRadius = $0.width*0.025
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  public private(set) lazy var passwordTextField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.backgroundColor = .clear
    instance.isSecureTextEntry = true
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.clipsToBounds = false
    instance.tintColor = Colors.main
    instance.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
    instance.attributedPlaceholder = NSAttributedString(string: "passwordTF".localized,
                                                        attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any
                                                        ])
    
    return instance
  }()
  public private(set) lazy var loginButton: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.buttonTapped(_:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .capsule
      config.baseBackgroundColor = Colors.main
      config.attributedTitle = AttributedString("signupButton".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.backgroundColor = Colors.main
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.width * 0.025 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "signupButton".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    opaque.publisher(for: \.bounds)
      .filter { $0 != .zero && opaque.layer.shadowPath?.boundingBox != $0 }
      .sink { [unowned self] in
        opaque.layer.shadowOpacity = 1
        opaque.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
      }
      .store(in: &subscriptions)
    instance.place(inside: opaque)
    
    return opaque
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
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
  }
}

extension NewAccountView: NewAccountControllerOutput {
  func signupCallback(result: Result<Bool, Error>) {
    isUserInteractionEnabled = true
    viewInput?.sendVerificationCode { [weak self] in
      guard let self = self else { return }
      
      switch $0 {
      case .success(let dict):
        guard let code = dict["confirmation_code"] as? Int,
              let expiresString = dict["expires_in"] as? String,
              let expiresDate = expiresString.dateTime,
              let email = self.mailTextField.text,
              let components = email.components(separatedBy: "@") as? [String],
              let username = components.first,
              let firstLetter = username.first,
              let lastLetter = username.last
        else { return }
        
        //              let email = "pbuxaroff@gmail.com"
        let banner = NewPopup(padding: self.padding*2,
                              contentPadding: .uniform(size: self.padding*2))
        let content = EmailVerificationPopupContent(code: code,
                                                    retryTimeout: 60,
                                                    email: email.replacingOccurrences(of: username, with: "\(firstLetter)\(String.init(repeating: "*", count: username.count-2))\(lastLetter)"),
                                                    color: Colors.main)
        content.verifiedPublisher
          .delay(for: .seconds(0.25), scheduler: DispatchQueue.main)
          .sink { [weak self] in
            guard let self = self else { return }
            
            self.viewInput?.emailConfirmed()
            AppData.isEmailVerified = true
            banner.dismiss()
          }
          .store(in: &banner.subscriptions)
        content.retryPublisher
          .sink { [unowned self] in self.viewInput?.sendVerificationCode { [unowned self] in
            
            switch $0 {
            case .success(let dict):
              guard let code = dict["confirmation_code"] as? Int else { return }
              AppData.emailVerificationCode
              
              content.onEmailSent(code)
            case.failure(let error):
#if DEBUG
              error.printLocalized(class: type(of: self), functionName: #function)
#endif
              let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                                    text: AppError.server.localizedDescription,
                                                                    tintColor: .systemRed,
                                                                    fontName: Fonts.Rubik.Regular,
                                                                    textStyle: .subheadline,
                                                                    textAlignment: .natural),
                                     contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                     isModal: false,
                                     useContentViewHeight: true,
                                     shouldDismissAfter: 2)
              banner.didDisappearPublisher
                .sink { _ in banner.removeFromSuperview() }
                .store(in: &self.subscriptions)
            }
          }}
          .store(in: &banner.subscriptions)
        banner.setContent(content)
        banner.didDisappearPublisher
          .sink { [unowned self] _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
      case .failure(let error):
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                              text: AppError.server.localizedDescription,
                                                              tintColor: .systemRed,
                                                              fontName: Fonts.Rubik.Regular,
                                                              textStyle: .subheadline,
                                                              textAlignment: .natural),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
      self.loginButton.setSpinning(on: false, color: .white, animated: true) {
        if #available(iOS 15, *) {
          self.loginButton.getSubview(type: UIButton.self)!.configuration?.attributedTitle = AttributedString("signupButton".localized,
                                                                                                              attributes: AttributeContainer([
                                                                                                                .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                                                .foregroundColor: UIColor.white as Any
                                                                                                              ]))
        } else {
          self.loginButton.getSubview(type: UIButton.self)!.setAttributedTitle(NSAttributedString(string: "signupButton".localized,
                                                                                                  attributes: [
                                                                                                    .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                                    .foregroundColor: UIColor.white as Any
                                                                                                  ]),
                                                                               for: .normal)
        }
      }
    }
  }
  
  func nameCheckerCallback(result: Result<Bool, Error>) {
    switch result {
    case .success(let exists):
      if !exists {
        if self.loginTextField.text!.count >= 4 {
          self.isLoginFilled = true
        }
      } else {
        self.loginTextField.showSign(state: .UsernameExists)
        self.isLoginFilled = false
      }
    case .failure(let error):
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
    }
    loginTextField.isShowingSpinner = false
  }
  
  func mailCheckerCallback(result: Result<Bool, Error>) {
    switch result {
    case .success(let exists):
      if !exists {
        self.isMailFilled = true
      } else {
        self.mailTextField.showSign(state: .EmailExists)
        self.isMailFilled = false
      }
    case .failure(let error):
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
    }
    mailTextField.isShowingSpinner = false
  }
}

private extension NewAccountView {
  @MainActor
  func setupUI() {
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    addGestureRecognizer(getTapRecogizer())
    addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
    stack.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
    stack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
    
    loginTextField.translatesAutoresizingMaskIntoConstraints = false
    loginTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: loginTextField.font!) + padding*2).isActive = true
    mailTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: mailTextField.font!) + padding*2).isActive = true
    passwordTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: passwordTextField.font!) + padding*2).isActive = true
    
    loginButton.translatesAutoresizingMaskIntoConstraints = false
    loginButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    loginButton.widthAnchor.constraint(equalTo: loginButton.heightAnchor, multiplier: 188/52).isActive = true
    
    logoIcon.translatesAutoresizingMaskIntoConstraints = false
    logoIcon.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.31).isActive = true
    logoText.translatesAutoresizingMaskIntoConstraints = false
    logoText.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
  }
  
  @objc
  func buttonTapped(_ sender: UIView) {
    if sender === loginButton.getSubview(type: UIButton.self) {
      guard let username = loginTextField.text,
            let mail = mailTextField.text,
            let password = passwordTextField.text
      else { return }
      
      if username.isEmpty {
        loginTextField.showSign(state: .UsernameNotFilled)
      }
      if mail.isEmpty {
        mailTextField.showSign(state: .UsernameNotFilled)
      }
      if password.isEmpty {
        passwordTextField.showSign(state: .UsernameNotFilled)
      }
      
      guard isCorrect else {
        let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                              text: "check_fields".localized,
                                                              tintColor: .systemRed,
                                                              fontName: Fonts.Rubik.Regular,
                                                              textStyle: .subheadline,
                                                              textAlignment: .natural),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
        return
      }
      
      if #available(iOS 15, *) {
        loginButton.getSubview(type: UIButton.self)!.configuration?.attributedTitle = AttributedString("signupButton".localized,
                                                                                                       attributes: AttributeContainer([
                                                                                                        .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                                        .foregroundColor: UIColor.clear as Any
                                                                                                       ]))
      } else {
        loginButton.getSubview(type: UIButton.self)!.setAttributedTitle(NSAttributedString(string: "signupButton".localized,
                                                                                           attributes: [
                                                                                            .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                                            .foregroundColor: UIColor.clear as Any
                                                                                           ]),
                                                                        for: .normal)
      }
      
      loginButton.getSubview(type: UIButton.self)!.setSpinning(on: true, color: .white, animated: true)

      viewInput?.signup(username: username,
                        email: mail,
                        password: password)
      isUserInteractionEnabled = false
    }
  }
  
  @objc
  func editingChanged(_ textField: UnderlinedSignTextField) {
    //guard let text = textField.text else { return }
    
    
  }
  
  @objc
  func dismissKeyboard() {
    endEditing(true)
  }
  
  func getTapRecogizer() -> UITapGestureRecognizer {
    let instance = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    instance.cancelsTouchesInView = false
    
    return instance
  }
}


extension NewAccountView: UITextFieldDelegate {
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField,
          let text = textField.text
    else { return true }
    
    if textField === loginTextField {
      if !text.isEmpty && text.count < 4 {
        loginTextField.showSign(state: .UsernameIsShort)
        isLoginFilled = false
      } else if text.isEmpty {
        loginTextField.hideSign()
      } else {
        textField.isShowingSpinner = true
        nameChecker.send(text)
      }
    } else if textField === mailTextField {
      if text.isEmpty {
        mailTextField.hideSign()
        isMailFilled = false
      } else if !text.isValidEmail {
        mailTextField.showSign(state: .EmailIsIncorrect)
      } else {
        textField.isShowingSpinner = true
        mailChecker.send(text)
      }
    } else if textField === passwordTextField {
      if text.isEmpty {
        isPwdFilled = false
        passwordTextField.hideSign()
      } else if text.count < 6 {
        passwordTextField.showSign(state: .PasswordIsShort)
        isPwdFilled = false
      } else {
        isPwdFilled = true
      }
    }
    
    return true
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField else { return true }
    
    textField.hideSign()
    
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField else { return true }
    textField.hideSign()
    
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField === loginTextField {
      mailTextField.becomeFirstResponder()
    } else if textField === mailTextField {
      passwordTextField.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
      if isCorrect {
        //                viewInput?.onSignupTap()
      }
    }
    return true
  }
}

extension NewAccountView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    }
  }
}
