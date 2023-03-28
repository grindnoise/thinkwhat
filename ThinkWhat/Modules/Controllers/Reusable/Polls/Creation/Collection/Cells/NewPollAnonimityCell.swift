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
      guard !stage.isNil else { return }
      
      setupUI()
    }
  }
  public var stageGlobal: NewPollController.Stage!
  ///**UI**
  public var color = UIColor.systemGray4 {
    didSet {
      guard oldValue != color else { return }
      
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
  @Published public private(set) var isAnimationComplete: Bool?
  @Published public var anonimityEnabled: Bool! {
    didSet {
      guard stage == stageGlobal, !anonimityEnabled.isNil, !openedConstraint.isActive else { return }
      
      closedConstraint.isActive = false
      openedConstraint.isActive = true
      boundsPublisher.send()
      nextButton.tintColor = color
      delay(seconds: 0.3) { [weak self] in
        guard let self = self else { return }
        
        self.nextButton.transform = .init(scaleX: 0.75, y: 0.75)
        UIView.animate(withDuration: 0.2) {
          self.nextButton.transform = .identity
          self.nextButton.alpha = 1
        }
      }
    }
  }
  @Published public private(set) var isStageComplete: Bool!
  public private(set) var boundsPublisher = PassthroughSubject<Void, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
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
  private lazy var descriptionLabel: UILabel = {
    let instance = UILabel()
//    instance.alpha = 1
    instance.numberOfLines = 0
    instance.textAlignment = .center
    instance.textColor = anonimityEnabled.isNil ? color : .label
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .body)
    instance.text = anonimityEnabled.isNil ? "new_poll_comments_placeholder".localized : anonimityEnabled ? "new_poll_comments_on".localized : "new_poll_comments_off".localized
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
    instance.spacing = 35
    
    return instance
  }()
  private lazy var nextButton: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "arrow.down.circle.fill"))
    instance.isUserInteractionEnabled = true
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.contentMode = .scaleAspectFill
    instance.tintColor = color
    instance.alpha = 0
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStage)))
    
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [nextButton])
    instance.spacing = padding
    instance.axis = .vertical
    instance.alignment = .center
    instance.distribution = .fillEqually
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)!) + padding*2).isActive = true
    
    return instance
  }()
  private lazy var anon: Avatar = {
    let instance = Avatar(userprofile: Userprofile.anonymous, isShadowed: true)
//    instance.setFilter(name: "CIPhotoEffectTonal", animated: false)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.isUserInteractionEnabled = true
    instance.tapPublisher
      .filter { [unowned self] _ in self.anonimityEnabled.isNil || !self.anonimityEnabled}
      .sink { [unowned self] _ in
        self.anonimityEnabled = true
        UIView.transition(with: descriptionLabel, duration: 0.3, options: .transitionCrossDissolve) { [weak self] in
          guard let self = self else { return }
          
          self.descriptionLabel.textColor = .secondaryLabel
          self.descriptionLabel.text = self.anonimityEnabled ? "new_poll_anonymity_on".localized : "new_poll_anonymity_off".localized
          
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
              self.user.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
              self.user.alpha = 0.75
            })
        self.user.toggleFilter(name: "CIPhotoEffectNoir", duration: 0.15)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var user: Avatar = {
    let instance = Avatar(userprofile: Userprofiles.shared.current!, isShadowed: true)
    instance.toggleFilter(name: "CIPhotoEffectNoir", duration: 0.3)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.isUserInteractionEnabled = true
    instance.heightAnchor.constraint(equalToConstant: 100).isActive = true
    instance.tapPublisher
      .filter { [unowned self] _ in self.anonimityEnabled.isNil || self.anonimityEnabled}
      .sink { [unowned self] _ in
        self.anonimityEnabled = false
        UIView.transition(with: descriptionLabel, duration: 0.3, options: .transitionCrossDissolve) { [weak self] in
          guard let self = self else { return }
          
          self.descriptionLabel.textColor = .secondaryLabel
          self.descriptionLabel.text = self.anonimityEnabled ? "new_poll_anonymity_on".localized : "new_poll_anonymity_off".localized
          
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
        self.user.toggleFilter(duration: 0.15)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private var openedConstraint: NSLayoutConstraint!
  private var closedConstraint: NSLayoutConstraint!
  
  
  
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
    
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1, xPoint: 500)
    self.drawLine(line: self.fgLine)
  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
    
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
      stack.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*3),
      stack.centerXAnchor.constraint(equalTo: centerXAnchor),
      descriptionLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: padding*2),
      descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
      buttonsStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: padding*2),
      buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    openedConstraint = buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*3)
    openedConstraint.isActive = false
    openedConstraint.priority = .defaultLow
    
    closedConstraint = descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*3)
    closedConstraint.isActive = true
    closedConstraint.priority = .defaultLow
    
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
    closedConstraint.isActive = true
    openedConstraint.isActive = false
    boundsPublisher.send()
    nextButton.removeFromSuperview()
    
    isStageComplete = true
    CATransaction.begin()
    CATransaction.setCompletionBlock() { [unowned self] in self.isAnimationComplete = true }
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

