//
//  CompatibilityView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CompatibilityView: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  public var percent: Double = 0 {
    didSet {
      guard percent != oldValue else { return }
      
      setProgress(value: percent)
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private lazy var percentageView: UIView = {
    let instance = UIView()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.layer.addSublayer(backgroundCircle)
    instance.layer.addSublayer(foregroundCircle)
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { [weak self] rect in
        guard let self = self else { return }
        
        let lineWidth = rect.width * 0.1
        self.backgroundCircle.lineWidth = lineWidth
        self.backgroundCircle.path = UIBezierPath(ovalIn: rect.insetBy(dx: lineWidth/2, dy: lineWidth/2)).cgPath
//        self.setProgress(value: self.percent)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var descriptionView: UIView = {
    let instance = UIView()
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      percentageView,
      descriptionView
    ])
    instance.spacing = padding
    instance.axis = .horizontal
    
    return instance
  }()
  private lazy var backgroundCircle: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(ovalIn: .zero).cgPath
    instance.fillColor = UIColor.clear.cgColor
    instance.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1).cgColor : UIColor.systemGray.withAlphaComponent(0.1).cgColor
    instance.lineWidth = 10
    instance.lineCap = .round
    
    return instance
  }()
  private lazy var foregroundCircle: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(ovalIn: .zero).cgPath
    instance.fillColor = UIColor.clear.cgColor
    instance.strokeColor = color.cgColor
    instance.lineWidth = 10
    instance.lineCap = .round
    
    return instance
  }()
  private let padding: CGFloat = 8
  private var isAnimating = false
  private var color: UIColor
  
  
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
  init(color: UIColor) {
    self.color = color
    
    super.init(frame: .zero)
    
    accessibilityIdentifier = "CompatibilityView"
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  public func animate(duration: TimeInterval, delay: TimeInterval) {
    isAnimating = true
    let anim = Animations.get(property: .StrokeEnd,
                              fromValue: 0,
                              toValue: 1,
                              duration: duration,
                              delay: delay,
                              timingFunction: .easeInEaseOut,
                              delegate: self,
                              isRemovedOnCompletion: false,
                              completionBlocks: [{ [weak self] in
      guard let self = self else { return }

      self.isAnimating = false
      self.foregroundCircle.strokeEnd = 1
      self.foregroundCircle.removeAllAnimations()
    }])
    foregroundCircle.add(anim, forKey: nil)
  }
  
  // MARK: - Overridden methods
  open override func layoutSubviews() {
    super.layoutSubviews()
    
    updateUI()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    backgroundCircle.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1).cgColor : UIColor.systemGray.withAlphaComponent(0.1).cgColor
  }
}

private extension CompatibilityView {
  @MainActor
  func setupUI() {
    stack.place(inside: self)//,

    foregroundCircle.strokeEnd = 0
    backgroundCircle.strokeStart = 0
    backgroundCircle.strokeEnd  = 1
  }
  
  @MainActor
  func updateUI() {

  }
  
  func setProgress(value: Double) {
    let lineWidth = percentageView.bounds.width * 0.1
    let startAngle = -CGFloat.pi / 2
    let path = UIBezierPath(arcCenter: CGPoint(x: percentageView.bounds.midX, y: percentageView.bounds.midY),
                            radius: percentageView.bounds.width/2 - lineWidth/2,
                            startAngle: startAngle,
                            endAngle: CGFloat.pi * 2 * value / 100 + startAngle,
                            clockwise: true)
    foregroundCircle.path = path.cgPath
  }
}

extension CompatibilityView: CAAnimationDelegate {
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

