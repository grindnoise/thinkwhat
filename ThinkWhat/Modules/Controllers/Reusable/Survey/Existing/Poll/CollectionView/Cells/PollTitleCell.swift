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
      
      updateUI()
    }
  }
  //Publishers
  public var profileTapPublisher = PassthroughSubject<Bool, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
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
  private lazy var headerView: UIStackView = {
    let leftStack = UIStackView(arrangedSubviews: [
      dateLabel,
      statsStack,
    ])
    leftStack.axis = .vertical
    leftStack.alignment = .leading
    leftStack.spacing = 4
    leftStack.distribution = .fillEqually
    
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
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
    constraint.identifier = "height"
    constraint.isActive = true
    
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
    
    setupUI()
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
  }
}

// MARK: - Private
private extension PollTitleCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    
    let stackView = UIStackView(arrangedSubviews: [
      headerView,
      titleLabel
    ])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.place(inside: contentView,
                    insets: .uniform(size: 8),//UIEdgeInsets(top: padding, left: 0, bottom: 16, right: 0),
                    bottomPriority: .defaultLow)
  }
  
  @MainActor
  func updateUI() {
    dateLabel.text = item.startDate.timeAgoDisplay()
    titleLabel.text = item.title
    ratingLabel.text = String(describing: item.rating)
    viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
    usernameLabel.text = item.owner.isAnonymous ? "" : item.owner.firstNameSingleWord + (item.owner.lastNameSingleWord.isEmpty ? "" : "\n\(item.owner.lastNameSingleWord)")
    avatar.userprofile = item.owner.isAnonymous ? Userprofile.anonymous : item.owner
    
    guard let constraint = titleLabel.getConstraint(identifier: "height"),
          let windowScene = window?.windowScene
    else { return }
    
    setNeedsLayout()
    constraint.constant = item.title.height(withConstrainedWidth: windowScene.screen.bounds.width,
                                            font: titleLabel.font)
    layoutIfNeeded()
  }
}
