//
//  PollTitleCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class PollTitleCell: UICollectionViewCell {
  
  // MARK: - Public properties
  public weak var item: Survey! {
    didSet {
      guard let item = item else { return }
      
      item.reference.viewsPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.viewsLabel.text = $0.roundedWithAbbreviations
        }
        .store(in: &subscriptions)
      
      item.reference.ratingPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.ratingLabel.text = String(describing: $0)
        }
        .store(in: &subscriptions)
      
      
//      titleInsets = .init(top: 0,
//                          left: mode == .Default ? padding : 0,
//                          bottom: 0,
//                          right: mode == .Default ? padding : 0)
      setupUI()
    }
  }
  public var mode: PollCollectionView.Mode = .Default {
    didSet {
//      guard let leftStack = headerStack.getSubview(type: UIStackView.self, identifier: "leftStack") else { return }
//
//      leftStack.alpha = mode == .Default ? 1 : 0
//
//      if mode == .Preview || mode == .Transition {
//        leftStack.transform = .init(scaleX: 0.75, y: 0.75)
//        topicView.placeTopLeading(inside: headerStack)
//        topicView.alpha = 1
//      }
    }
  }
  ///**Publishers**
  public var profileTapPublisher = PassthroughSubject<Bool, Never>()
  ///**UI**
  public var titleInsets: UIEdgeInsets = .zero
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var topicView: UIStackView = {
    let topicTitle = InsetLabel()
    topicTitle.font = UIFont(name: Fonts.Bold, size: 14)
    topicTitle.text = item.topic.title.uppercased()
    topicTitle.textColor = .white
    topicTitle.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    let topicIcon = Icon(category: item.topic.iconCategory)
    topicIcon.iconColor = .white
    topicIcon.isRounded = false
    topicIcon.clipsToBounds = false
    topicIcon.scaleMultiplicator = 1.65
    topicIcon.heightAnchor.constraint(equalTo: topicIcon.widthAnchor, multiplier: 1/1).isActive = true
    
    let instance = UIStackView(arrangedSubviews: [
      topicIcon,
      topicTitle
    ])
    instance.backgroundColor = item.topic.tagColor
    instance.axis = .horizontal
    instance.spacing = 2
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 100, font: topicTitle.font)).isActive = true
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var avatar: Avatar = {
    let instance = Avatar(isShadowed: true)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.isUserInteractionEnabled = true
    instance.tapPublisher
      .filter { $0 != Userprofile.anonymous && $0 != Userprofiles.shared.current }
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.profileTapPublisher.send(true)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var headerStack: UIStackView = {
    let leftStack = UIStackView(arrangedSubviews: [
      dateLabel,
      statsStack,
    ])
    leftStack.accessibilityIdentifier = "leftStack"
    leftStack.axis = .vertical
    leftStack.alignment = .leading
    leftStack.spacing = 4
    leftStack.distribution = .fillEqually
    leftStack.clipsToBounds = false
    
    let spacer = UIView()
    spacer.backgroundColor = .clear
    let instance = UIStackView(arrangedSubviews: [
      leftStack,
      spacer,
      usernameLabel,
      avatar
    ])
    instance.axis = .horizontal
    instance.spacing = 4
    
    return instance
  }()
  private lazy var dateLabel: InsetLabel = {
    let instance = InsetLabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    instance.textAlignment = .left
    instance.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: 100,
                                                                    font: instance.font)).isActive = true
#if DEBUG
    instance.text = "01.02.2013"
#endif
    
    return instance
  }()
  private lazy var usernameLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                      forTextStyle: .footnote)
    instance.textAlignment = .right
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.numberOfLines = 2
#if DEBUG
    instance.text = "01.02.2013"
#endif
    
    return instance
  }()
  private lazy var statsStack: UIStackView = {
    let ratingStack = UIStackView(arrangedSubviews: [ratingImage, ratingLabel])
    ratingStack.spacing = 2
    
    let viewsStack = UIStackView(arrangedSubviews: [viewsImage, viewsLabel])
    viewsStack.spacing = 2
    
    let instance = UIStackView(arrangedSubviews: [ratingStack, viewsStack])
    instance.spacing = 6
    instance.alignment = .leading
    
    return instance
  }()
  private lazy var ratingImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "star.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                                             scale: .medium)))
    instance.tintColor = Colors.Logo.Marigold.rawValue
    instance.contentMode = .center
    return instance
  }()
  private lazy var ratingLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    instance.textAlignment = .center
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] rect in
        guard let self = self,
              let text = instance.text,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = text.height(withConstrainedWidth: rect.width, font: instance.font) * 1.5
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var viewsImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "eye.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                                             scale: .medium)))
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.contentMode = .center
    return instance
  }()
  private lazy var viewsLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    instance.textAlignment = .center
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      comleteButton,
      watchButton,
    ])
    instance.spacing = 8
    instance.alignment = .center
    
    return instance
  }()
  private lazy var comleteButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "checkmark.seal.fill",
                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                             scale: .large)),
                      for: .normal)
    instance.tintColor = .systemGray4
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    //        instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
    
    return instance
  }()
  private lazy var watchButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "binoculars.fill",
                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                             scale: .large)),
                      for: .normal)
    instance.tintColor = .systemGray4
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    //        instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
    
    return instance
  }()
  private lazy var titleLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .center
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .largeTitle)
    instance.numberOfLines = 0
    
//    let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
//    constraint.identifier = "height"
//    constraint.isActive = true
    
    return instance
  }()
//  private lazy var stackView: UIStackView = {
//    let opaque = UIView.opaque()
//    titleLabel.place(inside: opaque,
//                     insets: titleInsets,
//                     bottomPriority: .defaultLow)
//
//    let instance = UIStackView(arrangedSubviews: [
//      headerStack,
//      opaque//titleLabel
//    ])
//    instance.axis = .vertical
//    instance.spacing = padding*3
//
//    return instance
//  }()
  
  
  
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
    
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    //        viewsLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    //        ratingLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    //        viewsView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    //
    //        //Set dynamic font size
    //        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    //
    //        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
    //                                            forTextStyle: .largeTitle)
    //        ratingLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
    //                                             forTextStyle: .caption2)
    //        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
    //                                            forTextStyle: .caption2)
    //        guard let constraint_1 = titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
    //              let constraint_2 = bottomView.getAllConstraints().filter({$0.identifier == "height"}).first,
    //              let item = item else { return }
    //        setNeedsLayout()
    //        constraint_1.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width,
    //                                                  font: titleLabel.font)
    //        constraint_2.constant = String(describing: item.rating).height(withConstrainedWidth: ratingLabel.bounds.width,
    //                                                                       font: ratingLabel.font)
    //        layoutIfNeeded()
    
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    profileTapPublisher = PassthroughSubject<Bool, Never>()
    avatar.clearImage()
  }
  
  
  
  // MARK: - Public methods
  public func onModeChanged(mode: PollCollectionView.Mode,
                            duration: TimeInterval = 0.2) {
    
    guard let leftStack = headerStack.getSubview(type: UIStackView.self, identifier: "leftStack") else { return }
    
    leftStack.alpha = 0
    leftStack.transform = .init(scaleX: 0.75, y: 0.75)
    topicView.placeTopLeading(inside: headerStack)
    topicView.alpha = 1
    
    UIView.animate(withDuration: duration,
                   delay: 0,
                   options: .curveEaseInOut) { [weak self] in
      guard let self = self else { return }
      
      self.topicView.alpha = 0
      self.topicView.transform = .init(scaleX: 0.75, y: 0.75)
      leftStack.alpha = 1
      leftStack.transform = .identity
    } completion: { _ in }
//    UIView.animate(withDuration: duration,
//                   delay: 0,
//                   options: .curveEaseInOut) { [weak self] in
//      guard let self = self else { return }
//
//      self.topicView.alpha = mode == .Preview ? 1 : 0
//      self.topicView.transform = mode == .Default ? .init(scaleX: 0.75, y: 0.75) : .identity
//      leftStack.alpha = mode == .Default ? 1 : 0
//      leftStack.transform = mode == .Preview ? .init(scaleX: 0.75, y: 0.75) : .identity
//    } completion: { [weak self] _ in
//      guard let self = self else { return }
//
//      self.mode = mode
//    }
  }
}

// MARK: - Private
private extension PollTitleCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    
//    stackView.place(inside: contentView,
//                    insets: UIEdgeInsets(top: padding*2, left: padding, bottom: padding*3, right: padding),
//                    bottomPriority: .defaultLow)
    
    contentView.addSubview(headerStack)
    contentView.addSubview(titleLabel)
    headerStack.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      headerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding*2),
      headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      titleLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: padding*2),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*2),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding*2),
    ])
    
    let constraint = titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding*2)
    constraint.priority = .defaultLow
    constraint.isActive = true
    
    dateLabel.text = item.startDate.timeAgoDisplay()
    titleLabel.text = item.title
    ratingLabel.text = String(describing: item.rating)
    viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
    usernameLabel.text = item.isAnonymous ? "" : item.owner.firstNameSingleWord + (item.owner.lastNameSingleWord.isEmpty ? "" : "\n\(item.owner.lastNameSingleWord)")
    avatar.userprofile = item.isAnonymous ? Userprofile.anonymous : item.owner
    
    guard let leftStack = headerStack.getSubview(type: UIStackView.self, identifier: "leftStack") else { return }
    
    leftStack.alpha = mode == .Default ? 1 : 0
    
    if mode == .Preview || mode == .Transition {
      leftStack.transform = .init(scaleX: 0.75, y: 0.75)
      topicView.placeTopLeading(inside: headerStack)
      topicView.alpha = 1
    }

//    guard let constraint = titleLabel.getConstraint(identifier: "height") else { return }
//
//    setNeedsLayout()
//    constraint.constant = item.title.height(withConstrainedWidth: bounds.width,
//                                            font: titleLabel.font)
//    layoutIfNeeded()
  }
}
