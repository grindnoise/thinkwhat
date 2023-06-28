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
//    instance.backgroundColor = .traitCollection.userInterfaceStyle != .dark ? .white : Colors.darkTheme
//    instance.layer.addSublayer(gradient)
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
  public private(set) lazy var button: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UIButton()
    instance.layer.zPosition = 100
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .capsule
      config.baseBackgroundColor = Colors.main
      config.attributedTitle = AttributedString("create_post".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.backgroundColor = Colors.main
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.height/2 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "create_post".localized,
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
        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
      }
      .store(in: &subscriptions)
    instance.place(inside: opaque)
    
    return opaque
  }()
  public var subscriptions = Set<AnyCancellable>()
  public var tapPublisher = PassthroughSubject<Void, Never>()
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private var shouldTerminate = false
  private let padding: CGFloat = 8
  private let maxItems = 15
  private var items = [Icon]() {
    didSet {
      guard !shouldTerminate && items.count < maxItems else { return }
      
      generateItems(maxItems - items.count)
    }
  }
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
  private lazy var logoIcon: Logo = { Logo() }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 0
    instance.backgroundColor = .clear
    instance.textAlignment = .center
    instance.text = "waiting_for_new_posts".localized
    instance.textColor = .label//Colors.Logo.Flame.rawValue
    instance.font = UIFont(name: Fonts.Rubik.Regular, size: 14)
    
//    Timer
//      .publish(every: 1, on: .main, in: .common)
//      .autoconnect()
//      .sink { [weak self] _ in
//        guard let self = self else { return }
//
//        guard self.dots.count < 3 else {
//          self.dots = ""
//          UIView.setAnimationsEnabled(false)
//          self.label.text! = "waiting_for_new_posts".localized
//          UIView.setAnimationsEnabled(true)
//
//          return
//        }
//
//        self.dots += "."
//        UIView.setAnimationsEnabled(false)
//        self.label.text! = "waiting_for_new_posts".localized + self.dots
//        UIView.setAnimationsEnabled(true)
//      }
//      .store(in: &subscriptions)
    
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
    logoIcon.placeInCenter(of: top,
                          topInset: 0,
                          bottomInset: 0)
//    let bottom = UIView.opaque()
//    bottom.accessibilityIdentifier = "bottom"
//    label.place(inside: bottom)
    let instance = UIStackView(arrangedSubviews: [
      top,
      label
    ])
    instance.axis = .vertical
    instance.spacing = 20
    
    return instance
  }()
  //  private var dots = ""
  public private(set) lazy var spiral: Icon = {
    let instance = Icon(frame: .zero,
                        category: .Spiral,
                        scaleMultiplicator: 1,
                        iconColor: "#1E1E1E".hexColor!.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.03))
    instance.backgroundColor = .clear//traitCollection.userInterfaceStyle != .dark ? .white : Colors.darkTheme
    
    return instance
  }()
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
    shouldTerminate = false
    spiral.startRotating(duration: 15)
    UIView.animate(withDuration: 0.5, animations: { [weak self]  in
        guard let self = self else { return }
        
        self.logoIcon.transform = .identity
        self.logoIcon.alpha = 1
    }) { _ in
      UIView.animate(withDuration: 1.25, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) { [weak self]  in
        guard let self = self else { return }
        
        self.logoIcon.transform = .init(scaleX: 0.9, y: 0.9)
        self.logoIcon.alpha = 0.95
      }
    }
    
    generateItems(maxItems)
  }
  
  public func removeAllAnimations() {
    shouldTerminate = true
    items.forEach { $0.removeFromSuperview() }
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    spiral.setIconColor("#1E1E1E".hexColor!.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.03))
    spiral.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .white : Colors.darkTheme
    button.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 8 : 4
    button.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
    button.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    label.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme.cgColor : UIColor.systemBackground.cgColor
  }
}

private extension EmptyHotCard {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = false
    
    stack.placeInCenter(of: body)
    
    body.insertSubview(spiral, belowSubview: stack)
    body.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    spiral.translatesAutoresizingMaskIntoConstraints = false
    spiral.backgroundColor = .clear
    spiral.heightAnchor.constraint(equalTo: spiral.widthAnchor).isActive = true
    spiral.widthAnchor.constraint(equalTo: body.heightAnchor, multiplier: 1.5).isActive = true
    spiral.centerXAnchor.constraint(equalTo: logoIcon.centerXAnchor).isActive = true
    spiral.centerYAnchor.constraint(equalTo: logoIcon.centerYAnchor).isActive = true
    
    shadowView.place(inside: self)
    
    setNeedsLayout()
    layoutIfNeeded()
    
    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    
    let constraint = button.bottomAnchor.constraint(equalTo: bottomAnchor)
    constraint.isActive = true
    publisher(for: \.bounds)
      .sink { [unowned self] in
        self.setNeedsLayout()
        constraint.constant = -$0.height/32
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    logoIcon.translatesAutoresizingMaskIntoConstraints = false
    logoIcon.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.31).isActive = true
    
    stack.layer.masksToBounds = false
    label.layer.masksToBounds = false
    label.layer.shadowPath = UIBezierPath(roundedRect: label.bounds, cornerRadius: label.bounds.height/2).cgPath
    label.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme.cgColor : UIColor.systemBackground.cgColor
    label.layer.shadowOffset = .zero
    label.layer.shadowRadius = label.bounds.height/2
    label.layer.shadowOpacity = 1
    
    logoIcon.layer.masksToBounds = false
    logoIcon.layer.shadowColor = Colors.main.cgColor
    logoIcon.layer.shadowOffset = .zero
    logoIcon.layer.shadowRadius = padding
    logoIcon.layer.shadowOpacity = 0.5
    
    animate()
  }

  func generateItems(_ count: Int) {
    func getRandomCategory() -> Icon.Category {
      let all = Set(Topics.shared.all.filter({ !$0.isOther }).map { $0.iconCategory })
      let current = Set(items.map { $0.category })
      var diff = all.subtracting(current)
      
      return Array(diff)[Int.random(in: 0...diff.count - 1)]
//      Topics.shared.all.filter({ !$0.isOther})[Int.random(in: 0...Topics.shared.all.count - 1)]
    }
    
    delay(seconds: Double.random(in: 0.2...2)) {[weak self] in
      guard let self = self else { return }
      
      let category = getRandomCategory()
      let random = Icon(frame: CGRect(origin: self.randomPoint(), size: .uniform(size: CGFloat.random(in: 20...40))))
      let color = Topics.shared.all.filter({ $0.iconCategory == category }).first?.tagColor ?? Colors.main
      random.iconColor = color
      random.scaleMultiplicator = 1
      random.category = category
      random.transform = .init(scaleX: 0.5, y: 0.5)
      random.alpha = 0
      random.startRotating(duration: Double.random(in: 5...30),
                           repeatCount: .infinity,
                           clockwise: Int.random(in: 1...3) % 2 == 0 ? true : false)
      random.setAnchorPoint(CGPoint(x: Int.random(in: -5...5), y: Int.random(in: -5...5)))
      random.layer.masksToBounds = false
      random.icon.shadowOffset = .zero
      random.icon.shadowOpacity = Float.random(in: 0.3...0.8)
      random.icon.shadowColor = color.cgColor
      random.icon.shadowRadius = random.bounds.width * 0.3
      
      if Int.random(in: 1...3) % 2 == 0 {
        self.body.insertSubview(random, belowSubview: self.stack)
      } else {
        self.body.insertSubview(random, belowSubview: self.spiral)
      }
      self.items.append(random)
      let duration = TimeInterval.random(in: 4...12)
      UIView.animate(withDuration: duration) {
        random.transform = CGAffineTransform(rotationAngle: Int.random(in: 0...9) % 2 == 0 ? .pi : -.pi)//Float.random(in: 0...360).degreesToRadians)
      }
      Timer.scheduledTimer(withTimeInterval: duration*0.9, repeats: false, block: { _ in
        UIView.animate(withDuration: TimeInterval.random(in: 0.3...0.8)) {
          random.alpha = 0
          random.transform = .init(scaleX: 0.5, y: 0.5)
        } completion: { _ in
          random.removeFromSuperview()
          self.items.remove(object: random)
        }
      })
      
      UIView.animate(withDuration: TimeInterval.random(in: 0.3...0.8)) {
        random.alpha = CGFloat.random(in: 0.2...0.6)
        random.transform = .identity
      }
    }
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
