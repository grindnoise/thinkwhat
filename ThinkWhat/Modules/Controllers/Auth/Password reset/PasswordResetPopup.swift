//
//  PasswordResetPopup.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class PasswordResetPopup: UIView {
  
  enum Mode { case ForceSelect, Default }
  
  
  
  // MARK: - Public properties
  public let dismissPublisher = PassthroughSubject<Void, Never> ()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat
  private let color: UIColor
  private lazy var icon: Icon = {
    let instance = Icon(category: .Letter, iconColor: color)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    instance.scaleMultiplicator = 1.5
    
    return instance
  }()
  private lazy var descriptionLabel: UILabel = {
    let instance = UILabel()
    instance.backgroundColor = .clear
    instance.textAlignment = .center
    instance.numberOfLines = 0
    instance.text = "password_reset_link_sent_description".localized
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)

    
    return instance
  }()
  private lazy var titleLabel: UILabel = {
    let instance = UILabel()
    instance.backgroundColor = .clear
    instance.textAlignment = .center
    instance.text = "password_reset_link_sent_title".localized
    instance.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .title1)

    
    return instance
  }()
  private lazy var button: UIButton = {
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
      config.attributedTitle = AttributedString("ok".localized.uppercased(),
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
      instance.setAttributedTitle(NSAttributedString(string: "ok".localized.uppercased(),
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
//    label.heightAnchor.constraint(equalToConstant: 100).isActive = true
    icon.placeInCenter(of: top,
                       topInset: padding,
                       bottomInset: padding)
    let buttonView = UIView.opaque()
    button.placeInCenter(of: buttonView,
                              topInset: 0,
                              bottomInset: 0)
    let instance = UIStackView(arrangedSubviews: [
//      UIView.verticalSpacer(60),
      top,
      titleLabel,
      descriptionLabel,
      buttonView
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    
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
  init(color: UIColor, padding: CGFloat = 8) {
    
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
    
  }
}

private extension PasswordResetPopup {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self)
    
    delay(seconds: 0.5) { [weak self] in
      guard let self = self else { return }
      
      let pathAnim = Animations.get(property: .Path,
                                    fromValue: (self.icon.icon as! CAShapeLayer).path!,
                                    toValue: (self.icon.getLayer(.Checkmark) as! CAShapeLayer).path!.getScaledPath(size: icon.bounds.size, scaleMultiplicator: 1.8),
                                    duration: 0.4,
                                    delay: 0,
                                    repeatCount: 0,
                                    autoreverses: false,
                                    timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                    delegate: nil,
                                    isRemovedOnCompletion: false)
      self.icon.icon.add(pathAnim, forKey: nil)

      let fillAnim = Animations.get(property: .FillColor,
                                    fromValue: self.icon.iconColor,
                                    toValue: UIColor.systemGreen.cgColor,
                                    duration: 0.4,
                                    delay: 0,
                                    delegate: nil)
      self.icon.icon.add(fillAnim, forKey: nil)
      (self.icon.icon as! CAShapeLayer).fillColor = UIColor.systemGreen.cgColor
    }
  }
  
  @objc
  func buttonTapped(_ sender: UIButton) {
    dismissPublisher.send()
    dismissPublisher.send(completion: .finished)
  }
}
