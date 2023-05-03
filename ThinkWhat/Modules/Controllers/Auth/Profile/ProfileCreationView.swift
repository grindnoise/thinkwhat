//
//  ProfileCreationView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import Agrume

class ProfileCreationView: UIView {
  
//  override var bounds: CGRect {
//    didSet {
//      print("ProfileCreationView.frame.bounds", bounds)
//    }
//  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var userSettingsView: UserSettingsCollectionView = {
    let instance = UserSettingsCollectionView(mode: .Creation,
                                              userprofile: Userprofiles.shared.current!)
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { rect in
        instance.cornerRadius = rect.width * 0.05
      }
      .store(in: &subscriptions)
    
    instance.$userprofileDescription
      .filter { !$0.isNil }
      .sink { [unowned self] in
        print($0)
        fatalError()
        //self.viewInput?.updateDescription($0!)
      }
      .store(in: &self.subscriptions)
    
    //            .sink { style in
    //                instance.backgroundColor = style == .dark ? .secondarySystemBackground : .systemBackground
    //            }
    //            .store(in: &subscriptions)
    //        traitCollection.publisher(for: \.userInterfaceStyle)
    //            .sink { style in
    //                instance.backgroundColor = style == .dark ? .secondarySystemBackground : .systemBackground
    //            }
    //            .store(in: &subscriptions)
    
    instance.namePublisher
      .sink { [unowned self] in
        guard let dict = $0 else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.updateUsername(dict)
      }
      .store(in: &subscriptions)
    
    instance.datePublisher
      .sink { [unowned self] in
        guard let date = $0 else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.updateBirthDate(date)
      }
      .store(in: &subscriptions)
    
    instance.genderPublisher
      .sink { [unowned self] in
        guard let gender = $0 else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.updateGender(gender)
      }
      .store(in: &subscriptions)
    
    instance.cameraPublisher
      .sink { [unowned self] in
        guard !$0.isNil else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.openCamera()
      }
      .store(in: &subscriptions)
    
    instance.galleryPublisher
      .sink { [unowned self] in
        guard !$0.isNil else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.openGallery()
      }
      .store(in: &subscriptions)
    
    instance.previewPublisher
      .sink { [unowned self] in
        guard let image = $0,
              let controller = self.viewInput
        else { return }
        
        let agrume = Agrume(images: [image], startIndex: 0, background: .colored(.black))
        agrume.show(from: controller)
        
      }
      .store(in: &subscriptions)
    
    instance.cityFetchPublisher
      .sink { [unowned self] in
        guard let string = $0,
              let userprofile = Userprofiles.shared.current
        else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.fetchCity(userprofile: userprofile, string: string)
      }
      .store(in: &self.subscriptions)
    
    instance.citySelectionPublisher
      .sink { [unowned self] in
        print($0)
        fatalError()
        //self.viewInput?.updateCity($0)
      }
      .store(in: &self.subscriptions)
    
    instance.facebookPublisher
      .sink { [unowned self] in
        guard let url = $0 else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.updateFacebook(url)
      }
      .store(in: &self.subscriptions)
    
    instance.instagramPublisher
      .sink { [unowned self] in
        guard let url = $0 else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.updateInstagram(url)
      }
      .store(in: &self.subscriptions)
    
    instance.tiktokPublisher
      .sink { [unowned self] in
        guard let url = $0 else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.updateTiktok(url)
      }
      .store(in: &self.subscriptions)
    
    instance.openURLPublisher
      .sink { [unowned self] in
        guard let url = $0 else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.openURL(url)
      }
      .store(in: &self.subscriptions)
    
    instance.topicPublisher
      .sink { [unowned self] in
        print($0)
        fatalError()
        //self.viewInput?.onTopicSelected($0)
      }
      .store(in: &subscriptions)
    
    instance.publicationsPublisher
      .sink { [unowned self] in
        guard !$0.isNil else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.onPublicationsSelected()
      }
      .store(in: &subscriptions)
    
    instance.subscribersPublisher
      .sink { [unowned self] in
        guard !$0.isNil else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.onSubscribersSelected()
      }
      .store(in: &subscriptions)
    
    instance.subscriptionsPublisher
      .sink { [unowned self] in
        guard !$0.isNil else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.onSubscriptionsSelected()
      }
      .store(in: &subscriptions)
    
    instance.watchingPublisher
      .sink { [unowned self] in
        guard !$0.isNil else { return }
        
        print($0)
        fatalError()
        //self.viewInput?.onWatchingSelected()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var actionButton: UIButton = {
    let instance = UIButton()
    instance.alpha = 0
    instance.layer.zPosition = 2
    instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    
    if #available(iOS 15, *) {
      let attrString = AttributedString("getStartedButton".localized.uppercased(), attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      var config = UIButton.Configuration.filled()
      config.attributedTitle = attrString
      config.baseBackgroundColor = .systemGray2//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
      //      config.image = UIImage(systemName: viewInput!.mode == .Preview ? "megaphone.fill" : "hand.point.left.fill",
      //                             withConfiguration: UIImage.SymbolConfiguration(scale: .large))
      //      config.imagePlacement = .trailing
      //      config.imagePadding = padding
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.buttonSize = .large
      
      instance.configuration = config
    } else {
      let attrString = NSMutableAttributedString(string: "getStartedButton".localized.uppercased(), attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ])
      instance.titleEdgeInsets.left = 20
      instance.titleEdgeInsets.right = 20
      //      instance.setImage(UIImage(systemName: viewInput!.mode == .Preview ? "megaphone.fill" : "hand.point.left.fill",
      //                                withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
      //                        for: .normal)
      //      instance.imageView?.tintColor = .white
      //      instance.imageEdgeInsets.left = 8
      //      //            instance.imageEdgeInsets.right = 8
      instance.setAttributedTitle(attrString, for: .normal)
      //      instance.semanticContentAttribute = .forceRightToLeft
      instance.backgroundColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
      instance.translatesAutoresizingMaskIntoConstraints = false
      
      let constraint = instance.widthAnchor.constraint(equalToConstant: "getStartedButton".localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!))
      constraint.identifier = "width"
      constraint.isActive = true
      
      instance.publisher(for: \.bounds)
        .sink { [weak self] rect in
          guard let self = self else { return }
          
          instance.cornerRadius = rect.height/3.25
          
          guard let constraint = instance.getConstraint(identifier: "width") else { return }
          //          self.setNeedsLayout()
          constraint.constant = "getStartedButton".localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!) + 40 + (instance .imageView?.bounds.width ?? 0)
          //          self.layoutIfNeeded()
        }
        .store(in: &subscriptions)
    }
    
    //    let shadowView = UIView()
    //    shadowView.clipsToBounds = false
    //    shadowView.backgroundColor = .clear
    //    shadowView.accessibilityIdentifier = "shadow"
    //    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    //    shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
    //    shadowView.layer.shadowRadius = 16
    //    shadowView.layer.shadowOffset = .zero
    //    shadowView.layer.zPosition = 1
    //    shadowView.publisher(for: \.bounds)
    //      .receive(on: DispatchQueue.main)
    //      .sink { [weak self] in
    //        guard let self = self else { return }
    //
    //        shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0,
    //                                                   cornerRadius: instance.cornerRadius).cgPath
    //      }
    //      .store(in: &subscriptions)
    //    shadowView.place(inside: instance)
    //    instance.layer.zPosition = 2
    
    return instance
  }()
  private lazy var gradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    let clear = UIColor.systemBackground.withAlphaComponent(0).cgColor
    let feathered = UIColor.systemBackground.cgColor
    instance.colors = [clear, clear, feathered]
    instance.locations = [0.0, 0.875, 0.935]
//    instance.frame = frame
//    publisher(for: \.bounds)
//      .sink { instance.bounds = $0 }
//      .store(in: &subscriptions)
    
    return instance
  }()
  
  
  // MARK: - Public properties
  weak var viewInput: (UIViewController & ProfileCreationViewInput)? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
    }
  }
  
  
  
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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    gradient.frame = bounds
  }
}

extension ProfileCreationView: ProfileCreationControllerOutput {
  
}

private extension ProfileCreationView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    
    userSettingsView.place(inside: self)
    layer.addSublayer(gradient)
    
    delay(seconds: 1) { [unowned self] in
      self.present()
    }
    
    addSubview(actionButton)
    actionButton.translatesAutoresizingMaskIntoConstraints = false
    actionButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    actionButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    let constraint = actionButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)//, constant: -tabBarHeight)
    constraint.identifier = "top"
    constraint.isActive = true
  }
  
  @objc
  func handleTap() {
    guard let viewInput = viewInput,
          let titleView = viewInput.navigationController?.navigationBar.subviews.filter({ $0 is UIStackView }).first as? UIStackView,
          let titleIcon = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "logoIcon" }).first as? Icon,
          let titleText = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "logoText" }).first as? Icon,
          let window = appDelegate.window,
          let constraint = actionButton.getConstraint(identifier: "top")
    else { return }
    
    let opaque = PassthroughView()
    opaque.frame = UIScreen.main.bounds
    opaque.place(inside: window)

    let loadingIcon: Icon = {
      let instance = Icon()
      instance.accessibilityIdentifier = "loadingIcon"
      instance.category = Icon.Category.Logo
      instance.iconColor = Colors.main
      instance.scaleMultiplicator = 1.2
      instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
      instance.alpha = 0
      
      return instance
    }()
    let loadingText: Icon = {
      let instance = Icon()
      instance.accessibilityIdentifier = "loadingText"
      instance.category = Icon.Category.LogoText
      instance.iconColor = Colors.main
      instance.scaleMultiplicator = 1.1
      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.5).isActive = true
      instance.alpha = 0
      
      return instance
    }()
    let loadingStack: UIStackView = {
      let opaque = UIView()
      opaque.backgroundColor = .clear
      
      let instance = UIStackView(arrangedSubviews: [
        opaque,
        loadingText
      ])
      instance.axis = .vertical
      instance.distribution = .equalCentering
      instance.spacing = 0
      instance.clipsToBounds = false
      
      loadingIcon.translatesAutoresizingMaskIntoConstraints = false
      opaque.translatesAutoresizingMaskIntoConstraints = false
      opaque.addSubview(loadingIcon)
      
      NSLayoutConstraint.activate([
        loadingIcon.topAnchor.constraint(equalTo: opaque.topAnchor),
        loadingIcon.bottomAnchor.constraint(equalTo: opaque.bottomAnchor),
        loadingIcon.centerXAnchor.constraint(equalTo: opaque.centerXAnchor),
        opaque.heightAnchor.constraint(equalTo: loadingText.heightAnchor, multiplier: 2)
      ])
      
      return instance
    }()
    loadingStack.placeInCenter(of: opaque,
                               widthMultiplier: 0.6)
        opaque.setNeedsLayout()
        opaque.layoutIfNeeded()
    
    ///Fake icons to animate
    let fakeLogoIcon: Icon = {
      let instance = Icon(frame: CGRect(origin: titleIcon.superview!.convert(titleIcon.frame.origin,
                                                                            to: opaque),
                                        size: titleIcon.bounds.size))
      instance.category = Icon.Category.Logo
      instance.iconColor = Colors.main
      instance.scaleMultiplicator = 1.2
      instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
      
      return instance
    }()
    let fakeLogoText: Icon = {
      let instance = Icon(frame: CGRect(origin: titleText.superview!.convert(titleText.frame.origin,
                                                                            to: opaque),
                                        size: titleText.bounds.size))
      
      instance.category = Icon.Category.LogoText
      instance.iconColor = Colors.main
      instance.scaleMultiplicator = 1.1
      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.5).isActive = true
      
      return instance
    }()
    
    opaque.addSubviews([fakeLogoIcon, fakeLogoText])
    titleIcon.alpha = 0
    titleText.alpha = 0
    
    fakeLogoIcon.icon.add(Animations.get(property: .Path,
                                     fromValue: (fakeLogoIcon.icon as! CAShapeLayer).path as Any,
                                     toValue: (loadingIcon.icon as! CAShapeLayer).path as Any,
                                     duration: 0.3,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                     delegate: self,
                                     isRemovedOnCompletion: false,
                                     completionBlocks: []),
                      forKey: nil)
    fakeLogoText.icon.add(Animations.get(property: .Path,
                                     fromValue: (fakeLogoText.icon as! CAShapeLayer).path as Any,
                                     toValue: (loadingText.icon as! CAShapeLayer).path as Any,
                                     duration: 0.3,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                     delegate: self,
                                     isRemovedOnCompletion: false,
                                     completionBlocks: []),
                      forKey: nil)

    UIView.animate(withDuration: 0.2) { [weak self] in
      guard let self = self else { return }
      
      self.userSettingsView.alpha = 0
      self.userSettingsView.transform = .init(scaleX: 0.85, y: 0.85)
    }
    
    setNeedsLayout()
    UIView.animate(withDuration: 0.4,
                   delay: 0,
//                   usingSpringWithDamping: 0.7,
//                   initialSpringVelocity: 0.3,
                   options: [.curveEaseInOut],
                   animations: { [weak self] in
      guard let self = self else { return }
      
      constraint.constant = 100
      self.layoutIfNeeded()
      
      fakeLogoIcon.frame = CGRect(origin: loadingStack.convert(loadingIcon.frame.origin,
                                                                      to: opaque),
                                  size: loadingIcon.bounds.size)
      fakeLogoText.frame = CGRect(origin: loadingStack.convert(loadingText.frame.origin,
                                                                      to: opaque),
                                  size: loadingText.bounds.size)
      
    }) { _ in
      loadingIcon.alpha = 1
      loadingText.alpha = 1
      fakeLogoText.removeFromSuperview()
      fakeLogoIcon.removeFromSuperview()
      viewInput.openApp()
    }
  }
  
  func present() {
    guard let constraint = actionButton.getConstraint(identifier: "top") else { return }
    
    delay(seconds: 0.5) {[weak self] in
      guard let self = self else { return }
      
      setNeedsLayout()
      //      layoutIfNeeded()
      //      setNeedsLayout()
      UIView.animate(
        withDuration: 0.35,
        delay: 0,
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
  }
}

extension ProfileCreationView: CAAnimationDelegate {
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
