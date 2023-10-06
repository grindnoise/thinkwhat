//
//  TopicHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

struct TopicCellHeaderConfiguration: UIContentConfiguration, Hashable {
  
  var topicItem: TopicHeaderItem!
  var mode: TopicsCollectionView.Mode!
  
  func makeContentView() -> UIView & UIContentView {
    return TopicCellHeaderContent(configuration: self)
  }
  
  func updated(for state: UIConfigurationState) -> Self {
    guard state is UICellConfigurationState else {
      return self
    }
    let updatedConfiguration = self
    return updatedConfiguration
  }
}

class TopicCellHeader: UICollectionViewListCell {
  
  // MARK: - Public properties
  public var item: TopicHeaderItem! {
    didSet {
//      setFade(animated: false)
    }
  }
  public var callback: Closure?
  public var mode: TopicsCollectionView.Mode = .Default
  override var isSelected: Bool {
    didSet {
//      guard oldValue != isSelected else { return }
      
//      setFade(animated: true)
    }
  }

  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func updateConfiguration(using state: UICellConfigurationState) {
    automaticallyUpdatesContentConfiguration = mode == .Default ? false : true
    //        automaticallyUpdatesBackgroundConfiguration = false
    //        accessories = state.isSelected ? [.checkmark(displayed: .always, options: UICellAccessory.CheckmarkOptions(isHidden: false, reservedLayoutWidth: nil, tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor))] : []
    //
    //        if state.isSelected, !callback.isNil { callback!() }
    
    var newConfiguration = TopicCellHeaderConfiguration().updated(for: state)
    newConfiguration.mode = mode 
    newConfiguration.topicItem = item
    
    contentConfiguration = newConfiguration
  }
  
  //    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
  //        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.isNil ? .systemGray : item.topic.tagColor
  //    }
  
  //    override func updateConstraints() {
  //        super.updateConstraints()
  //
  //        separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 100).isActive = true
  //        separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: .greatestFiniteMagnitude).isActive = true
  //    }
  
  // MARK: - Private methods
  private func setFade(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.15) { [weak self] in
        guard let self = self else { return }
        
        self.alpha = self.isSelected ? 1 : 0
      }
    } else {
      alpha = isSelected ? 1 : 0
    }
  }
}

class TopicCellHeaderContent: UIView, UIContentView {
  
  // MARK: - Destructor
  deinit {
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    tempSubscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  // MARK: - Public properties
  var configuration: UIContentConfiguration {
    get {
      currentConfiguration
    }
    set {
      guard let newConfiguration = newValue as? TopicCellHeaderConfiguration else {
        return
      }
      apply(configuration: newConfiguration)
    }
  }
  
  
  
  // MARK: - Private properties
  private var tempSubscriptions = Set<AnyCancellable>()
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private var currentConfiguration: TopicCellHeaderConfiguration! {
    didSet {
      guard !currentConfiguration.isNil else { return }
      
      tempSubscriptions.forEach { $0.cancel() }
      currentConfiguration.topicItem.topic.activeCountPublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.setTitle() }
        .store(in: &tempSubscriptions)
    }
  }
  private lazy var horizontalStack: UIStackView = {
    let opaque = UIView.opaque()
    opaque.addSubview(verticalStack)
    verticalStack.edgesToSuperview(insets: .init(top: padding, left: 0, bottom: padding, right: 0))
    
    let instance = UIStackView(arrangedSubviews: [
      icon,
      opaque,
    ])
    instance.axis = .horizontal
    instance.layer.insertSublayer(gradient, at: 0)
    instance.publisher(for: \.bounds)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.gradient.frame = $0
      }
      .store(in: &subscriptions)
    instance.spacing = 0
    return instance
  }()
  private lazy var verticalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [topicLabel,
                                                  topicDescription])
    instance.axis = .vertical
//    instance.distribution = .fillEqually
    instance.spacing = 0//padding/2
    
    return instance
  }()
  private lazy var icon: Icon = {
    let instance = Icon()
    instance.isRounded = false
    instance.scaleMultiplicator = 1.65
    instance.iconColor = .white
    instance.backgroundColor = .clear
    
    return instance
  }()
  private lazy var topicLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .center
    instance.font = UIFont(name: Fonts.Rubik.Medium, size: 20)
    instance.numberOfLines = 1
    instance.textColor = .white
    instance.textAlignment = .natural
    instance.height("T".height(withConstrainedWidth: 100, font: instance.font))
    
    return instance
  }()
  private lazy var topicDescription: UILabel = {
    let instance = UILabel()
    instance.text = "There's gonna be a description of the topic"
    instance.font = UIFont(name: Fonts.Rubik.Regular, size: 11)
    instance.textAlignment = .left
    instance.numberOfLines = 2
    instance.lineBreakMode = .byTruncatingTail
    instance.textColor = .white//traitCollection.userInterfaceStyle == .dark ? .darkGray : .label
    let constraint = instance.height("T".height(withConstrainedWidth: 100, font: instance.font))
    constraint.identifier = "height"
    
    return instance
  }()
  private lazy var gradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    instance.type = .radial
    instance.locations = [0, 0.5, 1.15]
    instance.setIdentifier("radialGradient")
    instance.startPoint = CGPoint(x: 0.5, y: 0.5)
    instance.endPoint = CGPoint(x: 1, y: 1)
    instance.masksToBounds = true
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private let padding: CGFloat = 8
  
  // MARK: - Initalization
  init(configuration: TopicCellHeaderConfiguration) {
    super.init(frame: .zero)
    
    setupUI()
    apply(configuration: configuration)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    //        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .systemGray : .label
    //        viewsCountLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    //        hotCountLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    //        topicDescription.textColor = traitCollection.userInterfaceStyle == .dark ?  .label : .darkGray
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
    topicLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .headline)
    topicDescription.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
  }
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    super.hitTest(point, with: event)
    
    Animations.tapCircled(layer: gradient,
                          fillColor: UIColor.white.withAlphaComponent(0.6).cgColor,
                          location: point,
                          duration: 0.2)
    
      return nil //avoid delivering touch events to the container view (self)
  }
}

// MARK: - Private
private extension TopicCellHeaderContent {
  func getGradientColors(color: UIColor) -> [CGColor] {
    return [
      color.cgColor,
      color.cgColor,
      color.lighter(0.05).cgColor,
    ]
  }
  
  func apply(configuration new: TopicCellHeaderConfiguration) {
    guard currentConfiguration != new else { return }
    
    
    if !currentConfiguration.isNil, new.topicItem.description != currentConfiguration.topicItem.description,
       let constraint = topicDescription.getConstraint(identifier: "height")
    {
      constraint.constant = new.topicItem.description.height(withConstrainedWidth: topicDescription.bounds.width, font: topicDescription.font)
    }
    
    currentConfiguration = new
    
    let color = currentConfiguration.topicItem.topic.tagColor
    
    icon.category = currentConfiguration.topicItem.topic.iconCategory
    topicDescription.text = currentConfiguration.topicItem.description
    gradient.colors = CAGradientLayer.getGradientColors(color: color)
    setTitle()
  }
  
  @MainActor
  func setupUI() {
    addSubview(horizontalStack)
    
    horizontalStack.edgesToSuperview(insets: .init(top: padding, left: 0, bottom: padding, right: padding))
    icon.width(to: horizontalStack, multiplier: 0.15)
  }
  
  func setTitle() {
    let attrString = NSMutableAttributedString(string: currentConfiguration.topicItem.title.uppercased() + ": ", attributes: [
      .font: topicLabel.font as Any
    ])
    attrString.append(NSAttributedString(string: String(describing: currentConfiguration.topicItem.topic.activeCount), attributes: [
      .font: UIFont(name: Fonts.Rubik.Regular, size: 20) as Any
    ]))
    topicLabel.attributedText = attrString
  }
}
