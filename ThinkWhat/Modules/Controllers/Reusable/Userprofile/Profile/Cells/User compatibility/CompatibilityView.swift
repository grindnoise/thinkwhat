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
//      guard percent != oldValue else {
//        setZeroCompatibility()
//
//        return
//      }
      
      foregroundCircle.path = getProgressPath(in: percentageView.bounds,
                                              progress: percent,
                                              lineWidth: percentageView.bounds.width * lineWidthMultiplier)
      animate(duration: 1, delay: 0)
    }
  }
  //Publishers
  @Published var showDetails = false {
    didSet {
      guard oldValue != showDetails else { return }
      
      setButtonTitle()
    }
  }
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
  ///**UI**
  private let lineWidthMultiplier: CGFloat = 0.125
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
  private lazy var disclosureView: UIStackView = {
    let label = UILabel()
    label.isUserInteractionEnabled = true
    label.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .footnote)
    label.textColor = color
    label.textAlignment = .center
    label.text = "more_info".localized.uppercased()
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    
    let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
    disclosureIndicator.accessibilityIdentifier = "chevron"
    disclosureIndicator.clipsToBounds = true
    disclosureIndicator.tintColor = .label
    disclosureIndicator.contentMode = .center
    disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
    disclosureIndicator.isUserInteractionEnabled = true
    disclosureIndicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    disclosureIndicator.heightAnchor.constraint(equalTo: disclosureIndicator.widthAnchor, multiplier: 1/1).isActive = true
    disclosureIndicator.widthAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 1000, font: label.font!)).isActive = true///3)
    
    let instance = UIStackView(arrangedSubviews: [
      label,
      disclosureIndicator
    ])
    instance.axis = .horizontal
    
    return instance
  }()
//  private lazy var disclosureButton: UIButton = {
//    let instance = UIButton()
//    instance.tintColor = color
//    instance.contentVerticalAlignment = .bottom
//    instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
////    instance.heightAnchor.constraint(equalToConstant: "more_info".localized.uppercased().height(withConstrainedWidth: 1000,
////                                                                                                font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .footnote)!)).isActive = true
//    return instance
//  }()
  private lazy var percentageView: UIView = {
    let instance = UIView()
    instance.alpha = 0
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
  private lazy var descriptionView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      descriptionLabel,
    ])
    instance.alpha = 0
    instance.axis = .vertical
//    descriptionLabel.place(inside: instance)
    instance.addSubview(disclosureView)
    disclosureView.translatesAutoresizingMaskIntoConstraints = false
    disclosureView.bottomAnchor.constraint(equalTo: instance.bottomAnchor).isActive = true
    disclosureView.centerXAnchor.constraint(equalTo: instance.centerXAnchor).isActive = true
    
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
      var attributedString: NSMutableAttributedString!
      let paragraph = NSMutableParagraphStyle()
      paragraph.alignment = .center
      var text = ""
      
      if #available(iOS 15.0, *) {
          paragraph.usesDefaultHyphenation = true
      } else {
          paragraph.hyphenationFactor = 1
      }
      
      if percent.isZero {
        text = "userprofile_compatibility_level_zero".localized
      } else if  1..<20 ~= Int(percent) {
        text = "userprofile_compatibility_level_ultra_low".localized
      } else if  20..<40 ~= Int(percent) {
        text = "userprofile_compatibility_level_low".localized
      } else if  40..<60 ~= Int(percent) {
        text = "userprofile_compatibility_level_middle".localized
      } else if  60..<80 ~= Int(percent) {
        text = "userprofile_compatibility_level_high".localized
      } else if  80..<100 ~= Int(percent) {
        text = "userprofile_compatibility_level_ultra_high".localized
      } else {
        text = "userprofile_compatibility_level_max".localized
      }
      
      if percent.isZero {
        attributedString = NSMutableAttributedString(string: "userprofile_compatibility_level_zero".localized,
                                                   attributes: [
                                                    .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline) as Any,
//                                                    .paragraphStyle: paragraph,
                                                   ])
        disclosureView.alpha = 0
      } else {
        attributedString = NSMutableAttributedString(string: text.uppercased() + "\n", attributes: [
          .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
          .foregroundColor: color as Any,
          .paragraphStyle: paragraph,
        ])
        
        attributedString.append(NSAttributedString(string: "userprofile_compatibility_level".localized,
                                                   attributes: [
                                                    .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline) as Any,
                                                    .paragraphStyle: paragraph,
                                                   ]))
        //      let attributedString = NSMutableAttributedString(string: "userprofile_compatibility_level_with_user".localized,
        //                                                       attributes: [
        //                                                        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline) as Any,
        //                                                        .paragraphStyle: paragraph,
        //                                                       ])
        //      attributedString.append(NSAttributedString(string: username, attributes: [
        //        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline) as Any,
        //        .paragraphStyle: paragraph,
        //      ]))
        //      attributedString.append(NSAttributedString(string: "userprofile_compatibility_level_with_user_is".localized, attributes: [
        //        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline) as Any,
        //        .paragraphStyle: paragraph,
        //      ]))
        //      attributedString.append(NSAttributedString(string: text, attributes: [
        //        .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
        //        .foregroundColor: color as Any,
        //        .paragraphStyle: paragraph,
        //      ]))
      }
      descriptionLabel.attributedText = attributedString
    }
    
    let maxDuration: Double = 2
    let animDuration = maxDuration * Double(percent) / Double(100)
    setDescriptionLabel()
    descriptionView.transform = .init(scaleX: 0.75, y: 0.75)
    percentageView.transform = .init(scaleX: 0.75, y: 0.75)
    UIView.animate(withDuration: 0.35, delay: 0.1) { [weak self] in
      guard let self = self else { return }
      
      self.descriptionView.alpha = 1
      self.descriptionView.transform = .identity
    }
    UIView.animate(withDuration: 0.35) { [weak self] in
      guard let self = self else { return }
      
      self.percentageView.alpha = 1
      self.percentageView.transform = .identity
    }
    
    guard percent != .zero else {
      foregroundCircle.opacity = 0
      percentageLabel.text = "0%"
      return
    }
    
    Publishers.countdown(queue: .main,
                         interval: .milliseconds(Int((animDuration/percent)*1000)),
                         times: .max(Int(percent)))
    .sink { [weak self] element in
      guard let self = self else { return }
      
      self.percentageLabel.text = "\(Int(self.percent) - element)%"
    }
    .store(in: &subscriptions)
      
    //    timer.sink(receiveCompletion: { _ in print("completed", to: &logger)} , receiveValue: { _ in print("started", to: &logger)} )//
    
    isAnimating = true
    let anim = Animations.get(property: .StrokeEnd,
                              fromValue: 0,
                              toValue: 1,
                              duration: animDuration,
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
    
    guard let label = disclosureView.arrangedSubviews.filter({ $0 is UILabel }).first as? UILabel,
          let imageView = disclosureView.arrangedSubviews.filter({ $0 is UIImageView }).first as? UIImageView
    else { return }
    
    label.textColor = color
    imageView.tintColor = color
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
  
  func setButtonTitle() {
    guard let imageView = disclosureView.arrangedSubviews.filter({ $0 is UIImageView }).first as? UIImageView else { return }
    
//    label.text = showDetails ? "hide_details".localized.uppercased() : "show_details".localized.uppercased()
    UIView.animate(withDuration: 0.3) { [weak self] in
      guard let self = self else { return }
      
      imageView.transform = self.showDetails ? CGAffineTransform(rotationAngle: .pi/2) : .identity
    }
    
//    UIView.setAnimationsEnabled(false)
//    disclosureButton.setAttributedTitle(NSMutableAttributedString(string: showDetails ? "hide_details".localized.uppercased() : "show_details".localized.uppercased(),
//                                                     attributes: [
//                                                      .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .footnote) as Any,
//                                                      .foregroundColor: color as Any,
//                                                     ]),
//                                        for: .normal)
////    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//      UIView.setAnimationsEnabled(true)
////    }
  }
  
  func setZeroCompatibility() {
    
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

