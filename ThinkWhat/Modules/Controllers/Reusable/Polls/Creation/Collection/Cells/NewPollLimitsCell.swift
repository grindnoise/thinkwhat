//
//  NewPollLimitsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollLimitsCell: UICollectionViewCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var stage: NewPollController.Stage! {
    didSet {
      guard !stage.isNil, stage != oldValue else { return }
      
      setupUI()
    }
  }
  public var stageGlobal: NewPollController.Stage!
  public var externalSubscriptions = Set<AnyCancellable>()
  
  ///**UI**
  public var color = UIColor.systemGray4 {
    didSet {
      guard oldValue != color else { return }
      
//      nextButton.tintColor = color
      fgLayer.backgroundColor = color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
      icon.setIconColor(color)
      UIView.animate(withDuration: 0.2) { [weak self] in
        guard let self = self else { return }
        
        self.imageView.tintColor = self.color
        
        guard let imageView = self.contentView.getSubview(type: UIImageView.self, identifier: "imageView") else { return }
        
        imageView.tintColor = self.color
      }
      
      let colorAnim = CABasicAnimation(path: "strokeColor", fromValue: fgLine.layer.strokeColor, toValue: color.cgColor, duration: 0.4)
      colorAnim.delegate = self
      colorAnim.setValue({ [weak self] in
        guard let self = self else { return }
        
        self.fgLine.layer.removeAnimation(forKey: "color")
      }, forKey: "completion")
      
      fgLine.layer.strokeColor = color.cgColor
    }
  }
  ///**Publishers**
  @Published public private(set) var animationCompletePublisher = PassthroughSubject<Void, Never>()
  @Published public var limit: Int! {
    didSet {
      guard (stage == stageGlobal || stageGlobal == .Ready), !limit.isNil else { return }//, !openedConstraint.isActive else { return }
      
      limitLabel.text = limit.isNil ? "" : limit.formattedWithSeparator
      
      guard oldValue.isNil else { return }
      
      nextStage()
    }
  }
  public private(set) var stageCompletePublisher = PassthroughSubject<Void, Never>()
  public private(set) var boundsPublisher = PassthroughSubject<Void, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private var isBannerOnScreen = false
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: stage.numImage)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
    instance.tintColor = .systemGray4
    instance.contentMode = .scaleAspectFit
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    instance.text = stage.title.uppercased()
    
    return instance
  }()
  private lazy var descriptionLabel: InsetLabel = {
    let instance = InsetLabel()
    instance.insets = .uniform(size: padding)
    instance.numberOfLines = 0
    instance.textAlignment = .center
    instance.textColor = limit.isNil ? color : .label
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
    instance.text = stage.placeholder
    instance.layer.insertSublayer(bgLayer, at: 0)
    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.publisher(for: \.bounds)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.bgLayer.frame = $0
        self.bgLayer.cornerRadius = $0.width*0.025
        self.fgLayer.frame = $0
        self.fgLayer.cornerRadius = $0.width*0.025
      }
      .store(in: &subscriptions)
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: instance.font))
    constraint.identifier = "heightAnchor"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var limitLabel: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 1
    instance.isUserInteractionEnabled = true
    instance.textColor = .secondaryLabel
    instance.textAlignment = .center
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title1)
    instance.text = limit.isNil ? 100.formattedWithSeparator : limit.formattedWithSeparator
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
    
    return instance
  }()
  private lazy var stageStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [imageView, label])
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true

    return instance
  }()
  private lazy var fgLine: Line = {
    let instance = Line()
    instance.layer.strokeColor = Colors.Logo.Flame.rawValue.cgColor
    
    return instance
  }()
  private lazy var bgLine: Line = {
    let instance = Line()
    instance.layer.strokeColor = UIColor.systemGray4.cgColor
    
    return instance
  }()
  private lazy var icon: Icon = {
    let instance = Icon(category: .Speedometer)
    instance.iconColor = UIColor.systemGray4
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.translatesAutoresizingMaskIntoConstraints = false
    instance.heightAnchor.constraint(equalToConstant: 70).isActive = true
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    return instance
  }()
  private lazy var bgLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.backgroundColor = UIColor.clear.cgColor//(traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor

    return instance
  }()
  private lazy var fgLayer: CALayer = {
    let instance = CAShapeLayer()
    instance.opacity = 0
    instance.backgroundColor = color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
    
    return instance
  }()
  
  
  
  // MARK: - Destructor
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
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    externalSubscriptions.forEach { $0.cancel() }
    animationCompletePublisher = PassthroughSubject<Void, Never>()
    stageCompletePublisher = PassthroughSubject<Void, Never>()
    boundsPublisher = PassthroughSubject<Void, Never>()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1, xPoint: 500)
    self.drawLine(line: self.fgLine)
    
    let height = self.descriptionLabel.text!.height(withConstrainedWidth: self.descriptionLabel.bounds.width - padding*2, font: self.descriptionLabel.font) + padding*2
    
    guard let constraint = self.descriptionLabel.getConstraint(identifier: "heightAnchor"),
          constraint.constant != height
    else { return }
    
    UIView.animate(withDuration: 0.3) { [weak self] in
      guard let self = self else { return }
      
      self.setNeedsLayout()
      constraint.constant = height
      self.layoutIfNeeded()
    }
    self.boundsPublisher.send()
  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
    UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
      guard let self = self else { return }
      
      self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .caption2)
      self.limitLabel.textColor = .label
      self.descriptionLabel.textColor = .label
    } completion: { _ in }
    
    Animations.unmaskLayerCircled(layer: fgLayer,
                                  location: CGPoint(x: descriptionLabel.bounds.midX, y: descriptionLabel.bounds.midY),
                                  duration: 0.5,
                                  opacityDurationMultiplier: 0.6,
                                  delegate: self)
    
    bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
    
    delay(seconds: seconds) {
      Animations.unmaskLayerCircled(unmask: false,
                                    layer: self.fgLayer,
                                    location: CGPoint(x: self.descriptionLabel.bounds.midX, y: self.descriptionLabel.bounds.midY),
                                    duration: 0.5,
                                    opacityDurationMultiplier: 0.6,
                                    delegate: self)
      
      self.bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
    }
    delay(seconds: seconds+0.6) { [weak self] in
      guard let self = self else { return }
      
      self.edit()
      self.externalSubscriptions.forEach { $0.cancel() }
    }
  }
}

// MARK: - Private
private extension NewPollLimitsCell {
  @MainActor
  func setupUI() {
//    contentView.translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .clear
    stageStack.placeTopLeading(inside: self,
                               leadingInset: 8,
                               topInset: -2)
    
    let views = [descriptionLabel,
                 icon,
//                 buttonsStack,
                 limitLabel]
    addSubviews(views)
    views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    NSLayoutConstraint.activate([
      icon.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*4),
      icon.centerXAnchor.constraint(equalTo: centerXAnchor, constant: padding*1),
      limitLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: padding*3),
      limitLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      limitLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
      descriptionLabel.topAnchor.constraint(equalTo: limitLabel.bottomAnchor, constant: padding*3),
      descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
//      buttonsStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: padding*4),
//      buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
//      buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    let constraint = descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*4)//buttonsStack
    constraint.isActive = true
    constraint.identifier = "bottomAnchor"
    constraint.priority = .defaultLow
    
    layer.insertSublayer(bgLine.layer, at: 0)
    layer.insertSublayer(fgLine.layer, at: 1)
  }
  
  func drawLine(line: Line,
                strokeEnd: CGFloat = 0,
                lineCap: CAShapeLayerLineCap = .round,
                xPoint: CGFloat? = nil) {
    let lineWidth = imageView.bounds.width*0.1
    let imageCenter = imageView.convert(imageView.center, to: contentView)
    let xPos = imageCenter.x
    let yPos = imageCenter.y + imageView.bounds.height/2 - lineWidth
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: xPos, y: yPos))
    path.addLine(to: CGPoint(x: xPos, y: xPoint ?? bounds.maxY + lineWidth))
    
    line.path = path
    line.layer.strokeStart = 0
    line.layer.strokeEnd = strokeEnd
    line.layer.lineCap = lineCap
    line.layer.lineWidth = lineWidth
    line.layer.path = line.path.cgPath
  }
  
  @objc
  func handleTap(recognizer: UITapGestureRecognizer) {
    guard stageGlobal == .Ready || stage == stageGlobal else { return }
    
    edit()
  }
  
  func edit() {
    guard !isBannerOnScreen else { return }
    
    isBannerOnScreen = true
    let banner = NewPopup(padding: self.padding*2,
                          contentPadding: .uniform(size: self.padding))
    let content = SurveyLimitPopupContent(limit: limit.isNil ? 100 : limit,
                                          mode: limit.isNil ? .ForceSelect : .Default,
                                          color: color)
    content.limitPublisher
      .sink { [unowned self] limit in
        banner.dismiss()
        self.limit = limit
      }
      .store(in: &banner.subscriptions)

    banner.setContent(content)
    banner.didDisappearPublisher
      .sink { [unowned self] _ in
        banner.removeFromSuperview();
        self.isBannerOnScreen = false
        self.descriptionLabel.text = "new_poll_limit_hint".localized
      }
      .store(in: &self.subscriptions)
  }
  
  @objc
  func nextStage() {
    UIView.transition(with: self.label, duration: 0.1, options: .transitionCrossDissolve) { [weak self] in
      guard let self = self else { return }
      
      self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    } completion: { _ in }
    
    boundsPublisher.send()
    delay(seconds: 0.4) {[weak self] in
      guard let self = self else { return }
      
      self.stageCompletePublisher.send()
      self.stageCompletePublisher.send(completion: .finished)
    }

    CATransaction.begin()
    CATransaction.setCompletionBlock() { [unowned self] in
      self.animationCompletePublisher.send()
      self.animationCompletePublisher.send(completion: .finished)
    }
    fgLine.layer.strokeColor = color.cgColor
    fgLine.layer.add(CABasicAnimation(path: "strokeEnd", fromValue: 0, toValue: 1, duration: 0.4), forKey: "strokeEnd")
    CATransaction.commit()
  }
}

extension NewPollLimitsCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}
