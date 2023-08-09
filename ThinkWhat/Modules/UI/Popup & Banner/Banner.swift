//
//  Banner.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

import UIKit
import Combine

class NewBanner: UIView {
  
  // MARK: - Public properties
  public let willAppearPublisher = PassthroughSubject<Bool, Never>()
  public let didAppearPublisher = PassthroughSubject<Bool, Never>()
  public let willDisappearPublisher = PassthroughSubject<Bool, Never>()
  public let didDisappearPublisher = PassthroughSubject<Bool, Never>()
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`Logic`
  private var isDismissing = false
  private var shouldDismissAfter: TimeInterval {
    didSet {
      guard shouldDismissAfter == 0 else { return }
      
      dismiss()
    }
  }
  private var isInteracting = false {
    didSet {
      guard isInteracting else { return }
      
      subscriptions.forEach { $0.cancel() }
    }
  }
  private let padding: CGFloat
  private let contentPadding: UIEdgeInsets
  private let isModal: Bool
  private let isShadowed: Bool
  ///`UI`
  private let contentView: UIView
  private let useContentViewHeight: Bool
  private lazy var background: UIView = {
    let instance = UIView()
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    
    return instance
  }()
  private lazy var shadowView: UIView = {
    let instance = UIView()
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "shadow"
    body.addEquallyTo(to: instance)
    
    if isShadowed && !isModal && traitCollection.userInterfaceStyle != .dark {
      instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
      instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.75).cgColor
      instance.layer.shadowRadius = padding
      instance.layer.shadowOffset = .zero
      instance.publisher(for: \.bounds)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
          
          instance.layer.shadowPath = UIBezierPath(roundedRect: $0,
                                                   cornerRadius: $0.width*0.025).cgPath
        }
        .store(in: &subscriptions)
    }
    
    return instance
  }()
  private lazy var body: UIView = {
    let instance = UIView()
    instance.accessibilityIdentifier = "body"
    instance.backgroundColor = traitCollection.userInterfaceStyle != .dark ? Colors.bannerLight : Colors.bannerDark
    instance.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.viewPanned(recognizer:))))
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    
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
  init(contentView: UIView,
       padding: CGFloat = 8,
       contentPadding: UIEdgeInsets = .uniform(size: 8),
       isModal: Bool,
       isShadowed: Bool = true,
       useContentViewHeight: Bool = false,
       shouldDismissAfter: TimeInterval = .greatestFiniteMagnitude) {
    self.isShadowed = isShadowed
    self.isModal = isModal
    self.contentView = contentView
    self.useContentViewHeight = useContentViewHeight
    self.padding = padding
    self.contentPadding = contentPadding
    self.shouldDismissAfter = shouldDismissAfter
    
    super.init(frame: UIScreen.main.bounds)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Public methods
  @objc
  public func dismiss() {
    guard !isDismissing else { return }
    
    isDismissing = true
    willDisappearPublisher.send(true)
    willDisappearPublisher.send(completion: .finished)
    
    UIView.animate(withDuration: 0.2,
                   delay: 0,
                   options: [.curveEaseInOut],
                   animations: { [weak self] in
      guard let self = self,
            let constraint = self.getConstraint(identifier: "top")
      else { return }
      
      self.setNeedsLayout()
      constraint.constant = -self.body.bounds.height
      self.layoutIfNeeded()
      self.backgroundColor = .clear
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.didDisappearPublisher.send(true)
      self.didDisappearPublisher.send(completion: .finished)
    }
  }
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    guard isShadowed && !isModal else { return }
    
    body.backgroundColor = traitCollection.userInterfaceStyle != .dark ? Colors.bannerLight : Colors.bannerDark
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    if isModal {
      return self
    }

    let view = super.hitTest(point, with: event)
    if view == self {
      return nil // avoid delivering touch events to the container view (self)
    } else {
      return view // the subviews will still receive touch events
    }
  }
}

private extension NewBanner {
  @MainActor
  func setupUI() {
    bounds = UIScreen.main.bounds
    frame = bounds
    backgroundColor = .clear
    autoresizingMask = [.flexibleHeight, .flexibleWidth]
    appDelegate.window?.addSubview(self)
    layer.zPosition = 1000
    
    addSubview(shadowView)
    body.addSubview(contentView)
    shadowView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      //      shadowView.topAnchor.constraint(equalTo: topAnchor, constant: statusBarFrame.height),
      shadowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
      shadowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
    ])
    if useContentViewHeight {
      contentView.place(inside: body,
                        insets: contentPadding,
                        bottomPriority: .defaultLow)
    } else {
      shadowView.widthAnchor.constraint(equalTo: shadowView.heightAnchor, multiplier: 5/1).isActive = true
    }
    
    
    let constraint = shadowView.topAnchor.constraint(equalTo: topAnchor, constant: statusBarFrame.height)
    constraint.isActive = true
    constraint.identifier = "top"
    
    setNeedsLayout()
    layoutIfNeeded()
    
    setNeedsLayout()
    constraint.constant = -body.bounds.height
    layoutIfNeeded()
    
    willAppearPublisher.send(true)
    willAppearPublisher.send(completion: .finished)
    setNeedsLayout()
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 0.4,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        self.backgroundColor = self.isModal ? UIColor.black.withAlphaComponent(0.8) : .clear
        constraint.constant = self.statusBarFrame.height
        self.layoutIfNeeded()
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.didAppearPublisher.send(true)
        self.didAppearPublisher.send(completion: .finished)
        
        guard self.shouldDismissAfter != .greatestFiniteMagnitude else { return }
        
        Timer.publish(every: 0.5, on: .main, in: .common)
          .autoconnect()
          .sink { [weak self] time in
            guard let self = self else { return }
            
            self.shouldDismissAfter -= 0.5
          }
          .store(in: &self.subscriptions)
      }
    
//    ///Dismiss on hand gesture
//    if !isModal {
//      body.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(self.dismiss)))
//      body.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(self.dismiss)))
//    }
  }
  
  @objc
  func viewPanned(recognizer: UIPanGestureRecognizer) {
    guard !isModal,
          let constraint = self.getConstraint(identifier: "top")
    else { return }
    
    isInteracting = true
    let height = body.bounds.height
    let yOrigin = -height
    
    let minConstant = -(height+statusBarFrame.height)
    let yTranslation = recognizer.translation(in: contentView).y
    
    constraint.constant += yTranslation
    
    if yTranslation > 0 {
      constraint.constant = min(constraint.constant, statusBarFrame.height)
    }
    constraint.constant = constraint.constant < minConstant ? minConstant : constraint.constant
    
    recognizer.setTranslation(.zero, in: contentView)
    var yPoint = convert(body.frame.origin, to: contentView).y + height
    yPoint = yPoint < 0 ? 0 : yPoint
    background.alpha = yPoint/(height+statusBarFrame.height)
    
    guard recognizer.state == .ended else {
      return
    }
    
    let yVelocity = recognizer.velocity(in: contentView).y
    let distance = abs(yOrigin) - abs(yPoint)
    if yVelocity < -500 {
      willDisappearPublisher.send(true)
      willDisappearPublisher.send(completion: .finished)
      
      let time = TimeInterval(distance/abs(yVelocity)*2.5)
      let duration: TimeInterval = time < 0.08 ? 0.08 : time
      UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        constraint.constant = yOrigin
        self.layoutIfNeeded()
        self.background.alpha = 0
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.didDisappearPublisher.send(true)
        self.didDisappearPublisher.send(completion: .finished)
      }
    } else if background.alpha > 0.33 {
      UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
        self.setNeedsLayout()
        constraint.constant = self.statusBarFrame.height//self.topMargin
        self.layoutIfNeeded()
        self.background.alpha = 1
      })
    } else {
      willDisappearPublisher.send(true)
      willDisappearPublisher.send(completion: .finished)
      
      
      UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        constraint.constant = yOrigin
        self.layoutIfNeeded()
        self.background.alpha = 0
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.didDisappearPublisher.send(true)
        self.didDisappearPublisher.send(completion: .finished)
      }
    }
  }
}
