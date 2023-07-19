//
//  EmptySubscriptionsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class EmptySubscriptionsView: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  public private(set) lazy var spiral: Icon = { Icon(frame: .zero, category: .Spiral, scaleMultiplicator: 1, iconColor: "#1E1E1E".hexColor!.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.7 : 0.03)) }()
  
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 16
  private lazy var label: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold,
                                      forTextStyle: .largeTitle)
    instance.text = "zero_subscriptions".localized
    instance.textColor = .secondaryLabel
    instance.textAlignment = .center
    instance.numberOfLines = 0
    
    instance.place(inside: opaque)
    
    return opaque
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
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.black.cgColor : UIColor.systemBackground.cgColor
    instance.setGradient(colors: [feathered, clear, clear, feathered],
                         locations: [0.0, 0.15, 0.85, 1.0])
    
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
  init() {
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
    
    label.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme.cgColor : UIColor.systemBackground.cgColor
    spiral.setIconColor("#1E1E1E".hexColor!.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.7 : 0.03))
    
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.black.cgColor : UIColor.systemBackground.cgColor
    fadeGradient.setGradient(colors: [feathered, clear, clear, feathered], locations: [0.0, 0.15, 0.85, 1.0])
  }
}

private extension EmptySubscriptionsView {
  @MainActor
  func setupUI() {
    layer.masksToBounds = true
    backgroundColor = .clear
    label.placeInCenter(of: self)
    
    insertSubview(spiral, belowSubview: label)
    spiral.translatesAutoresizingMaskIntoConstraints = false
    spiral.heightAnchor.constraint(equalTo: spiral.widthAnchor).isActive = true
    spiral.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1.5).isActive = true
    spiral.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    spiral.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    spiral.startRotating(duration: 15)
    
    label.layer.masksToBounds = false
    label.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme.cgColor : UIColor.systemBackground.cgColor
    label.layer.shadowOffset = .zero
    label.layer.shadowRadius = padding
    label.layer.shadowOpacity = 1
    label.publisher(for: \.bounds)
//      .filter { [unowned self] in $0.size != self.label.bounds.size }
      .sink { [unowned self] in self.label.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath }
      .store(in: &subscriptions)
    
    publisher(for: \.bounds)
      .sink { [unowned self] in self.fadeGradient.frame = $0 }
      .store(in: &subscriptions)
    
    setAnimationsEnabled(true)
    
    layer.addSublayer(fadeGradient)
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  func generateItems(_ count: Int) {
    func getRandomCategory() -> Icon.Category {
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
    }
    
    delay(seconds: Double.random(in: 0.2...2)) {[weak self] in
      guard let self = self,
            self.items.count < self.maxItems
      else { return }
      
      let category = getRandomCategory()
      let random = Icon(frame: CGRect(origin: self.randomPoint(), size: .uniform(size: CGFloat.random(in: 30...70))))
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
      
      self.insertSubview(random, belowSubview: self.label)
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
}

