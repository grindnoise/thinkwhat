//
//  HotCard.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class HotCard: UIView, Card {
  enum Action { case Next, Claim, Vote }
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  ///**Logic**
  public let item: Survey
  ///**Publishers**
  @Published public var action: Action?
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  public var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private let nextColor: UIColor
  private lazy var shadowView: UIView = {
    let instance = UIView()
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "shadow"
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    instance.layer.shadowRadius = 5
    instance.layer.shadowOffset = .zero
    body.addEquallyTo(to: instance)
    
    return instance
  }()
  private lazy var body: UIView = {
    let instance = UIView()
    instance.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .systemBackground : .secondarySystemBackground
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.width*0.05 }
      .store(in: &subscriptions)
    let collectionView = PollCollectionView(item: item)
    collectionView.place(inside: instance)
//    collectionView.isUserInteractionEnabled = false
    featheredView.place(inside: instance)
    
    return instance
  }()
  private lazy var featheredView: UIView = {
    let instance = UIView()
    instance.accessibilityIdentifier = "feathered"
    instance.layer.masksToBounds = true
    instance.layer.addSublayer(featheredLayer)
    instance.publisher(for: \.bounds)
      .sink { [unowned self] in self.featheredLayer.frame = $0 }
      .store(in: &subscriptions)

    return instance
  }()
  private lazy var featheredLayer: CAGradientLayer = {
    let instance = CAGradientLayer()
    setGradient(instance)
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      claimButton,
      voteButton,
      nextButton
    ])
    instance.axis = .horizontal
    instance.spacing = padding*2
    
    return instance
  }()
  private lazy var voteButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .small
      config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
      config.baseBackgroundColor = item.topic.tagColor
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.attributedTitle = AttributedString("hot_participate".localized.uppercased(),
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.width * 0.025 }
        .store(in: &subscriptions)
      instance.backgroundColor = item.topic.tagColor
//      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "hot_participate".localized.uppercased(),
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  private lazy var nextButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "arrowshape.right.fill",
                              withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
    //    instance.imageView?.contentMode = .scaleAspectFill
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1).isActive = true
//    instance.imageView?.contentMode = .center
    instance.tintColor = item.topic.tagColor//nextColor
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    return instance
  }()
  private lazy var claimButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "exclamationmark.triangle.fill",
                              withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1).isActive = true
//    instance.imageView?.contentMode = .center

    instance.tintColor = item.topic.tagColor
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    return instance
  }()
  
  
  
  // MARK: - Deinitialization
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
  init(item: Survey,
       nextColor: UIColor) {
    self.item = item
    self.nextColor = nextColor
    
    super.init(frame: .zero)
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Public methods
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    setGradient(featheredLayer)
    body.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .systemBackground : .secondarySystemBackground
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
  }
}

private extension HotCard {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = false
    
    shadowView.place(inside: self)
    
    setNeedsLayout()
    layoutIfNeeded()
    
    addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
//    stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*2).isActive = true
    stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    
    let constraint = stack.bottomAnchor.constraint(equalTo: bottomAnchor)
    constraint.isActive = true
    publisher(for: \.bounds)
      .sink { [unowned self] in
        self.setNeedsLayout()
        constraint.constant = -$0.height/32
        self.layoutIfNeeded()
        }
      .store(in: &subscriptions)
//    stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height/4).isActive = true
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  func setTasks() {
    //    tasks.append( Task {@MainActor [weak self] in
    //      for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
    //        guard let self = self else { return }
    //
    //
    //      }
    //    })
  }
  
  func setGradient(_ layer: CAGradientLayer) {
    let clear = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.withAlphaComponent(0).cgColor : UIColor.white.withAlphaComponent(0).cgColor
//    let quarterFeathered = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.withAlphaComponent(0.25).cgColor : UIColor.white.withAlphaComponent(0.25).cgColor
//    let halfFeathered = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.withAlphaComponent(0.5).cgColor : UIColor.white.withAlphaComponent(0.5).cgColor
    let feathered = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : UIColor.white.cgColor
    layer.colors = [clear, clear, feathered]
    layer.locations = [0.0, 0.75, 0.9]
//    layer.colors = [clear, clear, quarterFeathered,  halfFeathered, feathered]
//    layer.locations = [0.0, 0.8, 0.85, 0.925, 0.95]
  }
  
  @objc
  func handleTap(sender: UIButton) {
    if sender == voteButton {
      action = .Vote
    } else {
      action = sender == claimButton ? .Claim : .Next
    }
  }
}

