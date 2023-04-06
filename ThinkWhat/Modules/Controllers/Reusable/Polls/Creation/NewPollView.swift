//
//  NewPollView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollView: UIView {
  
  // MARK: - Public properties
  weak var viewInput: (NewPollViewInput & UIViewController)?
  ///**Publishers**
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private var color: UIColor = .systemGray {
    didSet {
      guard oldValue != color else { return }
      
      viewInput?.setColor(color)
      updateButton()
    }
  }
  private var isButtonEnabled: Bool = true {
    didSet {
      guard oldValue != isButtonEnabled else { return }
      
      updateButton()
    }
  }
  private lazy var collectionView: NewPollCollectionView = {
    let instance = NewPollCollectionView()
    instance.progressPublisher
      .sink { [weak self] in
        guard let self = self else { return }
      
        self.viewInput?.setProgress($0)
      }
      .store(in: &subscriptions)
    instance.addImagePublisher
      .sink { [weak self] in
        guard let self = self else { return }
      
        self.viewInput?.addImage()
      }
      .store(in: &subscriptions)
    //      instance.$topic
    instance.topicPublisher
      .filter { !$0.isNil }
      .sink { [unowned self] in self.color = $0!.tagColor }
      .store(in: &subscriptions)
    instance.$hasEnoughtBudget
      .sink { [unowned self] in self.isButtonEnabled = $0 }
      .store(in: &subscriptions)
    instance.$stage
      .filter { $0 == .Ready }
      .sink { [unowned self] _ in
        guard let constraint = self.actionButton.getConstraint(identifier: "top") else { return }
        
        self.actionButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        self.actionButton.alpha = 0
        
        self.toggleFade(true)
        setNeedsLayout()
        UIView.animate(
          withDuration: 0.35,
          delay: 0,//!selectedAnswer.isNil ? 0 : 0.25,
          usingSpringWithDamping: 0.8,
          initialSpringVelocity: 0.3,
          options: [.curveEaseInOut],
          animations: { [weak self] in
            guard let self = self else { return }
            
            self.actionButton.transform = .identity
            self.actionButton.alpha = 1
            constraint.constant = -(self.actionButton.bounds.height + tabBarHeight)
            self.layoutIfNeeded()
          }) { _ in }
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var actionButton: UIButton = {
    let instance = UIButton()
    instance.alpha = 0
    instance.layer.zPosition = 2
    instance.addTarget(self, action: #selector(self.preview), for: .touchUpInside)
    
    if #available(iOS 15, *) {
      let attrString = AttributedString("publication_preview".localized.uppercased(), attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      var config = UIButton.Configuration.filled()
      config.attributedTitle = attrString
      config.baseBackgroundColor = .systemGray2//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
      config.image = UIImage(systemName: "eye.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
      config.imagePlacement = .trailing
      config.imagePadding = padding
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.buttonSize = .large

      instance.configuration = config
    } else {
      let attrString = NSMutableAttributedString(string: "publication_preview".localized.uppercased(), attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ])
      instance.titleEdgeInsets.left = 20
      instance.titleEdgeInsets.right = 20
      instance.setImage(UIImage(systemName: "eye.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
      instance.imageView?.tintColor = .white
      instance.imageEdgeInsets.left = 8
      //            instance.imageEdgeInsets.right = 8
      instance.setAttributedTitle(attrString, for: .normal)
      instance.semanticContentAttribute = .forceRightToLeft
      instance.backgroundColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
      instance.translatesAutoresizingMaskIntoConstraints = false
      
      let constraint = instance.widthAnchor.constraint(equalToConstant: "publication_preview".localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!))
      constraint.identifier = "width"
      constraint.isActive = true
      
      instance.publisher(for: \.bounds)
        .sink { [weak self] rect in
          guard let self = self else { return }
          
          instance.cornerRadius = rect.height/3.25
          
          guard let constraint = instance.getConstraint(identifier: "width") else { return }
          constraint.constant = "publication_preview".localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!) + 40 + (instance .imageView?.bounds.width ?? 0)
        }
        .store(in: &subscriptions)
    }
    
    return instance
  }()
  private lazy var gradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    let clear = UIColor.clear.cgColor
    instance.colors = [clear, clear, clear]
    instance.locations = [0.0, 1, 1]
    instance.frame = frame
    publisher(for: \.bounds)
      .sink { instance.bounds = $0 }
      .store(in: &subscriptions)
    layer.addSublayer(instance)
    
    return instance
  }()
  private let padding: CGFloat = 8
  
  
  
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
    
    setupUI()
//    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension NewPollView: NewPollControllerOutput {
  func imageAdded(_ image: UIImage) {
    collectionView.addImage(image)
  }
  
  func willMoveToParent() {
    collectionView.isMovingToParent = true
  }
  
  
}


private extension NewPollView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    collectionView.place(inside: self)
    //    let touch = UITapGestureRecognizer(target: self, action:#selector(self.hideKeyboard))
    //    addGestureRecognizer(touch)
    addSubview(actionButton)
    actionButton.translatesAutoresizingMaskIntoConstraints = false
    actionButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    
    let constraint = actionButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)//, constant: -tabBarHeight)
    constraint.identifier = "top"
    constraint.isActive = true
  }
  
  func toggleFade(_ enable: Bool) {
    let clear = UIColor.systemBackground.withAlphaComponent(0).cgColor
    let feathered = UIColor.systemBackground.withAlphaComponent(0.95).cgColor
    
    let colorAnimation = Animations.get(property: .Colors,
                                        fromValue: gradient.colors as Any,
                                        toValue: [clear, clear, feathered] as Any,
                                        duration: 0.2,
                                        timingFunction: CAMediaTimingFunctionName.easeOut,
                                        delegate: self,
                                        isRemovedOnCompletion: false,
                                        completionBlocks: [
                                          { [weak self] in
                                            guard let self = self else { return }
                                            
                                            self.gradient.colors = [clear, clear, feathered]
                                          }
                                        ])
    let locationAnimation = Animations.get(property: .Locations,
                                           fromValue: gradient.locations as Any,
                                           toValue: [0.0, 0.815, 0.875] as Any,
                                           duration: 0.2,
                                           timingFunction: CAMediaTimingFunctionName.easeOut,
                                           delegate: self,
                                           isRemovedOnCompletion: false,
                                           completionBlocks: [
                                            { [weak self] in
                                              guard let self = self else { return }
                                              
                                              self.gradient.locations = [0.0, 0.815, 0.875]
                                              self.gradient.removeAllAnimations()
                                            }
                                           ])
    
    gradient.add(locationAnimation, forKey: nil)
    gradient.add(colorAnimation, forKey: nil)
  }
  
  @objc
  func preview() {
    endEditing(true)
    
    guard collectionView.hasEnoughtBudget else {
      let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                            text: "insufficient_balance",
                                                            tintColor: .systemRed),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
      
      return
    }
    
    viewInput?.preview(collectionView.makePreview())
  }
  
  @MainActor
  func updateButton() {
    if #available(iOS 15, *) {
      actionButton.configuration?.baseBackgroundColor = isButtonEnabled ? color : .systemGray
      actionButton.configuration?.image = UIImage(systemName: isButtonEnabled ? "eye.fill" : "eye.slash.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
    } else {
      actionButton.setImage(UIImage(systemName: "eye.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
      actionButton.backgroundColor = isButtonEnabled ? color : .systemGray
    }
  }
  
//  func setTasks() {
//    tasks.append( Task {@MainActor [weak self] in
//      for await _ in NotificationCenter.default.notifications(for: UIApplication.keyboardWillHideNotification) {
//        guard let self = self else { return }
//
//        collectionView.isKeyboardOnScreen = false
//        self.getSubview(type: UIView.self, identifier: "opaque")?.removeFromSuperview()
//      }
//    })
//    tasks.append( Task {@MainActor [weak self] in
//      for await _ in NotificationCenter.default.notifications(for: UIApplication.keyboardWillShowNotification) {
//        guard let self = self else { return }
//
//        collectionView.isKeyboardOnScreen = true
//        let opaque = UIView.opaque()
//        opaque.place(inside: self)
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
//        opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
//      }
//    })
//  }
//
//  @objc
//  func hideKeyboard() {
//    endEditing(true)
//  }
}

extension NewPollView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
      if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
        completionBlock()
      }
    }
  }
}
