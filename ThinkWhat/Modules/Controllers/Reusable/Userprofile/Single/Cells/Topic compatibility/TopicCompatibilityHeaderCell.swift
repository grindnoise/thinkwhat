//
//  DetailsCompatibilityHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

import UIKit
import Combine

class TopicCompatibilityHeaderCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public var compatibility: UserCompatibility! {
    didSet {
      guard let compatibility = compatibility else { return }
      
      collectionView.compatibility = compatibility
//      setupUI()
    }
  }
  //Publishers
  @Published public var fold = false {
    didSet {
//      guard let constraint = collectionView.getConstraint(identifier: "height") else { return }
      
//      isFolding = true
//      setNeedsLayout()
//      UIView.animate(withDuration: 0.2, animations:  { [weak self] in
//        guard let self = self else { return }
//
//        constraint.constant = 0
//        self.layoutIfNeeded()
//      })
    }
  }
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
  private var isFolding = false
  private let padding: CGFloat = 16
  private lazy var collectionView: TopicCompatibilityCollectionView = {
    let instance = TopicCompatibilityCollectionView()
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemFill : .secondarySystemBackground
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.05 }
      .store(in: &subscriptions)

    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.identifier = "height"
    constraint.isActive = true
  
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero && abs(constraint.constant) != abs($0.height) }
      .sink { [weak self] in
        guard let self = self,
              !self.isFolding
        else { return }
        
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
}

private extension TopicCompatibilityHeaderCell {
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



