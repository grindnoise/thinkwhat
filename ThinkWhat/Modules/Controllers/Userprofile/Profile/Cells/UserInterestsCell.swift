//
//  UserInterestsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.11.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserInterestsCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard let userprofile = userprofile else { return }
      
      setupUI()
      collectionView.userprofile = userprofile
    }
  }
  ///`Publishers`
  public var topicPublisher = PassthroughSubject<Topic, Never>()
  ///`UI`
  public var color: UIColor = .clear
  public var padding: CGFloat = 16 //{
//    didSet {
//      updateUI()
//    }
//  }
  public var insets: UIEdgeInsets? //{
//    didSet {
//      updateUI()
//    }
//  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private lazy var hintButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "questionmark",
                              withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                      for: .normal)
    instance.alpha = 0
    instance.tintColor = .secondaryLabel
    instance.addTarget(self, action: #selector(self.hintTapped), for: .touchUpInside)
//    instance.heightAnchor.constraint(equalTo: instance., multiplier: <#T##CGFloat#>)
    
    return instance
  }()
//  private lazy var background: UIView = {
//    let instance = UIView()
//    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    instance.publisher(for: \.bounds, options: .new)
//      .sink { rect in
//        instance.cornerRadius = rect.width*0.05
//      }
//      .store(in: &subscriptions)
//    stack.place(inside: instance,
//                insets: .uniform(size: padding),
//                bottomPriority: .defaultLow)
//
//    return instance
//  }()
  private lazy var stack: UIStackView = {
    
    
    let stack = UIStackView(arrangedSubviews: [
      headerImage,
      headerLabel,
      UIView.opaque(),
//      hintButton
    ])
    stack.axis = .horizontal
    stack.spacing = padding / 2
    
    let instance = UIStackView(arrangedSubviews: [
      stack,
      collectionView
    ])
    instance.axis = .vertical
    instance.spacing = padding
    
    return instance
  }()
  private lazy var headerImage: Icon = {
    let width = "T".height(withConstrainedWidth: 100, font: headerLabel.font)
    let instance = Icon(frame: CGRect(origin: .zero, size: .uniform(size: width)), category: .Logo, scaleMultiplicator: 1, iconColor: .secondaryLabel)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    
    return instance
  }()
  private lazy var headerLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.text = "userprofile_community_contribution".localized.uppercased()
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Medium, forTextStyle: .footnote)
    
    let heightConstraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
    heightConstraint.identifier = "height"
    heightConstraint.priority = .defaultHigh
    heightConstraint.isActive = true
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard let self = self,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var collectionView: InterestsCollectionView = {
    let instance = InterestsCollectionView()
    instance.backgroundColor = .clear
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.priority = .defaultHigh
    constraint.identifier = "height"
    constraint.isActive = true
    
    instance.publisher(for: \.contentSize, options: .new)
      .sink { [weak self] rect in
        guard let self = self,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = rect.height
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    instance.interestPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.topicPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
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
    
//    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    topicPublisher = PassthroughSubject<Topic, Never>()
    //        urlPublisher = CurrentValueSubject<URL?, Never>(nil)
    //        subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
    //        imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  }
}

private extension UserInterestsCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    
    stack.place(inside: self,
                insets: insets ?? .uniform(size: padding),//UIEdgeInsets(top: padding, left: padding, bottom: 0, right: padding))
                bottomPriority: .defaultLow)
  }
  
  @MainActor
  func updateUI() {
//    background.removeFromSuperview()
//
//    guard let insets = insets else {
//      background.place(inside: self,
//                       insets: .uniform(size: padding))
//      return
//    }
//    background.place(inside: self,
//                     insets: insets)
  }
  
  @objc
  func hintTapped() {
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                          icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: color),
                                                          text: "userprofile_contrib_hint",
                                                          tintColor: .clear,
                                                          fontName: Fonts.Rubik.Regular,
                                                          textStyle: .headline,
                                                          textAlignment: .natural),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: false,
                           useContentViewHeight: true,
                           shouldDismissAfter: 2)
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &self.subscriptions)
  }
}

