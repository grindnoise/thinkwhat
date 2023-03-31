//
//  NewPollHotCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollHotCell: UICollectionViewCell {
  
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
  @Published public private(set) var animationCompletePublisher = PassthroughSubject<Void, Never>()
  @Published public var isHot: Bool! {
    didSet {
      guard stage == stageGlobal, !isHot.isNil else { return }//, !openedConstraint.isActive else { return }
      
      if let constraint = buttonsStack.getConstraint(identifier: "heightAnchor") {
        setNeedsLayout()
        UIView.animate(withDuration: 0.3) { [weak self] in
          guard let self = self else { return }
          
          constraint.constant = "T".height(withConstrainedWidth: 100,
                                           font: UIFont.scaledFont(fontName: Fonts.Regular,
                                                                   forTextStyle: .body)!) + self.padding*2
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
  private let stackHeight: CGFloat = 70
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
    instance.numberOfLines = 0
    instance.textAlignment = .center
    instance.textColor = isHot.isNil ? color : .label
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
    instance.text = isHot.isNil ? "new_poll_hot_placeholder".localized : isHot ? "new_poll_hot_on".localized : "new_poll_hot_off".localized
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
      hotOnIcon,
      hotOffIcon
    ])
    instance.axis = .horizontal
    instance.distribution = .fillEqually
    instance.spacing = stackHeight/1.5
    
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
  private lazy var hotOnIcon: Icon = {
    let instance = Icon(category: .Hot)
    instance.iconColor = !isHot.isNil ? Colors.Logo.Flame.rawValue : UIColor.systemGray4//traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .secondarySystemBackground
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.translatesAutoresizingMaskIntoConstraints = false
    instance.heightAnchor.constraint(equalToConstant: stackHeight).isActive = true
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    return instance
  }()
  private lazy var hotOffIcon: Icon = {
    let instance = Icon(category: .HotDisabled)
    instance.iconColor = !isHot.isNil ? Colors.Logo.Flame.rawValue : UIColor.systemGray4//traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .secondarySystemBackground
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    return instance
  }()
//  private var openedConstraint: NSLayoutConstraint!
//  private var closedConstraint: NSLayoutConstraint!
  
  
  
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
    
    guard isHot.isNil else { return }
    
    let height = self.descriptionLabel.text!.height(withConstrainedWidth: self.descriptionLabel.bounds.width, font: self.descriptionLabel.font)
    
    guard let constraint = self.descriptionLabel.getConstraint(identifier: "heightAnchor"),
          constraint.constant != height
    else { return }
    
    self.setNeedsLayout()
    constraint.constant = height
    self.layoutIfNeeded()
    self.boundsPublisher.send()
  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
    UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
      guard let self = self else { return }
      
      self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .caption2)
    } completion: { _ in }
    
    UIView.transition(with: descriptionLabel, duration: 0.1, options: .transitionCrossDissolve) { [weak self] in
      guard let self = self else { return }
      
      self.descriptionLabel.textColor = .label
    } completion: { _ in }
    
    hotOnIcon.setIconColor(UIColor.systemGray4)//traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .secondarySystemBackground)
    hotOffIcon.setIconColor(UIColor.systemGray4)//traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .secondarySystemBackground)
//    textView.becomeFirstResponder()
//
//    UIView.animate(withDuration: 0.2, animations: { [weak self] in
//      guard let self = self else { return }
//
//      print(self.placeholder.frame)
//      print(self.placeholder.alpha)
//      self.placeholder.alpha = 0
//      self.placeholder.transform = .init(scaleX: 0.75, y: 0.75)
//    }) { [weak self] _ in
//      guard let self = self else { return }
//
//      self.placeholder.removeFromSuperview()
//
//      guard !self.textView.isFirstResponder else { return }
//
//      self.textView.becomeFirstResponder()
//    }
  }
}

// MARK: - Private
private extension NewPollHotCell {
  @MainActor
  func setupUI() {
//    contentView.translatesAutoresizingMaskIntoConstraints = false
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
  func handleTap(recognizer: UITapGestureRecognizer) {
//    guard !isHot.isNil else { return }
//    guard stageGlobal == .Ready || stage == stageGlobal else { return }
    
    guard let v = recognizer.view else { return }
    if let icon = v as? Icon {
        let selectedIcon: Icon! = icon == hotOnIcon ? hotOnIcon : hotOffIcon
        let deselectedIcon: Icon! = icon != hotOnIcon ? hotOnIcon : hotOffIcon
        
      if !isHot.isNil {
        if isHot && icon == hotOnIcon || !isHot && icon == hotOffIcon {
          return
        }
      }
        
        let enableAnim  = Animations.get(property: .FillColor,
                                         fromValue: selectedIcon.iconColor.cgColor,
                                         toValue: Colors.Logo.Flame.rawValue.cgColor,
                                         duration: 0.3,
                                         timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                         delegate: nil,
                                         isRemovedOnCompletion: true)
        let disableAnim = Animations.get(property: .FillColor,
                                         fromValue: deselectedIcon.iconColor.cgColor,
                                         toValue: UIColor.systemGray4.cgColor,//traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : UIColor.secondarySystemBackground.cgColor,
                                         duration: 0.3,
                                         timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                         delegate: nil,
                                         isRemovedOnCompletion: true)
        
        selectedIcon.icon.add(enableAnim, forKey: nil)
        (selectedIcon.icon as! CAShapeLayer).fillColor = Colors.Logo.Flame.rawValue.cgColor//traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor
        deselectedIcon.icon.add(disableAnim, forKey: nil)
      (deselectedIcon.icon as! CAShapeLayer).fillColor = UIColor.systemGray4.cgColor// traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : UIColor.secondarySystemBackground.cgColor
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 2.5,
            options: [.curveEaseInOut],
            animations: {
              selectedIcon.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in }
      
      if isHot.isNil {
        isHot = selectedIcon == hotOnIcon
      } else {
        isHot = !isHot
      }
      
      UIView.transition(with: descriptionLabel, duration: 0.1, options: .transitionCrossDissolve) { [weak self] in
        guard let self = self else { return }
        
        self.descriptionLabel.textColor = .label
        self.descriptionLabel.text = self.isHot ? "new_poll_hot_on".localized : "new_poll_hot_off".localized
        
        let height = self.descriptionLabel.text!.height(withConstrainedWidth: self.descriptionLabel.bounds.width, font: self.descriptionLabel.font)
        
        guard let constraint = self.descriptionLabel.getConstraint(identifier: "heightAnchor"),
              constraint.constant != height
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = height
        self.layoutIfNeeded()
        self.boundsPublisher.send()
      } completion: { _ in }
        
        deselectedIcon.icon.add(disableAnim, forKey: nil)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
          deselectedIcon.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        })
    }
  }
  
  @objc
  func nextStage() {
    UIView.transition(with: self.label, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
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
    stageCompletePublisher.send()
    stageCompletePublisher.send(completion: .finished)

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

extension NewPollHotCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}
