//
//  Banner.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewBanner: UIView {
  
  // MARK: - Public properties
  public let willAppearPublisher = PassthroughSubject<Bool, Never>()
  public let didAppearPublisher = PassthroughSubject<Bool, Never>()
  public let willDisappearPublisher = PassthroughSubject<Bool, Never>()
  public let didDisappearPublisher = PassthroughSubject<Bool, Never>()
  ///**Logic**
  public  let isModal: Bool
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var timerSubscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var isDismissing = false
  private let shouldPresent: Bool // Present after init immediatelly
  private var shouldDismissAfter: TimeInterval {
    didSet {
      guard !isModal && shouldDismissAfter == 0 && !isInteracting else { return }
      
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
  private var topConstraint: NSLayoutConstraint!
  
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
       shouldPresent: Bool = true,
       shouldDismissAfter: TimeInterval = .zero) {
    self.isShadowed = isShadowed
    self.isModal = isModal
    self.shouldPresent = shouldPresent
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
    UIView.animate(withDuration: 0.2,
                   delay: 0/*shouldDismissAfter*/,
                   options: [.curveEaseInOut],
                   animations: { [weak self] in
      guard let self = self else { return }
      
      self.isDismissing = true
      self.willDisappearPublisher.send(true)
      self.willDisappearPublisher.send(completion: .finished)
      self.setNeedsLayout()
      self.topConstraint.constant = -self.body.bounds.height
      self.layoutIfNeeded()
      self.backgroundColor = .clear
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.didDisappearPublisher.send(true)
      self.didDisappearPublisher.send(completion: .finished)
    }
//    func animate() {
//      UIView.animate(withDuration: 0.2,
//                     delay: 0/*shouldDismissAfter*/,
//                     options: [.curveEaseInOut],
//                     animations: { [weak self] in
//        guard let self = self else { return }
//        
//        self.isDismissing = true
//        self.willDisappearPublisher.send(true)
//        self.willDisappearPublisher.send(completion: .finished)
//        self.setNeedsLayout()
//        self.topConstraint.constant = -self.body.bounds.height
//        self.layoutIfNeeded()
//        self.backgroundColor = .clear
//      }) { [weak self] _ in
//        guard let self = self else { return }
//        
//        self.didDisappearPublisher.send(true)
//        self.didDisappearPublisher.send(completion: .finished)
//      }
//    }
//    
//    guard !isDismissing && !isInteracting else { return }
//    
//    if shouldDismissAfter == .zero {
//      animate()
//    } else {
//      delay(seconds: shouldDismissAfter) { [weak self] in
//        guard !self.isNil else { return }
//        
//        animate()
//      }
//    }
  }
  
  public func present() {
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
        self.topConstraint.constant = self.statusBarFrame.height
        self.layoutIfNeeded()
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.didAppearPublisher.send(true)
        self.didAppearPublisher.send(completion: .finished)
        
        guard self.shouldDismissAfter != .zero else { return }
        
        self.countdown()
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
  func countdown() {
    timerSubscriptions.forEach { $0.cancel() }
    Timer.publish(every: 0.5, on: .main, in: .common)
      .autoconnect()
      .sink { [unowned self] _ in self.shouldDismissAfter -= 0.5 }
      .store(in: &timerSubscriptions)
  }
  
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
    
    
    topConstraint = shadowView.topAnchor.constraint(equalTo: topAnchor, constant: statusBarFrame.height)
    topConstraint.isActive = true
//    constraint.identifier = "top"
    
    setNeedsLayout()
    layoutIfNeeded()
    
    setNeedsLayout()
    topConstraint.constant = -body.bounds.height
    layoutIfNeeded()
    
    guard shouldPresent else { return }
    
    present()
    
//    ///Dismiss on hand gesture
//    if !isModal {
//      body.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(self.dismiss)))
//      body.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(self.dismiss)))
//    }
  }
  
  @objc
  func viewPanned(recognizer: UIPanGestureRecognizer) {
    guard !isModal else { return }
    
    isInteracting = true
    let height = body.bounds.height
    let yOrigin = -height
    
    let minConstant = -(height+statusBarFrame.height)
    let yTranslation = recognizer.translation(in: contentView).y
    
    topConstraint.constant += yTranslation
    
    if yTranslation > 0 {
      topConstraint.constant = min(topConstraint.constant, statusBarFrame.height)
    }
    topConstraint.constant = topConstraint.constant < minConstant ? minConstant : topConstraint.constant
    
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
        self.topConstraint.constant = yOrigin
        self.layoutIfNeeded()
        self.background.alpha = 0
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.didDisappearPublisher.send(true)
        self.didDisappearPublisher.send(completion: .finished)
      }
    } else if topConstraint.constant < -statusBarFrame.height/2 {
      willDisappearPublisher.send(true)
      willDisappearPublisher.send(completion: .finished)
      
      UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        self.topConstraint.constant = yOrigin
        self.layoutIfNeeded()
        self.background.alpha = 0
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.didDisappearPublisher.send(true)
        self.didDisappearPublisher.send(completion: .finished)
      }
    } else {
      // Temporarily enlarge dismiss interval to prevent dismiss
      shouldDismissAfter = .greatestFiniteMagnitude
      UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        self.topConstraint.constant = self.statusBarFrame.height
        self.layoutIfNeeded()
        self.background.alpha = 1
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.isInteracting = false
        self.shouldDismissAfter = Constants.TimeIntervals.bannerAutoDismiss
        self.countdown()
      }
    }
  }
}

struct Banners {
  @MainActor
  static func error(container: inout Set<AnyCancellable>, text: String = AppError.server.localizedDescription) {
    let banner = NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                                                          text: text),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: false,
                           useContentViewHeight: true,
                           shouldDismissAfter: 2)
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &container)
  }
}
