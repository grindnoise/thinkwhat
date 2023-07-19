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
      if let opaque = stack.arrangedSubviews.filter({ $0.accessibilityIdentifier == "opaque"}).first {
        stack.removeArrangedSubview(opaque)
      }
      stack.addArrangedSubview(descriptionView)
//      setupUI()
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
  @Published var showDetails = false
  //UI
  public var color: UIColor = .clear
  
  
  
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
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Bold, forTextStyle: .headline)
    
    return instance
  }()
  private lazy var percentageLabel: UILabel = {
    let instance = UILabel()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.font = UIFont(name: Fonts.Rubik.SemiBold, size: $0.height * 0.3) }
      .store(in: &subscriptions)
    instance.textColor = .systemGray
    instance.textAlignment = .center
    instance.numberOfLines = 1
    instance.text = "0%"
    
    return instance
  }()
//  private lazy var disclosureView: UIStackView = {
//    let label = UILabel()
//    label.isUserInteractionEnabled = true
//    label.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .footnote)
//    label.textColor = color
//    label.textAlignment = .center
//    label.text = "more_info".localized.uppercased()
//    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
//
//
//    let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
//    disclosureIndicator.accessibilityIdentifier = "chevron"
//    disclosureIndicator.clipsToBounds = true
//    disclosureIndicator.tintColor = .label
//    disclosureIndicator.contentMode = .center
//    disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
//    disclosureIndicator.isUserInteractionEnabled = true
//    disclosureIndicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
//    disclosureIndicator.heightAnchor.constraint(equalTo: disclosureIndicator.widthAnchor, multiplier: 1/1).isActive = true
//    disclosureIndicator.widthAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 1000, font: label.font!)).isActive = true///3)
//
//    let instance = UIStackView(arrangedSubviews: [
//      label,
//      disclosureIndicator
//    ])
//    instance.axis = .horizontal
//
//    return instance
//  }()
//  private lazy var disclosureButton: UIButton = {
//    let instance = UIButton()
//    instance.tintColor = color
//    instance.contentVerticalAlignment = .bottom
//    instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
////    instance.heightAnchor.constraint(equalToConstant: "more_info".localized.uppercased().height(withConstrainedWidth: 1000,
////                                                                                                font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .footnote)!)).isActive = true
//    return instance
//  }()
  private lazy var button: UIView = {
    let shadowView = UIView.opaque()
    shadowView.layer.masksToBounds = false
    shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    shadowView.layer.shadowOffset = .zero
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    shadowView.publisher(for: \.bounds)
      .sink {
        shadowView.layer.shadowRadius = $0.height/8
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2.25).cgPath
      }
      .store(in: &subscriptions)
    let button = UIButton()
    button.setAttributedTitle(NSAttributedString(string: "show_details".localized.uppercased(),
                                                 attributes: [
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                  .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.white : Colors.main as Any
                                                 ]),
                              for: .normal)
    button.contentEdgeInsets = UIEdgeInsets(top: padding/1.5, left: padding, bottom: padding/1.5, right: padding)
    button.accessibilityIdentifier = "profileButton"
    button.imageEdgeInsets.left = padding/2
    button.semanticContentAttribute = .forceRightToLeft
    button.adjustsImageWhenHighlighted = false
    button.setImage(UIImage(systemName: ("magnifyingglass"), withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
    button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemFill : .systemBackground
    button.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : Colors.main
    button.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    button.publisher(for: \.bounds)
      .sink { button.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    button.place(inside: shadowView)
    
    return shadowView
  }()
  private lazy var percentageView: UIView = {
    let instance = UIView()
//    instance.alpha = 0
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
    let opaque = UIView.opaque()
    button.placeInCenter(of: opaque)
    let instance = UIStackView()
    if !percent.isZero {
      instance.addArrangedSubview(UIView.opaque())
      instance.addArrangedSubview(descriptionLabel)
      instance.addArrangedSubview(button)
      instance.addArrangedSubview(UIView.opaque())
    } else {
      instance.addArrangedSubview(descriptionLabel)
      descriptionLabel.widthAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    }
    instance.alpha = 0
    instance.axis = .vertical
    instance.spacing = padding * 2
    instance.alignment = .center
//    descriptionLabel.place(inside: instance)
//    instance.addSubview(button)
//    button.translatesAutoresizingMaskIntoConstraints = false
//    button.bottomAnchor.constraint(equalTo: instance.bottomAnchor).isActive = true
//    button.centerXAnchor.constraint(equalTo: instance.centerXAnchor).isActive = true
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      percentageView,
      //descriptionView
      UIView.opaque()
    ])
    instance.spacing = padding*2
    instance.axis = .horizontal
//    instance.alignment = .center
    
    return instance
  }()
  private lazy var backgroundCircle: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(ovalIn: .zero).cgPath
    instance.fillColor = UIColor.clear.cgColor
    instance.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1).cgColor : UIColor.white.blended(withFraction: 0.1, of: UIColor.lightGray).cgColor
//    instance.lineWidth = 10
    instance.lineCap = .round
    instance.shadowColor = UIColor.lightGray.withAlphaComponent(0.25).cgColor
    instance.shadowRadius = padding/2
    instance.shadowOffset = .zero
    instance.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.masksToBounds = false
//    instance.publisher(for: \.bounds)
//      .sink { instance.shadowPath = UIBezierPath(ovalIn: $0).cgPath }
//      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var foregroundCircle: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(ovalIn: .zero).cgPath
    instance.fillColor = UIColor.clear.cgColor
    instance.strokeColor = color.cgColor
//    instance.lineWidth = 10
    instance.lineCap = .round
    instance.shadowColor = color.withAlphaComponent(0.35).cgColor
    instance.shadowRadius = padding/2
    instance.shadowOffset = .zero
    instance.masksToBounds = false
    instance.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
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
  
//  init(color: UIColor) {
//    self.color = color
//
//    super.init(frame: .zero)
//
//    accessibilityIdentifier = "CompatibilityView"
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  public func animate(duration: TimeInterval, delay: TimeInterval) {
    func setDescriptionLabel() {
      var attributedString: NSMutableAttributedString!
//      let paragraph = NSMutableParagraphStyle()
//      paragraph.alignment = .center
      var text = ""
//
//      if #available(iOS 15.0, *) {
//          paragraph.usesDefaultHyphenation = true
//      } else {
//          paragraph.hyphenationFactor = 1
//      }
      
      if percent.isZero {
        text = "userprofile_compatibility_level_zero".localized
        color = .systemGray
      } else if  1..<15 ~= Int(percent) {
        text = "userprofile_compatibility_level_ultra_low".localized
        color = .systemGreen
      } else if  15..<40 ~= Int(percent) {
        text = "userprofile_compatibility_level_low".localized
        color = .systemYellow
      } else if  40..<60 ~= Int(percent) {
        text = "userprofile_compatibility_level_middle".localized
        color = .systemOrange
      } else if  60..<75 ~= Int(percent) {
        text = "userprofile_compatibility_level_high".localized
        color = .systemPink
      } else if  75..<90 ~= Int(percent) {
        text = "userprofile_compatibility_level_ultra_high".localized
        color = .systemRed
      } else {
        text = "userprofile_compatibility_level_max".localized
        color = .systemPurple
      }
      
      foregroundCircle.shadowColor = color.withAlphaComponent(0.25).cgColor
      descriptionLabel.text = text.uppercased()
      descriptionLabel.textColor = color
    }
    
    let maxDuration: Double = 2
    let animDuration = maxDuration * Double(percent) / Double(100)
    setDescriptionLabel()
//    descriptionView.transform = .init(scaleX: 0.75, y: 0.75)
//    percentageView.transform = .init(scaleX: 0.75, y: 0.75)
    UIView.animate(withDuration: 0.35, delay: 0.1) { [weak self] in
      guard let self = self else { return }

      self.descriptionView.alpha = 1
//      self.descriptionView.transform = .identity
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
    
    UIView.transition(with: percentageLabel, duration: animDuration) { [weak self] in
      guard let self = self else { return }
      
      self.percentageLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .white : color.darker(0.5)
      if let button = self.button.getSubview(type: UIButton.self) {
        button.tintColor = self.traitCollection.userInterfaceStyle == .dark ? UIColor.white : color
        button.setAttributedTitle(NSAttributedString(string: "show_details".localized.uppercased(),
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                      .foregroundColor: self.traitCollection.userInterfaceStyle == .dark ? UIColor.white : color as Any
                                                     ]),
                                  for: .normal)
      }
    }
    
    let colorAnim = Animations.get(property: .StrokeColor,
                                   fromValue: foregroundCircle.strokeColor as Any,
                                   toValue: color.cgColor,
                                   duration: animDuration,
                                   delay: delay,
                                   timingFunction: .easeInEaseOut,
                                   delegate: self,
                                   isRemovedOnCompletion: false,
                                   completionBlocks: [{ [weak self] in
           guard let self = self else { return }

      self.foregroundCircle.strokeColor = color.cgColor
         }])
    foregroundCircle.add(colorAnim, forKey: nil)
    
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
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    backgroundCircle.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1).cgColor : UIColor.white.blended(withFraction: 0.1, of: UIColor.lightGray).cgColor
    backgroundCircle.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    foregroundCircle.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    button.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    if let btn = button.getSubview(type: UIButton.self) {
      btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemFill : .white
      btn.tintColor = self.traitCollection.userInterfaceStyle == .dark ? UIColor.white : color
      btn.setAttributedTitle(NSAttributedString(string: "show_details".localized.uppercased(),
                                                                                    attributes: [
                                                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                                                      .foregroundColor: self.traitCollection.userInterfaceStyle == .dark ? UIColor.white : color as Any
                                                                                    ]),
                                                                 for: .normal)
    }
    percentageLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : color.darker(0.5)
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
    let temp = {
      let instance = UILabel()
      instance.textAlignment = .center
      instance.numberOfLines = 0
      instance.attributedText = descriptionLabel.attributedText
      
      return instance
    }() // try! descriptionLabel.copyObject() as! UIView
    temp.frame = CGRect(origin: descriptionLabel.superview!.convert(descriptionLabel.frame.origin, to: descriptionView), size: descriptionLabel.bounds.size)
    descriptionLabel.alpha = 0
    descriptionView.addSubview(temp)
    
    UIView.animate(withDuration: 0.15,
                   delay: 0,
                   options: .curveEaseInOut) { [weak self] in
      guard let self = self else { return }
      
      temp.center = .init(x: self.descriptionView.bounds.midX, y: self.descriptionView.bounds.midY)
      self.button.alpha = 0
      self.button.transform = .init(scaleX: 0.35, y: 0.35)
    } completion: { [weak self] _ in
      guard let self = self else { return }
      
      self.descriptionLabel.alpha = 1
      temp.removeFromSuperview()
      descriptionView.arrangedSubviews.forEach { [weak self] in
        guard let self = self else { return }
        if $0 !== self.descriptionLabel {
          self.descriptionView.removeArrangedSubview($0)
          $0.removeFromSuperview()
        }
      }
    }
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

