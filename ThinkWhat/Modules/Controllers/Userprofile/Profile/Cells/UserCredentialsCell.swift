//
//  UserCredentialsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserCredentialsCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard !userprofile.isNil else { return }
      
      setupUI()
      setTasks()
    }
  }
  //Publishers
  public var urlPublisher = CurrentValueSubject<URL?, Never>(nil)
  public var subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public var imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  //UI
  public var color: UIColor = .gray
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding : CGFloat = 8
  private lazy var avatar: Avatar = {
    let instance = Avatar(userprofile: userprofile, isShadowed: traitCollection.userInterfaceStyle != .dark)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.tapPublisher
      .sink { [unowned self] _ in self.imagePublisher.send(instance.image) }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var usernameLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .left
    instance.numberOfLines = 3
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = padding

    let attrStr = NSMutableAttributedString(string: "\(userprofile.username)\n", attributes: [
      .font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .title2) as Any,
      .paragraphStyle: paragraphStyle
    ])
    if !userprofile.fullName.isEmpty {
      attrStr.append(NSAttributedString(string: "\(userprofile.fullName) (\(userprofile.gender.rawValue.localized.lowercased()), \(userprofile.age))", attributes: [
        .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .subheadline) as Any,
        .foregroundColor: UIColor.secondaryLabel
      ]))
    }
//    attrStr.append(NSAttributedString(string: "\n\(userprofile.gender.rawValue.localized), \(userprofile.age)", attributes: [
//      .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote) as Any,
//      .foregroundColor: UIColor.tertiaryLabel
//    ]))
    instance.attributedText = attrStr
    
    return instance
  }()
  private lazy var subscriptionButton: UIView = {
    let shadowView = UIView.opaque()
    shadowView.layer.masksToBounds = false
    shadowView.accessibilityIdentifier = "subscriptionButton"
    shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    shadowView.layer.shadowOffset = .zero
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    shadowView.publisher(for: \.bounds)
      .sink {
        shadowView.layer.shadowRadius = $0.height/8
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2.25).cgPath
      }
      .store(in: &subscriptions)
    let button = UIButton()
    button.setAttributedTitle(NSAttributedString(string: "unsubscribe".localized.uppercased(),
                                                 attributes: [
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                  .foregroundColor: UIColor.systemRed as Any
                                                 ]),
                              for: .normal)
    button.accessibilityIdentifier = "subscriptionButton"
    button.contentEdgeInsets = UIEdgeInsets(top: padding/1.5, left: padding, bottom: padding/1.5, right: padding)
    button.imageEdgeInsets.left = padding/2
    button.adjustsImageWhenHighlighted = false
    button.semanticContentAttribute = .forceRightToLeft
    button.setImage(UIImage(systemName: ("xmark"), withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
    button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemFill : .systemBackground
    button.tintColor = .systemRed
    button.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    button.publisher(for: \.bounds)
      .sink { button.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    button.place(inside: shadowView)
    
    return shadowView
  }()
  private lazy var stack: UIStackView = {
    let nested = UIStackView(arrangedSubviews: [
      usernameLabel,
      UIView.opaque(),
      subscriptionButton,
    ])
    nested.alignment = .leading
    nested.axis = .vertical
    nested.spacing = padding
    nested.accessibilityIdentifier = "nested"
    
    let opaque = UIView.opaque()
    opaque.addSubview(avatar)
    
    let instance = UIStackView(arrangedSubviews: [
      avatar,
      nested,
    ])
    instance.layer.masksToBounds = false
    instance.axis = .horizontal
    instance.spacing = padding*2
    instance.alignment = .center
    
    avatar.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.35).isActive = true
    
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
    
    avatar.isShadowed = traitCollection.userInterfaceStyle != .dark
    subscriptionButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    subscriptionButton.getSubview(type: UIButton.self)?.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .white
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    urlPublisher = CurrentValueSubject<URL?, Never>(nil)
    subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
    imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  }
}

private extension UserCredentialsCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
  
    stack.place(inside: contentView,
                insets: .init(top: padding*2, left: padding*2, bottom: padding, right: padding*2),
                bottomPriority: .defaultLow)
  }
  
  @MainActor
  func setTasks() {
    ///**Subscription events**
    ///Subscribed at added
    userprofile.subscriptionFlagPublisher
      .receive(on: DispatchQueue.main )
      .sink { [unowned self] _ in self.toggleSubscription() }
      .store(in: &subscriptions)
    
    
    
    
//    tasks.append(Task {@MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsAppend) {
//        guard let self = self,
//              let dict = notification.object as? [Userprofile: Userprofile],
//              let userprofile = dict.values.first,
//              self.userprofile == userprofile
//        else { return }
//
//        self.toggleSubscription()
//      }
//    })
//
//    //Subscribed at removed
//    tasks.append(Task {@MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
//        guard let self = self,
//              let dict = notification.object as? [Userprofile: Userprofile],
//              let userprofile = dict.values.first,
//              self.userprofile == userprofile
//        else { return }
//
//        self.toggleSubscription()
//      }
//    })
    
    //Subscription api error
    tasks.append(Task {@MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionOperationFailure) {
        guard let self = self else { return }
        
        self.toggleSubscription()
      }
    })
  }
  
  @MainActor
  func toggleSubscription() {
    subscriptionButton.isUserInteractionEnabled = true
    subscriptionButton.setSpinning(on: false) { [weak self] in
      guard let self = self,
            let button = subscriptionButton.getSubview(type: UIButton.self)
      else { return }
      
      button.setAttributedTitle(NSAttributedString(string: "unsubscribe".localized.uppercased(),
                                                   attributes: [
                                                    .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                    .foregroundColor: UIColor.systemRed as Any
                                                   ]),
                                for: .normal)
      button.imageView?.tintColor = .systemRed
    }
  }
  
  @objc
  func handleTap() {
    subscriptionButton.isUserInteractionEnabled = false
    subscriptionPublisher.send(!userprofile.subscribedAt)
    
    subscriptionButton.isUserInteractionEnabled = false
    subscriptionButton.setSpinning(on: true, color: .systemRed) { [weak self] in
      guard let self = self,
            let button = self.subscriptionButton.getSubview(type: UIButton.self)
      else { return }
      
      button.imageView?.tintColor = .clear
      button.setAttributedTitle(NSAttributedString(string: "unsubscribe".localized.uppercased(),
                                                   attributes: [
                                                    .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                    .foregroundColor: UIColor.clear as Any
                                                   ]),
                                for: .normal)
    }
  }
  
  @objc
  func urlTapped(recognizer: UITapGestureRecognizer) {
    guard let sender = recognizer.view else { return }
    
    if sender is FacebookLogo, let url = userprofile.facebookURL {
      urlPublisher.send(url)
    } else if sender is InstagramLogo, let url = userprofile.instagramURL {
      urlPublisher.send(url)
    } else if sender is TikTokLogo, let url = userprofile.tiktokURL {
      urlPublisher.send(url)
    }
  }
}
