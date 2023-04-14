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
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var logoIcon: Icon = {
    let instance = Icon(category: .Logo, scaleMultiplicator: 1, iconColor: Colors.Logo.Flame.rawValue)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    
    return instance
  }()
  private lazy var stack: UIStackView = {
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
      loginTextField,
      passwordTextField,
      buttonView
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    
    return instance
  }()
  private lazy var loginTextField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.backgroundColor = .clear
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
                                                          .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline) as Any
                                                        ])
    instance.publisher(for: \.bounds)
      .sink {
        bgLayer.frame = $0
        bgLayer.cornerRadius = $0.width*0.025
        fgLayer.frame = $0
        fgLayer.cornerRadius = $0.width*0.025
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var passwordTextField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.backgroundColor = .clear
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
    instance.clipsToBounds = false
    instance.attributedPlaceholder = NSAttributedString(string: "passwordTF".localized,
                                                        attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline) as Any
                                                        ])
    let bgLayer = CAShapeLayer()
    bgLayer.backgroundColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor
    let fgLayer = CAShapeLayer()
    fgLayer.name = "foreground"
    fgLayer.opacity = 0
    fgLayer.backgroundColor = Colors.Logo.Flame.rawValue.withAlphaComponent(0.1).cgColor
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
    
    return instance
  }()
  public lazy var loginButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
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
  }
  
  @objc
  func handleTap(sender: UIButton) {
//    viewInput?.nextScene()
  }
}

extension SignInView: UITextFieldDelegate {
  
}
