//
//  EmptyCard.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class EmptyHotCard: UIView, Card {
  enum Action { case Next, Claim, Vote }

  public lazy var body: UIView = {
    let instance = UIView()
    instance.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .systemBackground : .tertiarySystemBackground
    instance.layer.addSublayer(gradient)
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero }
      .sink { [unowned self] in
        self.gradient.frame = $0
        instance.cornerRadius = $0.width*0.05
      }
      .store(in: &subscriptions)

    return instance
  }()
  public lazy var button: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .small
      config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
      config.baseBackgroundColor = .clear
      let red = UIView.opaque()
      red.backgroundColor = Colors.Logo.Flame.rawValue
      config.background.customView = red
      config.image = UIImage(systemName: "megaphone.fill",
                             withConfiguration: UIImage.SymbolConfiguration(scale: .large))
      config.imagePlacement = .trailing
      config.imagePadding = padding
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.attributedTitle = AttributedString("create_post".localized.uppercased(),
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.setImage(UIImage(systemName: "megaphone.fill",
                                withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                        for: .normal)
      instance.imageView?.tintColor = .white
      instance.imageEdgeInsets.left = 8
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.width * 0.025 }
        .store(in: &subscriptions)
//      instance.backgroundColor = Colors.Logo.Flame.rawValue
      instance.setAttributedTitle(NSAttributedString(string: "create_post".localized.uppercased(),
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  public var subscriptions = Set<AnyCancellable>()
  public var tapPublisher = PassthroughSubject<Void, Never>()
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var shadowView: UIView = {
    let instance = UIView()
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "shadow"
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    instance.layer.shadowRadius = 5
    instance.layer.shadowOffset = .zero
    body.addEquallyTo(to: instance)
    
    return instance
  }()
  private lazy var loadingIndicator: LoadingIndicator = {
    let instance = LoadingIndicator(mode: .Topics,
                                    color: Colors.Logo.Flame.rawValue,
                                    duration: 0.75,
                                    isInfinite: true)
    instance.colorPublisher
      .filter { !$0.isNil }
      .sink { [weak self] in
        guard let self = self,
              let color = $0
        else { return }
//
        if self.traitCollection.userInterfaceStyle != .dark {
          self.gradient.add(Animations.get(property: .Colors,
                                           fromValue: self.gradient.colors as Any,
                                           toValue: [UIColor.white.blended(withFraction: 0.05,
                                                                           of: color).cgColor,
                                                     UIColor.white.blended(withFraction: 0.1,
                                                                           of: color).cgColor] as Any,
                                           duration: 0.5,
                                           timingFunction: .easeInEaseOut,
                                           delegate: self,
                                           isRemovedOnCompletion: true,
                                           completionBlocks: [
                                            {[weak self] in
                                              guard let self = self else { return }

                                              self.gradient.colors = [UIColor.white.blended(withFraction: 0.05,
                                                                                            of: color).cgColor,
                                                                      UIColor.white.blended(withFraction: 0.1,
                                                                                            of: color).cgColor]
                                            }]),
                            forKey: nil)
          self.gradient.colors = [UIColor.white.blended(withFraction: 0.05,
                                                        of: color).cgColor,
                                  UIColor.white.blended(withFraction: 0.1,
                                                        of: color).cgColor]
        }

        UIView.animate(withDuration: 0.5) {
          if #available(iOS 15, *) {
            if let bg = self.button.configuration?.background.customView {
              bg.backgroundColor = color
            }
          } else {
            self.button.backgroundColor = color
          }
//          self.label.textColor = color
        }
//        UIView.transition(with: self.label, duration: 0.1, options: .transitionCrossDissolve) {
//          self.label.textColor = color
//        }

      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var gradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.blended(withFraction: 0.05,
                                                                                                                                                     of: Colors.Logo.Flame.rawValue).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.blended(withFraction: 0.1,
                                                                                                                                   of: Colors.Logo.Flame.rawValue).cgColor
    instance.setGradient(colors: [clear, feathered],
                         locations: [0.0, 0.5])
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 0
    instance.backgroundColor = .clear
    instance.textAlignment = .center
    instance.text = "waiting_for_new_posts".localized
    instance.textColor = .secondaryLabel//Colors.Logo.Flame.rawValue
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title3)
    
    Timer
      .publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        guard self.dots.count < 3 else {
          self.dots = ""
          UIView.setAnimationsEnabled(false)
          self.label.text! = "waiting_for_new_posts".localized
          UIView.setAnimationsEnabled(true)
          
          return
        }
        
        self.dots += "."
        UIView.setAnimationsEnabled(false)
        self.label.text! = "waiting_for_new_posts".localized + self.dots
        UIView.setAnimationsEnabled(true)
      }
      .store(in: &subscriptions)

    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
    loadingIndicator.placeInCenter(of: top,
                        topInset: 0,
                        bottomInset: 0)
    let instance = UIStackView(arrangedSubviews: [
      top,
      label
    ])
    instance.axis = .vertical
    instance.spacing = 50
    
    return instance
  }()
  private var dots = ""
//  private lazy var icon: Icon = {
//    let instance = Icon(category: .Logo, iconColor: Colors.Logo.Flame.rawValue)
//    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
//    instance.scaleMultiplicator = 1
//
//    return instance
//  }()
  
  
  
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
  init() {
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  // MARK: - Public
  public func animate() {
    loadingIndicator.start(animated: false)
  }
  
  public func removeAllAnimations() {
    loadingIndicator.removeAllAnimations()
  }
}

private extension EmptyHotCard {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = false
    
    body.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .white : .tertiarySystemBackground
    
    shadowView.place(inside: self)
    
    setNeedsLayout()
    layoutIfNeeded()
    
    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    
    let constraint = button.bottomAnchor.constraint(equalTo: bottomAnchor)
    constraint.isActive = true
    publisher(for: \.bounds)
      .sink { [unowned self] in
        self.setNeedsLayout()
        constraint.constant = -$0.height/32
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    stack.placeInCenter(of: body)
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    loadingIndicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35).isActive = true
    
    loadingIndicator.start()
    
//    addSubview(label)
//    label.translatesAutoresizingMaskIntoConstraints = false
//
//    NSLayoutConstraint.activate([
//      label.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: padding),
//      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
//      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
//      label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -padding),
//    ])
  }

  
  @objc
  func handleTap(sender: UIButton) {
    tapPublisher.send()
  }
}

extension EmptyHotCard: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
      if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
        completionBlock()
      }
    }
  }
}

