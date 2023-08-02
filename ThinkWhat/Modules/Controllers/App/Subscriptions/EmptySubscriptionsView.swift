//
//  EmptySubscriptionsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class EmptyPublicationsView: UIView {
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  public private(set) lazy var spiral: Icon = {
    Icon(frame: .zero, category: .Spiral,
         scaleMultiplicator: 1,
         iconColor: traitCollection.userInterfaceStyle == .dark ? spiralDarkColor : spiralLightColor) }()
  ///**Publishers**
  public let buttonTapEvent = PassthroughSubject<Void, Never>()
  ///**UI**
  public var backgroundLightColor: UIColor {
    didSet {
      guard oldValue != backgroundLightColor, traitCollection.userInterfaceStyle != .dark else { return }
      
      backgroundColor = backgroundLightColor
      updateGradient()
    }
  }
  public var backgroundDarkColor: UIColor {
    didSet {
      guard oldValue != backgroundDarkColor, traitCollection.userInterfaceStyle == .dark else { return }
      
      backgroundColor = backgroundDarkColor
      updateGradient()
    }
  }
  public var spiralLightColor: UIColor {
    didSet {
      guard oldValue != spiralLightColor, traitCollection.userInterfaceStyle != .dark else { return }
      
      backgroundColor = spiralLightColor
    }
  }
  public var spiralDarkColor: UIColor {
    didSet {
      guard oldValue != spiralDarkColor, traitCollection.userInterfaceStyle == .dark else { return }
      
      backgroundColor = spiralDarkColor
    }
  }
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let mode: Survey.SurveyCategory
  private let showsButton: Bool
  private let showsLogo: Bool
  ///**UI**
  private let labelText: String
  private let buttonText: String
  private let buttonColor: UIColor
  private lazy var logoIcon: Logo = {
    let instance = Logo()
    instance.layer.shadowOpacity = 1
    instance.layer.shadowColor = Colors.main.withAlphaComponent(0.35).cgColor
    instance.layer.shadowRadius = padding/2
    instance.layer.shadowOffset = .zero
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 0
    instance.attributedText = NSAttributedString(string: !labelText.isEmpty ? labelText.localized : mode == .Subscriptions ? mode.localizedDescription : Survey.SurveyCategory.All.localizedDescription,
                                                 attributes: [
                                                  .font: UIFont.scaledFont(fontName: Fonts.Rubik.Medium, forTextStyle: .headline) as Any,
                                                  .foregroundColor: UIColor.secondaryLabel,
                                                  .paragraphStyle: { let paragraphStyle = NSMutableParagraphStyle(); paragraphStyle.lineSpacing = padding/2; return paragraphStyle }(),
                                                 ])
    instance.textAlignment = .center
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let instance = UIStackView()
    instance.axis = .vertical
    instance.spacing = 20
    
    return instance
  }()
  private let padding: CGFloat = 16
  private lazy var blur: UIVisualEffectView = {
    let instance = UIVisualEffectView(effect: UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterial))
    instance.cornerRadius = padding
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    stack.place(inside: instance.contentView, insets: .uniform(size: padding*2))
    
    return instance
  }()
  private let maxItems = 16
  private var items = [Icon]() {
    didSet {
      guard !shouldTerminate && items.count < maxItems else { return }
      
      generateItems(maxItems - items.count)
    }
  }
  private var shouldTerminate = false
  private lazy var fadeGradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    let clear = (traitCollection.userInterfaceStyle == .dark ? backgroundDarkColor : backgroundLightColor).withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? backgroundDarkColor.cgColor : backgroundLightColor.cgColor
    instance.setGradient(colors: [feathered, clear, clear, feathered],
                         locations: [0.0, 0.15, 0.85, 1.0])
    
    return instance
  }()
  public private(set) lazy var button: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UIButton()
    instance.layer.zPosition = 100
    instance.addTarget(self,
                       action: #selector(self.handleTap),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .capsule
      config.baseBackgroundColor = buttonColor
      config.attributedTitle = AttributedString(buttonText.localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.backgroundColor = buttonColor
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.height/2 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: buttonText.localized,
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
  init(mode: Survey.SurveyCategory = .All,
       labelText: String = "",
       showsButton: Bool = false,
       showsLogo: Bool = false,
       buttonText: String = "",
       buttonColor: UIColor = Colors.main,
       backgroundLightColor: UIColor = .clear,
       backgroundDarkColor: UIColor = .clear,
       spiralLightColor: UIColor = Colors.spiralLight, // UIColor.white.blended(withFraction: 0.04, of: UIColor.lightGray),//"#1E1E1E".hexColor!.withAlphaComponent(0.04),
       spiralDarkColor: UIColor = Colors.spiralDark) { // }"#1E1E1E".hexColor!.withAlphaComponent(0.7)) {
    self.mode = mode
    self.labelText = labelText
    self.showsLogo = showsLogo
    self.showsButton = showsButton
    self.buttonText = buttonText
    self.buttonColor = buttonColor
    self.backgroundLightColor = backgroundLightColor
    self.backgroundDarkColor = backgroundDarkColor
    self.spiralDarkColor = spiralDarkColor
    self.spiralLightColor = spiralLightColor
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  public func setAnimationsEnabled(_ flag: Bool) {
    if flag {
      spiral.startRotating(duration: 15)
      shouldTerminate = false
      generateItems(maxItems)
    } else {
      spiral.stopRotating()
      shouldTerminate = true
      items.forEach { $0.removeFromSuperview() }
    }
  }
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? backgroundDarkColor : backgroundLightColor
    spiral.setIconColor(traitCollection.userInterfaceStyle == .dark ? spiralDarkColor : spiralLightColor)
    
    // Set gradient colors
    updateGradient()
    
    // Blur effect
    blur.effect = UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterial)
  }
}

private extension EmptyPublicationsView {
  @MainActor
  func setupUI() {
    layer.masksToBounds = true
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? backgroundDarkColor : backgroundLightColor
    
    if showsLogo {
      stack.addArrangedSubview(logoIcon)
      stack.alignment = .center
      UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) { [weak self] in
        guard let self = self else { return }
        
        self.logoIcon.transform = .init(scaleX: 0.95, y: 0.95)
        self.logoIcon.alpha = 0.95
      }
    }
    
    blur.placeInCenter(of: self)
    blur.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    stack.addArrangedSubview(label)
    
    insertSubview(spiral, belowSubview: blur)
    spiral.translatesAutoresizingMaskIntoConstraints = false
    spiral.heightAnchor.constraint(equalTo: spiral.widthAnchor).isActive = true
    spiral.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1.5).isActive = true
    spiral.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    spiral.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    spiral.startRotating(duration: 15)
    
//    if showsLogo {
//      logoIcon.translatesAutoresizingMaskIntoConstraints = false
//      logoIcon.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.31).isActive = true
//    }
    
    //    label.layer.masksToBounds = false
    //    label.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme.cgColor : UIColor.lightGray.withAlphaComponent(0.25).cgColor
    //    label.layer.shadowOffset = .zero
    //    label.layer.shadowRadius = padding
    //    label.layer.shadowOpacity = 1
    //    label.publisher(for: \.bounds)
    ////      .filter { [unowned self] in $0.size != self.label.bounds.size }
    //      .sink { [unowned self] in
    //        self.label.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
    //
    ////        guard let bg = self.label.getSubview(type: UIView.self, identifier: "bg") else { return }
    ////
    ////        bg.cornerRadius = $0.width * 0.025
    //      }
    //      .store(in: &subscriptions)
    
    publisher(for: \.bounds)
      .sink { [unowned self] in self.fadeGradient.frame = $0 }
      .store(in: &subscriptions)
    
    //    setAnimationsEnabled(true)
    
    layer.addSublayer(fadeGradient)
    
    if showsButton {
      addSubview(button)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
      button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding*2).isActive = true
    }
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  func generateItems(_ count: Int) {
    func getRandomCategory() -> Icon.Category {
      switch self.mode {
      case.Subscriptions:
        let all = [
          10038,
          10039,
          10040,
          10041,
          10064,
          10047,
          11002,
          42,
        ].map { Icon.Category(rawValue: $0)! }
        
        return all[Int.random(in: 0..<all.count-1)]
      default:
        let all = Set(Topics.shared.all.filter({ !$0.isOther }).map { $0.iconCategory })
        let current = Set(items.map { $0.category })
        let diff = all.subtracting(current)
        
        return Array(diff)[Int.random(in: 0...diff.count - 1)]
      }
    }
    
    delay(seconds: items.count < maxItems/2 ? 0 : Double.random(in: 0.2...2)) {[weak self] in
      guard let self = self,
            self.items.count < self.maxItems
      else { return }
      
      let category = getRandomCategory()
      let random = Icon(frame: CGRect(origin: self.randomPoint(), size: .uniform(size: CGFloat.random(in: 20...50))))
      let color = UIColor.random()
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
      
      self.insertSubview(random, belowSubview: self.blur)
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
      
      UIView.animate(withDuration: TimeInterval.random(in: 0.3...0.8)) { [weak self] in
        guard let self = self else { return }
        
        random.alpha = CGFloat.random(in: self.traitCollection.userInterfaceStyle == .dark ? 0.2...0.6 : 0.3...0.7)
        random.transform = .identity
      }
    }
  }
  
  func updateGradient() {
    let clear = (traitCollection.userInterfaceStyle == .dark ? backgroundDarkColor : backgroundLightColor).withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? backgroundDarkColor.cgColor : backgroundLightColor.cgColor
    fadeGradient.setGradient(colors: [feathered, clear, clear, feathered],
                         locations: [0.0, 0.15, 0.85, 1.0])
  }
  
  @objc
  func handleTap() {
    buttonTapEvent.send()
  }
}

