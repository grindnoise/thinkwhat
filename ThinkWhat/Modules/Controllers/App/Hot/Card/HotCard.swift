//
//  HotCard.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class HotCard: UIView, Card {
  enum Action { case Next, Claim, Vote }
  // MARK: - Overridden properties
//  override var bounds: CGRect {
//    didSet {
//      guard oldValue != bounds, bounds.size != .zero else { return }
//
//      maxBgItems = Int(bounds.width*bounds.height / bounds.width/20)
//      setBackground()
//    }
//  }
  
//  override var frame: CGRect {
//    didSet {
//      guard oldValue.size != frame.size, frame.size != .zero else { return }
//
//      maxBgItems = Int(frame.width*frame.height / frame.width/20)
//      setBackground()
//    }
//  }
  
  
  // MARK: - Public properties
  ///**Logic**
  public let item: Survey
  public var subscriptions = Set<AnyCancellable>()
  public private(set) var isBanned = false
  public private(set) var isComplete = false
  ///**Publishers**
  @Published public var action: Action?
  ///**UI**
  public lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      claimButton,
//      UIView.opaque(),
      voteButton,
//      UIView.opaque(),
      nextButton
    ])
    instance.axis = .horizontal
//    instance.alignment = .center
//    instance.distribution = .fillEqually
//    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/5).isActive = true
    instance.spacing = padding*5
    
    return instance
  }()
  public lazy var body: UIView = {
    let instance = UIView()
    instance.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .systemBackground : .tertiarySystemBackground
    if !isReplica {
      instance.publisher(for: \.bounds)
        .receive(on: DispatchQueue.main)
        .filter { $0 != .zero }
        .sink { instance.cornerRadius = $0.width*0.05 }
        .store(in: &subscriptions)
    }
    instance.layer.addSublayer(gradient)
    collectionView.place(inside: instance)
//    collectionView.isUserInteractionEnabled = false
    featheredView.place(inside: instance)
    instance.publisher(for: \.bounds)
      .sink { [unowned self] in self.gradient.frame = $0 }
      .store(in: &subscriptions)
    
    return instance
  }()
  public private(set) lazy var voteButton: UIButton = {
//    let opaque = UIView.opaque()
//    opaque.layer.masksToBounds = false
//
//    let instance = UIButton()
//    instance.addTarget(self,
//                       action: #selector(self.handleTap(sender:)),
//                       for: .touchUpInside)
//    if #available(iOS 15, *) {
//      var config = UIButton.Configuration.filled()
//      config.cornerStyle = .capsule
//      config.baseBackgroundColor = item.topic.tagColor
//      config.attributedTitle = AttributedString("hot_participate".localized.capitalized,
//                                                attributes: AttributeContainer([
//                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
//                                                  .foregroundColor: UIColor.white as Any
//                                                ]))
//      instance.configuration = config
//    } else {
//      instance.backgroundColor = item.topic.tagColor
//      instance.publisher(for: \.bounds)
//        .sink { instance.cornerRadius = $0.height/2 }
//        .store(in: &subscriptions)
//      instance.setAttributedTitle(NSAttributedString(string: "hot_participate".localized.capitalized,
//                                                     attributes: [
//                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
//                                                      .foregroundColor: UIColor.white as Any
//                                                     ]),
//                                  for: .normal)
//    }
//    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 52/188).isActive = true
//    opaque.publisher(for: \.bounds)
//      .filter { $0 != .zero && opaque.layer.shadowPath?.boundingBox != $0 }
//      .sink { [unowned self] in
//        opaque.layer.shadowOpacity = 1
//        opaque.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
//        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? self.item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
//        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
//        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
//      }
//      .store(in: &subscriptions)
//    instance.place(inside: opaque)
//
//    return opaque
    let instance = UIButton()
    instance.publisher(for: \.bounds)
      .sink { instance.setImage(UIImage(systemName: "play.fill",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: $0.width*0.75, weight: .semibold)), for: .normal) }
      .store(in: &subscriptions)
    //    instance.imageView?.contentMode = .scaleAspectFill
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1).isActive = true
    instance.imageView?.contentMode = .scaleAspectFit
    instance.tintColor = item.topic.tagColor
    instance.imageView?.layer.masksToBounds = false
    instance.imageView?.layer.shadowOpacity = 1
    instance.imageView?.layer.shadowOffset = .zero
    instance.imageView?.layer.shadowRadius = padding
    instance.imageView?.layer.shadowColor = item.topic.tagColor.withAlphaComponent(0.35).cgColor
    instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
    
//    UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) { [weak self] in
//      guard !self.isNil else { return }
//
//      instance.transform = .init(scaleX: 0.95, y: 0.95)
//      instance.alpha = 0.95
//    }
//    instance.imageView?.layer.masksToBounds = false
    return instance
    
  }()
  public lazy var nextButton: UIButton = {
    let instance = UIButton()
    instance.publisher(for: \.bounds)
      .sink { instance.setImage(UIImage(systemName: "arrow.forward",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: $0.width*0.5, weight: .semibold)), for: .normal) }
      .store(in: &subscriptions)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1).isActive = true
//    instance.heightAnchor.constraint(equalToConstant: 44).isActive = true
    instance.imageView?.contentMode = .scaleAspectFit
    instance.tintColor = nextColor
    instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
    instance.imageView?.layer.shadowOpacity = 1
    instance.imageView?.layer.masksToBounds = false
    instance.imageView?.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 1)
    instance.imageView?.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 4 : 2
    instance.imageView?.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? nextColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
    
    return instance
  }()
  public lazy var claimButton: UIButton = {
    let instance = UIButton()
    instance.publisher(for: \.bounds)
      .sink { instance.setImage(UIImage(systemName: "exclamationmark.triangle",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: $0.width*0.5, weight: .semibold)), for: .normal) }
      .store(in: &subscriptions)

    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1).isActive = true
//    instance.imageView?.contentMode = .scaleAspectFit

    instance.tintColor = .systemYellow//item.topic.tagColor
    instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
    instance.imageView?.layer.shadowOpacity = 1
    instance.imageView?.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 1)
    instance.imageView?.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 4 : 2
    instance.imageView?.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemYellow.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.2).cgColor
    instance.imageView?.layer.masksToBounds = false
    
    return instance
  }()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let isReplica: Bool
  private let padding: CGFloat = 8
  private let nextColor: UIColor
  private lazy var shadowView: UIView = {
    let instance = UIView()
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "shadow"
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowColor = UISettings.Shadows.color
    instance.layer.shadowRadius = UISettings.Shadows.radius(padding: padding)
    instance.layer.shadowOffset = UISettings.Shadows.offset
    body.addEquallyTo(to: instance)
    
    return instance
  }()
  private lazy var collectionView: PollCollectionView  = { PollCollectionView(item: item,
                                                                              mode: .Vote,
                                                                              viewMode: isReplica ? .Transition : .Preview) }()
  private lazy var featheredView: UIView = {
    let instance = UIView()
    instance.accessibilityIdentifier = "featheredView"
    instance.layer.masksToBounds = true
    instance.layer.addSublayer(fadeGradient)
    instance.publisher(for: \.bounds)
      .sink { [unowned self] in self.fadeGradient.frame = $0 }
      .store(in: &subscriptions)

    return instance
  }()
  private lazy var gradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.cgColor//.blended(withFraction: 0.05, of: item.topic.tagColor).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.blended(withFraction: 0.025, of: item.topic.tagColor).cgColor
    instance.setGradient(colors: [clear, feathered],
                         locations: [0.0, 0.5])
    
    return instance
  }()
  private lazy var fadeGradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.blended(withFraction: 0.025, of: item.topic.tagColor).cgColor
    instance.setGradient(colors: [clear, clear, feathered],
                         locations: [0.0, 0.65, 0.875])
    
    return instance
  }()
  // Animation for popular vote
  private let maxItems = 16
  private var items = [Icon]() {
    didSet {
      guard !shouldTerminate && items.count < maxItems else { return }

      if item.isComplete {
        animateCompletion()
      } else if item.isBanned {
        animateBan()
      }
    }
  }
  private var shouldTerminate = false
  // Background image setting
  private var maxBgItems = 30
  private let maxBgIconEdge: CGFloat = 40
  private var bgItems = [Icon]() {
    didSet {
      guard bgItems.count < maxBgItems else { return }

      setBackground()
    }
  }
  
  
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
  init(item: Survey,
       nextColor: UIColor,
       isReplica: Bool = false) {
    self.isReplica = isReplica
    self.item = item
    self.nextColor = nextColor
    
    super.init(frame: .zero)
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Public methods
  public func setBanned(_ completion: @escaping () -> ()) {
    guard !isBanned else { return }
    
    isBanned = true
    
    UIView.animate(withDuration: 0.25,
                   delay: 0,
                   options: .curveEaseInOut) { [unowned self] in
      self.stack.alpha = 0
      self.stack.transform = .init(scaleX: 0.75, y: 0.75)
      self.collectionView.alpha = 0
    }
    
//    let attrString = NSMutableAttributedString(string: "".localized,
//                                               attributes: [
//
//                                               ])
    let blur: UIVisualEffectView = {
      let instance = UIVisualEffectView(effect: UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterial))
      instance.cornerRadius = padding*2
      instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
      instance.alpha = 0
      
      let label = UILabel()
      label.backgroundColor = .clear
      label.font = UIFont.scaledFont(fontName: Fonts.Rubik.Bold, forTextStyle: .title1)
      label.text = "survey_banned_notification".localized
      label.textColor = .white
      label.numberOfLines = 0
      label.textAlignment = .center
      label.place(inside: instance.contentView, insets: .uniform(size: padding))
      
      return instance
    }()
    
    blur.placeInCenter(of: self, widthMultiplier: 0.65)
    blur.transform = .init(scaleX: 0.5, y: 0.5)
    
    animateBan()
    
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.cgColor
    
    UIView.animate(
      withDuration: 0.6,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut],
      animations: {
        blur.transform = .identity
        blur.alpha = 1
      })
    
    let colorAnimation = Animations.get(property: .Colors,
                                        fromValue: [clear, clear, feathered] as Any,
                                        toValue: [clear, UIColor.systemRed.cgColor, UIColor.systemRed.cgColor] as Any,
                                        duration: 0.4,
                                        timingFunction: CAMediaTimingFunctionName.easeIn,
                                        delegate: self,
                                        isRemovedOnCompletion: false,
                                        completionBlocks:
                                          {[weak self] in
                                            guard let self = self else { return }
                                            
                                            self.fadeGradient.colors = [clear, UIColor.systemRed.cgColor, UIColor.systemRed.cgColor]
                                            delay(seconds: 2.5) {
                                                self.fadeGradient.removeAllAnimations()
                                                completion()
                                              }
                                          })
    let locationAnimation = Animations.get(property: .Locations,
                                           fromValue: [0.0, 0.5, 0.9] as Any,
                                           toValue: [-1.0, 0, 1] as Any,
                                           duration: 0.4,
                                           timingFunction: CAMediaTimingFunctionName.easeIn,
                                           delegate: self,
                                           isRemovedOnCompletion: false,
                                           completionBlocks:
                                            {[weak self] in
                                              guard let self = self else { return }
                                              
                                              self.fadeGradient.locations = [-1.0, 0, 1]
                                            })
    
    fadeGradient.add(locationAnimation, forKey: nil)
    fadeGradient.add(colorAnimation, forKey: nil)
  }
  
  public func setComplete(_ completion: @escaping () -> ()) {
    guard !isComplete else { return }
    
    isComplete = true
    
    UIView.animate(withDuration: 0.25,
                   delay: 0,
                   options: .curveEaseInOut) { [unowned self] in
      self.stack.alpha = 0
      self.stack.transform = .init(scaleX: 0.75, y: 0.75)
      self.collectionView.alpha = 0.25
    }
    
    let blur: UIVisualEffectView = {
      let instance = UIVisualEffectView(effect: UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterial))
      instance.cornerRadius = padding*2
      instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
      instance.alpha = 0
      
      let label = UILabel()
      label.backgroundColor = .clear
      label.font = UIFont.scaledFont(fontName: Fonts.Rubik.Bold, forTextStyle: .largeTitle)
      label.text = "survey_complete_notification".localized + "\n🥳"
      label.textColor = .white
      label.numberOfLines = 0
      label.textAlignment = .center
      label.place(inside: instance.contentView, insets: .uniform(size: padding))
      
      return instance
    }()
    
    blur.placeInCenter(of: self, widthMultiplier: 0.65)
    blur.transform = .init(scaleX: 0.5, y: 0.5)
    
    animateCompletion()
    
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.cgColor
    let colorAnimation = Animations.get(property: .Colors,
                                        fromValue: [clear, clear, feathered] as Any,
                                        toValue: [clear, UIColor.systemGreen.cgColor, UIColor.systemGreen.cgColor] as Any,
                                        duration: 0.4,
                                        timingFunction: CAMediaTimingFunctionName.easeIn,
                                        delegate: self,
                                        isRemovedOnCompletion: false,
                                        completionBlocks:
                                          {[weak self] in
                                            guard let self = self else { return }
                                            
                                            self.fadeGradient.colors = [clear, UIColor.systemGreen.cgColor, UIColor.systemGreen.cgColor]
//                                            label.place(inside: self,
//                                                        insets: .uniform(size: self.padding*2))
//                                            label.transform = .init(scaleX: 1.25, y: 1.25)
                                            UIView.animate(
                                              withDuration: 0.6,
                                              delay: 0,
                                              usingSpringWithDamping: 0.8,
                                              initialSpringVelocity: 0.3,
                                              options: [.curveEaseInOut],
                                              animations: {
                                                blur.transform = .identity
                                                blur.alpha = 1
                                              }) { _ in delay(seconds: 1.5) {
                                                self.fadeGradient.removeAllAnimations()
                                                completion()
                                              }
                                              }
                                          })
    let locationAnimation = Animations.get(property: .Locations,
                                           fromValue: [0.0, 0.5, 0.9] as Any,
                                           toValue: [-1.0, 0, 1] as Any,
                                           duration: 0.4,
                                           timingFunction: CAMediaTimingFunctionName.easeIn,
                                           delegate: self,
                                           isRemovedOnCompletion: false,
                                           completionBlocks:
                                            { [weak self] in
                                              guard let self = self else { return }
                                              
                                              self.fadeGradient.locations = [-1.0, 0, 1]
                                            })
    
    fadeGradient.add(locationAnimation, forKey: nil)
    fadeGradient.add(colorAnimation, forKey: nil)
  }
  
  ///Disable gradient
  public func fadeOut(duration: TimeInterval) {
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    gradient.add(Animations.get(property: .Colors,
                                fromValue: gradient.colors as Any,
                                toValue: [clear, clear, clear] as Any,
                                duration: duration,
                                timingFunction: .easeInEaseOut,
                                delegate: self,
                                isRemovedOnCompletion: false,
                                completionBlocks:
                                  {[weak self] in
                                    guard let self = self else { return }
                                    
                                    self.gradient.colors = [clear, clear, clear]
                                  }),
                 forKey: nil)
    gradient.add(Animations.get(property: .Locations,
                                fromValue: gradient.locations as Any,
                                toValue: [0, 1, 1] as Any,
                                duration: duration,
                                timingFunction: .easeInEaseOut,
                                delegate: self,
                                isRemovedOnCompletion: false,
                                completionBlocks:
                                  {[weak self] in
                                    guard let self = self else { return }
                                    
                                    self.gradient.locations = [0, 1, 1]
                                    self.gradient.removeAllAnimations()
                                  }),
                 forKey: nil)
    
    fadeGradient.add(Animations.get(property: .Colors,
                                    fromValue: fadeGradient.colors as Any,
                                    toValue: [clear, clear, clear] as Any,
                                    duration: duration,
                                    timingFunction: .easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: false,
                                    completionBlocks:
                                      {[weak self] in
                                        guard let self = self else { return }
                                        
                                        self.fadeGradient.colors = [clear, clear, clear]
                                      }),
                     forKey: nil)
    fadeGradient.add(Animations.get(property: .Locations,
                                    fromValue: fadeGradient.locations as Any,
                                    toValue: [0, 1, 1] as Any,
                                    duration: duration,
                                    timingFunction: .easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: false,
                                    completionBlocks:
                                      {[weak self] in
                                        guard let self = self else { return }
                                        
                                        self.fadeGradient.locations = [0, 1, 1]
                                        self.fadeGradient.removeAllAnimations()
                                      }),
                     forKey: nil)
    
      UIView.animate(withDuration: duration) {[weak self] in
        guard let self = self else { return }
        
        self.shadowView.layer.shadowOpacity = 0
      }
  }
  
  ///Animates
  public func togglePollMode() {
    collectionView.viewMode = .Default
  }
  
  /// Animate stack button
  public func animateButtons() {
    // Vote btn
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.toValue = 1.15
    animation.autoreverses = true
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    animation.duration = 1
//    animation.beginTime = CACurrentMediaTime() + 0.5
    animation.repeatCount = .infinity
    voteButton.imageView?.layer.add(animation, forKey: nil)
    
    // Claim btn
    let keyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
    
    keyframeAnimation.values = [NSNumber(value: -CGFloat(5).degreesToRadians),
                                NSNumber(value: CGFloat(5).degreesToRadians),
                                NSNumber(value: -CGFloat(5).degreesToRadians)]
    keyframeAnimation.keyTimes = [0, 0.5, 1]
    keyframeAnimation.duration = 3
    keyframeAnimation.repeatCount = .infinity
    claimButton.imageView?.layer.add(keyframeAnimation, forKey:"transform.rotation.z")
    
    // Next btn
    UIView.animate(withDuration: 0.75, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) { [weak self] in
      guard let self = self else { return }
      
      self.nextButton.imageView?.center.x += self.padding/2
    }
  }
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.blended(withFraction: 0.025, of: item.topic.tagColor).cgColor
    
    fadeGradient.setGradient(colors: [clear, clear, feathered],
                             locations: [0.0, 0.75, 0.9])
    
    let clear_2 = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.cgColor//.blended(withFraction: 0.05, of: item.topic.tagColor).cgColor
    gradient.setGradient(colors: [clear_2, feathered],
                         locations: [0.0, 0.5])
    
    body.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .white : .tertiarySystemBackground
    //    body.backgroundColor = traitCollection.userInterfaceStyle != .dark ? UIColor.white.blended(withFraction: 0.055, of: item.topic.tagColor) : .tertiarySystemBackground
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    voteButton.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 8 : 4
    voteButton.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
    voteButton.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
    claimButton.imageView?.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 1)
    claimButton.imageView?.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 4 : 2
    claimButton.imageView?.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.2).cgColor
    nextButton.imageView?.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 1)
    nextButton.imageView?.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 4 : 2
    nextButton.imageView?.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
    
    bgItems.forEach { $0.iconColor = .lightGray.withAlphaComponent(CGFloat.random(in: traitCollection.userInterfaceStyle == .dark ? 0.015...0.03 : 0.04...0.045)) }
  }
}

private extension HotCard {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = false
    
    body.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .white : .tertiarySystemBackground
    
    shadowView.place(inside: self)
    
    setNeedsLayout()
    layoutIfNeeded()
    
    let views = [
      voteButton,
      claimButton,
      nextButton
    ]
    addSubviews(views)
    views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    
    publisher(for: \.bounds)
      .filter { $0.size != .zero }
      .receive(on: DispatchQueue.main )
      .sink { [weak self] in
        guard let self = self else { return }
        
        let count = Int($0.width*$0.height / $0.width/20)
        
        if count != maxBgItems {
          self.maxBgItems = count
          self.setBackground()
        }
      }
      .store(in: &subscriptions)
    voteButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    voteButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding*1).isActive = true
    voteButton.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1/7).isActive = true
    claimButton.trailingAnchor.constraint(equalTo: voteButton.leadingAnchor, constant: -padding*5).isActive = true
    claimButton.centerYAnchor.constraint(equalTo: voteButton.centerYAnchor).isActive = true
    claimButton.heightAnchor.constraint(equalTo: voteButton.heightAnchor).isActive = true
    nextButton.leadingAnchor.constraint(equalTo: voteButton.trailingAnchor, constant: padding*5).isActive = true
    nextButton.centerYAnchor.constraint(equalTo: voteButton.centerYAnchor).isActive = true
    nextButton.heightAnchor.constraint(equalTo: voteButton.heightAnchor).isActive = true
    
    animateButtons()
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  func setTasks() {
    //    tasks.append( Task {@MainActor [weak self] in
    //      for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
    //        guard let self = self else { return }
    //
    //
    //      }
    //    })
  }
  
//  func setGradient(layer: CAGradientLayer,
//                   colors: [CGColor],
//                   locations: [NSNumber]) {
////    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
////    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.blended(withFraction: 0.1, of: item.topic.tagColor).cgColor
//    layer.colors = colors//[clear, clear, feathered]
//    layer.locations = locations//[0.0, 0.75, 0.9]
//  }
  
  /// Adds random scattered topic icons to background
  @MainActor
  func setBackground() {
    let icon = Icon(frame: body.randomFrame(size: .uniform(size: CGFloat.random(in: maxBgIconEdge*0.75...maxBgIconEdge)),
                                            excludeAreas: bgItems.map { CGRect(origin: $0.frame.origin,
                                                                               size: .uniform(size: $0.bounds.width + $0.bounds.width*0.5)) } ))
//                    category: item.topic.iconCategory,
//                    scaleMultiplicator: 1,
//                    iconColor: .brown)
    icon.iconColor = .lightGray.withAlphaComponent(CGFloat.random(in: traitCollection.userInterfaceStyle == .dark ? 0.015...0.03 : 0.045...0.05))
    icon.scaleMultiplicator = 1
    icon.category = item.topic.iconCategory
    icon.transform = .init(rotationAngle: CGFloat.random(in: (-.pi / 2)...(-.pi / 2 + .pi * 2)))
    
//    body.addSubview(icon)
    body.insertSubview(icon, belowSubview: collectionView)
    bgItems.append(icon)
  }
  
  @objc
  func handleTap(sender: UIButton) {
    if sender == voteButton {
      action = .Vote
    } else {
      action = sender == claimButton ? .Claim : .Next
      isUserInteractionEnabled = sender != nextButton
    }
  }
  
  /// Shows completion animation with floating checkmark seals
  func animateCompletion() {
    let third = UIScreen.main.bounds.width * 1/3
    let random = Icon(frame: CGRect(origin: self.randomPoint(center.x - third...center.x + third, center.y - third...center.y + third),
                                    size: .uniform(size: CGFloat.random(in: 40...60))))
    let color = UIColor.white.withAlphaComponent(CGFloat.random(in: 0.7...0.9))
    random.iconColor = color
    random.scaleMultiplicator = 1
    random.category = .CheckMarkSealFill
    random.startRotating(duration: Double.random(in: 10...20),
                         repeatCount: .infinity,
                         clockwise: Int.random(in: 1...3) % 2 == 0 ? true : false)
    random.setAnchorPoint(CGPoint(x: Int.random(in: -5...5), y: Int.random(in: -5...5)))
//    random.layer.masksToBounds = false
//    random.icon.shadowOffset = .zero
//    random.icon.shadowOpacity = Float.random(in: 0.5...0.8)
//    random.icon.shadowColor = color.cgColor
//    random.icon.shadowRadius = random.bounds.width * 0.3
    
    self.insertSubview(random, belowSubview: self.getSubview(type: UIVisualEffectView.self) ?? collectionView)
    self.items.append(random)
    let duration = TimeInterval.random(in: 6...8)
      UIView.animate(withDuration: duration) {
        random.transform = CGAffineTransform(rotationAngle: Int.random(in: 0...9) % 2 == 0 ? .pi : -.pi)
      }
      Timer.scheduledTimer(withTimeInterval: duration*0.9, repeats: false, block: { _ in
        UIView.animate(withDuration: TimeInterval.random(in: 0.3...0.8)) {
          random.alpha = 0
          random.transform = .init(scaleX: 0.25, y: 0.25)
        } completion: { _ in
          random.removeFromSuperview()
        }
      })
    }
  
  /// Shows ban animation
  func animateBan() {
    let third = UIScreen.main.bounds.width * 1/3
    let random = Icon(frame: CGRect(origin: self.randomPoint(center.x - third...center.x + third, center.y - third...center.y + third),
                                    size: .uniform(size: CGFloat.random(in: 40...60))))
    let color = UIColor.white.withAlphaComponent(CGFloat.random(in: 0.7...0.9))
    random.iconColor = color
    random.scaleMultiplicator = 1
    random.alpha = 0
    random.transform = .init(scaleX: 0.5, y: 0.5)
    random.category = .ExclamationMark
    random.startRotating(duration: Double.random(in: 10...20),
                         repeatCount: .infinity,
                         clockwise: Int.random(in: 1...3) % 2 == 0 ? true : false)
    random.setAnchorPoint(CGPoint(x: Int.random(in: -5...5), y: Int.random(in: -5...5)))
    
    self.insertSubview(random, belowSubview: self.getSubview(type: UIVisualEffectView.self) ?? collectionView)
    self.items.append(random)
    let duration = TimeInterval.random(in: 6...8)
    UIView.animate(withDuration: duration) {
      random.transform = CGAffineTransform(rotationAngle: Int.random(in: 0...9) % 2 == 0 ? .pi : -.pi)
    }
    Timer.scheduledTimer(withTimeInterval: duration*0.9, repeats: false, block: { _ in
      UIView.animate(withDuration: TimeInterval.random(in: 0.3...0.8)) {
        random.alpha = 0
        random.transform = .init(scaleX: 0.25, y: 0.25)
      } completion: { _ in
        random.removeFromSuperview()
      }
    })
    UIView.animate(withDuration: TimeInterval.random(in: 0.3...0.6)) { [weak self] in
      guard let self = self else { return }
      
      random.alpha = CGFloat.random(in: self.traitCollection.userInterfaceStyle == .dark ? 0.3...0.7 : 0.7...0.9)
      random.transform = .identity
    }
    }
}

extension HotCard: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
    }
  }
}
