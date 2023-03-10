//
//  Popup.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class Popup: UIView {
  
  // MARK: - Public properties
  public let willAppearPublisher = PassthroughSubject<Bool, Never>()
  public let didAppearPublisher = PassthroughSubject<Bool, Never>()
  public let willDisappearPublisher = PassthroughSubject<Bool, Never>()
  public let didDisappearPublisher = PassthroughSubject<Bool, Never>()
  public var subscriptions = Set<AnyCancellable>()
  
  
  
  // MARK: - IB Outlets
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var background: UIView! {
    didSet {
      background.backgroundColor = UIColor.black.withAlphaComponent(0.8)
      background.alpha = 0
    }
  }
  @IBOutlet weak var body: UIView! {
    didSet {
      body.backgroundColor = traitCollection.userInterfaceStyle == .dark ? darkColor : lightColor
      body.publisher(for: \.bounds)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.body.cornerRadius = $0.width*0.05
        }
        .store(in: &subscriptions)
    }
  }
  @IBOutlet weak var container: UIView!
  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
  @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
  
  
  
  // MARK: - Private properties
  private var tasks: [Task<Void, Never>?] = []
  private let heightScaleFactor: CGFloat
  private var yOrigin: CGFloat = 0
  private var height: CGFloat = 0 {
    didSet {
      if oldValue != height {
        yOrigin = -(UIScreen.main.bounds.height/2 + height/2)
      }
    }
  }
  ///**UI**
  private let lightColor: UIColor
  private let darkColor: UIColor
  private var originalContainerHeight = CGFloat.zero
  private var padding: CGFloat = 16
  private var lastHeight: CGFloat = 0
  private let useContentViewHeight: Bool
  ///Auto dismiss
  private var isDismissing = false
  private var shouldDismissAfter: TimeInterval {
    didSet {
      guard shouldDismissAfter == 0 else { return }
      
      dismiss()
    }
  }
  private var isModal = false
  private var isInteracting = false {
    didSet {
      guard isInteracting else { return }
      
      subscriptions.forEach { $0.cancel() }
    }
  }
  private weak var callbackDelegate : CallbackObservable?
  private weak var bannerDelegate: BannerObservable?
  
  
  
  // MARK: - Destructor
  deinit {
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  init(contentPadding: CGFloat = 8,
       heightScaleFactor: CGFloat = 0.5,
       shouldDismissAfter: TimeInterval = .greatestFiniteMagnitude,
       useContentViewHeight: Bool = false,
       lightColor: UIColor = .red,
       darkColor: UIColor = .tertiarySystemBackground) {
    
    self.lightColor = lightColor
    self.darkColor = darkColor
    self.shouldDismissAfter = shouldDismissAfter
    self.padding = contentPadding
    self.heightScaleFactor = heightScaleFactor
    self.useContentViewHeight = useContentViewHeight
    
    super.init(frame: UIScreen.main.bounds)

    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    body.backgroundColor = traitCollection.userInterfaceStyle == .dark ? darkColor : lightColor
  }
  
  
  
  // MARK: - Public methods
  public func present(content: UIView, isModal _isModal: Bool = false, dismissAfter seconds: TimeInterval = 0) {
    content.frame = container.frame
    content.addEquallyTo(to: container)
    content.setNeedsLayout()
    content.layoutIfNeeded()
    
    isInteracting = false
    isModal       = _isModal
    body.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    bannerDelegate?.onBannerWillAppear(self)
    willAppearPublisher.send(true)
    willAppearPublisher.send(completion: .finished)
    
    alpha = 1
    UIView.animate(
      withDuration: 0.45,
      delay: 0,
      usingSpringWithDamping: 0.75,
      initialSpringVelocity: 0.4,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        self.centerYConstraint.constant = 0
        self.layoutIfNeeded()
        self.body.transform = .identity
      }) {[weak self] _ in
        guard let self = self else { return }
        
        self.bannerDelegate?.onBannerDidAppear(self)
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
    
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
      self.background.alpha = 1
    })
  }
  
  public func dismiss() {//_ sender: Optional<Any> = nil) {
    subscriptions.forEach { $0.cancel() }
    isDismissing = true
    bannerDelegate?.onBannerWillDisappear(self)
    willDisappearPublisher.send(true)
    willDisappearPublisher.send(completion: .finished)
    
    UIView.animate(withDuration: 0.35, delay: 0, options: [.curveLinear], animations: { [weak self] in
      guard let self = self else { return }
      
      self.background.alpha = 0
    }) {[weak self] _ in
      guard let self = self else { return }
      
      //            self.accessibilityIdentifier = sender as? String
      self.bannerDelegate?.onBannerDidDisappear(self)
      self.didDisappearPublisher.send(true)
      self.didDisappearPublisher.send(completion: .finished)
    }
    UIView.animate(withDuration: 0.25,
                   delay: 0,
                   options: [.curveEaseInOut],
                   animations: { [weak self] in
      guard let self = self else { return }
      
      self.setNeedsLayout()
      self.centerYConstraint.constant += abs(self.yOrigin)
      self.layoutIfNeeded()
      self.background.alpha = 0
      self.body.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }) { _ in }
  }
  
  public func onContainerHeightChange(_ height: CGFloat) {
    //        guard !isDismissing else { return }
    guard lastHeight != height else { return }
    lastHeight = height
    
    setNeedsLayout()
    self.height = min((height + padding*2), UIScreen.main.bounds.height * 0.8)//body.frame.width * heightScaleFactor
    heightConstraint.constant = self.height
    centerYConstraint.constant = yOrigin
    layoutIfNeeded()
  }
  
  public func resize(_ height: CGFloat, animationDuration: TimeInterval) {
    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0) {
      self.setNeedsLayout()
      self.heightConstraint.constant = height
      self.layoutIfNeeded()
    }
  }
  
}

private extension Popup {
  @MainActor
  func setupUI() {
    guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
    
    backgroundColor             = .clear
    bounds                      = UIScreen.main.bounds
    contentView.frame               = bounds
    contentView.autoresizingMask    = [.flexibleHeight, .flexibleWidth]
    layer.zPosition = 2000
    appDelegate.window?.addSubview(self)
    addSubview(contentView)
    
    //Set default height
    setNeedsLayout()
    height                      = UIScreen.main.bounds.height * heightScaleFactor//body.frame.width * heightScaleFactor
    heightConstraint.constant   = height
    centerYConstraint.constant  = yOrigin
    layoutIfNeeded()
    body.cornerRadius = body.frame.width * 0.07
    //        guard let constraint = container.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
    originalContainerHeight     = container.bounds.height//constraint.constant
  }
}


class NewPopup: UIView {
  
  // MARK: - Public properties
  public let willAppearPublisher = PassthroughSubject<Bool, Never>()
  public let didAppearPublisher = PassthroughSubject<Bool, Never>()
  public let willDisappearPublisher = PassthroughSubject<Bool, Never>()
  public let didDisappearPublisher = PassthroughSubject<Bool, Never>()
  public var subscriptions = Set<AnyCancellable>()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
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
  ///`UI`
  //  private let useShadows: Bool
  private var contentView: UIView! {
    didSet {
      guard !contentView.isNil else { return }
      
      setupUI()
    }
  }
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
    
    if !isModal && traitCollection.userInterfaceStyle != .dark {
      instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
      instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
      instance.layer.shadowRadius = 16
      instance.layer.shadowOffset = .zero
      instance.publisher(for: \.bounds)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
          
          instance.layer.shadowPath = UIBezierPath(roundedRect: $0,
                                                   cornerRadius: $0.width*0.05).cgPath
        }
        .store(in: &subscriptions)
    }
    
    return instance
  }()
  private lazy var body: UIView = {
    let instance = UIView()
    instance.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .systemBackground : .tertiarySystemBackground
//    instance.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.viewPanned(recognizer:))))
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.width*0.05 }
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
  init(contentView: UIView? = nil,
       padding: CGFloat = 16,
       contentPadding: UIEdgeInsets = .uniform(size: 8),
       isModal: Bool = true,
       useContentViewHeight: Bool = true,
       shouldDismissAfter: TimeInterval = .greatestFiniteMagnitude) {
    self.padding = padding
    self.isModal = isModal
    self.useContentViewHeight = useContentViewHeight
    self.contentPadding = contentPadding
    self.shouldDismissAfter = shouldDismissAfter
    
    super.init(frame: UIScreen.main.bounds)
    
    guard !contentView.isNil else { return }
    
    self.contentView = contentView
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    body.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .systemBackground : .tertiarySystemBackground
  }
  
  
  // MARK: - Public methods
  public func setContent(_ view: UIView) {
    self.contentView = view
  }
  
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
      constraint.constant = self.shadowView.bounds.height + UIScreen.main.bounds.height/2
      self.layoutIfNeeded()
      self.backgroundColor = .clear
      self.body.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.didDisappearPublisher.send(true)
      self.didDisappearPublisher.send(completion: .finished)
    }
  }
}

private extension NewPopup {
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
      shadowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
      shadowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
    ])
    
    if useContentViewHeight {
      contentView.place(inside: body,
                        insets: contentPadding,
                        bottomPriority: .defaultLow)
    } else {
      shadowView.widthAnchor.constraint(equalTo: shadowView.heightAnchor, multiplier: 1/1).isActive = true
    }
    
    
    let constraint = shadowView.centerYAnchor.constraint(equalTo: centerYAnchor)
    constraint.isActive = true
    constraint.identifier = "top"
    
    setNeedsLayout()
    layoutIfNeeded()
    
    setNeedsLayout()
    constraint.constant = -(statusBarFrame.height + shadowView.bounds.height + UIScreen.main.bounds.height/2)
    layoutIfNeeded()
    
    willAppearPublisher.send(true)
    willAppearPublisher.send(completion: .finished)
    body.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    setNeedsLayout()
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 0.4,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        self.body.transform = .identity
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        constraint.constant = 0
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
  }
}
