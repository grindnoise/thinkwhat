//
//  LoadingIndicator.swift
//
//  Code generated using QuartzCode 1.62.0 on 14.11.17.
//  www.quartzcodeapp.com
//

import UIKit
import Combine

class LoadingIndicator: UIView {
  
  enum Mode { case Logo, Topics }
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  public var color: UIColor {
    didSet {
      guard oldValue != color else {  return }
      
      logo.setIconColor(color)
    }
  }
  ///`Publishers`
  public let didDisappearPublisher = PassthroughSubject<Bool, Never>()//: PassthroughSubject<Bool, Never>!
  public let colorPublisher = CurrentValueSubject<UIColor?, Never>(nil)
  ///`UI`
  public var duration: TimeInterval
  public var isAnimating = false
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`UI`
 public private(set) lazy var logo: Icon = {
    let instance = Icon(frame: frame,
                        category: .Logo,
                        scaleMultiplicator: 1,
                        iconColor: color)
//    instance.alpha = 0
    
    return instance
  }()
  private lazy var outerIcon: Icon = {
    let instance = Icon(frame: frame,
                        category: .LogoOuter,
                        scaleMultiplicator: 1,
                        iconColor: color)
    instance.publisher(for: \.bounds)
      .sink { [weak self] in
        guard let self = self,
              let centerYAnchor = self.innerIcon.getConstraint(identifier: "centerYAnchor"),
              let centerXAnchor = self.innerIcon.getConstraint(identifier: "centerXAnchor")
        else { return }

        print("centerYAnchor", $0)
        
        self.setNeedsLayout()
        centerYAnchor.constant = -$0.width * 0.0965//-= 7
        centerXAnchor.constant = $0.width * 0.0827//+= 6
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    instance.alpha = 0
    
    return instance
  }()
  private lazy var innerIcon: Icon = {
    let instance = Icon(frame: frame,
                        category: .LogoInner,
                        scaleMultiplicator: 1,
                        iconColor: .white)
//    instance.publisher(for: \.bounds)
//      .sink { [weak self] in
//        guard let self = self,
//              let centerYAnchor = instance.getConstraint(identifier: "centerYAnchor"),
//              let centerXAnchor = instance.getConstraint(identifier: "centerXAnchor")
//        else { return }
//
//        print("centerYAnchor", $0)
//      }
//      .store(in: &subscriptions)
    
    return instance
  }()
  private var colorAnimation: CAAnimation?
  private var scaleAnimation: CAAnimation?
  ///`Logic`
  private let shouldSendCompletion: Bool
  private var colorAnimationStopped = false {
    didSet {
      guard /*!oldValue && */colorAnimationStopped && scaleAnimationStopped else { return }
      colorAnimation = nil
      scaleAnimation = nil
      animationsStopped.send(true)
    }
  }
  private var scaleAnimationStopped = false
  private let mode: Mode
  private let animationsStopped = PassthroughSubject<Bool, Never>()
  private var shouldStopAnimating = false
  private var isInfinite: Bool
  
  
  // MARK: - Deinitialization
  deinit {
    logo.layer.removeAllAnimations()
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  init(mode: Mode = .Logo,
       color: UIColor,
       duration: TimeInterval = 1,
       shouldSendCompletion: Bool = true,
       isInfinite: Bool = false,
       alpha: CGFloat = 0
  ) {
    
    self.mode = mode
    self.isInfinite = isInfinite
    self.duration = duration
    self.color = color
    self.shouldSendCompletion = shouldSendCompletion
    
    super.init(frame: .zero)
    
    setupUI()
    logo.alpha = alpha
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  @MainActor
  public func start(animated: Bool = true) {
//    guard !isAnimating else { return }
    
    guard animated else {
      logo.alpha = 1
      delay(seconds: 0.01) { [weak self] in
        guard let self = self else { return }
        
        self.layer.removeAllAnimations()
        switch self.mode {
        case .Logo:
          self.logo.layer.removeAllAnimations()
//          self.logo.layer.removeAllAnimations()
//          UIView.animate(withDuration: 0, animations:  {
//            self.logo.transform = .identity
//            self.logo.alpha = 1
//          }) { _ in
          UIView.animate(withDuration: 0.75, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
              self.logo.transform = .init(scaleX: 0.9, y: 0.9)
              self.logo.alpha = 0.85
            }
//          }
        case.Topics:
          self.outerIcon.layer.removeAllAnimations()
          self.innerIcon.layer.removeAllAnimations()
          UIView.animate(withDuration: 0, animations:  {
            self.outerIcon.transform = .identity
            self.outerIcon.alpha = 1
          }) { _ in
            UIView.animate(withDuration: 0.75, delay: 0, options: [.autoreverse, .repeat]) {
              self.outerIcon.transform = .init(scaleX: 0.9, y: 0.9)
              self.outerIcon.alpha = 0.75
            }
          }
        }
        self.mode == .Topics ? self.animateTopics() : ()//self.animate()
      }
      
      return
    }
    
    mode == .Logo ? { logo.transform = .init(scaleX: 0.75, y: 0.75) }() : { outerIcon.transform = .init(scaleX: 0.75, y: 0.75) }()
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        switch self.mode {
        case .Logo:
          self.logo.alpha = 1
          self.logo.transform = .identity
        case .Topics:
          self.outerIcon.alpha = 1
          self.outerIcon.transform = .identity
        }
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.layer.removeAllAnimations()
        switch self.mode {
        case .Logo:
          self.logo.layer.removeAllAnimations()
//          UIView.animate(withDuration: 0, animations:  {
//            self.logo.transform = .identity
//            self.logo.alpha = 1
//          }) { _ in
            UIView.animate(withDuration: 0.75, delay: 0, options: [.autoreverse, .repeat]) {
              self.logo.transform = .init(scaleX: 0.9, y: 0.9)
              self.logo.alpha = 0.75
            }
//          }
          self.animate()
        case.Topics:
          self.outerIcon.layer.removeAllAnimations()
          self.innerIcon.layer.removeAllAnimations()
//          UIView.animate(withDuration: 0, animations:  {
//            self.outerIcon.transform = .identity
//            self.outerIcon.alpha = 1
//          }) { _ in
            UIView.animate(withDuration: 0.75, delay: 0, options: [.autoreverse, .repeat]) {
              self.outerIcon.transform = .init(scaleX: 0.9, y: 0.9)
              self.outerIcon.alpha = 0.75
            }
//          }
          self.animateTopics()
        }
      }
  }
  
  public func removeAllAnimations() {
    isAnimating = false
    self.layer.removeAllAnimations()
    self.logo.layer.removeAllAnimations()
    self.outerIcon.layer.removeAllAnimations()
    self.innerIcon.layer.removeAllAnimations()
    self.innerIcon.layer.add(Animations.get(property: .Path,
                                            fromValue: (innerIcon.icon as! CAShapeLayer).path as Any,
                                            toValue: (innerIcon.icon as! CAShapeLayer).path as Any,
                                            duration: 0.1,
                                            delay: 0,
                                            repeatCount: 1,
                                            autoreverses: false,
                                            timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                            delegate: nil,
                                            isRemovedOnCompletion: true,
                                            completionBlocks: []),
                             forKey: "topics")
    UIView.animate(withDuration: 0) {
      self.outerIcon.transform = .identity
      self.outerIcon.alpha = 1
      self.logo.transform = .identity
      self.logo.alpha = 1
    }
  }
  
//  public func reset() {
//    colorAnimationStopped = false
//    scaleAnimationStopped = false
////    private let animationsStopped = PassthroughSubject<Bool, Never>()
//    shouldStopAnimating = false
////    didDisappearPublisher = PassthroughSubject<Bool, Never>()
//  }
  
  @MainActor
  public func stop(reset: Bool = false, completion: Closure? = nil) {
    guard mode == .Topics else {
      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        guard let self = self else { return }
        
        self.logo.transform = .init(scaleX: 0.5, y: 0.5)
        self.logo.alpha = 0
//        self.logo.transform = .identity
//        self.logo.alpha = 1
      }) { [weak self] _ in
        guard let self = self else { return }
        
        completion?()
        self.shouldStopAnimating = true
        self.didDisappearPublisher.send(true)
        self.didDisappearPublisher.send(completion: .finished)
      }
      
      return
    }
    
    shouldStopAnimating = true
    
    animationsStopped
      .sink { [weak self]_  in
        guard let self = self else { return }
        
        UIView.animate(
          withDuration: 0.25,
          delay: 0,
          options: [.curveEaseInOut],
          animations: { [weak self] in
            guard let self = self else { return }
            
            self.logo.transform = .init(scaleX: 0.5, y: 0.5)
            self.logo.alpha = 0
          }) { [weak self] _ in
            guard let self = self else { return }
            
            self.logo.icon.removeAllAnimations()
            self.didDisappearPublisher.send(true)
            self.isAnimating = false
            
            guard reset else { return }
            
            self.colorAnimationStopped = false
            self.scaleAnimationStopped = false
            self.shouldStopAnimating = false
            
            guard self.shouldSendCompletion else { return }
            
            self.didDisappearPublisher.send(completion: .finished)
          }
      }
      .store(in: &subscriptions)
  }
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
  
//  override func layoutSubviews() {
//    super.layoutSubviews()
//
//    guard let centerYAnchor = innerIcon.getConstraint(identifier: "centerYAnchor"),
//          let centerXAnchor = innerIcon.getConstraint(identifier: "centerXAnchor")
//    else { return }
//
//    print("centerYAnchor")
//  }
}

private extension LoadingIndicator {
  @MainActor
  func setupUI() {
    clipsToBounds = false
    heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1/1).isActive = true
    backgroundColor = .clear
  
    switch mode {
    case .Logo:
      logo.place(inside: self)
    case.Topics:
      outerIcon.place(inside: self)
      innerIcon.placeCentered(inside: outerIcon, withMultiplier: 0.5)
//      outerIcon.addSubview(innerIcon)
//      innerIcon.translatesAutoresizingMaskIntoConstraints = false
//      NSLayoutConstraint.activate([
//        innerIcon.centerXAnchor.constraint(equalTo: outerIcon.centerXAnchor),
//        innerIcon.widthAnchor.constraint(equalTo: outerIcon.widthAnchor, multiplier: 0.56),
//        innerIcon.centerYAnchor.constraint(equalTo: outerIcon.centerYAnchor)
//      ])
//      innerIcon.place(inside: outerIcon)
      innerIcon.layer.zPosition = 10
      
//      setNeedsLayout()
//      layoutIfNeeded()
      
//      guard let centerYAnchor = innerIcon.constraints.filter({ $0.identifier == "centerYAnchor" }).first,
//guard let centerXAnchor = innerIcon.getConstraint(identifier: "centerXAnchor") else { return }
////
//      print(centerXAnchor)
    }
  }
  
  @MainActor
  func animate() {//from: UIColor, to: UIColor) {
//    guard !isAnimating else { return }
    isAnimating = true
    
    colorAnimation = Animations.get(property: .FillColor,
                                    fromValue: color.cgColor as Any,
                                    toValue: color.withAlphaComponent(0.75).cgColor as Any,
                                    duration: duration,
                                    delay: 0,
                                    repeatCount: isInfinite ? .infinity : 1,
                                    autoreverses: true,
                                    timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: true,
                                    completionBlocks: [
                                      {[weak self] in
                                        guard let self = self else { return }
                                        
                                        self.isAnimating = false
                                        
                                        if self.shouldStopAnimating {
//                                          self.colorAnimation = nil
                                          self.colorAnimationStopped = true
//                                          self.scaleAnimationStopped = true
                                        } else {
                                          self.animate()
                                        }
                                      }])
    scaleAnimation = Animations.get(property: .Path,
                                    fromValue: (logo.icon as! CAShapeLayer).path as Any,
                                    toValue: (logo.icon as! CAShapeLayer).path?.getScaledPath(size: bounds.size, scaleMultiplicator: 1.15) as Any,
                                    duration: duration,
                                    delay: 0,
                                    repeatCount: isInfinite ? .infinity : 1,
                                    autoreverses: true,
                                    timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: true,
                                    completionBlocks: [
                                      {[weak self] in
                                        guard let self = self else { return }
                                        
                                        self.isAnimating = false
                                        
                                        if self.shouldStopAnimating {
//                                          self.scaleAnimation = nil
                                          self.scaleAnimationStopped = true
                                        } else {
                                          self.animate()
                                        }
                                      }])
    
    logo.icon.add(scaleAnimation!, forKey: "alpha")
    logo.icon.add(colorAnimation!, forKey: "scale")
  }
  
  @MainActor
  func animateTopics() {
    func getRandomTopic() -> Topic {
      Topics.shared.all[Int.random(in: 0...Topics.shared.all.count - 1)]
    }
    
    let random = getRandomTopic()
    
    guard random.iconCategory != .Logo else { animateTopics(); return }

    colorPublisher.send(random.tagColor)
    isAnimating = true
    
    let destinationPath = (innerIcon.getLayer(random.iconCategory) as! CAShapeLayer).path!.getScaledPath(size: innerIcon.bounds.size, scaleMultiplicator: 1.5)
    let pathAnimation = Animations.get(property: .Path,
                                       fromValue: (innerIcon.icon as! CAShapeLayer).path as Any,
                                       toValue: destinationPath as Any,
                                       duration: 0.35,
                                       delay: 0,
                                       repeatCount: 1,
                                       autoreverses: false,
                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                       delegate: self,
                                       isRemovedOnCompletion: true,
                                       completionBlocks: [
                                        {[weak self] in
                                          guard let self = self,
                                                self.isAnimating
                                          else { return }

//                                          self.logo.category = random.iconCategory
                                          delay(seconds: 2) { [weak self] in
                                            guard let self = self else { return }

                                            self.animateTopics()
                                          }
                                        }])
    let innerColorAnimation = Animations.get(property: .FillColor,
                                        fromValue: outerIcon.iconColor.cgColor as Any,
                                        toValue: random.tagColor.cgColor as Any,
                                        duration: 0.35,
                                        delay: 0,
                                        repeatCount: 1,
                                        autoreverses: false,
                                        timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                        delegate: nil,
                                        isRemovedOnCompletion: true,
                                        completionBlocks: [])
    (self.outerIcon.icon as! CAShapeLayer).fillColor = random.tagColor.cgColor
    (self.innerIcon.icon as! CAShapeLayer).path = destinationPath//(innerIcon.getLayer(random.iconCategory) as! CAShapeLayer).path
//
    innerIcon.icon.add(pathAnimation, forKey: "topics")
    outerIcon.icon.add(innerColorAnimation, forKey: "color")
  }
}

extension LoadingIndicator: CAAnimationDelegate {
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
