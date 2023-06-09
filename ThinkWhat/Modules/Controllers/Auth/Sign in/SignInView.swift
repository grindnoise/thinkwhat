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

class SignInView: UIView {
  
  // MARK: - Public properties
  ///**UI**
  public private(set) lazy var logoIcon: Icon = {
    let instance = Icon(category: .Logo, scaleMultiplicator: 1, iconColor: Colors.main)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    
    return instance
  }()
  public private(set) lazy var logoText: Icon = {
    let instance = Icon(category: .LogoText, scaleMultiplicator: 1, iconColor: Colors.main)
    instance.alpha = 0
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.5).isActive = true
    
    return instance
  }()
  public private(set) lazy var stack: UIStackView = {
    let top = UIView.opaque()
    logoIcon.placeInCenter(of: top,
                           topInset: 0,
                           bottomInset: 0)
    let spacer = UIView.verticalSpacer(padding*5)
    logoText.placeInCenter(of: spacer,
                           topInset: 0,
                           bottomInset: 0)
  
    let buttonView = UIView.opaque()
    loginButton.placeInCenter(of: buttonView,
                              topInset: 0,
                              bottomInset: 0)
    let opaque = UIView.opaque()
    signupStack.placeXCentered(inside: opaque, topInset: 0, bottomInset: 0)
    
    let opaque2 = UIView.opaque()
    apple.placeXCentered(inside: opaque2, topInset: 0, bottomInset: 0)
    
    
//    let buttonsStack = UIStackView(arrangedSubviews: [
//      opaque,
//      forgotButton
//    ])
//    buttonsStack.axis = .vertical
//    buttonsStack.spacing = 0
    
    let instance = UIStackView(arrangedSubviews: [
      top,
      spacer,
      UIView.verticalSpacer(0),
      loginContainer,
      passwordContainer,
      //      UIView.verticalSpacer(padding),
      buttonView,
//      UIView.verticalSpacer(padding*2),
      opaque,
      opaque2,
      separator,
      logos,
//      opaque
//      buttonsStack
    ])
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
                                                                                                  font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .footnote)!)/2)
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
    bgLayer.backgroundColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    let fgLayer = CAShapeLayer()
    fgLayer.name = "foreground"
    fgLayer.opacity = 0
    fgLayer.backgroundColor = UIColor.systemBackground.blended(withFraction: traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.2,
                                                               of: traitCollection.userInterfaceStyle == .dark ? .white : Colors.main).cgColor
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
    fgLayer.backgroundColor = Colors.main.withAlphaComponent(0.1).cgColor
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
    fgLayer.backgroundColor = UIColor.systemBackground.blended(withFraction: traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.2,
                                                               of: traitCollection.userInterfaceStyle == .dark ? .white : Colors.main).cgColor
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
      config.baseBackgroundColor = Colors.main
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
      instance.backgroundColor = Colors.main
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
  public private(set) lazy var separator: UIStackView = {
    let limiter = HorizontalLimiter(alignment: .Middle, lineColor: .tertiaryLabel, lineWidth: 1)
    limiter.accessibilityIdentifier = "HorizontalLimiter"
    var constraint = limiter.widthAnchor.constraint(equalToConstant: 50)
    constraint.identifier = "widthAnchor"
    constraint.isActive = true
    
    let instance = UIStackView(arrangedSubviews: [
      limiter,
      label,
      HorizontalLimiter(alignment: .Middle, lineColor: .tertiaryLabel, lineWidth: 1)
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
    instance.textColor = .secondaryLabel
    instance.textAlignment = .center
    instance.text = "providerLabel".localized.uppercased()
    instance.accessibilityIdentifier = "label"
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .footnote)
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
    let instance = ASAuthorizationAppleIDButton(type: .signIn, style: traitCollection.userInterfaceStyle == .dark ? .white : .black)
    instance.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
    
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
                                                    .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
                                                    .foregroundColor: Colors.main as Any
                                                   ]),
                                for: .normal)
    
    return instance
  }()
  public private(set) lazy var signupStack: UIStackView = {
    let text: UILabel = {
      let instance = UILabel()
      instance.numberOfLines = 0
      instance.textColor = .secondaryLabel
      instance.textAlignment = .center
      instance.text = "dont_have_account_yet".localized
      instance.accessibilityIdentifier = "label"
      instance.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline)
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
                                                    .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
                                                    .foregroundColor: Colors.main as Any
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
}

extension SignInView: SignInControllerOutput {
  func providerSignInCallback(result: Result<Bool, Error>) {
    stopLoader(success: false) { [weak self] in
      guard let self = self,
            case .success(_) = result
      else  { return }
      
      self.viewInput?.nextScene()
    }
//    switch result {
//    case .success(_):
//      guard let userprofile = Userprofiles.shared.current,
//            userprofile.wasEdited == false else {
//        stopLoader(success: true) { [weak self] in
//          guard let self = self else { return }
//
//          self.viewInput?.openApp()
//        }
//        return
//      }
//
//      stopLoader(success: false) { [weak self] in
//        guard let self = self else { return }
//
//        self.viewInput?.openProfile()
//      }
//    case .failure(_):
//      stopLoader(success: false) {}
//    }
  }
  
  /**
   Disable UI interaction and show loading animation.
   */
  func startAuthorizationUI(provider: AuthProvider) {
    isUserInteractionEnabled = false
//    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
//    blurEffectView.effect = nil
//    blurEffectView.addEquallyTo(to: self)
    let bgView = UIView()
    bgView.backgroundColor = .systemBackground
    bgView.accessibilityIdentifier = "bgView"
    bgView.alpha = 0
    bgView.addEquallyTo(to: self)
    
    let fakeLogo = {
      let instance = Icon()
      instance.accessibilityIdentifier = "fakeLogo"
      //      instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
      instance.iconColor = Colors.main
      instance.frame = CGRect(origin: self.stack.convert(logoIcon.frame.origin, to: self),
                              size: logoIcon.bounds.size)
      instance.scaleMultiplicator = 1
      instance.category = .Logo
      
      return instance
    }()
    
    addSubview(fakeLogo)
    logoIcon.alpha = 0
    
    let spinner = LoadingIndicator(color: Colors.main,
                                   shouldSendCompletion: true,
                                   alpha: 1)
    spinner.alpha = 0
    let label: UILabel = {
      let instance = UILabel()
      instance.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .body)
      instance.text = "provider_authorization_progress".localized
      instance.textAlignment = .center
      instance.textColor = .label
      Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          guard self.dots.count < 3 else {
            self.dots = ""
            UIView.setAnimationsEnabled(false)
            instance.text! = "provider_authorization_progress".localized
            UIView.setAnimationsEnabled(true)
            
            return
          }
          
          self.dots += "."
          UIView.setAnimationsEnabled(false)
          instance.text! = "provider_authorization_progress".localized + self.dots
          UIView.setAnimationsEnabled(true)
        }
        .store(in: &timerSubscription)
      
      return instance
    }()
    let stack: UIStackView = {
      let instance = UIStackView(arrangedSubviews: [
        spinner,
        label,
      ])
      instance.axis = .vertical
      instance.spacing = padding
      
      return instance
    }()
    stack.placeInCenter(of: bgView)//blurEffectView.contentView)//,
//                        yOffset: -NavigationController.Constants.NavBarHeightSmallState)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35).isActive = true
    bgView.setNeedsLayout()
    bgView.layoutIfNeeded()
    let coordinate = stack.convert(spinner.logo.frame.origin, to: bgView)
    
    UIView.animate(withDuration: 0.6,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 0.3,
                   options: [.curveEaseInOut],
                   animations: {
      bgView.alpha = 1//UIBlurEffect(style: .prominent)
      fakeLogo.frame.origin = coordinate
      fakeLogo.frame.size = spinner.bounds.size
    }) { _ in
      spinner.alpha = 1
      fakeLogo.alpha = 0
//      fakeLogo.removeFromSuperview()
      spinner.start(animated: false)
    }
  }
  
  func mailSignInCallback(result: Result<Bool, Error>) {
    isUserInteractionEnabled = true
    loginButton.setSpinning(on: false, color: .clear, animated: true) { [weak self] in
      guard let self = self else { return }
      
      if #available(iOS 15, *) {
        self.loginButton.configuration?.attributedTitle = AttributedString("loginButton".localized.uppercased(),
                                                                      attributes: AttributeContainer([
                                                                        .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                                        .foregroundColor: UIColor.white as Any
                                                                      ]))
      } else {
        self.loginButton.setAttributedTitle(NSAttributedString(string: "loginButton".localized.uppercased(),
                                                          attributes: [
                                                            .font: UIFont(name: Fonts.Bold, size: 20) as Any,
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
      instance.iconColor = Colors.main
      instance.scaleMultiplicator = 1.2
      instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
      instance.alpha = 0
      
      return instance
    }()
    let loadingText: Icon = {
      let instance = Icon()
      instance.accessibilityIdentifier = "loadingText"
      instance.category = Icon.Category.LogoText
      instance.iconColor = Colors.main
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
    let fakeLogoIcon: Icon = {
      let instance = Icon(frame: CGRect(origin: logoIcon.superview!.convert(logoIcon.frame.origin,
                                                                            to: opaque),
                                        size: logoIcon.bounds.size))
      instance.iconColor = Colors.main
      instance.scaleMultiplicator = 1
      instance.category = .Logo
      
      return instance
    }()
    let fakeLogoText: Icon = {
      let instance = Icon(frame: CGRect(origin: logoText.superview!.convert(logoText.frame.origin,
                                                                            to: opaque),
                                        size: logoText.bounds.size))
      
      instance.iconColor = Colors.main
      instance.scaleMultiplicator = 1
      instance.category = .LogoText
      
      return instance
    }()

    opaque.addSubviews([fakeLogoIcon, fakeLogoText])
    logoIcon.alpha = 0
    logoText.alpha = 0

    fakeLogoIcon.icon.add(Animations.get(property: .Path,
                                     fromValue: (fakeLogoIcon.icon as! CAShapeLayer).path as Any,
                                     toValue: (loadingIcon.icon as! CAShapeLayer).path as Any,
                                     duration: 0.3,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                     delegate: self,
                                     isRemovedOnCompletion: false,
                                     completionBlocks: []),
                      forKey: nil)
    fakeLogoText.icon.add(Animations.get(property: .Path,
                                     fromValue: (fakeLogoText.icon as! CAShapeLayer).path as Any,
                                     toValue: (loadingText.icon as! CAShapeLayer).path as Any,
                                     duration: 0.3,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                     delegate: self,
                                     isRemovedOnCompletion: false,
                                     completionBlocks: []),
                      forKey: nil)



    UIView.animate(withDuration: 0.6,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 0.3,
                   options: [.curveEaseInOut],
                   animations: { [weak self] in
      guard let self = self else { return }

      self.subviews.forEach {
        $0.alpha = 0
        $0.transform = .init(scaleX: 0.75, y: 0.75)
      }
      fakeLogoIcon.frame = CGRect(origin: loadingStack.convert(loadingIcon.frame.origin,
                                                                      to: opaque),
                                  size: loadingIcon.bounds.size)
      fakeLogoText.frame = CGRect(origin: loadingStack.convert(loadingText.frame.origin,
                                                                      to: opaque),
                                  size: loadingText.bounds.size)

    }) { _ in
      loadingIcon.alpha = 1
      loadingText.alpha = 1
      fakeLogoText.removeFromSuperview()
      fakeLogoIcon.removeFromSuperview()
      completion()
    }
  }
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
//    passwordTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6).isActive = true
    loginTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: loginTextField.font!) + padding*2).isActive = true
    passwordTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: passwordTextField.font!) + padding*2).isActive = true
    stack.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
    stack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
    google.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
    
    addSubview(forgotButton)
    forgotButton.translatesAutoresizingMaskIntoConstraints = false
    forgotButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    forgotButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    
    apple.translatesAutoresizingMaskIntoConstraints = false
    apple.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
  }
  
  @objc
  func handleTap(_ sender: UITapGestureRecognizer) {
    if sender.view?.accessibilityIdentifier == "password",
       let foreground = passwordContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first,
       !passwordTextField.isFirstResponder {
      
      Animations.unmaskLayerCircled(layer: foreground,
                                    location: sender.location(ofTouch: 0, in: passwordContainer),
                                    duration: 0.4,
                                    opacityDurationMultiplier: 1,
                                    delegate: self) { [unowned self] in self.passwordTextField.becomeFirstResponder() }
      passwordTextField.becomeFirstResponder()
    } else if sender.view?.accessibilityIdentifier == "login",
              let foreground = loginContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first,
              !loginTextField.isFirstResponder {
      loginTextField.becomeFirstResponder()
      
      Animations.unmaskLayerCircled(layer: foreground,
                                    location: sender.location(ofTouch: 0, in: passwordContainer),
                                    duration: 0.4,
                                    opacityDurationMultiplier: 1,
                                    delegate: self) { [unowned self] in self.loginTextField.becomeFirstResponder() }
    } else if sender.view?.accessibilityIdentifier == "recognizer" {
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
    } else if sender === apple {//appleLogo {
      viewInput?.providerSignIn(provider: .Apple)
    }
  }
  
  @objc
  func buttonTapped(_ sender: UIButton) {
    if sender === loginButton {
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
          loginButton.configuration?.attributedTitle = AttributedString("loginButton".localized.uppercased(),
                                                                        attributes: AttributeContainer([
                                                                          .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                                          .foregroundColor: UIColor.clear as Any
                                                                        ]))
        } else {
          loginButton.setAttributedTitle(NSAttributedString(string: "loginButton".localized.uppercased(),
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
    } else if sender == apple {
      viewInput?.providerSignIn(provider: .Apple)
    }
  }
  
  /**
   Enable UI interaction and hide loading animation.
   - parameter success: Flag for success
   - parameter completion: Callback closure
   */
  func stopLoader(success: Bool,
                  completion: @escaping Closure) {
    isUserInteractionEnabled = true
    
    guard let bgView = getSubview(type: UIView.self, identifier: "bgView"),//let blurEffectView = getSubview(type: UIVisualEffectView.self),
          let fakeLogo = getSubview(type: Icon.self, identifier: "fakeLogo"),
          let spinner = bgView.getSubview(type: LoadingIndicator.self),
          let label = bgView.getSubview(type: UILabel.self)
    else { return }
    
    fakeLogo.alpha = spinner.logo.alpha
    fakeLogo.transform = spinner.logo.transform
    spinner.alpha = 0
    
    switch success {
    case false:
      UIView.animate(withDuration: 0.6,
                     delay: 0,
                     usingSpringWithDamping: 0.7,
                     initialSpringVelocity: 0.3,
                     options: [.curveEaseInOut],
                     animations: { [weak self] in
        guard let self = self else { return }
        
        bgView.alpha = 0
        label.alpha = 0
        label.transform = .init(scaleX: 0.75, y: 0.75)
        fakeLogo.alpha = 1
        fakeLogo.transform = .identity
        fakeLogo.frame.origin = self.stack.convert(logoIcon.frame.origin, to: self)
        fakeLogo.frame.size = self.logoIcon.frame.size
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.logoIcon.alpha = 1
        bgView.removeFromSuperview()
        fakeLogo.removeFromSuperview()
        spinner.removeFromSuperview()
        label.removeFromSuperview()
        self.timerSubscription.forEach { $0.cancel() }
        completion()
      }
    case true:
      let loadingIcon: Icon = {
        let instance = Icon(category: Icon.Category.Logo)
        instance.iconColor = Colors.main
        instance.scaleMultiplicator = 1.2
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        
        return instance
      }()
      let loadingText: Icon = {
        let instance = Icon(category: Icon.Category.LogoText)
        instance.iconColor = Colors.main
        instance.isRounded = false
        instance.clipsToBounds = false
        instance.scaleMultiplicator = 1.1
        instance.alpha = 0
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.5).isActive = true
        
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
        instance.alpha = 0
        
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
      
      loadingStack.placeInCenter(of: bgView,//blurEffectView.contentView,
                                 widthMultiplier: 0.6)//,
      bgView.setNeedsLayout()
      bgView.layoutIfNeeded()
      loadingText.transform = .init(scaleX: 0.5, y: 0.5)
      
      loadingText.icon.add(Animations.get(property: .FillColor,
                                          fromValue: Colors.main.cgColor as Any,
                                          toValue: Colors.Logo.Flame.next().rawValue as Any,
                                          duration: 0.3,
                                          delay: 0,
                                          repeatCount: 0,
                                          autoreverses: false,
                                          timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                          delegate: nil,
                                          isRemovedOnCompletion: false),
                           forKey: nil)
      loadingIcon.icon.add(Animations.get(property: .FillColor,
                                          fromValue: Colors.main.cgColor as Any,
                                          toValue: Colors.Logo.Flame.next().rawValue as Any,
                                          duration: 0.3,
                                          delay: 0,
                                          repeatCount: 0,
                                          autoreverses: false,
                                          timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                          delegate: self,
                                          isRemovedOnCompletion: false,
                                          completionBlocks: []),
                           forKey: nil)
      fakeLogo.icon.add(Animations.get(property: .Path,
                                       fromValue: (fakeLogo.icon as! CAShapeLayer).path as Any,
                                       toValue: (loadingIcon.icon as! CAShapeLayer).path as Any,
                                       duration: 0.3,
                                       delay: 0,
                                       repeatCount: 0,
                                       autoreverses: false,
                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                       delegate: self,
                                       isRemovedOnCompletion: false,
                                       completionBlocks: []),
                        forKey: nil)
      
      
      UIView.animate(withDuration: 0.6,
                     delay: 0,
                     usingSpringWithDamping: 0.7,
                     initialSpringVelocity: 0.3,
                     options: [.curveEaseInOut],
                     animations: { [weak self] in
        guard let self = self else { return }
        
//        blurEffectView.effect = nil
        label.alpha = 0
        label.transform = .init(scaleX: 0.75, y: 0.75)
        fakeLogo.alpha = 1
        fakeLogo.transform = .identity
        fakeLogo.frame.origin = loadingStack.convert(loadingIcon.frame.origin, to: bgView)
        fakeLogo.frame.size = loadingIcon.frame.size
        self.stack.alpha = 0
      }) { [weak self] _ in
        guard let self = self else { return }
        
        loadingStack.alpha = 1
//        blurEffectView.removeFromSuperview()
        fakeLogo.removeFromSuperview()
        spinner.removeFromSuperview()
        label.removeFromSuperview()
        self.timerSubscription.forEach { $0.cancel() }
        
        UIView.animate(withDuration: 0.3,
                       animations: {
          loadingText.transform = .identity
          loadingText.alpha = 1
        }) { _ in
          completion()
        }
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

//extension SignupView: CAAnimationDelegate {
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        guard !isAnimationStopped else { return }
//        providerProgressIndicator?.layer.removeAllAnimations()
//        bounce()
//    }
//}
