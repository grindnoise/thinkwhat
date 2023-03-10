//
//  UserSettingsInfoCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserSettingsInfoCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  ///`UI`
  public private(set) var padding: CGFloat = 16
  public private(set) var insets: UIEdgeInsets = .zero
  public var color: UIColor = Colors.System.Red.rawValue {
    didSet {
      collectionView.color = color
    }
  }
  ///`Publishers`
  @Published public private(set) var userprofileDescription: String?
  @Published public private(set) var scrollPublisher: CGPoint?
  public private(set) var cityFetchPublisher = PassthroughSubject<String, Never>()
  public private(set) var citySelectionPublisher = PassthroughSubject<City, Never>()
  public private(set) var topicPublisher = PassthroughSubject<Topic, Never>()
  public private(set) var openURLPublisher = PassthroughSubject<URL, Never>()
  public private(set) var facebookPublisher = PassthroughSubject<String, Never>()
  public private(set) var instagramPublisher = PassthroughSubject<String, Never>()
  public private(set) var tiktokPublisher = PassthroughSubject<String, Never>()
  public private(set) var googlePublisher = PassthroughSubject<String, Never>()
  public private(set) var twitterPublisher = PassthroughSubject<String, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`UI`
  private lazy var collectionView: UserSettingsInfoCollectionView = {
    let instance = UserSettingsInfoCollectionView()
    instance.clipsToBounds = true
    instance.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .secondarySystemBackground : .tertiarySystemBackground
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.05 }
      .store(in: &subscriptions)
    
    instance.$userprofileDescription
      .filter { !$0.isNil }
      .sink { [unowned self] in userprofileDescription = $0! }
      .store(in: &subscriptions)
    instance.cityFetchPublisher
      .filter { !$0.isNil }
      .sink { [unowned self] in self.cityFetchPublisher.send($0!) }
      .store(in: &self.subscriptions)
    instance.citySelectionPublisher
      .sink { [unowned self] in self.citySelectionPublisher.send($0) }
      .store(in: &self.subscriptions)
    instance.facebookPublisher
      .sink { [unowned self] in self.facebookPublisher.send($0) }
      .store(in: &self.subscriptions)
    instance.instagramPublisher
      .sink { [unowned self] in self.instagramPublisher.send($0) }
      .store(in: &self.subscriptions)
    instance.tiktokPublisher
      .sink { [unowned self] in self.tiktokPublisher.send($0) }
      .store(in: &self.subscriptions)
    instance.openURLPublisher
      .sink { [unowned self] in self.openURLPublisher.send($0) }
      .store(in: &self.subscriptions)
    instance.$scrollPublisher
      .eraseToAnyPublisher()
      .filter { !$0.isNil }
      .sink { [unowned self] in self.scrollPublisher = $0 }
      .store(in: &self.subscriptions)
    instance.topicPublisher
      .sink { [unowned self] in self.topicPublisher.send($0) }
      .store(in: &self.subscriptions)
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.identifier = "height"
    constraint.isActive = true
    
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero && abs(constraint.constant) != $0.height }
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        constraint.constant = $0.height
        self.layoutIfNeeded()
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
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    collectionView.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .secondarySystemBackground : .tertiarySystemBackground
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
  }
  
    override func prepareForReuse() {
      super.prepareForReuse()
  
      citySelectionPublisher = PassthroughSubject<City, Never>()
      cityFetchPublisher = PassthroughSubject<String, Never>()
      topicPublisher = PassthroughSubject<Topic, Never>()
      openURLPublisher = PassthroughSubject<URL, Never>()
      facebookPublisher = PassthroughSubject<String, Never>()
      instagramPublisher = PassthroughSubject<String, Never>()
      tiktokPublisher = PassthroughSubject<String, Never>()
      googlePublisher = PassthroughSubject<String, Never>()
      twitterPublisher = PassthroughSubject<String, Never>()
//            urlPublisher = CurrentValueSubject<URL?, Never>(nil)
//            subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
//            imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
    }
  
  
  
  // MARK: - Public methods
  public func setInsets(_ insets: UIEdgeInsets) {
    self.insets = insets
    
    setupUI()
  }
  
  public func setPadding(_ padding: CGFloat) {
    self.insets = .zero
    self.padding = padding
    
    setupUI()
  }
}

private extension UserSettingsInfoCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    
    collectionView.removeFromSuperview()
    collectionView.place(inside: self,
                         insets: insets == .zero ? .uniform(size: padding) : insets,
                         bottomPriority: .defaultLow)
  }
}

