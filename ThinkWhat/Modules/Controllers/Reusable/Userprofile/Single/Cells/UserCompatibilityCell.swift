//
//  UserCompatibilityCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserCompatibilityCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard let userprofile = userprofile else { return }
      
      collectionView.userprofile = userprofile
//      setupUI()
    }
  }
  //Publishers
  public let refreshPublisher = PassthroughSubject<Bool, Never>()
  public let disclosurePublisher = PassthroughSubject<TopicCompatibility, Never>()
  //UI
  public var color: UIColor = .clear {
    didSet {
      collectionView.color = color
    }
  }
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private var wasUnfolded = false
  private var minHeight: CGFloat = .zero
  private var maxHeight: CGFloat = .zero
  private let padding: CGFloat = 16
  private lazy var collectionView: UserCompatibilityCollectionView = {
    let instance = UserCompatibilityCollectionView()
    instance.clipsToBounds = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.05 }
      .store(in: &subscriptions)

    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.identifier = "height"
    constraint.isActive = true
    
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero && abs(constraint.constant) != abs($0.height) && $0.height != 44 }
      .sink { [weak self] in
        guard let self = self,
              !self.wasUnfolded
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = $0.height
        self.layoutIfNeeded()
        
        guard instance.numberOfItems(inSection: 1) == 0 else {
          self.maxHeight = max(self.maxHeight, $0.height)
          return
        }
        self.minHeight = $0.height
      }
      .store(in: &subscriptions)
    
    instance.refreshPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.refreshPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.foldPublisher
      .sink { [weak self] shouldFold in
        guard let self = self else { return }
        
          self.wasUnfolded = true
          self.setNeedsLayout()
          UIView.animate(withDuration: 0.3) {
            constraint.constant = shouldFold ? self.minHeight : self.maxHeight
            self.layoutIfNeeded()
          }
      }
      .store(in: &subscriptions)
    
    instance.disclosurePublisher
      .sink { [unowned self] in  self.disclosurePublisher.send($0) }
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
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    collectionView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
  }
}

private extension UserCompatibilityCell {
  @MainActor
  func setupUI() {
    collectionView.place(inside: self,
                         insets: UIEdgeInsets(top: padding, left: padding, bottom: 0, right: padding),
                         bottomPriority: .defaultLow)
  }
  
  @objc
  func hintTapped() {
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                          icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: color),
                                                          text: "userprofile_contrib_hint",
                                                          tintColor: .clear,
                                                          fontName: Fonts.Regular,
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



