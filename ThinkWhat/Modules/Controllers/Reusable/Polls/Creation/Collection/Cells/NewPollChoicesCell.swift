//
//  NewPollChoicesCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollChoicesCell: UICollectionViewCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var stage: NewPollController.Stage! {
    didSet {
      guard !stage.isNil, oldValue != stage else { return }
      
      setupUI()
    }
  }
  public var choices: [NewPollChoice]! //{
//    didSet {
//      guard !choices.isNil else { return }
//
//      setupUI()
//    }
//  }
  public var externalSubscriptions = Set<AnyCancellable>()
  public var topicColor: UIColor = .systemGray {
    didSet {
      guard !stage.isNil else { return }
      
      if choices.count >= 2 {
        if #available(iOS 15, *) {
          button.configuration?.baseBackgroundColor = topicColor
        } else {
          button.setAttributedTitle(NSAttributedString(string: "new_poll_choice_add".localized,
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                        .foregroundColor: topicColor as Any
                                                       ]),
                                    for: .normal)
        }
      }
    }
  }
  ///**Publishers**
  @Published public var stageGlobal: NewPollController.Stage!
  @Published public private(set) var wasEdited: Bool?
  @Published public var removedChoice: NewPollChoice?
  @Published public private(set) var animationCompletePublisher = PassthroughSubject<Void, Never>()
  @Published public private(set) var stageAnimationFinished: NewPollController.Stage!
  @Published public var isKeyboardOnScreen: Bool!
  @Published public var isMovingToParent: Bool!
  public private(set) var stageCompletePublisher = PassthroughSubject<Void, Never>()
  public private(set) var addChoicePublisher = CurrentValueSubject<Bool?, Never>(nil)
  public private(set) var boundsPublisher = PassthroughSubject<Bool, Never>()
  ///**UI**
  @Published public var color = UIColor.systemGray4 {
    didSet {
      guard oldValue != color else { return }
      
      fgLayer.backgroundColor = color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
      
//      if choices.count >= 2 {
//        if #available(iOS 15, *) {
//          button.configuration?.baseBackgroundColor = topicColor
//        } else {
//          button.setAttributedTitle(NSAttributedString(string: "new_poll_choice_add".localized,
//                                                       attributes: [
//                                                        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
//                                                        .foregroundColor: topicColor as Any
//                                                       ]),
//                                    for: .normal)
//        }
//      }
      nextButton.tintColor = color
      
      UIView.animate(withDuration: 0.4) { [weak self] in
        guard let self = self else { return }
        
        self.imageView.tintColor = self.color
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
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var collectionView: NewPollChoicesCollectionView = {
    let instance = NewPollChoicesCollectionView(dataItems: choices,
                                                stage: stage,
                                                stageGlobal: stageGlobal)
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.isActive = true
    
    instance.$removedChoice
      .sink { [unowned self] in self.removedChoice = $0 }
      .store(in: &subscriptions)
    instance.$wasEdited
      .sink { [unowned self] in
        print("$wasEdited")
        self.wasEdited = $0
      }
      .store(in: &subscriptions)
    
    $stageGlobal
      .filter { !$0.isNil }
      .eraseToAnyPublisher()
      .sink { instance.stageGlobal = $0! }
      .store(in: &subscriptions)
    $isMovingToParent
      .filter { !$0.isNil }
      .eraseToAnyPublisher()
      .sink { instance.isMovingToParent = $0!}
      .store(in: &subscriptions)
    $isKeyboardOnScreen
      .filter { !$0.isNil }
      .eraseToAnyPublisher()
      .sink { instance.isKeyboardOnScreen = $0!}
      .store(in: &subscriptions)
    
    setNeedsLayout()
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero && constraint.constant != $0.height }
      .sink { [weak self] in
        guard let self = self else { return }
        
        constraint.constant = $0.height
        self.layoutIfNeeded()
        self.boundsPublisher.send(true)
      }
      .store(in: &subscriptions)
    
    
    return instance
  }()
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: stage.numImage)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
    instance.tintColor = color
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
  private lazy var stageStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [imageView, label])
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
    instance.publisher(for: \.bounds)
      .sink {
        print($0)
      }
      .store(in: &subscriptions)
    
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
  private lazy var button: UIButton = {
    let instance = UIButton()
    
    if #available(iOS 15, *) {
      let attrString = AttributedString("new_poll_choice_add".localized.uppercased(), attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .body) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      var config = UIButton.Configuration.filled()
      config.attributedTitle = attrString
      config.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
      config.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
      config.imagePlacement = .trailing
      config.imagePadding = padding
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.buttonSize = .large
      
      instance.configuration = config
    } else {
      instance.setAttributedTitle(NSAttributedString(string: "new_poll_choice_add".localized,
                                                     attributes: [
                                                      .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                      .foregroundColor: topicColor as Any
                                                     ]),
                                  for: .normal)
      instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground//color
    }
    instance.addTarget(self, action: #selector(self.addChoice), for: .touchUpInside)
    
    return instance
  }()
  private lazy var nextButton: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "arrow.down.circle.fill"))
    instance.isUserInteractionEnabled = true
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    instance.contentMode = .scaleAspectFill
    instance.tintColor = topicColor
    instance.alpha = 0
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStage)))
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
    constraint.isActive = true
    constraint.identifier = "heightAnchor"
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [button, nextButton])//button
    instance.spacing = padding
    instance.axis = .vertical
//    instance.distribution = .fillEqually
    instance.alignment = .center
    
    return instance
  }()
  private lazy var placeholder: InsetLabel = {
    let instance = InsetLabel()
    instance.insets = .uniform(size: padding)
    instance.numberOfLines = 0
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline)
    instance.text = stage.placeholder
    instance.textColor = .tertiaryLabel
    instance.textAlignment = .center
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
    
    boundsPublisher = PassthroughSubject<Bool, Never>()
    addChoicePublisher = CurrentValueSubject<Bool?, Never>(nil)
    animationCompletePublisher = PassthroughSubject<Void, Never>()
    externalSubscriptions.forEach { $0.cancel() }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1, xPoint: 500)
    self.drawLine(line: self.fgLine)
  }
  
  // MARK: - Public methods
  public func present(index: Int, seconds: Double = .zero) {
    if index == 0 {
      Animations.unmaskLayerCircled(layer: fgLayer,
                                    location: CGPoint(x: placeholder.bounds.midX, y: placeholder.bounds.midY),
                                    duration: 0.5,
                                    opacityDurationMultiplier: 0.6,
                                    delegate: self)
      
      bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
      
      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        guard let self = self else { return }
        
        self.placeholder.textColor = .label
      }) { [weak self] _ in
        guard let self = self else { return }
        
        delay(seconds: 1) {
          Animations.unmaskLayerCircled(unmask: false,
                                        layer: self.fgLayer,
                                        location: CGPoint(x: self.placeholder.bounds.midX, y: self.placeholder.bounds.midY),
                                        duration: 0.5,
                                        opacityDurationMultiplier: 0.6,
                                        delegate: self)
          
          self.bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
        }
        
        UIView.animate(withDuration: 0.2, delay: 1.5, options: .curveEaseIn) {
          self.placeholder.alpha = 0
          self.placeholder.transform = .init(scaleX: 0.75, y: 0.75)
        } completion: { _ in
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            
            self.collectionView.alpha = 1
            self.buttonsStack.alpha = 1
          } completion: { _ in self.placeholder.removeFromSuperview() }
        }
      }
    } else if index != 0, stageGlobal == stage {
      if index == 1 {
        if let constraint = nextButton.getConstraint(identifier: "heightAnchor") {
          setNeedsLayout()
          UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.buttonsStack.spacing = self.padding
            self.nextButton.alpha = 1
            constraint.constant = "T".height(withConstrainedWidth: 100,
                                             font: UIFont.scaledFont(fontName: Fonts.Regular,
                                                                     forTextStyle: .body)!) + self.padding*2
            self.layoutIfNeeded()
          }
        }
        boundsPublisher.send(true)
//        buttonsStack.addArrangedSubview(nextButton)
//        delay(seconds: 0.3) { [weak self] in
//          guard let self = self else { return }
//
//          self.nextButton.transform = .init(scaleX: 0.75, y: 0.75)
//          UIView.animate(withDuration: 0.2) {
//            self.nextButton.transform = .identity
//            self.nextButton.alpha = 1
//          }
//        }
      }
//      boundsPublisher.send(true)
      
      if #available(iOS 15, *) {
        button.configuration?.baseBackgroundColor = topicColor
      } else {
        button.setAttributedTitle(NSAttributedString(string: "new_poll_choice_add".localized,
                                                     attributes: [
                                                      .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                      .foregroundColor: topicColor as Any
                                                     ]),
                                  for: .normal)
      }
    }
    
    
    
    guard seconds != .zero else {
      collectionView.present(index: index)
      
      return
    }
    
    delay(seconds: seconds + (index == 0 ? 0.6 : 0)) { [weak self] in
      guard let self = self else { return }
      
      self.collectionView.present(index: index)
    }
  }
  
  public func refreshChoices(_ instances: [NewPollChoice]) {
    choices = instances
    collectionView.refreshChoices(instances)
  }
  
  public func addSecondChoice() {
    endEditing(true)
    addChoicePublisher.send(true)
  }
}

// MARK: - Private
private extension NewPollChoicesCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stageStack.placeTopLeading(inside: self,
                               leadingInset: 8,
                               topInset: -2)
    addSubview(collectionView)
    addSubview(buttonsStack)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    buttonsStack.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*4),
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
      buttonsStack.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: padding*2),
//      buttonsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
      buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    let constraint = nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*4)
    constraint.isActive = true
    constraint.identifier = "bottomAnchor"
    constraint.priority = .defaultLow
    
    buttonsStack.spacing = 0
    
    layer.insertSublayer(bgLine.layer, at: 0)
    layer.insertSublayer(fgLine.layer, at: 1)
    
    guard stageGlobal.rawValue <= stage.rawValue else { return }
    
    addSubview(placeholder)
    placeholder.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      placeholder.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*4),
      placeholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      placeholder.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
//      placeholder.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*4)
    ])
    
    let constraint_2 = placeholder.bottomAnchor.constraint(equalTo: nextButton.bottomAnchor)
    constraint_2.isActive = true
//    constraint_2.priority = .defaultLow
    
    collectionView.alpha = 0
    buttonsStack.alpha = 0
  }
  
  @objc
  func nextStage() {
    UIView.transition(with: self.label, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
      guard let self = self else { return }
      
      self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    } completion: { _ in }
    
    endEditing(true)
//    buttonsStack.removeArrangedSubview(nextButton)
//    nextButton.removeFromSuperview()
    if let heightAnchor = nextButton.getConstraint(identifier: "heightAnchor") { //,
//       let bottomAnchor = buttonsStack.getConstraint(identifier: "bottomAnchor"){
      setNeedsLayout()
      UIView.animate(withDuration: 0.3) { [weak self] in
        guard let self = self else { return }
        
        heightAnchor.constant = 0
        self.buttonsStack.spacing = 0
//        bottomAnchor.constant = 0
        self.layoutIfNeeded()
      }
    }
    
    boundsPublisher.send(true)
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
  
  @objc
  func addChoice() {
    guard choices.count > 1 else { return }
    endEditing(true)
    addChoicePublisher.send(true)
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
}

extension NewPollChoicesCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}

