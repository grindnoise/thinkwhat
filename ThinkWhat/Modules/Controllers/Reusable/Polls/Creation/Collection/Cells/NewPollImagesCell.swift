//
//  NewPollImagesCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollImagesCell: UICollectionViewCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var stage: NewPollController.Stage! {
    didSet {
      guard !stage.isNil, stage != oldValue else { return }
      
      setupUI()
    }
  }
  public var stageGlobal: NewPollController.Stage!
  public var images: [NewPollImage]!
  public var topicColor: UIColor = .systemGray
  public var externalSubscriptions = Set<AnyCancellable>()
  ///**Publishers**
  @Published public var removedImage: NewPollImage?
  public private(set) var stageCompletePublisher = PassthroughSubject<Void, Never>()
  public private(set) var animationCompletePublisher = PassthroughSubject<Void, Never>()
  @Published public private(set) var stageAnimationFinished: NewPollController.Stage!
  @Published public var isKeyboardOnScreen: Bool!
  @Published public var isMovingToParent: Bool!
  public private(set) var addImagePublisher = PassthroughSubject<Void, Never>()
  public private(set) var boundsPublisher = PassthroughSubject<Bool, Never>()
  ///**UI**
  @Published public var color = UIColor.systemGray4 {
    didSet {
      guard oldValue != color else { return }
      
      fgLayer.backgroundColor = color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
      
      if #available(iOS 15, *) {
        button.configuration?.baseBackgroundColor = color
      } else {
        button.setAttributedTitle(NSAttributedString(string: "new_poll_image_add".localized,
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                        .foregroundColor: color as Any
                                                       ]),
                                    for: .normal)
      }
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
  private lazy var collectionView: NewPollImagesCollectionView = {
    let instance = NewPollImagesCollectionView(images)
    let constraint = instance.heightAnchor.constraint(equalToConstant: 1)
    constraint.isActive = true
    
    instance.$removedImage
      .sink { [unowned self] in self.removedImage = $0 }
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
        
        constraint.constant = max(1, $0.height)
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
//    instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100,
//                                                                    font: instance.font)).isActive = true
//
    return instance
  }()
  private lazy var stageStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [imageView, label])
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
//    label.heightAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    
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
      let attrString = AttributedString("new_poll_image_add".localized.uppercased(), attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .body) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      var config = UIButton.Configuration.filled()
      config.attributedTitle = attrString
      config.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
      config.image = UIImage(systemName: "photo.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
      config.imagePlacement = .trailing
      config.imagePadding = padding
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.buttonSize = .large
      
      instance.configuration = config
    } else {
      instance.setAttributedTitle(NSAttributedString(string: "new_poll_image_add".localized,
                                                     attributes: [
                                                      .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                      .foregroundColor: topicColor as Any
                                                     ]),
                                  for: .normal)
      instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground//color
    }
    
//    instance.setAttributedTitle(NSAttributedString(string: "new_poll_image_add".localized,
//                                                   attributes: [
//                                                    .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
//                                                    .foregroundColor: topicColor as Any
//                                                   ]),
//                                for: .normal)
//    instance.setImage(UIImage(systemName: "photo.fill"), for: .normal)
//    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)!) + padding).isActive = true
    instance.addTarget(self,
                       action: #selector(self.addImage),
                       for: .touchUpInside)
    
    return instance
  }()
  private lazy var nextButton: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "arrow.down.circle.fill"))
    instance.isUserInteractionEnabled = true
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.contentMode = .scaleAspectFill
    instance.tintColor = topicColor
    instance.alpha = 0
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStage)))
    
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [button])
    instance.spacing = padding
    instance.axis = .vertical
    instance.alignment = .center
    instance.distribution = .fillEqually
    
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
    
    externalSubscriptions.forEach { $0.cancel() }
    boundsPublisher = PassthroughSubject<Bool, Never>()
    addImagePublisher = PassthroughSubject<Void, Never>()
//    topicPublisher = PassthroughSubject<Topic, Never>()
    animationCompletePublisher = PassthroughSubject<Void, Never>()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1, xPoint: 500)
    self.drawLine(line: self.fgLine)
  }
  
  // MARK: - Public methods
  public func present(seconds: Double = .zero) {
    UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
      guard let self = self else { return }
      
      self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .caption2)
    } completion: { _ in }
    
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
      } completion: { _ in self.placeholder.removeFromSuperview()
        self.collectionView.present()
        self.buttonsStack.addArrangedSubview(self.nextButton)
        self.boundsPublisher.send(true)
        self.nextButton.transform = .init(scaleX: 0.75, y: 0.75)
        self.collectionView.transform = .init(scaleX: 0.75, y: 0.75)
        self.buttonsStack.transform = .init(scaleX: 0.75, y: 0.75)
        UIView.animate(withDuration: 0.2) {
          self.collectionView.alpha = 1
          self.buttonsStack.alpha = 1
          self.nextButton.alpha = 1
          self.nextButton.transform = .identity
          self.buttonsStack.transform = .identity
          self.collectionView.transform = .identity
        }
      }
    }
  }
  
  public func update(_ instances: [NewPollImage]) {
    collectionView.update(instances)
  }
}

// MARK: - Private
private extension NewPollImagesCell {
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
      collectionView.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*2),
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
      buttonsStack.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: padding*3),
//      buttonsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
      buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    let constraint = buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*4)
    constraint.isActive = true
    constraint.priority = .defaultLow
    
    layer.insertSublayer(bgLine.layer, at: 0)
    layer.insertSublayer(fgLine.layer, at: 1)
    
    guard stageGlobal.rawValue <= stage.rawValue else { return }
    
    addSubview(placeholder)
    placeholder.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      placeholder.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*4),
      placeholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      placeholder.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    let constraint_2 = placeholder.bottomAnchor.constraint(equalTo: buttonsStack.bottomAnchor)
    constraint_2.isActive = true
    
    collectionView.alpha = 0
    buttonsStack.alpha = 0
  }
  
  @objc
  func handleTap() {
    present()
  }
  
  @objc
  func addImage() {
    guard stageGlobal == .Ready || stage == stageGlobal else { return }
    
    addImagePublisher.send()
//    collectionView.addChoice()
  }
  
  @objc
  func nextStage() {
    UIView.transition(with: self.label, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
      guard let self = self else { return }
      
      self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    } completion: { _ in }
    
    buttonsStack.removeArrangedSubview(nextButton)
    nextButton.removeFromSuperview()
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

extension NewPollImagesCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}


