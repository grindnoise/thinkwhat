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
      voteButton,
      nextButton
    ])
    instance.axis = .horizontal
    instance.spacing = padding*2
    
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
  public private(set) lazy var voteButton: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .capsule
      config.baseBackgroundColor = item.topic.tagColor
      config.attributedTitle = AttributedString("hot_participate".localized.capitalized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.backgroundColor = item.topic.tagColor
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.height/2 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "hot_participate".localized.capitalized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 52/188).isActive = true
    opaque.publisher(for: \.bounds)
      .filter { $0 != .zero && opaque.layer.shadowPath?.boundingBox != $0 }
      .sink { [unowned self] in
        opaque.layer.shadowOpacity = 1
        opaque.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? self.item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
      }
      .store(in: &subscriptions)
    instance.place(inside: opaque)
    
    return opaque
  }()
  public lazy var nextButton: UIButton = {
    let instance = UIButton()
    instance.layer.masksToBounds = false
    instance.setImage(UIImage(systemName: "arrowshape.right.fill",
                              withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
    //    instance.imageView?.contentMode = .scaleAspectFill
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1).isActive = true
//    instance.imageView?.contentMode = .center
    instance.tintColor = item.topic.tagColor//nextColor
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    instance.imageView?.layer.shadowOpacity = 1
    instance.imageView?.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 1)
    instance.imageView?.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 4 : 2
    instance.imageView?.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
    instance.imageView?.layer.masksToBounds = false
    return instance
  }()
  public lazy var claimButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "exclamationmark.triangle.fill",
                              withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1).isActive = true
//    instance.imageView?.contentMode = .center

    instance.tintColor = item.topic.tagColor
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    instance.imageView?.layer.shadowOpacity = 1
    instance.imageView?.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 1)
    instance.imageView?.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 4 : 2
    instance.imageView?.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
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
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    instance.layer.shadowRadius = 5
    instance.layer.shadowOffset = .zero
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
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.blended(withFraction: 0.05, of: item.topic.tagColor).cgColor
    instance.setGradient(colors: [clear, feathered],
                         locations: [0.0, 0.5])
    
    return instance
  }()
  private lazy var fadeGradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.blended(withFraction: 0.05, of: item.topic.tagColor).cgColor
    instance.setGradient(colors: [clear, clear, feathered],
                         locations: [0.0, 0.75, 0.9])
    
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
    
    let label = UILabel()
    label.backgroundColor = .clear
    label.alpha = 0
    label.font = UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .largeTitle)
    label.text = "survey_banned_notification".localized// + "\n⚠︎"
    label.textColor = .white
    label.numberOfLines = 0
    label.textAlignment = .center
//    label.attributedText = attrString
    
    
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.cgColor
    let colorAnimation = Animations.get(property: .Colors,
                                        fromValue: [clear, clear, feathered] as Any,
                                        toValue: [clear, UIColor.systemRed.cgColor, UIColor.systemRed.cgColor] as Any,
                                        duration: 0.4,
                                        timingFunction: CAMediaTimingFunctionName.easeIn,
                                        delegate: self,
                                        isRemovedOnCompletion: false,
                                        completionBlocks: [
                                          {[weak self] in
                                            guard let self = self else { return }
                                            
                                            self.fadeGradient.colors = [clear, UIColor.systemRed.cgColor, UIColor.systemRed.cgColor]
                                            label.place(inside: self,
                                                        insets: .uniform(size: self.padding*2))
                                            label.transform = .init(scaleX: 1.25, y: 1.25)
                                            UIView.animate(
                                              withDuration: 0.6,
                                              delay: 0,
                                              usingSpringWithDamping: 0.8,
                                              initialSpringVelocity: 0.3,
                                              options: [.curveEaseInOut],
                                              animations: {
                                                label.transform = .identity
                                                label.alpha = 1
                                              }) { _ in delay(seconds: 1) { completion() } }
                                          }])
    let locationAnimation = Animations.get(property: .Locations,
                                           fromValue: [0.0, 0.5, 0.9] as Any,
                                           toValue: [-1.0, 0, 1] as Any,
                                           duration: 0.4,
                                           timingFunction: CAMediaTimingFunctionName.easeIn,
                                           delegate: self,
                                           isRemovedOnCompletion: false,
                                           completionBlocks: [
                                            {[weak self] in
                                              guard let self = self else { return }
                                              
                                              self.fadeGradient.locations = [-1.0, 0, 1]
                                            }])
    
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
    
//    let attrString = NSMutableAttributedString(string: "".localized,
//                                               attributes: [
//
//                                               ])
    
    let label = UILabel()
    label.backgroundColor = .clear
    label.alpha = 0
    label.font = UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .largeTitle)
    label.text = "survey_complete_notification".localized + "\n🥳"
    label.textColor = .white
    label.numberOfLines = 0
    label.textAlignment = .center
//    label.attributedText = attrString
    
    
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.cgColor
    let colorAnimation = Animations.get(property: .Colors,
                                        fromValue: [clear, clear, feathered] as Any,
                                        toValue: [clear, UIColor.systemGreen.cgColor, UIColor.systemGreen.cgColor] as Any,
                                        duration: 0.4,
                                        timingFunction: CAMediaTimingFunctionName.easeIn,
                                        delegate: self,
                                        isRemovedOnCompletion: false,
                                        completionBlocks: [
                                          {[weak self] in
                                            guard let self = self else { return }
                                            
                                            self.fadeGradient.colors = [clear, UIColor.systemGreen.cgColor, UIColor.systemGreen.cgColor]
                                            label.place(inside: self,
                                                        insets: .uniform(size: self.padding*2))
                                            label.transform = .init(scaleX: 1.25, y: 1.25)
                                            UIView.animate(
                                              withDuration: 0.6,
                                              delay: 0,
                                              usingSpringWithDamping: 0.8,
                                              initialSpringVelocity: 0.3,
                                              options: [.curveEaseInOut],
                                              animations: {
                                                label.transform = .identity
                                                label.alpha = 1
                                              }) { _ in delay(seconds: 0.5) { completion() } }
                                          }])
    let locationAnimation = Animations.get(property: .Locations,
                                           fromValue: [0.0, 0.5, 0.9] as Any,
                                           toValue: [-1.0, 0, 1] as Any,
                                           duration: 0.4,
                                           timingFunction: CAMediaTimingFunctionName.easeIn,
                                           delegate: self,
                                           isRemovedOnCompletion: false,
                                           completionBlocks: [
                                            {[weak self] in
                                              guard let self = self else { return }
                                              
                                              self.fadeGradient.locations = [-1.0, 0, 1]
                                            }])
    
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
                                completionBlocks: [
                                  {[weak self] in
                                    guard let self = self else { return }
                                    
                                    self.gradient.colors = [clear, clear, clear]
                                  }]),
                 forKey: nil)
    gradient.add(Animations.get(property: .Locations,
                                fromValue: gradient.locations as Any,
                                toValue: [0, 1, 1] as Any,
                                duration: duration,
                                timingFunction: .easeInEaseOut,
                                delegate: self,
                                isRemovedOnCompletion: false,
                                completionBlocks: [
                                  {[weak self] in
                                    guard let self = self else { return }
                                    
                                    self.gradient.locations = [0, 1, 1]
                                    self.gradient.removeAllAnimations()
                                  }]),
                 forKey: nil)
    
    fadeGradient.add(Animations.get(property: .Colors,
                                    fromValue: fadeGradient.colors as Any,
                                    toValue: [clear, clear, clear] as Any,
                                    duration: duration,
                                    timingFunction: .easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: false,
                                    completionBlocks: [
                                      {[weak self] in
                                        guard let self = self else { return }
                                        
                                        self.fadeGradient.colors = [clear, clear, clear]
                                      }]),
                     forKey: nil)
    fadeGradient.add(Animations.get(property: .Locations,
                                    fromValue: fadeGradient.locations as Any,
                                    toValue: [0, 1, 1] as Any,
                                    duration: duration,
                                    timingFunction: .easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: false,
                                    completionBlocks: [
                                      {[weak self] in
                                        guard let self = self else { return }
                                        
                                        self.fadeGradient.locations = [0, 1, 1]
                                        self.fadeGradient.removeAllAnimations()
                                      }]),
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
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.blended(withFraction: 0.05, of: item.topic.tagColor).cgColor
    
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
    claimButton.imageView?.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
    nextButton.imageView?.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 1)
    nextButton.imageView?.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 4 : 2
    nextButton.imageView?.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? item.topic.tagColor.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
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
    
    addSubview(stack)
    voteButton.translatesAutoresizingMaskIntoConstraints = false
    stack.translatesAutoresizingMaskIntoConstraints = false
//    stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*2).isActive = true
    stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    
    let constraint = stack.bottomAnchor.constraint(equalTo: bottomAnchor)
    constraint.isActive = true
    publisher(for: \.bounds)
      .sink { [unowned self] in
        self.setNeedsLayout()
        constraint.constant = -$0.height/32
        self.layoutIfNeeded()
        }
      .store(in: &subscriptions)
//    stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height/4).isActive = true
    voteButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
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
  
  @objc
  func handleTap(sender: UIView) {
//    setBanned {}
//    collectionView.mode = .Default
    if sender == voteButton.getSubview(type: UIButton.self) {
      action = .Vote
    } else {
      action = sender == claimButton ? .Claim : .Next
      isUserInteractionEnabled = sender != nextButton
    }
  }
}

extension HotCard: CAAnimationDelegate {
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
