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
  public var username = ""
  public var percent: Double = .zero {
    didSet {
      guard percent != oldValue else { return }
      
      foregroundCircle.path = getProgressPath(in: percentageView.bounds,
                                              progress: percent,
                                              lineWidth: percentageView.bounds.width * lineWidthMultiplier)
      animate(duration: 1, delay: 0.15)
    }
  }
  //Publishers
  @Published var showDetails = false 
  //UI
  public var color: UIColor = .clear {
    didSet {
      updateUI()
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let lineWidthMultiplier: CGFloat = 0.115
  private lazy var descriptionLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .center
    instance.numberOfLines = 0
    instance.text = "100%"
    
    return instance
  }()
  private lazy var percentageLabel: UILabel = {
    let instance = UILabel()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.font = UIFont(name: Fonts.Semibold, size: $0.height * 0.3) }
      .store(in: &subscriptions)
    instance.textAlignment = .center
    instance.numberOfLines = 1
    instance.text = "100%"
    
    return instance
  }()
  private lazy var disclosureButton: UIButton = {
    let instance = UIButton()
    instance.tintColor = color
    instance.contentVerticalAlignment = .bottom
    instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
//    instance.heightAnchor.constraint(equalToConstant: "more_info".localized.uppercased().height(withConstrainedWidth: 1000,
//                                                                                                font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .footnote)!)).isActive = true
    return instance
  }()
  private lazy var percentageView: UIView = {
    let instance = UIView()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.layer.addSublayer(backgroundCircle)
    instance.layer.addSublayer(foregroundCircle)
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { [weak self] rect in
        guard let self = self else { return }
        
        let lineWidth = rect.width * self.lineWidthMultiplier
        self.backgroundCircle.lineWidth = lineWidth
        self.backgroundCircle.path = UIBezierPath(ovalIn: rect.insetBy(dx: lineWidth/2, dy: lineWidth/2)).cgPath
        
        guard self.percent != .zero else { return }

        self.foregroundCircle.path = self.getProgressPath(in: rect, progress: self.percent, lineWidth: lineWidth)
      }
      .store(in: &subscriptions)
        
    percentageLabel.placeInCenter(of: instance, heightMultiplier: 0.75)
    
    return instance
  }()
  private lazy var descriptionView: UIView = {
    let instance = UIView()
    instance.alpha = 0
    
    descriptionLabel.place(inside: instance)
    instance.addSubview(disclosureButton)
    disclosureButton.translatesAutoresizingMaskIntoConstraints = false
    disclosureButton.bottomAnchor.constraint(equalTo: instance.bottomAnchor).isActive = true
    disclosureButton.centerXAnchor.constraint(equalTo: instance.centerXAnchor).isActive = true
    
//    UIStackView(arrangedSubviews: [
//      descriptionLabel,
//      disclosureButton,
//    ])
//    instance.spacing = padding
//    instance.axis = .vertical
    
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
//    instance.lineWidth = 10
    instance.lineCap = .round
    
    return instance
  }()
  private lazy var foregroundCircle: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(ovalIn: .zero).cgPath
    instance.fillColor = UIColor.clear.cgColor
    instance.strokeColor = color.cgColor
//    instance.lineWidth = 10
    instance.lineCap = .round
//    instance.publisher(for: \.bounds)
//      .sink { [weak self] in
//        guard let self = self else { return }
//
//        let lineWidth = percentageView.bounds.width * lineWidthMultiplier
//        let startAngle = -CGFloat.pi / 2
//        let path = UIBezierPath(arcCenter: CGPoint(x: percentageView.bounds.midX, y: percentageView.bounds.midY),
//                                radius: percentageView.bounds.width/2 - lineWidth/2,
//                                startAngle: startAngle,
//                                endAngle: CGFloat.pi * 2 * value / 100 + startAngle,
//                                clockwise: true)
//        foregroundCircle.path = path.cgPath
//      }
//      .store(in: &subscriptions)
    
    return instance
  }()
  private let padding: CGFloat = 8
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
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    accessibilityIdentifier = "CompatibilityView"
    setupUI()
  }
//  init(color: UIColor) {
//    self.color = color
//
//    super.init(frame: .zero)
//
//    accessibilityIdentifier = "CompatibilityView"
//    setupUI()
//  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  public func animate(duration: TimeInterval, delay: TimeInterval) {
    func setDescriptionLabel() {
      descriptionView.alpha = 0
      descriptionView.transform = .init(scaleX: 0.75, y: 0.75)
      
      var level = "userprofile_compatibility_level_low".localized
      if  33..<66 ~= Int(percent) {
        level = "userprofile_compatibility_level_middle".localized
      } else {
        level = "userprofile_compatibility_level_high".localized
      }
      
      let attributedString = NSMutableAttributedString(string: "userprofile_compatibility_level_with_user".localized,
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline) as Any
                                                       ])
      attributedString.append(NSAttributedString(string: username, attributes: [
        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline) as Any
      ]))
      attributedString.append(NSAttributedString(string: "userprofile_compatibility_level_with_user_is".localized, attributes: [
        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline) as Any
      ]))
      attributedString.append(NSAttributedString(string: level, attributes: [
        .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .headline) as Any,
        .foregroundColor: color as Any
      ]))
      descriptionLabel.attributedText = attributedString
      
      disclosureButton.setAttributedTitle(NSMutableAttributedString(string: "more_info".localized.uppercased(),
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .footnote) as Any,
                                                        .foregroundColor: color as Any
                                                       ]),
                                          for: .normal)
      
      UIView.animate(withDuration: 0.35, delay: 0.1) { [weak self] in
        guard let self = self else { return }
        
        self.descriptionView.alpha = 1
        self.descriptionView.transform = .identity
      }
    }
    
    setDescriptionLabel()
    
    guard percent != .zero else {
      foregroundCircle.opacity = 0
      percentageLabel.text = "0%"
      return
    }
    
    let timer = Publishers.countdown(queue: .main,
                                     interval: .milliseconds(Int((1.0/percent)*1000)),
                                     times: .max(Int(percent)))
    timer.sink { [weak self] element in
      guard let self = self else { return }
      
      self.percentageLabel.text = "\(Int(self.percent) - element)%"
    }.store(in: &subscriptions)
      
    //    timer.sink(receiveCompletion: { _ in print("completed", to: &logger)} , receiveValue: { _ in print("started", to: &logger)} )//
    
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
    foregroundCircle.strokeColor = color.cgColor
  }
  
  func getProgressPath(in rect: CGRect, progress: Double, lineWidth: CGFloat) -> CGPath {
    let startAngle = -CGFloat.pi / 2
    foregroundCircle.lineWidth = lineWidth
    return UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY),
                        radius: rect.width/2 - lineWidth/2,
                        startAngle: startAngle,
                        endAngle: CGFloat.pi * 2 * progress / 100 + startAngle,
                        clockwise: true).cgPath
  }
  
  @objc
  func handleTap() {
    showDetails = !showDetails
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

