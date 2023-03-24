//
//  NewPollCommentsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollCommentsCell: UICollectionViewCell {
  
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
  @Published public var commentsEnabled: Bool!
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
    instance.textColor = commentsEnabled.isNil ? color : .label
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
    instance.text = commentsEnabled.isNil ? "new_poll_comments_placeholder".localized : commentsEnabled ? "new_poll_comments_on".localized : "new_poll_comments_off".localized
    
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
      commentsOnIcon,
      commentsOffIcon
    ])
    instance.axis = .horizontal
    instance.distribution = .fillEqually
    instance.spacing = 35
    
    return instance
  }()
  private lazy var nextButton: UIButton = {
    let instance = UIButton()
    instance.setAttributedTitle(NSAttributedString(string: "new_poll_choice_next".localized,
                                                   attributes: [
                                                    .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                    .foregroundColor: color as Any
                                                   ]),
                                for: .normal)
    instance.addTarget(self, action: #selector(self.nextStage), for: .touchUpInside)
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = { UIStackView(arrangedSubviews: [nextButton]) }()
  private lazy var commentsOnIcon: Icon = {
    let instance = Icon(category: .Comments)
    instance.iconColor = commentsEnabled.isNil ? color : .systemGray
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.heightAnchor.constraint(equalToConstant: 70).isActive = true
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    return instance
  }()
  private lazy var commentsOffIcon: Icon = {
    let instance = Icon(category: .CommentsDisabled)
    instance.iconColor = commentsEnabled.isNil ? color : .systemGray
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
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
    
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1, xPoint: 500)
    self.drawLine(line: self.fgLine)
  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
    commentsOnIcon.setIconColor(UIColor.systemGray)
    commentsOffIcon.setIconColor(UIColor.systemGray)
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
private extension NewPollCommentsCell {
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
      stack.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*2),
      stack.centerXAnchor.constraint(equalTo: centerXAnchor),
      descriptionLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: padding*2),
      descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      buttonsStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: padding),
      buttonsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
    ])
    
    let constraint = buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*2)
    constraint.isActive = true
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
//    guard !commentsEnabled.isNil else { return }
//    guard stageGlobal == .Ready || stage == stageGlobal else { return }
    
    guard let v = recognizer.view else { return }
    if let icon = v as? Icon {
        let selectedIcon: Icon! = icon == commentsOnIcon ? commentsOnIcon : commentsOffIcon
        let deselectedIcon: Icon! = icon != commentsOnIcon ? commentsOnIcon : commentsOffIcon
        
      if !commentsEnabled.isNil {
        if commentsEnabled && icon == commentsOnIcon || !commentsEnabled && icon == commentsOffIcon {
          return
        }
      }
        
        let enableAnim  = Animations.get(property: .FillColor,
                                         fromValue: selectedIcon.iconColor.cgColor,
                                         toValue: color.cgColor,
                                         duration: 0.3,
                                         timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                         delegate: nil,
                                         isRemovedOnCompletion: true)
        let disableAnim = Animations.get(property: .FillColor,
                                         fromValue: deselectedIcon.iconColor.cgColor,
                                         toValue: UIColor.systemGray.cgColor,
                                         duration: 0.3,
                                         timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                         delegate: nil,
                                         isRemovedOnCompletion: true)
        
        selectedIcon.icon.add(enableAnim, forKey: nil)
        (selectedIcon.icon as! CAShapeLayer).fillColor = color.cgColor//traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor
        deselectedIcon.icon.add(disableAnim, forKey: nil)
        (deselectedIcon.icon as! CAShapeLayer).fillColor = UIColor.systemGray.cgColor
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 2.5,
            options: [.curveEaseInOut],
            animations: {
                selectedIcon.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in }
      
      if commentsEnabled.isNil {
        commentsEnabled = selectedIcon == commentsOnIcon
      } else {
        commentsEnabled = !commentsEnabled
      }
      
      UIView.transition(with: descriptionLabel, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
        guard let self = self else { return }
        
        self.descriptionLabel.textColor = .label
        self.descriptionLabel.text = self.commentsEnabled ? "new_poll_comments_on".localized : "new_poll_comments_off".localized
      } completion: { _ in }
        
        deselectedIcon.icon.add(disableAnim, forKey: nil)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
            deselectedIcon.transform = .identity
        })
    }
  }
  
  @objc
  func nextStage() {
    buttonsStack.removeArrangedSubview(nextButton)
    boundsPublisher.send()
    nextButton.removeFromSuperview()
    
    CATransaction.begin()
    CATransaction.setCompletionBlock() { [unowned self] in self.isAnimationComplete = true }
    fgLine.layer.strokeColor = color.cgColor
    fgLine.layer.add(CABasicAnimation(path: "strokeEnd", fromValue: 0, toValue: 1, duration: 0.4), forKey: "strokeEnd")
    CATransaction.commit()
  }
}

extension NewPollCommentsCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}
