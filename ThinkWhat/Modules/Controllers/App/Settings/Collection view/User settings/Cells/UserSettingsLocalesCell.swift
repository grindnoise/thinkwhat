//
//  UserSettingsLocalesCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.10.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class UserSettingsLocalesCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public var locales: [LanguageItem]! {
    didSet {
      guard !locales.isNil else { return }
      
      setupUI()
    }
  }
  public var insets: UIEdgeInsets = .uniform(Constants.UI.padding)
  public var requestBoundsPublisher = PassthroughSubject<Void, Never>()
  public var selectionPublisher = PassthroughSubject<Void, Never>()
  public var boundsPublisher = PassthroughSubject<Bool, Never>() // Bool - animated flag
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = Constants.UI.Colors.cellHeader
    instance.text = "content_language".localized.uppercased() + " (\(locales.filter({ $0.selected }).count))"
    instance.font = Fonts.cellHeader
    instance.height(instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
    
    return instance
  }()
  private lazy var header: UIStackView = {
    // Header stack
    let image: UIImageView = {
      let instance = UIImageView(image: UIImage(systemName: "globe", withConfiguration: UIImage.SymbolConfiguration(scale: .small)))
      instance.tintColor = Constants.UI.Colors.cellHeader
      instance.contentMode = .center
      instance.height("T".height(withConstrainedWidth: 100, font: label.font))
      
      return instance
    }()
    let instance = UIStackView(arrangedSubviews: [
      image,
      label,
      UIView.opaque(),
    ])
    instance.axis = .horizontal
    instance.spacing = Constants.UI.padding/2
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    // Main stack
    let instance = UIStackView(arrangedSubviews: [
      header,
      dataView
    ])
    instance.axis = .vertical
    instance.spacing = Constants.UI.padding
    
//    let constraint = instance.height(100)
//    constraint.identifier = "height"
    
    return instance
  }()
  private var shouldAnimateBoundsChange = false
  ///**Logic**
  private lazy var dataView: LanguagesCollectionView = {
    let instance = LanguagesCollectionView(dataItems: locales)
    
    let constraint = instance.height(50)
    constraint.identifier = "height"
    
    instance.backgroundColor = Constants.UI.Colors.textField(color: .white, traitCollection: traitCollection)
    instance.selectionPublisher
      .sink { [weak self] in
        guard let self = self else { return }
      
        self.label.text = "content_language".localized.uppercased() + " (\(self.locales.filter({ $0.selected }).count))"
        self.selectionPublisher.send()
      }
      .store(in: &subscriptions)
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    
    Timer.publish(every: 0.1, on: .main, in: .common)
      .autoconnect()
      .sink { [unowned self] _ in self.requestBoundsPublisher.send() }
      .store(in: &subscriptions)
    
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
    
    if #available(iOS 17.0, *) {
      registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(self.updateTraits))
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if #unavailable(iOS 17) {
      updateTraits()
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    requestBoundsPublisher = PassthroughSubject<Void, Never>()
    selectionPublisher = PassthroughSubject<Void, Never>()
    boundsPublisher = PassthroughSubject<Bool, Never>()
  }
  
  // MARK: - Public methods
  public func setHeight(_ height: CGFloat) {
    let newVal = height - header.bounds.height - stack.spacing - insets.top - insets.bottom
    
    guard let constraint = dataView.getConstraint(identifier: "height"),
          constraint.constant != newVal
    else { return }
    
    setNeedsLayout()
    constraint.constant = newVal
    layoutIfNeeded()
    boundsPublisher.send(shouldAnimateBoundsChange)
    shouldAnimateBoundsChange = true
  }
}

// MARK: - Private
private extension UserSettingsLocalesCell {
  @MainActor
  func setupUI() {
//    clipsToBounds = false
//    contentView.clipsToBounds = false
////    layer.masksToBounds = false
////    contentView.layer.masksToBounds = false
//    addSubview(stack)
//    stack.edgesToSuperview(insets: insets, priority: .defaultHigh)
////    stack.topToSuperview(offset: insets.top)
////    stack.leadingToSuperview(offset: insets.left)
////    stack.trailingToSuperview(offset: insets.right)
////    contentView.bottom(to: dataView, offset: insets.bottom, priority: .defaultLow)
//////    stack.bottomToSuperview(offset: -insets.bottom, priority: .defaultLow)
    
    
    clipsToBounds = true
    contentView.addSubview(stack)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
      stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
    ])
    
    let constraint = stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom)
    constraint.isActive = true
    constraint.priority = .defaultLow
    
    if #available(iOS 17.0, *) {
      registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(self.updateTraits))
    }
  }
  
  @objc
  func updateTraits() {
    dataView.backgroundColor = Constants.UI.Colors.textField(color: .white, traitCollection: traitCollection)
  }
}

