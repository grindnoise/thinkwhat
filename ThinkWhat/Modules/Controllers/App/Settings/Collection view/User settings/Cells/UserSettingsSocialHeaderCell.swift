//
//  UserSettingsSocialHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserSettingsSocialHeaderCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard let userprofile = userprofile else { return }
      
      collectionView.userprofile = userprofile
    }
  }
  ///`Publishers`
  public var openURLPublisher = PassthroughSubject<URL, Never>()
  public var facebookPublisher = PassthroughSubject<String, Never>()
  public var instagramPublisher = PassthroughSubject<String, Never>()
  public var tiktokPublisher = PassthroughSubject<String, Never>()
  public var googlePublisher = PassthroughSubject<String, Never>()
  public var twitterPublisher = PassthroughSubject<String, Never>()
  public let keyboardWillAppear = PassthroughSubject<Bool, Never>()
  @Published public private(set) var scrollPublisher: CGPoint?
  ///`UI`
  public var color: UIColor = .label {
    didSet {
      collectionView.color = color
    }
  }
  public var padding: CGFloat = 8 {
    didSet {
      updateUI()
    }
  }
  public var insets: UIEdgeInsets? {
    didSet {
      updateUI()
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`UI`
  private lazy var background: UIView = {
    let instance = UIView()
//    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.publisher(for: \.bounds, options: .new)
      .sink { rect in
        instance.cornerRadius = rect.width*0.05
      }
      .store(in: &subscriptions)
    stack.place(inside: instance,
                insets: .uniform(size: padding*2),
                bottomPriority: .defaultLow)
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let headerStack = UIStackView(arrangedSubviews: [
      headerImage,
      headerLabel,
      UIView.opaque(),
    ])
    headerStack.axis = .horizontal
    headerStack.spacing = padding/2
    
    let instance = UIStackView(arrangedSubviews: [
      headerStack,
      collectionView
    ])
    instance.axis = .vertical
    instance.spacing = 0
    
    return instance
  }()
  private lazy var headerImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "at"))
    instance.tintColor = Constants.UI.Colors.cellHeader
    instance.contentMode = .scaleAspectFit
//    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font)).isActive = true
    
    return instance
  }()
  private lazy var headerLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = Constants.UI.Colors.cellHeader
    instance.text = "social_media".localized.uppercased()
    instance.font = Fonts.cellHeader
    
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
  private lazy var collectionView: UserSettingsSocialCollectionView = {
    let instance = UserSettingsSocialCollectionView(color: color)
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
    instance.openURLPublisher
      .sink { [unowned self] in self.openURLPublisher.send($0) }
      .store(in: &subscriptions)
    instance.instagramPublisher
      .sink { [unowned self] in self.instagramPublisher.send($0) }
      .store(in: &subscriptions)
    instance.facebookPublisher
      .sink { [unowned self] in self.facebookPublisher.send($0) }
      .store(in: &subscriptions)
    instance.tiktokPublisher
      .sink { [unowned self] in self.tiktokPublisher.send($0) }
      .store(in: &subscriptions)
    instance.$scrollPublisher
      .eraseToAnyPublisher()
      .filter { !$0.isNil }
      .sink { [unowned self] _ in self.scrollPublisher = self.headerLabel.convert(self.headerLabel.frame.origin, to: self) }
      .store(in: &self.subscriptions)
    
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
    
    setupUI()
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
  
  //    override func prepareForReuse() {
  //        super.prepareForReuse()
  //
  //        urlPublisher = CurrentValueSubject<URL?, Never>(nil)
  //        subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
  //        imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  //    }
}

private extension UserSettingsSocialHeaderCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    
    background.place(inside: self,
                     insets: .init(top: padding*2, left: padding, bottom: padding*2, right: padding))
  }
  
  @MainActor
  func updateUI() {
    background.removeFromSuperview()

    guard let insets = insets else {
      background.place(inside: self,
                       insets: .uniform(size: padding))
      return
    }
    background.place(inside: self,
                     insets: insets)
  }
}



