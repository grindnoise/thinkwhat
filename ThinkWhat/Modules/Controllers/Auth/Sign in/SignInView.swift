//
//  SignInView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import AuthenticationServices
import TinyConstraints

class SignInView: UIView {
  
  // MARK: - Public properties
  ///**UI**
  public private(set) lazy var logoText: LogoText = { LogoText() }()
  public private(set) lazy var logoIcon: Logo = {
    let instance = Logo()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.layer.masksToBounds = false
    instance.layer.shadowColor = Constants.UI.Colors.main.cgColor
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
    let opaque = UIView.opaque()
    signupStack.placeXCentered(inside: opaque, topInset: 0, bottomInset: 0)
    
    let opaque2 = UIView.opaque()
    appleDark.placeXCentered(inside: opaque2, topInset: 0, bottomInset: 0)
    apple.placeXCentered(inside: opaque2, topInset: 0, bottomInset: 0)
    
    let instance = UIStackView(arrangedSubviews: [
      top,
      spacer,
      UIView.verticalSpacer(0),
      loginContainer,
      passwordContainer,
      buttonView,
      opaque,
      opaque2,
      separator,
      logos,
    ])
    instance.addGestureRecognizer(getTapRecogizer())
    instance.axis = .vertical
    instance.spacing = padding*2
    instance.publisher(for: \.bounds)
      .filter { !$0.width.isZero }
      .sink { [weak self] in
        guard let self = self,
              let limiter = self.separator.arrangedSubviews.filter({ $0.accessibilityIdentifier == "HorizontalLimiter"}).first,
              let constraint = limiter.getConstraint(identifier: "widthAnchor")
        else { return }

        self.separator.setNeedsLayout()
        constraint.constant = max(0, $0.width/2 - self.padding - "providerLabel".localized.uppercased().width(withConstrainedHeight: 100,
                                                                                                              font: UIFont(name: Fonts.Rubik.Regular, size: 14)!)/2)
        self.separator.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
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
    
    return instance
  }()
  public private(set) lazy var loginTextField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.backgroundColor = .clear
    instance.tintColor = Constants.UI.Colors.main
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.textContentType = .name
    instance.autocorrectionType = .no
    instance.spellCheckingType = .no
    instance.clipsToBounds = false
    instance.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    instance.keyboardType = .asciiCapable

//    let bgLayer = CAShapeLayer()
//    bgLayer.backgroundColor = UIColor.secondarySystemFill.cgColor//(traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
//    let fgLayer = CAShapeLayer()
//    fgLayer.name = "foreground"
//    fgLayer.opacity = 0
//    fgLayer.backgroundColor = Colors.main.withAlphaComponent(0.1).cgColor
//    instance.layer.insertSublayer(bgLayer, at: 0)
//    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.attributedPlaceholder = NSAttributedString(string: "usernameTF".localized,
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
    instance.keyboardType = .asciiCapable
    instance.isSecureTextEntry = true
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.clipsToBounds = false
    instance.tintColor = Constants.UI.Colors.main
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
      config.baseBackgroundColor = Constants.UI.Colors.main
      config.attributedTitle = AttributedString("loginButton".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.backgroundColor = Constants.UI.Colors.main
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.height/2 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "loginButton".localized,
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
        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
      }
      .store(in: &subscriptions)
    instance.place(inside: opaque)
    
    return opaque
  }()
  public private(set) lazy var separator: UIStackView = {
    let limiter = HorizontalLimiter(alignment: .Middle, lineColor: traitCollection.userInterfaceStyle == .dark ? "#828487".hexColor! : "#8C96A3".hexColor!, lineWidth: 1)
    limiter.accessibilityIdentifier = "HorizontalLimiter"
    var constraint = limiter.widthAnchor.constraint(equalToConstant: 50)
    constraint.identifier = "widthAnchor"
    constraint.isActive = true
    
    let instance = UIStackView(arrangedSubviews: [
      limiter,
      label,
      HorizontalLimiter(alignment: .Middle, lineColor: traitCollection.userInterfaceStyle == .dark ? "#828487".hexColor! : "#8C96A3".hexColor!, lineWidth: 1)
    ])
    instance.spacing = padding
    instance.axis = .horizontal
    instance.accessibilityIdentifier = "separator"
//      instance.distribution = .fillEqually
    
    return instance
  }()
  public private(set) lazy var label: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 0
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? "#828487".hexColor : "#8C96A3".hexColor
    instance.textAlignment = .center
    instance.text = "providerLabel".localized.uppercased()
    instance.accessibilityIdentifier = "label"
    instance.font = UIFont(name: Fonts.Rubik.Regular, size: 11)
//    label.translatesAutoresizingMaskIntoConstraints = false
    instance.widthAnchor.constraint(equalToConstant: "providerLabel".localized.uppercased().width(withConstrainedHeight: 100, font: instance.font)).isActive = true
    
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
//  public private(set) lazy var appleLogo: AppleLogo = {
//    let instance = AppleLogo()
//    instance.isUserInteractionEnabled = true
//    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
//    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
//    instance.isOpaque = false
//
//    return instance
//  }()
  public private(set) lazy var apple: ASAuthorizationAppleIDButton = {
    let instance = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    instance.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
    instance.publisher(for: \.bounds)
      .sink { (instance as UIControl).cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    instance.alpha = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    
    return instance
  }()
  public private(set) lazy var appleDark: ASAuthorizationAppleIDButton = {
    let instance = ASAuthorizationAppleIDButton(type: .signIn, style: .white )
    instance.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
    instance.publisher(for: \.bounds)
      .sink { (instance as UIControl).cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    instance.alpha = traitCollection.userInterfaceStyle == .dark ? 1 : 0
    
    return instance
  }()
  public private(set) lazy var logos: UIView = {
    let instance = UIView.opaque()
    let stack = UIStackView(arrangedSubviews: [
//      appleLogo,
      google,
    ])
    stack.accessibilityIdentifier =  "stack"
    if AppData.shared.countryByIP == "RU" {
      stack.addArrangedSubview(vk)
    }
    stack.spacing = padding
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
    instance.setAttributedTitle(NSAttributedString(string: "registration".localized,
                                                   attributes: [
                                                    .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                    .foregroundColor: Constants.UI.Colors.main as Any
                                                   ]),
                                for: .normal)
    
    return instance
  }()
  public private(set) lazy var signupStack: UIStackView = {
    let text: UILabel = {
      let instance = UILabel()
      instance.numberOfLines = 0
      instance.textColor = traitCollection.userInterfaceStyle == .dark ? "#828487".hexColor : "#8C96A3".hexColor
      instance.textAlignment = .center
      instance.text = "dont_have_account_yet".localized
      instance.accessibilityIdentifier = "label"
      instance.font = UIFont(name: Fonts.Rubik.Regular, size: 14)
//        instance.widthAnchor.constraint(equalToConstant: "providerLabel".localized.uppercased().width(withConstrainedHeight: 100, font: instance.font)).isActive = true
      
      return instance
    }()
    
    let instance = UIStackView(arrangedSubviews: [
      text,
      signupButton
    ])
    instance.axis = .horizontal
    instance.spacing = padding
    
    return instance
  }()
  public private(set) lazy var forgotButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.buttonTapped(_:)),
                       for: .touchUpInside)
    instance.setAttributedTitle(NSAttributedString(string: "forgotLabel".localized,
                                                   attributes: [
                                                    .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                    .foregroundColor: Constants.UI.Colors.main as Any
                                                   ]),
                                for: .normal)
    
    return instance
  }()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var timerSubscription = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private var dots = ""
  
  
  
  // MARK: - Public properties
  weak var viewInput: (UIViewController & SignInViewInput)? {
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
  
  // MARK: - Overridden
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground
    label.textColor = traitCollection.userInterfaceStyle == .dark ? "#828487".hexColor : "#8C96A3".hexColor
    loginButton.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 8 : 4
    loginButton.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
    loginButton.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
    
    if let label = signupStack.arrangedSubviews.filter({ $0.accessibilityIdentifier == "label"}).first as? UILabel {
      label.textColor = traitCollection.userInterfaceStyle == .dark ? "#828487".hexColor : "#8C96A3".hexColor
    }
    
    if traitCollection.userInterfaceStyle == .dark {
      appleDark.alpha = 1
      apple.alpha = 0
    } else {
      appleDark.alpha = 0
      apple.alpha = 1
    }
//    if let pwdBgLayer = passwordContainer.layer.sublayers?.filter({ $0.name == "background"}).first,
//       let pwdFgLayer = passwordContainer.layer.sublayers?.filter({ $0.name == "foreground"}).first,
//       let loginBgLayer = loginContainer.layer.sublayers?.filter({ $0.name == "background"}).first,
//       let loginFgLayer = loginContainer.layer.sublayers?.filter({ $0.name == "foreground"}).first {
//
//      let bgColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
//      let fgColor = UIColor.systemBackground.blended(withFraction: traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.2,
//                                                     of: traitCollection.userInterfaceStyle == .dark ? .white : Colors.main).cgColor
//
//      pwdBgLayer.backgroundColor = bgColor
//      pwdFgLayer.backgroundColor = fgColor
//      loginBgLayer.backgroundColor = bgColor
//      loginFgLayer.backgroundColor = fgColor
//    }
  }
}

extension SignInView: SignInControllerOutput {
  /// Animates sign in routine, disables UI interaction within
  func startLoadingAnim() {
    let spinner = Logo()
    let spiral = Icon(frame: .zero, category: .Spiral,
                      scaleMultiplicator: 1,
                      iconColor: traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.spiralDark : Constants.UI.Colors.spiralLight)
    let bgView = UIView()
    bgView.alpha = 0
    bgView.layer.zPosition = 2000
    bgView.accessibilityIdentifier = "loadingSpinner"
    bgView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground
    bgView.addSubview(spiral)
    bgView.addSubview(spinner)
    bgView.layer.masksToBounds = true
    appDelegate.window?.addSubview(bgView)
    bgView.edgesToSuperview()
    
    spiral.aspectRatio(1)
    spiral.widthToHeight(of: bgView, multiplier: 1.5)
    spiral.centerInSuperview()
    spiral.transform = .init(scaleX: 0.75, y: 0.75)
    spiral.alpha = 0
    spinner.centerXToSuperview()
    spinner.centerYToSuperview()
    spinner.widthToSuperview(multiplier: 0.31)
    spinner.alpha = 0
    
    let movingLogo = Logo(frame: CGRect(origin: self.stack.convert(logoIcon.frame.origin, to: self),
                                                                    size: logoIcon.bounds.size))
    movingLogo.removeConstraints(movingLogo.getAllConstraints())
    movingLogo.accessibilityIdentifier = "movingLogo"
    bgView.addSubview(movingLogo)
    logoIcon.alpha = 0
    
    bgView.setNeedsLayout()
    bgView.layoutIfNeeded()
    let coordinate = bgView.convert(spinner.frame.origin, to: bgView)
    
    // Animations
    spiral.startRotating(duration: 5)
    UIView.animate(withDuration: 0.3,
                   delay: 0,
                   options: .curveEaseInOut) {
      bgView.alpha = 1
      movingLogo.frame.origin = coordinate
      movingLogo.frame.size = spinner.bounds.size
      spiral.alpha = 1
      spiral.transform = .identity
    } completion: { _ in
      spinner.alpha = 1
      movingLogo.alpha = 0
      UIView.animate(withDuration: 1,
                     delay: 0,
                     options: [.autoreverse, .repeat, .curveEaseInOut]) {
        spinner.transform = .init(scaleX: 0.95, y: 0.95)
      }
    }
  }
  
  /// Stops loading animation and enables UI interaction
  /// - Parameter completion: executed instructions
  func stopLoadingAnim(completion: @escaping Closure) {
    guard let bgView = appDelegate.window?.getSubview(type: UIView.self, identifier: "loadingSpinner"),
          let movingLogo = bgView.getSubview(type: Logo.self, identifier: "movingLogo"),
          let spiral = bgView.getSubview(type: Icon.self),
          let tempLogo = bgView.getSubview(type: Logo.self)
    else { return }
    

    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
      tempLogo.transform = .identity
      tempLogo.alpha = 1
    }) { _ in
      spiral.removeFromSuperview()
      tempLogo.alpha = 0
      movingLogo.alpha = 1
      UIView.animate(withDuration: 0.6,
                     delay: 0,
                     usingSpringWithDamping: 0.7,
                     initialSpringVelocity: 0.3,
                     options: [.curveEaseInOut],
                     animations: { [weak self] in
        guard let self = self else { return }
        
        bgView.backgroundColor = .clear
        spiral.transform = .init(scaleX: 1.25, y: 1.25)
        spiral.alpha = 0
        movingLogo.frame.origin = self.stack.convert(logoIcon.frame.origin, to: self)
        movingLogo.frame.size = self.logoIcon.frame.size
        
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.logoIcon.alpha = 1
        movingLogo.alpha = 0
        bgView.removeFromSuperview()
        movingLogo.removeFromSuperview()
        tempLogo.removeFromSuperview()
        completion()
      }
    }
  }
  
  func mailSignInCallback(result: Result<Bool, Error>) {
    isUserInteractionEnabled = true
    loginButton.setSpinning(on: false, color: .clear, animated: true) { [weak self] in
      guard let self = self else { return }
      
      if #available(iOS 15, *) {
        self.loginButton.getSubview(type: UIButton.self)!.configuration?.attributedTitle = AttributedString("loginButton".localized,
                                                                      attributes: AttributeContainer([
                                                                        .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                                        .foregroundColor: UIColor.white as Any
                                                                      ]))
      } else {
        self.loginButton.getSubview(type: UIButton.self)!.setAttributedTitle(NSAttributedString(string: "loginButton".localized,
                                                          attributes: [
                                                            .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                            .foregroundColor: UIColor.white as Any
                                                          ]),
                                       for: .normal)
      }
      
      guard case .success(_) = result else { return }
      
      self.viewInput?.nextScene()
    }
  }
  
  func animateTransitionToApp(_ completion: @escaping Closure) {
    guard let viewInput = viewInput,
          let window = appDelegate.window
    else { completion(); return }
    
    viewInput.navigationItem.setHidesBackButton(true, animated: true)
    
    let opaque = PassthroughView()
    opaque.frame = UIScreen.main.bounds
    opaque.place(inside: window)

    let loadingIcon: Icon = {
      let instance = Icon()
      instance.accessibilityIdentifier = "loadingIcon"
      instance.category = Icon.Category.Logo
      instance.iconColor = Constants.UI.Colors.main
      instance.scaleMultiplicator = 1.2
      instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
      instance.alpha = 0
      
      return instance
    }()
    let loadingText: Icon = {
      let instance = Icon()
      instance.accessibilityIdentifier = "loadingText"
      instance.category = Icon.Category.LogoText
      instance.iconColor = Constants.UI.Colors.main
      instance.scaleMultiplicator = 1.1
      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.5).isActive = true
      instance.alpha = 0
      
      return instance
    }()
    let loadingStack: UIStackView = {
      let opaque = UIView()
      opaque.backgroundColor = .clear
      
      let instance = UIStackView(arrangedSubviews: [
        opaque,
        loadingText
      ])
      instance.axis = .vertical
      instance.distribution = .equalCentering
      instance.spacing = 0
      instance.clipsToBounds = false
      
      loadingIcon.translatesAutoresizingMaskIntoConstraints = false
      opaque.translatesAutoresizingMaskIntoConstraints = false
      opaque.addSubview(loadingIcon)
      
      NSLayoutConstraint.activate([
        loadingIcon.topAnchor.constraint(equalTo: opaque.topAnchor),
        loadingIcon.bottomAnchor.constraint(equalTo: opaque.bottomAnchor),
        loadingIcon.centerXAnchor.constraint(equalTo: opaque.centerXAnchor),
        opaque.heightAnchor.constraint(equalTo: loadingText.heightAnchor, multiplier: 2)
      ])
      
      return instance
    }()
    loadingStack.placeInCenter(of: opaque,
                               widthMultiplier: 0.6)
        opaque.setNeedsLayout()
        opaque.layoutIfNeeded()
    
    
    
    ///Fake icons to animate
    let movingLogoIcon: Icon = {
      let instance = Icon(frame: CGRect(origin: logoIcon.superview!.convert(logoIcon.frame.origin,
                                                                            to: opaque),
                                        size: logoIcon.bounds.size))
      instance.iconColor = Constants.UI.Colors.main
      instance.scaleMultiplicator = 1
      instance.category = .Logo
      
      return instance
    }()
    let movingLogoText: Icon = {
      let instance = Icon(frame: CGRect(origin: logoText.superview!.convert(logoText.frame.origin,
                                                                            to: opaque),
                                        size: logoText.bounds.size))
      
      instance.iconColor = Constants.UI.Colors.main
      instance.scaleMultiplicator = 1
      instance.category = .LogoText
      
      return instance
    }()

    opaque.addSubviews([movingLogoIcon, movingLogoText])
    logoIcon.alpha = 0
    logoText.alpha = 0

    movingLogoIcon.icon.add(Animations.get(property: .Path,
                                     fromValue: (movingLogoIcon.icon as! CAShapeLayer).path as Any,
                                     toValue: (loadingIcon.icon as! CAShapeLayer).path as Any,
                                     duration: 0.3,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                     delegate: self,
                                     isRemovedOnCompletion: false),
                      forKey: nil)
    movingLogoText.icon.add(Animations.get(property: .Path,
                                     fromValue: (movingLogoText.icon as! CAShapeLayer).path as Any,
                                     toValue: (loadingText.icon as! CAShapeLayer).path as Any,
                                     duration: 0.3,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                     delegate: self,
                                     isRemovedOnCompletion: false),
                      forKey: nil)



    UIView.animate(withDuration: 0.6,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 0.3,
                   options: [.curveEaseInOut],
                   animations: { [weak self] in
      guard let self = self else { return }

//      spiral.alpha = 1
      self.subviews.forEach {
        $0.alpha = 0
        $0.transform = .init(scaleX: 0.75, y: 0.75)
      }
      movingLogoIcon.frame = CGRect(origin: loadingStack.convert(loadingIcon.frame.origin,
                                                                      to: opaque),
                                  size: loadingIcon.bounds.size)
      movingLogoText.frame = CGRect(origin: loadingStack.convert(loadingText.frame.origin,
                                                                      to: opaque),
                                  size: loadingText.bounds.size)

    }) { _ in
      loadingIcon.alpha = 1
      loadingText.alpha = 1
      movingLogoText.removeFromSuperview()
      movingLogoIcon.removeFromSuperview()
      completion()
    }
  }
}

private extension SignInView {
  @MainActor
  func setupUI() {
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground
    
    addGestureRecognizer(getTapRecogizer())
    //    stack.placeCentered(inside: self, withMultiplier: 0.75)
//        setNeedsLayout()
//        layoutIfNeeded()
    
    addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
    stack.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
    stack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
    
    loginTextField.translatesAutoresizingMaskIntoConstraints = false
    loginTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: loginTextField.font!) + padding*2).isActive = true
    passwordTextField.translatesAutoresizingMaskIntoConstraints = false
    passwordTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: passwordTextField.font!) + padding*2).isActive = true
    google.heightAnchor.constraint(equalTo: loginButton.heightAnchor, multiplier: 0.75).isActive = true
    
    loginButton.translatesAutoresizingMaskIntoConstraints = false
    loginButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    loginButton.widthAnchor.constraint(equalTo: loginButton.heightAnchor, multiplier: 188/52).isActive = true
    
    addSubview(forgotButton)
    forgotButton.translatesAutoresizingMaskIntoConstraints = false
    forgotButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    forgotButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    
    appleDark.translatesAutoresizingMaskIntoConstraints = false
    appleDark.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
    apple.translatesAutoresizingMaskIntoConstraints = false
    apple.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
    
    logoIcon.translatesAutoresizingMaskIntoConstraints = false
    logoIcon.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.31).isActive = true
    logoText.translatesAutoresizingMaskIntoConstraints = false
    logoText.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
  }
  
  @objc
  func handleTap(_ sender: UITapGestureRecognizer) {
//    if sender.view?.accessibilityIdentifier == "password",
//       let foreground = passwordContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first,
//       !passwordTextField.isFirstResponder {
//
//      Animations.unmaskLayerCircled(layer: foreground,
//                                    location: sender.location(ofTouch: 0, in: passwordContainer),
//                                    duration: 0.4,
//                                    opacityDurationMultiplier: 1,
//                                    delegate: self) { [unowned self] in self.passwordTextField.becomeFirstResponder() }
//      passwordTextField.becomeFirstResponder()
//    } else if sender.view?.accessibilityIdentifier == "login",
//              let foreground = loginContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first,
//              !loginTextField.isFirstResponder {
//      loginTextField.becomeFirstResponder()
//
//      Animations.unmaskLayerCircled(layer: foreground,
//                                    location: sender.location(ofTouch: 0, in: passwordContainer),
//                                    duration: 0.4,
//                                    opacityDurationMultiplier: 1,
//                                    delegate: self) { [unowned self] in self.loginTextField.becomeFirstResponder() } } else
    if sender.view?.accessibilityIdentifier == "recognizer" {
      sender.view?.removeFromSuperview()
      endEditing(true)
    } else if sender.view === google {
//      startAuthorizationUI(provider: .Google)
//      isUserInteractionEnabled = false
      viewInput?.providerSignIn(provider: .Google)
    } else if sender.view === vk {
//      startAuthorizationUI(provider: .Google)
//      isUserInteractionEnabled = false
      viewInput?.providerSignIn(provider: .VK)
    } else if sender === apple || sender === appleDark {
      viewInput?.providerSignIn(provider: .Apple)
    }
  }
  
  @objc
  func test() {
    fatalError()
  }
  
  @objc
  func buttonTapped(_ sender: UIButton) {
    if sender === loginButton.getSubview(type: UIButton.self) {
      dismissKeyboard()
      guard let username = loginTextField.text,
            let password = passwordTextField.text
      else { return }
      
      if username.isEmpty {
        loginTextField.showSign(state: .UsernameNotFilled)
      }
      if password.isEmpty {
        passwordTextField.showSign(state: .UsernameNotFilled)
      }
      if !username.isEmpty && !password.isEmpty {
        if #available(iOS 15, *) {
          loginButton.getSubview(type: UIButton.self)!.configuration?.attributedTitle = AttributedString("loginButton".localized.uppercased(),
                                                                        attributes: AttributeContainer([
                                                                          .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                                          .foregroundColor: UIColor.clear as Any
                                                                        ]))
        } else {
          loginButton.getSubview(type: UIButton.self)!.setAttributedTitle(NSAttributedString(string: "loginButton".localized.uppercased(),
                                                            attributes: [
                                                              .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                              .foregroundColor: UIColor.clear as Any
                                                            ]),
                                         for: .normal)
        }
        loginButton.setSpinning(on: true, color: .white, animated: true)
        viewInput?.mailSignIn(username: username, password: password)
        isUserInteractionEnabled = false
      }
    } else if sender === signupButton {
      viewInput?.signUp()
    } else if sender == forgotButton {
      viewInput?.resetPassword()
    } else if sender == apple || sender === appleDark {
      viewInput?.providerSignIn(provider: .Apple)
    }
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

extension SignInView: UITextFieldDelegate {
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField else { return true }
    
    textField.hideSign()
    
    getSubview(type: UIView.self, identifier: "recognizer")?.removeFromSuperview()
    
    if textField === loginTextField,
       //       let background = loginContainer.layer.sublayers?.filter({ $0.name == "background" }).first,
       let layer = loginContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first {
      
      Animations.unmaskLayerCircled(unmask: false,
                                    layer: layer,
                                    location: CGPoint(x: loginContainer.bounds.midX, y: loginContainer.bounds.midY),
                                    duration: 0.2,
                                    opacityDurationMultiplier: 1,
                                    delegate: self) { layer.opacity = 0 }
      //      background.add(Animations.get(property: .Opacity, fromValue: 0, toValue: 1, duration: 0.2, delegate: nil), forKey: nil)
      //      background.opacity = 1
    } else if textField === passwordTextField,
              //              let background = passwordContainer.layer.sublayers?.filter({ $0.name == "background" }).first,
              let layer = passwordContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first {
      
      Animations.unmaskLayerCircled(unmask: false,
                                    layer: layer,
                                    location: CGPoint(x: loginContainer.bounds.midX, y: loginContainer.bounds.midY),
                                    duration: 0.2,
                                    opacityDurationMultiplier: 1,
                                    delegate: self) { layer.opacity = 0 }
      //      background.add(Animations.get(property: .Opacity, fromValue: 0, toValue: 1, duration: 0.2, delegate: nil), forKey: nil)
      //      background.opacity = 1
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
    insertSubview(opaque, belowSubview: stack)
    opaque.translatesAutoresizingMaskIntoConstraints = false
    opaque.topAnchor.constraint(equalTo: topAnchor).isActive = true
    opaque.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    opaque.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    opaque.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//    opaque.place(inside: self)
    
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    
    return true
  }
  
  @objc
  func textFieldDidChange(_ textField: UITextField) {
    guard let text = textField.text else { return }
    
    textField.text = text.lowercased()
  }
}

extension SignInView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    }
  }
}

//extension SignupView: CAAnimationDelegate {
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        guard !isAnimationStopped else { return }
//        providerProgressIndicator?.layer.removeAllAnimations()
//        bounce()
//    }
//}
