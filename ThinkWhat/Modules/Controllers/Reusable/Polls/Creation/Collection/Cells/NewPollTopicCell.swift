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
      guard !stage.isNil else { return }
      
      setupUI()
    }
  }
  ///**Publishers**
  @Published public private(set) var topic: Topic! {
    didSet {
      guard let topic = topic,
            topic != oldValue
      else { return }
      
      line.layer.add(Animations.get(property: .StrokeEnd,
                                    fromValue: 0,
                                    toValue: 1,
                                    duration: 0.3,
                                    timingFunction: .easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: false,
                                    completionBlocks: [{ [weak self] in
        guard let self = self else { return }
          
        self.line.layer.strokeEnd = 1
      }]),
                     forKey: nil)
      line.layer.add(Animations.get(property: .StrokeColor,
                                    fromValue: line.layer.strokeColor as Any,
                                    toValue: topic.tagColor.cgColor,
                                    duration: 0.3,
                                    timingFunction: .easeInEaseOut,
                                    delegate: self,
                                    isRemovedOnCompletion: false,
                                    completionBlocks: [{ [weak self] in
        guard let self = self else { return }
          
        self.line.layer.strokeColor = topic.tagColor.cgColor
        self.line.layer.removeAllAnimations()
      }]),
                     forKey: nil)
      
      tagCapsule.color = topic.tagColor
      tagCapsule.text = topic.title
      tagCapsule.iconCategory = topic.iconCategory
      UIView.animate(withDuration: 0.3) { [weak self] in
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
  private lazy var tagCapsule: TagCapsule = { TagCapsule(text: stage.title().uppercased(),
                                                         padding: 4,
                                                         color: Colors.Logo.Flame.rawValue,
                                                         font: UIFont(name: Fonts.Bold, size: 20)!,
                                                         iconCategory: .Logo) }()
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "\(stage.rawValue + 1).circle.fill"))
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
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    instance.text = "new_poll_survey_topic".localized.uppercased()
    
    return instance
  }()
  private lazy var stageStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [imageView, label])
//    let constraint = instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
//                                                                                     font: label.font)*22)
//    constraint.identifier = "heightAnchor"
//    constraint.isActive = true
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    return instance
  }()
  private let line = Line()
    
  
  
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
    
//    topicPublisher = PassthroughSubject<Topic, Never>()
  }
  
  
  
  // MARK: - Public methods
  func present() {
    delay(seconds: 0.5) { [weak self] in
      guard let self = self else { return }
      let banner = NewPopup(padding: self.padding*2,
                            contentPadding: .uniform(size: self.padding*2))
      let content = AccountManagementPopupContent(mode: .Delete,
                                                  color: Colors.Logo.Flame.rawValue)
      content.actionPublisher
        .sink { _ in banner.dismiss() }
        .store(in: &banner.subscriptions)
      
      banner.setContent(content)
      banner.didDisappearPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.topic = Topics.shared[80]
          banner.removeFromSuperview()
        }
        .store(in: &self.subscriptions)
    }
  }
}

// MARK: - Private
private extension NewPollTopicCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stageStack.placeTopLeading(inside: self,
                               leadingInset: 8,
                               topInset: 16)
    addSubview(tagCapsule)
    tagCapsule.translatesAutoresizingMaskIntoConstraints = false
    tagCapsule.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(self.handleTap)))
    NSLayoutConstraint.activate([
      tagCapsule.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: 16),
      tagCapsule.centerXAnchor.constraint(equalTo: centerXAnchor),
      tagCapsule.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
    ])
    
    layer.insertSublayer(line.layer, at: 0)
    publisher(for: \.bounds)
      .sink { [unowned self] _ in self.drawLine() }
      .store(in: &subscriptions)
  }
  
  @objc
  func handleTap() {
    present()
  }
  
  func drawLine() {
    let lineWidth = imageView.bounds.width*0.1
    let imageCenter = stageStack.convert(imageView.center, to: contentView)
    let xPos = imageCenter.x //- lineWidth/2
    let yPos = imageCenter.y + imageView.bounds.height/2 - lineWidth/2
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: xPos, y: yPos))
    path.addLine(to: CGPoint(x: xPos, y: bounds.maxY))
    
    line.path = path
    line.layer.strokeStart = 0
    line.layer.strokeEnd = 0
    line.layer.lineCap = .round
    line.layer.lineWidth = lineWidth
    line.layer.strokeColor = topic.isNil ? Colors.Logo.Flame.rawValue.cgColor : topic.tagColor.cgColor
    line.layer.path = line.path.cgPath
  }
}

extension NewPollTopicCell: CAAnimationDelegate {
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
