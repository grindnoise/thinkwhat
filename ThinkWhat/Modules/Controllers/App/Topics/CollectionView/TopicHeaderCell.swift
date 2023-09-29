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
  public var item: TopicHeaderItem!
  public var callback: Closure?
  public var mode: TopicsCollectionView.Mode = .Default
  
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
    
    horizontalStack.edgesToSuperview(insets: .init(top: padding*2, left: 0, bottom: padding, right: padding))
    icon.width(to: horizontalStack, multiplier: 0.15)
  }
  
  private func setTitle() {
    let attrString = NSMutableAttributedString(string: currentConfiguration.topicItem.title.uppercased() + ": ", attributes: [
      .font: topicLabel.font as Any
    ])
    attrString.append(NSAttributedString(string: String(describing: currentConfiguration.topicItem.topic.activeCount), attributes: [
      .font: UIFont(name: Fonts.Rubik.Regular, size: 20) as Any
    ]))
    topicLabel.attributedText = attrString
  }
}

//class TopicCellHeaderContent: UIView, UIContentView {
//
//  // MARK: - Destructor
//  deinit {
//    tasks.forEach { $0?.cancel() }
//    subscriptions.forEach { $0.cancel() }
//    NotificationCenter.default.removeObserver(self)
//#if DEBUG
//    print("\(String(describing: type(of: self))).\(#function)")
//#endif
//  }
//
//  // MARK: - Public properties
//  var configuration: UIContentConfiguration {
//    get {
//      currentConfiguration
//    }
//    set {
//      guard let newConfiguration = newValue as? TopicCellHeaderConfiguration else {
//        return
//      }
//      apply(configuration: newConfiguration)
//    }
//  }
//
//
//
//  // MARK: - Private properties
//  private var subscriptions = Set<AnyCancellable>()
//  private var tasks: [Task<Void, Never>?] = []
//  //UI
//  private var currentConfiguration: TopicCellHeaderConfiguration!
//  private lazy var horizontalStack: UIStackView = {
//    let instance = UIStackView(arrangedSubviews: [
//      icon,
//      verticalStack,
//      viewsLabel
//    ])
//    instance.axis = .horizontal
//
//    instance.spacing = 6
//    return instance
//  }()
//  private lazy var verticalStack: UIStackView = {
//    let instance = UIStackView(arrangedSubviews: [titleView, topicDescription])
//    instance.axis = .vertical
//    //                instance.distribution = .fillEqually
//    instance.spacing = 0
//    return instance
//  }()
//  @MainActor private lazy var viewsLabel: UILabel = {
//    let instance = UILabel()
//    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
//    instance.textAlignment = .right
//    instance.textColor = .label
//    instance.alpha = 0
//
//    return instance
//  }()
//  //    private lazy var iconContainer: UIView = {
//  //        let instance = UIView()
//  //        instance.backgroundColor = .clear
//  //        instance.addSubview(icon)
//  //
//  //        icon.translatesAutoresizingMaskIntoConstraints = false
//  //
//  //        NSLayoutConstraint.activate([
//  //            icon.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
//  //            icon.topAnchor.constraint(equalTo: instance.topAnchor),
//  //            icon.heightAnchor.constraint(equalTo: instance.heightAnchor),
//  //            //            icon.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
//  //            icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1/1)
//  //        ])
//  //
//  //        return instance
//  //    }()
//  private lazy var icon: Icon = {
//    let instance = Icon()
//    instance.isRounded = false
//    instance.scaleMultiplicator = 1.65
//    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//    instance.iconColor = .white
//    instance.backgroundColor = .clear
//    instance.layer.addSublayer(iconGradient)
//
//    instance.publisher(for: \.bounds, options: .new)
//      .sink { rect in
//
//        instance.cornerRadius = rect.width/3.25
//
//        guard let layer = instance.layer.getSublayer(identifier: "radialGradient"),
//              layer.bounds != rect
//        else { return }
//
//        layer.frame = rect
//      }
//      .store(in: &subscriptions)
//
//    return instance
//  }()
//  private lazy var titleView: UIView = {
//    let instance = UIView()
//    instance.backgroundColor = .clear
//    instance.addSubview(topicTitle)
//    topicTitle.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      topicTitle.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
//      topicTitle.topAnchor.constraint(equalTo: instance.topAnchor),
//      topicTitle.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//    ])
//
//    return instance
//  }()
//  private lazy var topicLabel: UILabel = {
//    let instance = UILabel()
//    instance.textAlignment = .center
//    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title3)
//    instance.numberOfLines = 1
//    instance.textColor = .white
//    instance.translatesAutoresizingMaskIntoConstraints = false
//
//    let widthConstraint = instance.widthAnchor.constraint(equalToConstant: 50)
//    widthConstraint.identifier = "width"
//    widthConstraint.isActive = true
//
//    let heightConstraint = instance.heightAnchor.constraint(equalToConstant: 300)
//    heightConstraint.identifier = "height"
//    heightConstraint.isActive = true
//
//    return instance
//  }()
//  private lazy var topicTitle: UIView = {
//    let instance = UIView()
//    instance.backgroundColor = .clear
//    instance.layer.addSublayer(titleGradient)
//
//    topicLabel.place(inside: instance, insets: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
//
//    instance.publisher(for: \.bounds)
//      .filter { $0 != .zero }
//      .sink { rect in
//        instance.cornerRadius = rect.height/2.25
//
//        guard let layer = instance.layer.getSublayer(identifier: "radialGradient"),
//              layer.bounds != rect
//        else { return }
//
//        layer.frame = rect
//      }
//      .store(in: &subscriptions)
//
//    return instance
//  }()
//  private lazy var topicDescription: UILabel = {
//    let instance = UILabel()
//    instance.text = "There's gonna be a description of the topic"
//    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
//    instance.textAlignment = .left
//    instance.numberOfLines = 1
//    instance.lineBreakMode = .byTruncatingTail
//    instance.textColor = .label//traitCollection.userInterfaceStyle == .dark ? .darkGray : .label
//
//    return instance
//  }()
//  private lazy var iconGradient: CAGradientLayer = {
//    let instance = CAGradientLayer()
//    instance.type = .radial
//    instance.colors = getGradientColors(color: .systemGray)
//    instance.locations = [0, 0.5, 1.15]
//    instance.setIdentifier("radialGradient")
//    instance.startPoint = CGPoint(x: 0.5, y: 0.5)
//    instance.endPoint = CGPoint(x: 1, y: 1)
//    instance.publisher(for: \.bounds)
//      .filter { $0 != .zero }
//      .sink { instance.cornerRadius = $0.height/3.25 }
//      .store(in: &subscriptions)
//
//    return instance
//  }()
//  private lazy var titleGradient: CAGradientLayer = {
//    let instance = CAGradientLayer()
//    instance.type = .radial
//    instance.colors = getGradientColors(color: .systemGray)
//    instance.locations = [0, 0.5, 1.15]
//    instance.setIdentifier("radialGradient")
//    instance.startPoint = CGPoint(x: 0.5, y: 0.5)
//    instance.endPoint = CGPoint(x: 1, y: 1)
//    instance.publisher(for: \.bounds)
//      .filter { $0 != .zero }
//      .sink { rect in
//        instance.cornerRadius = rect.height/2.25
//      }
//      .store(in: &subscriptions)
//
//    return instance
//  }()
//  //    private let hotCountView: UIImageView = {
//  //        let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
//  //        instance.tintColor = .systemRed
//  //        instance.contentMode = .scaleAspectFit
//  //        instance.translatesAutoresizingMaskIntoConstraints = false
//  //        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
//  //        return instance
//  //    }()
//  //    private lazy var hotCountLabel: UILabel = {
//  //        let instance = UILabel()
//  //        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption1)
//  //        instance.textAlignment = .center
//  //        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//  //
//  //        return instance
//  //    }()
//  //    private lazy var viewsCountView: UIImageView = {
//  //        let instance = UIImageView(image: UIImage(systemName: "eye.fill"))
//  //        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//  //        instance.contentMode = .scaleAspectFit
//  //        instance.translatesAutoresizingMaskIntoConstraints = false
//  //        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
//  //        return instance
//  //    }()
//  //    private lazy var viewsCountLabel: UILabel = {
//  //        let instance = UILabel()
//  //        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption1)
//  //        instance.textAlignment = .center
//  //        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//  //
//  //        return instance
//  //    }()
//  //    private lazy var statsStack: UIStackView = {
//  //        let instance = UIStackView(arrangedSubviews: [viewsCountView, viewsCountLabel, hotCountView, hotCountLabel,])
//  //        instance.alignment = .center
//  //        instance.spacing = 2
//  //        return instance
//  //    }()
//  //    private lazy var statsView: UIView = {
//  //        let instance = UIView()
//  //        instance.backgroundColor = .clear
//  //        instance.translatesAutoresizingMaskIntoConstraints = false
//  //        instance.addSubview(statsStack)
//  //
//  //        statsStack.translatesAutoresizingMaskIntoConstraints = false
//  //
//  //        NSLayoutConstraint.activate([
//  //            statsStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
//  //            statsStack.topAnchor.constraint(equalTo: instance.topAnchor),
//  //            statsStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//  //        ])
//  //
//  //        return instance
//  //    }()
//  //    @MainActor private lazy var viewsLabel: UILabel = {
//  //        let instance = UILabel()
//  //        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .callout)
//  //        instance.textAlignment = .right
//  //        instance.textColor = .secondaryLabel
//  //
//  //        return instance
//  //    }()
//  private let padding: CGFloat = 10
//
//
//
//  // MARK: - Initalization
//  init(configuration: TopicCellHeaderConfiguration) {
//    super.init(frame: .zero)
//
//    setupUI()
//    apply(configuration: configuration)
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//
//
//  // MARK: - Overriden methods
//  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//    super.traitCollectionDidChange(previousTraitCollection)
//
//    //        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .systemGray : .label
//    //        viewsCountLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//    //        hotCountLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//    //        topicDescription.textColor = traitCollection.userInterfaceStyle == .dark ?  .label : .darkGray
//
//    //Set dynamic font size
//    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
//
//    topicLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .headline)
//    topicDescription.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
//    refreshConstraints()
//  }
//}
//
//// MARK: - Private
//private extension TopicCellHeaderContent {
//  func getGradientColors(color: UIColor) -> [CGColor] {
//    return [
//      color.cgColor,
//      color.cgColor,
//      color.lighter(0.05).cgColor,
//    ]
//  }
//
//  func apply(configuration: TopicCellHeaderConfiguration) {
//    guard currentConfiguration != configuration else { return }
//
//    currentConfiguration = configuration
//
//    let color = currentConfiguration.topicItem.topic.tagColor
//
//    //icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.topicItem.topic.tagColor
//    //        icon.backgroundColor = color
//    //        topicTitle.backgroundColor = color
//    icon.category = currentConfiguration.topicItem.topic.iconCategory
//    topicLabel.text = currentConfiguration.topicItem.title.uppercased()
//    topicDescription.text = currentConfiguration.topicItem.description
//    titleGradient.colors = getGradientColors(color: color)
//    iconGradient.colors = getGradientColors(color: color)
//    if currentConfiguration.mode == .Default {
//      viewsLabel.text = String(describing: currentConfiguration.topicItem.topic.activeCount.roundedWithAbbreviations)
//      viewsLabel.textColor = configuration.topicItem.topic.activeCount > 0 ? color : .secondaryLabel
//
//      currentConfiguration.topicItem.topic.activeCountPublisher
//        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] in self.viewsLabel.text = $0.roundedWithAbbreviations }
//        .store(in: &subscriptions)
//      viewsLabel.alpha = 1
//    }
//    //        viewsLabel.text = String(describing: currentConfiguration.topicItem.topic.active.roundedWithAbbreviations)
//
//    //        if currentConfiguration.topicItem.topic.hotTotal == 0 {
//    //            statsStack.removeArrangedSubview(hotCountView)
//    //            statsStack.removeArrangedSubview(hotCountLabel)
//    //            hotCountView.removeFromSuperview()
//    //            hotCountLabel.removeFromSuperview()
//    //        } else {
//    //            if !statsStack.arrangedSubviews.contains(hotCountView) { statsStack.addArrangedSubview(hotCountView) }
//    //            if !statsStack.arrangedSubviews.contains(hotCountLabel) { statsStack.addArrangedSubview(hotCountLabel) }
//    //        }
//    //        viewsCountLabel.text = String(describing: currentConfiguration.topicItem.topic.viewsTotal.roundedWithAbbreviations)
//    //        hotCountLabel.text = String(describing: currentConfiguration.topicItem.topic.hotTotal.roundedWithAbbreviations)
//
//    guard let constraint = topicLabel.getConstraint(identifier: "height") else { return }
//
//    let height = "test".height(withConstrainedWidth: 100, font: topicLabel.font)
//    constraint.constant = height// + 4
//    self.layoutIfNeeded()
//
//    refreshConstraints()
//  }
//
//  @MainActor
//  func setupUI() {
//    addSubview(horizontalStack)
//    horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//    icon.translatesAutoresizingMaskIntoConstraints = false
//
//    NSLayoutConstraint.activate([
//      horizontalStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: padding),
//      horizontalStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
//      icon.widthAnchor.constraint(equalTo: horizontalStack.widthAnchor, multiplier: 0.15),
//    ])
//
//    let constr = horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -padding)
//    constr.priority = .defaultHigh
//    constr.isActive = true
//
//    let constraint = topicDescription.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -padding)
//    constraint.priority = .defaultLow
//    constraint.isActive = true
//  }
//
//  @MainActor
//  func refreshConstraints() {
//    guard let constraint = topicLabel.getConstraint(identifier: "width") else { return }
//
//    //        topicTitle.insets = UIEdgeInsets(top: 0, left: topicTitle.bounds.height/3, bottom: 0, right: topicTitle.bounds.height/3)
//    let width = currentConfiguration.topicItem.topic.title.width(withConstrainedHeight: topicLabel.bounds.height, font: topicLabel.font)
//
//    self.setNeedsLayout()
//    constraint.constant = width + topicTitle.cornerRadius*2 //+ topicTitle.insets.left*2
//    self.layoutIfNeeded()
//    //        topicTitle.frame.origin = .zero
//
//    //        statsStack.translatesAutoresizingMaskIntoConstraints = false
//    //        guard let constraint_2 = statsStack.getConstraint(identifier: "height") else {
//    //            let constraint_2 = statsStack.heightAnchor.constraint(equalToConstant: "1".height(withConstrainedWidth: 50, font: viewsCountLabel.font))
//    //            constraint_2.identifier = "height"
//    //            constraint_2.isActive = true
//    //            return
//    //        }
//    //        constraint_2.constant = "1".height(withConstrainedWidth: 50, font: viewsCountLabel.font)
//
//    //        guard let constraint = topicTitle.getAllConstraints().filter({$0.identifier == "height"}).first,
//    //              let constraint_2 = descriptionLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
//    //              let constraint_3 = topicLabel.getAllConstraints().filter({ $0.identifier == "width"}).first
//    //        else { return }
//    //
//    //        let height = item.title.height(withConstrainedWidth: topicTitle.bounds.width, font: topicTitle.font)
//    //        let height_2 = item.truncatedDescription.height(withConstrainedWidth: descriptionLabel.bounds.width, font: descriptionLabel.font)
//    //        let width = item.topic.title.width(withConstrainedHeight: topicLabel.bounds.height, font: topicLabel.font)
//    ////        guard height != constraint.constant else { return }
//    //        setNeedsLayout()
//    //        constraint.constant = height + topicTitle.insets.top + topicTitle.insets.bottom
//    //        constraint_2.constant = height_2 + descriptionLabel.insets.top + descriptionLabel.insets.bottom
//    //        constraint_3.constant = width + topicLabel.insets.right*2.5 + topicLabel.insets.left*2.5
//    //        layoutIfNeeded()
//    //        topicStackView.updateConstraints()
//    //        topicLabel.frame.origin = .zero
//    //        avatar.imageView.image = UIImage(systemName: "face.smiling.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: avatar.bounds.size.height*0.5, weight: .regular, scale: .medium))
//  }
//}
//
//
