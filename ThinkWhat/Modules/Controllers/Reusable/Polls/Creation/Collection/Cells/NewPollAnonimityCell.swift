//
//  NewPollAnonimityCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollAnonimityCell: UICollectionViewCell {
  
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
      
      fgLayer.backgroundColor = color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
      nextButton.tintColor = color
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
  public private(set) var animationCompletePublisher = PassthroughSubject<Void, Never>()
  @Published public var anonymityEnabled: Bool! {
    didSet {
      guard stage == stageGlobal, !anonymityEnabled.isNil else { return }//, !openedConstraint.isActive else { return }
      
      if let constraint = buttonsStack.getConstraint(identifier: "heightAnchor") {
        setNeedsLayout()
        UIView.animate(withDuration: 0.3) { [weak self] in
          guard let self = self else { return }
          
          constraint.constant = "T".height(withConstrainedWidth: 100,
                                           font: UIFont.scaledFont(fontName: Fonts.Regular,
                                                                   forTextStyle: .headline)!) + self.padding*2
          self.layoutIfNeeded()
        }
      }
      boundsPublisher.send()
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
  private let stackHeight: CGFloat = 100
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
//    instance.alpha = 1
    instance.numberOfLines = 0
    instance.textAlignment = .center
    instance.textColor = anonymityEnabled.isNil ? color : .label
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
    instance.text = anonymityEnabled.isNil ? stage.placeholder : anonymityEnabled ? "new_poll_anonymity_on".localized : "new_poll_anonymity_off".localized
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
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      user,
      anon
    ])
    instance.axis = .horizontal
    instance.distribution = .fillEqually
    instance.spacing = stackHeight/2
    
    return instance
  }()
  private lazy var nextButton: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "arrow.down.circle.fill"))
    instance.isUserInteractionEnabled = true
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.contentMode = .scaleAspectFill
    instance.tintColor = color
//    instance.alpha = 0
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStage)))
    
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [nextButton])
    instance.spacing = padding
    instance.axis = .vertical
    instance.alignment = .center
    instance.distribution = .fillEqually
    let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
    constraint.isActive = true
    constraint.identifier = "heightAnchor"
    
    return instance
  }()
  private lazy var anon: Avatar = {
    let instance = Avatar(userprofile: Userprofile.anonymous, isShadowed: true, filter: "CIPhotoEffectNoir")
    instance.alpha = anonymityEnabled.isNil ? 0.75 : anonymityEnabled == true ? 1 : 0.75
    instance.transform = anonymityEnabled.isNil ? .identity : anonymityEnabled == true ? CGAffineTransform(scaleX: 1.1, y: 1.1) : CGAffineTransform(scaleX: 0.75, y: 0.75)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.isUserInteractionEnabled = true
    instance.tapPublisher
      .filter { [unowned self] _ in self.stageGlobal == .Ready || self.stage == self.stageGlobal }
      .filter { [unowned self] _ in self.anonymityEnabled.isNil || !self.anonymityEnabled}
      .sink { [unowned self] _ in
        
        self.anonymityEnabled = true
        UIView.transition(with: descriptionLabel, duration: 0.1, options: .transitionCrossDissolve) { [weak self] in
          guard let self = self else { return }
          
          self.descriptionLabel.textColor = .label
          self.descriptionLabel.text = self.anonymityEnabled ? "new_poll_anonymity_on".localized : "new_poll_anonymity_off".localized
          
          let height = self.descriptionLabel.text!.height(withConstrainedWidth: self.descriptionLabel.bounds.width,
                                                          font: self.descriptionLabel.font)
          
          guard let constraint = self.descriptionLabel.getConstraint(identifier: "heightAnchor"),
                constraint.constant != height
          else { return }
          
          self.setNeedsLayout()
          constraint.constant = height
          self.layoutIfNeeded()
          self.boundsPublisher.send()
        } completion: { _ in }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 2.5,
            options: [.curveEaseInOut],
            animations: { [unowned self] in
              instance.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
              instance.alpha = 1
              self.user.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
              self.user.alpha = 0.75
            })
        self.user.toggleFilter(on: true, duration: 0.15)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var user: Avatar = {
    let instance = Avatar(userprofile: Userprofiles.shared.current!, isShadowed: true, filter: "CIPhotoEffectNoir")
    if anonymityEnabled.isNil || anonymityEnabled == false {
      instance.toggleFilter(on: false)
    }
    instance.alpha = anonymityEnabled.isNil ? 0.75 : anonymityEnabled == false ? 1 : 0.75
    instance.transform = anonymityEnabled.isNil ? .identity : anonymityEnabled == false ? CGAffineTransform(scaleX: 1.1, y: 1.1) : CGAffineTransform(scaleX: 0.75, y: 0.75)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.isUserInteractionEnabled = true
    instance.heightAnchor.constraint(equalToConstant: stackHeight).isActive = true
    instance.tapPublisher
      .filter { [unowned self] _ in self.stageGlobal == .Ready || self.stage == self.stageGlobal }
      .filter { [unowned self] _ in self.anonymityEnabled.isNil || self.anonymityEnabled}
      .sink { [unowned self] _ in
        self.anonymityEnabled = false
        UIView.transition(with: descriptionLabel, duration: 0.1, options: .transitionCrossDissolve) { [weak self] in
          guard let self = self else { return }
          
          self.descriptionLabel.textColor = .label
          self.descriptionLabel.text = self.anonymityEnabled ? "new_poll_anonymity_on".localized : "new_poll_anonymity_off".localized
          
          let height = self.descriptionLabel.text!.height(withConstrainedWidth: self.descriptionLabel.bounds.width, font: self.descriptionLabel.font)
          
          guard let constraint = self.descriptionLabel.getConstraint(identifier: "heightAnchor"),
                constraint.constant != height
          else { return }
          
          self.setNeedsLayout()
          constraint.constant = height
          self.layoutIfNeeded()
          self.boundsPublisher.send()
        } completion: { _ in }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 2.5,
            options: [.curveEaseInOut],
            animations: { [unowned self] in
              instance.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
              instance.alpha = 1
              self.anon.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
              self.anon.alpha = 0.75
            })
        self.user.toggleFilter(on: false, duration: 0.15)
      }
      .store(in: &subscriptions)
    
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
      self.descriptionLabel.textColor = .label
    } completion: { _ in }
    
    Animations.unmaskLayerCircled(layer: fgLayer,
                                  location: CGPoint(x: descriptionLabel.bounds.midX, y: descriptionLabel.bounds.midY),
                                  duration: 0.5,
                                  opacityDurationMultiplier: 0.6,
                                  delegate: self)
    
    bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
    
    delay(seconds: 1) {
      Animations.unmaskLayerCircled(unmask: false,
                                    layer: self.fgLayer,
                                    location: CGPoint(x: self.descriptionLabel.bounds.midX, y: self.descriptionLabel.bounds.midY),
                                    duration: 0.5,
                                    opacityDurationMultiplier: 0.6,
                                    delegate: self)
      
      self.bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
    }
  }
}

// MARK: - Private
private extension NewPollAnonimityCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stageStack.placeTopLeading(inside: self,
                               leadingInset: 8,
                               topInset: -2)

    addSubview(stack)
    addSubview(buttonsStack)
    addSubview(descriptionLabel)
    stack.translatesAutoresizingMaskIntoConstraints = false
    buttonsStack.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*4),
      stack.centerXAnchor.constraint(equalTo: centerXAnchor, constant: padding*1),
      descriptionLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: padding*3),
      descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
      buttonsStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: padding*3),
      buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    let constraint = buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*4)
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
  func nextStage() {
    UIView.transition(with: self.label, duration: 0.3, options: .transitionCrossDissolve) { [weak self] in
      guard let self = self else { return }
      
      self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    } completion: { _ in }
    
    if let heightAnchor = buttonsStack.getConstraint(identifier: "heightAnchor"),
       let bottomAnchor = buttonsStack.getConstraint(identifier: "bottomAnchor"){
      setNeedsLayout()
      UIView.animate(withDuration: 0.3) { [weak self] in
        guard let self = self else { return }
        
        heightAnchor.constant = 0
        bottomAnchor.constant = 0
        self.layoutIfNeeded()
      }
    }
    
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

extension NewPollAnonimityCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}

