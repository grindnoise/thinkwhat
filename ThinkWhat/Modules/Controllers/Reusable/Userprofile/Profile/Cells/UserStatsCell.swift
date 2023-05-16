//
//  UserStatsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserStatsCell: UICollectionViewListCell {
  
  enum Mode {
    case Userprofile, Settings
  }
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard let userprofile = userprofile else { return }
      
      collectionView.userprofile = userprofile
    }
  }
  ///`Publishers`
  public var publicationsPublisher = PassthroughSubject<Userprofile, Never>()
  public let commentsPublisher = PassthroughSubject<Userprofile, Never>()
  public let subscribersPublisher = PassthroughSubject<Userprofile, Never>()
  ///`Logic`
  public var mode: Mode = .Userprofile {
    didSet {
      collectionView.mode = mode
    }
  }
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
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
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
    let instance = UIStackView(arrangedSubviews: [
      label,
      collectionView
    ])
    instance.axis = .vertical
    instance.spacing = 8
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.text = "stats".localized.uppercased()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    
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
  private lazy var collectionView: UserStatsCollectionView = {
    let instance = UserStatsCollectionView(color: color)
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
    
    instance.subscribersPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.subscribersPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.commentsPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.commentsPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.publicationsPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.publicationsPublisher.send($0)
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
    
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    publicationsPublisher = PassthroughSubject<Userprofile, Never>()
  //        urlPublisher = CurrentValueSubject<URL?, Never>(nil)
  //        subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
  //        imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
      }
}

private extension UserStatsCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    
    background.place(inside: self,
                     insets: UIEdgeInsets(top: padding*2, left: padding, bottom: padding*2, right: padding))
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


