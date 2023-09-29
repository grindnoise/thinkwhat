//
//  PasswordResetView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class PasswordResetView: UIView {
  
  // MARK: - Public properties
  ///**UI**
  public private(set) lazy var stack: UIStackView = {
    let title = {
      let instance = UILabel()
      instance.numberOfLines = 0
      instance.textAlignment = .natural
      instance.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .largeTitle)
      instance.text = "password_reset_link_title".localized
      
      return instance
    }()
    let description = {
      let instance = UILabel()
      instance.numberOfLines = 0
      instance.textAlignment = .natural
      instance.textColor = .secondaryLabel
      instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
      instance.text = "password_reset_link_description".localized
      
      return instance
    }()

    let buttonView = UIView.opaque()
    button.placeInCenter(of: buttonView,
                              topInset: 0,
                              bottomInset: 0)
    
    let instance = UIStackView(arrangedSubviews: [
      title,
      description,
      UIView.verticalSpacer(padding),
      mailContainer,
      UIView.verticalSpacer(100),
//      buttonView,
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    
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
    opaque.accessibilityIdentifier = "mail"
    opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    return instance
  }()
  public private(set) lazy var mailTextField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.keyboardType = .emailAddress
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
    instance.attributedPlaceholder = NSAttributedString(string: "mailTF".localized,
                                                        attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                        ])
    
    return instance
  }()
  public private(set) lazy var button: UIButton = {
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
      config.attributedTitle = AttributedString("send_password_reset_link".localized.uppercased(),
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
      instance.setAttributedTitle(NSAttributedString(string: "send_password_reset_link".localized.uppercased(),
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private var mail = "" {
    didSet {
      guard !mail.isEmpty else { return }
      
      if !mail.isValidEmail {
        mailTextField.showSign(state: .EmailIsIncorrect)
      }
    }
  }
  
  
  // MARK: - Public properties
  weak var viewInput: (PasswordResetViewInput & UIViewController)? {
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

extension PasswordResetView: PasswordResetControllerOutput {
  func callback(_ result: Result<Bool, Error>) {
    isUserInteractionEnabled = true
    button.setSpinning(on: false, color: .clear, animated: true) { [weak self] in
      guard let self = self else { return }
      
      if #available(iOS 15, *) {
        self.button.configuration?.attributedTitle = AttributedString("send_password_reset_link".localized.uppercased(),
                                                                      attributes: AttributeContainer([
                                                                        .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                                        .foregroundColor: UIColor.white as Any
                                                                      ]))
      } else {
        self.button.setAttributedTitle(NSAttributedString(string: "send_password_reset_link".localized.uppercased(),
                                                          attributes: [
                                                           .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                           .foregroundColor: UIColor.white as Any
                                                          ]),
                                       for: .normal)
      }
    }
    
    switch result {
    case .success(_):
      let banner = NewPopup(padding: padding*5,
                            contentPadding: .uniform(size: padding*3))

      let content = PasswordResetPopup(color: Colors.main,
                                       padding: padding)
      banner.setContent(content)
      content.dismissPublisher
        .sink { banner.dismiss() }
        .store(in: &subscriptions)
      banner.didDisappearPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          banner.removeFromSuperview()
          self.viewInput?.navigationController?.popViewController(animated: true)
        }
        .store(in: &subscriptions)
    case .failure(let error):
      let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "xmark.circle.fill")!,
                                                            text: error.localizedDescription,
                                                            textColor: .label,
                                                            tintColor: .systemRed,
                                                            fontName: Fonts.Regular,
                                                            textStyle: .subheadline,
                                                            textAlignment: .natural),
                             contentPadding: UIEdgeInsets(top: padding*2, left: padding, bottom: padding*2, right: padding),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 3)
      
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
    }
  }
  
  @objc
  func handleTap(_ sender: UITapGestureRecognizer) {
    if let foreground = mailContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first,
       !mailTextField.isFirstResponder {
    
    mailTextField.becomeFirstResponder()
    
    Animations.unmaskLayerCircled(layer: foreground,
                                  location: sender.location(ofTouch: 0, in: mailContainer),
                                  duration: 0.4,
                                  opacityDurationMultiplier: 1,
                                  delegate: self) { [unowned self] in self.mailTextField.becomeFirstResponder() }
    } else if sender.view?.accessibilityIdentifier == "recognizer" {
      sender.view?.removeFromSuperview()
      endEditing(true)
    }
  }
  
  @objc
  func buttonTapped(_ sender: UIButton) {
    guard mail.isValidEmail else { return }
    
    if #available(iOS 15, *) {
      self.button.configuration?.attributedTitle = AttributedString("send_password_reset_link".localized.uppercased(),
                                                                    attributes: AttributeContainer([
                                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                                      .foregroundColor: UIColor.clear as Any
                                                                    ]))
    } else {
      self.button.setAttributedTitle(NSAttributedString(string: "send_password_reset_link".localized.uppercased(),
                                                        attributes: [
                                                         .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                         .foregroundColor: UIColor.clear as Any
                                                        ]),
                                     for: .normal)
    }
    button.setSpinning(on: true, color: .white, animated: true)
    isUserInteractionEnabled = false
    viewInput?.sendResetLink(mail)
  }
}

private extension PasswordResetView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    
    stack.placeInCenter(of: self)
    mailContainer.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
    mailTextField.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: mailTextField.font!) + padding*2).isActive = true
    
    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    button.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
  }
}

extension PasswordResetView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    }
  }
}

extension PasswordResetView: UITextFieldDelegate {
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    
    getSubview(type: UIView.self, identifier: "recognizer")?.removeFromSuperview()
    
    if let text = mailTextField.text {
      mail = text
    }
    
    guard let layer = mailContainer.layer.sublayers?.filter({ $0.name == "foreground" }).first else { return true }
    
    Animations.unmaskLayerCircled(unmask: false,
                                  layer: layer,
                                  location: CGPoint(x: mailContainer.bounds.midX, y: mailContainer.bounds.midY),
                                  duration: 0.2,
                                  opacityDurationMultiplier: 1,
                                  delegate: self) { layer.opacity = 0 }
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
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField else { return true }
    
    textField.hideSign()
    
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    mailTextField.resignFirstResponder()
    
    return true
  }
}
