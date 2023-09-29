//
//  TopicCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

struct TopicCellConfiguration: UIContentConfiguration, Hashable {
  
  var topicItem: TopicItem!
  var mode: TopicsCollectionView.Mode!
  
  func makeContentView() -> UIView & UIContentView {
    return TopicCellContent(configuration: self)
  }
  
  func updated(for state: UIConfigurationState) -> Self {
    guard state is UICellConfigurationState else {
      return self
    }
    let updatedConfiguration = self
    return updatedConfiguration
  }
}

class TopicCell: UICollectionViewListCell {
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private lazy var tapRecognizer: UITapGestureRecognizer = { UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))) }()
  
  // MARK: - Public properties
  public var mode: TopicsCollectionView.Mode = .Default {
    didSet {
      tapRecognizer.isEnabled = mode == .Default
    }
  }
  public var item: TopicItem!
  public var callback: Closure?
  public var touchSubject = PassthroughSubject<[Topic: CGPoint], Never>()
  
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
    
    guard mode == .Default else { return }
    
    addGestureRecognizer(tapRecognizer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func updateConfiguration(using state: UICellConfigurationState) {
    automaticallyUpdatesBackgroundConfiguration = false
    automaticallyUpdatesContentConfiguration = mode == .Default ? false : true
    
    if mode == .Selection {
      accessories = state.isSelected ? [.checkmark(displayed: .always,
                                                   options: UICellAccessory.CheckmarkOptions(isHidden: false,
                                                                                             reservedLayoutWidth: nil,
                                                                                             tintColor: item.topic.tagColor))] : []
    }
    
    if state.isSelected, !callback.isNil { callback!() }
    
    var newConfiguration = TopicCellConfiguration().updated(for: state)
    newConfiguration.mode = mode
    newConfiguration.topicItem = item
    tintColor = item.topic.tagColor
    
    contentConfiguration = newConfiguration
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
    backgroundConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : item.topic.tagColor.withAlphaComponent(0.1)
    backgroundConfiguration = backgroundConfig
    
    //        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
    //        let accessoryConfig = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: UIImage(systemName: "chevron.right")), placement: .trailing(displayed: .always, at: {
    //            _ in 0
    //        }), isHidden: false, reservedLayoutWidth: nil, tintColor: tintColor, maintainsFixedSize: true)
    //        accessories = [UICellAccessory.customView(configuration: accessoryConfig)]
  }
  
  //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  //        let touch = touches.first
  //        guard let point = touch?.location(in: self) else { return }
  //
  //        super.touchesBegan(touches, with: event)
  //        guard let item = item else { return }
  //        touchSubject.send([item.topic: point])
  //    }
  
  override func prepareForReuse() {
    //        touchSubject = .init(nil)
    super.prepareForReuse()
  }
  
  @objc
  private func handleTap(recognizer: UITapGestureRecognizer) {
    guard let item = item else { return }
    
    touchSubject.send([item.topic: recognizer.location(ofTouch: 0, in: self)])
  }
}

class TopicCellContent: UIView, UIContentView {
  
  // MARK: - Public properties
  public var configuration: UIContentConfiguration {
    get {
      currentConfiguration
    }
    set {
      guard let newConfiguration = newValue as? TopicCellConfiguration else {
        return
      }
      apply(configuration: newConfiguration)
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tempSubscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private var currentConfiguration: TopicCellConfiguration! {
    didSet {
      guard !currentConfiguration.isNil else { return }
      
      tempSubscriptions.forEach { $0.cancel() }
      currentConfiguration.topicItem.topic.activeCountPublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.totalCountLabel.text = String(describing: $0) }
        .store(in: &tempSubscriptions)
    }
  }
  private lazy var horizontalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [verticalStack, totalCountLabel])
    instance.axis = .horizontal
    instance.spacing = padding
    return instance
  }()
  private lazy var verticalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      tagCapsule,
      topicDescription
    ])
    instance.axis = .vertical
    instance.alignment = .leading
    instance.spacing = padding/2
    
    return instance
  }()
  private lazy var tagCapsule: TagCapsule = {
//    let title = item.topic.isOther ? "\(item.topic.parent!.title.localized)/\(item.topic.title.localized)" : { item.topic.title.localized }()
    let instance = TagCapsule(text: "",//title.uppercased(),
                              padding: padding,
                              textPadding: .init(top: padding/3, left: 0, bottom: padding/3, right: 0),
                              color: .clear,//item.topic.tagColor,
                              font: UIFont(name: Fonts.Rubik.Medium, size: 12)!,
                              isShadowed: false,
                              iconCategory: .Null,//item.topic.isOther ? item.topic.parent!.iconCategory : item.topic.iconCategory,
                              image: nil)
//    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: instance.font) + padding/2).isActive = true
    
    return instance
  }()
  private lazy var topicDescription: UILabel = {
    let instance = UILabel()
    instance.text = "There's gonna be a description of the topic"
    instance.font = UIFont(name: Fonts.Rubik.Regular, size: 11)
    instance.textAlignment = .natural
    instance.numberOfLines = 0
//    instance.lineBreakMode = .byTruncatingTail
    instance.textColor = .label//traitCollection.userInterfaceStyle == .dark ? .darkGray : .label
    let constraint = instance.height("T".height(withConstrainedWidth: 100, font: instance.font))
    constraint.identifier = "height"
    
    instance.publisher(for: \.bounds)
      .filter { [unowned self] in self.descriptionWidth < $0.width }
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.descriptionWidth = $0.width
        self.setNeedsLayout()
        constraint.constant = self.currentConfiguration.topicItem.description.height(withConstrainedWidth: $0.width, font: instance.font)
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  @MainActor private lazy var totalCountLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont(name: Fonts.Rubik.Regular, size: 14)
    instance.textAlignment = .right
    instance.textColor = .label
    instance.alpha = 0
    
    return instance
  }()
  private lazy var gradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    instance.type = .radial
    instance.colors = getGradientColors(color: .systemGray)
    instance.locations = [0, 0.5, 1.15]
    instance.setIdentifier("radialGradient")
    instance.startPoint = CGPoint(x: 0.5, y: 0.5)
    instance.endPoint = CGPoint(x: 1, y: 1)
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { rect in
        instance.cornerRadius = rect.height/3.25
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private let padding: CGFloat = 8
  private var descriptionWidth: CGFloat = .zero
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    tempSubscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  // MARK: - Initalization
  init(configuration: TopicCellConfiguration) {
    super.init(frame: .zero)
    
    currentConfiguration = configuration
    setupUI()
    apply(configuration: configuration)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
//    guard let item = currentConfiguration.topicItem else { return }
    
    //        (topicIcon.icon as! CAShapeLayer).fillColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : item.topic.tagColor.cgColor
    
//    //Set dynamic font size
//    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
//
//    topicTitle.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
//                                        forTextStyle: .headline)
//    viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                        forTextStyle: .callout)
//
//    guard let constraint = topicTitle.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
//
//    setNeedsLayout()
//    constraint.constant = item.title.height(withConstrainedWidth: topicTitle.bounds.width, font: topicTitle.font)
//    layoutIfNeeded()
  }
}

// MARK: - Private
private extension TopicCellContent {
  func apply(configuration new: TopicCellConfiguration) {
//    guard currentConfiguration != new else { return }
    
//    if let constraint = topicDescription.getConstraint(identifier: "height"), topicDescription.bounds.width.isZero { //}!bounds.width.isZero {
//      // Force update bounds if it is zero
////      if topicDescription.bounds.width.isZero {
//        setNeedsLayout()
//        layoutIfNeeded()
////      }
//      constraint.constant = new.topicItem.description.height(withConstrainedWidth: topicDescription.bounds.width, font: topicDescription.font)
//    }
    
    currentConfiguration = new
    
    let color = currentConfiguration.topicItem.topic.tagColor
    gradient.colors = getGradientColors(color: color)
    //        topicIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.topicItem.topic.tagColor
    tagCapsule.color = color
    tagCapsule.text = currentConfiguration.topicItem.topic.title
    tagCapsule.iconCategory = currentConfiguration.topicItem.topic.iconCategory
//    topicTitle.text = currentConfiguration.topicItem.title.uppercased()
    topicDescription.text = currentConfiguration.topicItem.description
    //        topicDescription.textColor = traitCollection.userInterfaceStyle == .dark ? .darkGray : .label
    if currentConfiguration.mode == .Default {
      totalCountLabel.alpha = 1
      totalCountLabel.text = String(describing: currentConfiguration.topicItem.topic.activeCount.roundedWithAbbreviations)
      totalCountLabel.textColor = new.topicItem.topic.activeCount > 0 ? color : .secondaryLabel
      currentConfiguration.topicItem.topic.activeCountPublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.totalCountLabel.text = $0.roundedWithAbbreviations }
        .store(in: &subscriptions)
    }
  }
  
  @MainActor
  func setupUI() {
    addSubview(horizontalStack)
    horizontalStack.translatesAutoresizingMaskIntoConstraints = false
    //        iconContainer.translatesAutoresizingMaskIntoConstraints = false
    //        icon.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      horizontalStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: padding/2),
      horizontalStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 0),
//      topicLabel.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 100, font: topicTitle.font)),
      //            iconContainer.widthAnchor.constraint(equalTo: horizontalStack.widthAnchor, multiplier: 0.15)
      //            horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      //            icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1/1),
      //            icon.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor),
      //            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
      //            horizontalStack.widthAnchor.constraint(equalTo: widthAnchor),
      //            horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: padding)
    ])

    let constr = horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
    constr.priority = .defaultHigh
    constr.isActive = true

    let constraint = topicDescription.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -padding/2)
    constraint.priority = .defaultLow
    constraint.isActive = true
//    horizontalStack.edgesToSuperview(insets: .init(top: padding*2, left: 0, bottom: padding, right: padding))
  }
  
  func getGradientColors(color: UIColor) -> [CGColor] {
    return [
      color.cgColor,
      color.cgColor,
      color.lighter(0.05).cgColor,
    ]
  }
}
