//
//  CurrentUserAccountCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AccountManagementHeaderCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard !userprofile.isNil else { return }
      
      //            setText()
      //            setColors()
    }
  }
  public private(set) var actionPublisher = PassthroughSubject<AccountManagementCell.Mode, Never>()
  ///`UI`
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
  @Published public var color: UIColor?
  
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
    let headerStack = UIStackView(arrangedSubviews: [
      headerImage,
      headerLabel,
      UIView.opaque(),
//      hintButton
    ])
    headerStack.axis = .horizontal
      headerStack.spacing = padding/2
    
    let instance = UIStackView(arrangedSubviews: [
      headerStack,
      collectionView
    ])
    instance.axis = .vertical
    instance.spacing = 8
    
    return instance
  }()
  private lazy var headerImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "gearshape.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(scale: .medium)))
    instance.tintColor = Constants.UI.Colors.cellHeader
    instance.contentMode = .scaleAspectFit
//    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font)).isActive = true
    
    return instance
  }()
  private lazy var headerLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = Constants.UI.Colors.cellHeader
    instance.text = "account_management".localized.uppercased()
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
  private lazy var collectionView: AccountManagementCollectionView = {
    let instance = AccountManagementCollectionView()
    instance.backgroundColor = .clear
    
    instance.actionPublisher
      .sink { [unowned self] in self.actionPublisher.send($0)}
      .store(in: &subscriptions)
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 50)
    constraint.priority = .defaultHigh
    constraint.identifier = "height"
    constraint.isActive = true
    
    observers.append(instance.observe(\.contentSize, options: .new) {[weak self] view, change in
      guard let self = self,
            let height = change.newValue?.height,
            let constraint = instance.getConstraint(identifier: "height")
      else { return }
      
      self.setNeedsLayout()
      constraint.constant = height
      self.layoutIfNeeded()
    })
    
    $color
      .sink { instance.color = $0 }
      .store(in: &self.subscriptions)
    
//    instance.publisher(for: \.contentSize, options: .new)
//      .sink { [weak self] rect in
//        guard let self = self,
//              let constraint = instance.getConstraint(identifier: "height")
//        else { return }
//
//        self.setNeedsLayout()
//        constraint.constant = rect.height
//        self.layoutIfNeeded()
//      }
//      .store(in: &subscriptions)
    
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
    
    //        setTasks()
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
  }
}

private extension AccountManagementHeaderCell {
  
  func setTasks() {
    
  }
  
  @MainActor
  func setupUI() {
    background.place(inside: self,
                     insets: .uniform(size: padding))
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

