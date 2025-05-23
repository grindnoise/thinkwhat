//
//  PercentageView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class PercentageView: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  public var percent: Int = 0
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let backgroundLine = CAShapeLayer()
  private let foregroundLine = CAShapeLayer()
  private var bgLightColor: UIColor {
    didSet {
      guard oldValue != bgLightColor, traitCollection.userInterfaceStyle != .dark else { return }
      
      backgroundLine.strokeColor = bgLightColor.cgColor
    }
  }
  private var bgDarkColor: UIColor {
    didSet {
      guard oldValue != bgDarkColor, traitCollection.userInterfaceStyle == .dark else { return }
      
      backgroundLine.strokeColor = bgDarkColor.cgColor
    }
  }
  public let lineWidth: CGFloat
  private var isAnimating = false
  
  
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
  init(lineWidth: CGFloat,
       foregoundColor: UIColor,
       backgroundLightColor: UIColor = .secondarySystemBackground,
       backgroundDarkColor: UIColor = .tertiarySystemBackground) {
    self.lineWidth = lineWidth
    self.bgLightColor = backgroundLightColor
    self.bgDarkColor = backgroundDarkColor
    
    super.init(frame: .zero)
    
    foregroundLine.strokeColor = foregoundColor.cgColor
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  public func setPercent(value: Double, animated: Bool) {
    guard animated, !isAnimating else {
      foregroundLine.strokeStart = 0
      foregroundLine.strokeEnd = value
      
      return
    }
    
    isAnimating = true
    let anim = Animations.get(property: .StrokeEnd,
                              fromValue: foregroundLine.strokeEnd,
                              toValue: value,
                              duration: Animations.Duration.percentageStroke,
                              timingFunction: .easeInEaseOut,
                              delegate: self,
                              isRemovedOnCompletion: false,
                              completionBlocks: { [weak self] in
      guard let self = self else { return }
      
      self.isAnimating = false
      self.foregroundLine.strokeEnd = value
      self.foregroundLine.removeAllAnimations()
    })
    foregroundLine.add(anim, forKey: nil)
    //    foregroundLine.strokeEnd = value
  }
  
  public func setColor(foregound: UIColor,
                       background: UIColor,
                       animated: Bool) {
    guard animated else {
      foregroundLine.strokeColor = foregound.cgColor
      backgroundLine.strokeColor = background.cgColor
      return
    }
  }
  
  public func setBackgroundLightColor(_ color: UIColor) {
    bgLightColor = color
  }
  
  public func setBackgroundDarkColor(_ color: UIColor) {
    bgDarkColor = color
  }
  
  // MARK: - Overridden methods
  open override func layoutSubviews() {
    super.layoutSubviews()
    
    updateUI()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    backgroundLine.strokeColor = traitCollection.userInterfaceStyle == .dark ? bgDarkColor.cgColor : bgLightColor.cgColor
  }
}

private extension PercentageView {
  @MainActor
  func setupUI() {
    layer.addSublayer(backgroundLine)
    layer.addSublayer(foregroundLine)
    
    foregroundLine.strokeStart = 0
    foregroundLine.strokeEnd = 0
    backgroundLine.strokeColor = traitCollection.userInterfaceStyle == .dark ? bgDarkColor.cgColor : bgLightColor.cgColor
    accessibilityIdentifier = "PercentageView"
  }
  
  @MainActor
  func updateUI() {
    let backgroundPath = UIBezierPath()
    backgroundPath.move(to: CGPoint(x: 0 + lineWidth / 2, y: frame.height/2))
    backgroundPath.addLine(to: CGPoint(x: frame.width - lineWidth / 2, y: frame.height/2))
    backgroundPath.stroke()
    
    backgroundLine.path = backgroundPath.cgPath
//    backgroundLine.strokeColor = backgroundColor.cgColor
    backgroundLine.lineWidth = lineWidth
    backgroundLine.lineCap = .round

    let foregroundPath = UIBezierPath()
    foregroundPath.move(to: CGPoint(x: 0 + lineWidth / 2, y: frame.height/2))// - path.lineWidth / 2))
    foregroundPath.addLine(to: CGPoint(x: frame.width - lineWidth / 2, y: frame.height/2))// - path.lineWidth / 2))
    foregroundPath.stroke()
    
    foregroundLine.path = foregroundPath.cgPath
    foregroundLine.lineWidth = lineWidth
    foregroundLine.lineCap = .round
  }
}

extension PercentageView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
    }
  }
}

