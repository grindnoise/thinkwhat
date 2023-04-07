//
//  NewPollTopicCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollTopicCell: UICollectionViewCell {
  
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
  
  ///**Publishers**
  public private(set) var stageCompletePublisher = PassthroughSubject<Void, Never>()
  public private(set) var animationCompletePublisher = PassthroughSubject<Void, Never>()
  @Published public var topic: Topic! {
    didSet {
      guard let topic = topic,
            topic != oldValue
      else { return }
      
      guard stageGlobal == stage || stageGlobal == .Ready else { return }
      
      UIView.transition(with: self.label, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
        guard let self = self else { return }
        
        self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
      } completion: { _ in }
      
      if oldValue.isNil {
        stageCompletePublisher.send()
        stageCompletePublisher.send(completion: .finished)
        CATransaction.begin()
        CATransaction.setCompletionBlock() { [unowned self] in
          self.animationCompletePublisher.send()
          self.animationCompletePublisher.send(completion: .finished)
        }
        fgLine.layer.strokeColor = topic.tagColor.cgColor
        fgLine.layer.add(CABasicAnimation(path: "strokeEnd", fromValue: 0, toValue: 1, duration: 0.4), forKey: "strokeEnd")
        CATransaction.commit()
      } else {
        let colorAnim = CABasicAnimation(path: "strokeColor", fromValue: fgLine.layer.strokeColor, toValue: topic.tagColor.cgColor, duration: 0.4)
        colorAnim.delegate = self
        colorAnim.setValue({ [weak self] in
          guard let self = self else { return }
          
          self.fgLine.layer.removeAnimation(forKey: "color")
        }, forKey: "completion")
        
        fgLine.layer.strokeColor = topic.tagColor.cgColor
      }
      tagCapsule.color = topic.tagColor
      tagCapsule.text = topic.title
      tagCapsule.iconCategory = topic.iconCategory
      UIView.animate(withDuration: 0.4) { [weak self] in
        guard let self = self else { return }
        
        self.imageView.tintColor = self.topic.tagColor
      }
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var tagCapsule: TagCapsule = { TagCapsule(text: stage.title.uppercased(),
                                                         padding: 4,
                                                         color: Colors.Logo.Flame.rawValue,
                                                         font: UIFont(name: Fonts.Bold, size: 20)!,
                                                         iconCategory: .Logo) }()
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: stage.numImage)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
    instance.tintColor = Colors.Logo.Flame.rawValue
    instance.contentMode = .scaleAspectFit
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.font = UIFont.scaledFont(fontName: stage == stageGlobal ? Fonts.OpenSans.Bold.rawValue : Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    instance.text = "new_poll_topic".localized.uppercased()
    
    return instance
  }()
  private lazy var stageStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [imageView, label])
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
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
    instance.backgroundColor = Colors.Logo.Flame.rawValue.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
    
    return instance
  }()
  
  
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    externalSubscriptions.forEach { $0.cancel() }
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
    
    animationCompletePublisher = PassthroughSubject<Void, Never>()
    stageCompletePublisher = PassthroughSubject<Void, Never>()
    externalSubscriptions.forEach { $0.cancel() }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1)
    self.drawLine(line: self.fgLine)
  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
    Animations.unmaskLayerCircled(layer: fgLayer,
                                  location: CGPoint(x: placeholder.bounds.midX, y: placeholder.bounds.midY),
                                  duration: 0.5,
                                  opacityDurationMultiplier: 0.6,
                                  delegate: self)
    
    bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) { [weak self] in
      guard let self = self else { return }
      
      self.placeholder.textColor = .label
    }
//      self.placeholder.transform = .init(scaleX: 1.05, y: 1.05)
//    }) { [weak self] _ in
//      guard let self = self else { return }
//
      delay(seconds: seconds) { [weak self] in
        guard let self = self else { return }
        
        let banner = NewPopup(padding: self.padding*2,
                              contentPadding: .uniform(size: self.padding))
        let content = TopicSelectionPopupContent(mode: self.topic.isNil ? .ForceSelect : .Default,
                                                 color: Colors.Logo.Flame.rawValue)
        content.topicPublisher
          .sink { topic in
            banner.dismiss()
            
            delay(seconds: 0.15) { [unowned self] in
              self.topic = topic
            }
          }
          .store(in: &banner.subscriptions)
        
        banner.setContent(content)
        banner.didAppearPublisher
          .sink { [unowned self] _ in
//            self.placeholder.removeFromSuperview()
            self.placeholder.alpha = 0
            self.tagCapsule.alpha = 1
          }
          .store(in: &self.subscriptions)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
    }
//  }
}

  
  // MARK: - Private
  private extension NewPollTopicCell {
    @MainActor
    func setupUI() {
      backgroundColor = .clear
      clipsToBounds = false
      stageStack.placeTopLeading(inside: self,
                                 leadingInset: 8,
                                 topInset: 16)
      addSubview(tagCapsule)
      tagCapsule.alpha = stageGlobal == .Topic ? 0 : 1
      tagCapsule.translatesAutoresizingMaskIntoConstraints = false
      tagCapsule.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                             action: #selector(self.handleTap)))
      NSLayoutConstraint.activate([
        tagCapsule.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*3),
        tagCapsule.centerXAnchor.constraint(equalTo: centerXAnchor, constant: padding),
        tagCapsule.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*4),
      ])
      
      if stageGlobal == .Topic {
        addSubview(placeholder)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
          placeholder.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*3),
          placeholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
          placeholder.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
        ])
        
        let constraint = placeholder.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*4)
        constraint.isActive = true
        constraint.priority = .required
      }
      
      layer.insertSublayer(bgLine.layer, at: 0)
      layer.insertSublayer(fgLine.layer, at: 1)
    }
    
    @objc
    func handleTap() {
      guard stageGlobal == .Ready || stage == stageGlobal else { return }
      
      present()
    }
    
    func drawLine(line: Line,
                  strokeEnd: CGFloat = 0,
                  lineCap: CAShapeLayerLineCap = .round) {
      let lineWidth = imageView.bounds.width*0.1
      let imageCenter = imageView.convert(imageView.center, to: contentView)
      let xPos = imageCenter.x //- lineWidth/2
      let yPos = imageCenter.y + imageView.bounds.height/2 - lineWidth
      
      let path = UIBezierPath()
      path.move(to: CGPoint(x: xPos, y: yPos))
      path.addLine(to: CGPoint(x: xPos, y: bounds.maxY + lineWidth))
      
      line.path = path
      line.layer.strokeStart = 0
      line.layer.strokeEnd = strokeEnd
      line.layer.lineCap = lineCap
      line.layer.lineWidth = lineWidth
      line.layer.path = line.path.cgPath
    }
  }
  
  extension NewPollTopicCell: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
      guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
      
      completion()
    }
  }
