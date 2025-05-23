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
import TinyConstraints

class ProfileCreationView: UIView {
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private lazy var avatar: Avatar = {
    let instance = Avatar(userprofile: viewInput!.userprofile, 
//                          isShadowed: true,
//                          mode: .Editing,
                          showsProgress: true,
                          progressColor: Constants.UI.Colors.main,
                          progressLineWidthMultiplier: 0.05,
                          progressBgLineWidthMultiplier: 0.075)
    instance.widthToHeight(of: instance)
    instance.isUserInteractionEnabled = true
    
    // Image tapped
    instance.previewPublisher.sink { [weak self] in
      guard let self = self,
            let image = $0,
            let controller = self.viewInput
      else { return }
      
      let agrume = Agrume(images: [image], startIndex: 0, background: .colored(.black))
      agrume.show(from: controller)
      
    }.store(in: &subscriptions)
    
    // Camera tapped
    instance.cameraPublisher
      .filter { !$0.isNil }
      .sink { [unowned self] _ in self.viewInput?.openCamera() }
      .store(in: &subscriptions)
    
    // Gallery tapped
    instance.galleryPublisher
      .filter { !$0.isNil }
      .sink { [unowned self] _ in self.viewInput?.openGallery() }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var dataView: ProfileCreationCollectionView = {
    let instance = ProfileCreationCollectionView(userprofile: viewInput!.userprofile, locales: viewInput!.locales)
    instance.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .secondarySystemBackground : .tertiarySystemBackground
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.05 }
      .store(in: &subscriptions)
    
    // Add listeners
    // Check username availability with sligth debounce
    instance.usernameEditingPublisher
      .receive(on: DispatchQueue.main)
      .debounce(for: .seconds(0.75), scheduler: DispatchQueue.main)
//      .filter { $0.count >= Constants.Validators.usernameMinLenth }
      .sink { [weak self] in
        guard let self = self else { return }
        
        if $0.count >= Constants.Validators.usernameMinLenth, $0 != self.viewInput?.userprofile.username {
          self.viewInput?.checkUsernameAvailability($0)
        } else if $0.isEmpty {
          self.dataView.setUsernameState(.empty)
          self.viewInput?.setUsernameState(.empty)
        } else {
          self.dataView.setUsernameState(.short)
          self.viewInput?.setUsernameState(.short)
        }
      }
      .store(in: &subscriptions)
    
    // Loading indicator callback
    instance.usernameEditingPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        
        
        if $0.count >= Constants.Validators.usernameMinLenth {
          guard $0 != self.viewInput?.userprofile.username else {
            instance.setUsernameState(.correct)
            self.viewInput?.setUsernameState(.correct)
            return
          }
          
          instance.setUsernameState(.waiting)
          self.viewInput?.setUsernameState(.waiting)
        } else if $0.isEmpty {
          instance.setUsernameState(.empty)
          self.viewInput?.setUsernameState(.empty)
        } else {
          instance.setUsernameState(.short)
          self.viewInput?.setUsernameState(.short)
        }
      }
      .store(in: &subscriptions)
    
    // Show error sign if idle
    instance.usernameEditingPublisher
      .receive(on: DispatchQueue.main)
      .filter { $0.count < Constants.Validators.usernameMinLenth }
      .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
      .sink { [weak self]  in
        guard let self = self else { return }
        
        if $0.isEmpty {
          self.dataView.setUsernameState(.empty)
          self.viewInput?.setUsernameState(.empty)
        } else {
          self.dataView.setUsernameState(.short)
          self.viewInput?.setUsernameState(.short)
        }
      }
      .store(in: &subscriptions)
    
    // Set username
    instance.usernameEditingPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.setUsername($0)
      }
      .store(in: &subscriptions)
    
    // Set birth date
    instance.birthDatePublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.setBirthDate($0)
      }
      .store(in: &subscriptions)
    
    // Gender listener
    instance.genderPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.setGender($0)
      }
      .store(in: &subscriptions)
    
    // Locales listener
    instance.localePublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.setLocales()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  public private(set) lazy var button: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .capsule
      config.baseBackgroundColor = Constants.UI.Colors.main
      config.attributedTitle = AttributedString("getStartedButton".localized.capitalized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.backgroundColor = Constants.UI.Colors.main
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.height/2 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "getStartedButton".localized.capitalized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    opaque.heightToWidth(of: opaque, multiplier: 52/188)
    opaque.publisher(for: \.bounds)
      .filter { $0 != .zero && opaque.layer.shadowPath?.boundingBox != $0 }
      .sink { [unowned self] in
        opaque.layer.shadowOpacity = 1
        opaque.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
      }
      .store(in: &subscriptions)
    opaque.addSubview(instance)
    opaque.alpha = 0
    instance.edgesToSuperview()
    
    return opaque
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
  
  // MARK: - Overridden
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    
//    gradient.frame = bounds
//  }
}

extension ProfileCreationView: ProfileCreationControllerOutput {
  func didAppear() {
    guard let btnConstraint = button.getConstraint(identifier: "bottom"),
          let colConstraint = dataView.getConstraint(identifier: "bottom")
    else { return }
    
    button.alpha = 1

    delay(seconds: 2) {
      UIView.animate(withDuration: 0.3) { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        colConstraint.constant -= Constants.UI.padding*2 + button.bounds.height
        btnConstraint.constant = 0
        self.layoutIfNeeded()
      }
    }
  }
  
  func usernameLoadingCallback() {
    dataView.setUsernameState(.waiting)
    viewInput?.setUsernameState(.waiting)
  }
  
  func usernameAvailabilityCallback(_ res: Result<Bool, Error>) {
    switch res {
    case .success(let isAvailable):
      dataView.setUsernameState(!isAvailable ? .correct : .busy)
      viewInput?.setUsernameState(!isAvailable ? .correct : .busy)
    case .failure(let error):
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
      dataView.setUsernameState(.error)
      viewInput?.setUsernameState(.error)
    }
  }
  
  func transitionToApp(_ completion: @escaping Closure) {
    guard let viewInput = viewInput,
          let titleView = viewInput.navigationController?.navigationBar.subviews.filter({ $0 is UIStackView }).first as? UIStackView,
          let logoIcon = titleView.arrangedSubviews.filter({ $0 is Logo }).first as? Logo,
          let logoText = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "opaque" }).first?.subviews.filter({ $0 is LogoText }).first as? LogoText,
          let window = appDelegate.window,
          let constraint = button.getConstraint(identifier: "top")
    else { return }
    
    let opaque = PassthroughView()
    opaque.frame = UIScreen.main.bounds
    opaque.place(inside: window)

    let tempLogo = Logo()
    let tempLogoText = LogoText()
    let loadingStack: UIStackView = {
      let opaque = UIView.opaque()
      tempLogo.placeInCenter(of: opaque, topInset: 0, bottomInset: 0)
      let instance = UIStackView(arrangedSubviews: [
        opaque,
        tempLogoText,
      ])
      instance.axis = .vertical
      instance.spacing = 30
      tempLogo.alpha = 0
      tempLogoText.alpha = 0
      
      return instance
    }()
    
    loadingStack.placeInCenter(of: opaque)
    
    tempLogo.translatesAutoresizingMaskIntoConstraints = false
    tempLogo.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.31).isActive = true
    tempLogoText.translatesAutoresizingMaskIntoConstraints = false
    tempLogoText.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    opaque.setNeedsLayout()
    opaque.layoutIfNeeded()
    
    ///Fake icons to animate
    let fakeLogo = Logo(frame: CGRect(origin: logoIcon.superview!.convert(logoIcon.frame.origin, to: self),
                                                                    size: logoIcon.bounds.size))
    let fakeLogoText = LogoText(frame: CGRect(origin: logoText.superview!.convert(logoText.frame.origin, to: self),
                                                                    size: logoText.bounds.size))
    fakeLogo.removeConstraints(fakeLogo.getAllConstraints())
    fakeLogoText.removeConstraints(fakeLogoText.getAllConstraints())
    opaque.addSubviews([fakeLogo, fakeLogoText])
    logoIcon.alpha = 0
    logoText.alpha = 0
    
    let spiral = Icon(frame: .zero,
                      category: .Spiral,
                      scaleMultiplicator: 1,
                      iconColor: traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.spiralDark : Constants.UI.Colors.spiralLight)
    opaque.insertSubview(spiral, belowSubview: loadingStack)
    spiral.translatesAutoresizingMaskIntoConstraints = false
    spiral.heightAnchor.constraint(equalTo: spiral.widthAnchor).isActive = true
    spiral.widthAnchor.constraint(equalTo: opaque.heightAnchor, multiplier: 1.5).isActive = true
    spiral.centerXAnchor.constraint(equalTo: fakeLogo.centerXAnchor).isActive = true
    spiral.centerYAnchor.constraint(equalTo: fakeLogo.centerYAnchor).isActive = true
    spiral.alpha = 0
    
    setNeedsLayout()
    UIView.animate(withDuration: 0.6,
                   delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 0.3,
                   options: [.curveEaseInOut],
                   animations: { [weak self] in
      guard let self = self else { return }
      
      constraint.constant = 100
      self.layoutIfNeeded()
      opaque.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground
      spiral.alpha = 1
      
      fakeLogo.frame = CGRect(origin: loadingStack.convert(tempLogo.frame.origin, to: opaque),
                              size: tempLogo.bounds.size)
      fakeLogoText.frame = CGRect(origin: loadingStack.convert(tempLogoText.frame.origin, to: opaque),
                                  size: tempLogoText.bounds.size)
      
    }) { _ in
      tempLogo.alpha = 1
      tempLogoText.alpha = 1
      fakeLogoText.removeFromSuperview()
      fakeLogo.removeFromSuperview()
      completion()
    }
  }
  
  func setProgress(_ percent: Double) {
    avatar.setProgress(value: percent, duration: 0.75)
  }
}

private extension ProfileCreationView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    
    // Add avatar and username on the top
    addSubview(avatar)
    avatar.topToSuperview(offset: Constants.UI.padding*2, usingSafeArea: true)
    avatar.centerXToSuperview()
    avatar.widthToSuperview(multiplier: 0.4)
    
    // Add collection view
    addSubview(dataView)
    dataView.topToBottom(of: avatar, offset: Constants.UI.padding*4)
    dataView.leadingToSuperview(offset: Constants.UI.padding*2)
    dataView.trailingToSuperview(offset: Constants.UI.padding*2)
    let colConstraint = dataView.bottomToSuperview(usingSafeArea: true)
    colConstraint.identifier = "bottom"
    
    // Add button
    addSubview(button)
    let btnConstraint = button.bottomToSuperview(offset: 100, usingSafeArea: true)
    btnConstraint.identifier = "bottom"
    button.centerXToSuperview()
    button.widthToSuperview(multiplier: 0.5)
    
    // Force hide keyboard on screen tap
    addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.hideKeyboard)))
    
    // Traits listener
    if #available(iOS 17.0, *) {
      registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(self.updateTraits))
    }
  }
  
  @MainActor
  @objc
  func updateTraits() {
    dataView.backgroundColor = self.traitCollection.userInterfaceStyle != .dark ? .secondarySystemBackground : .tertiarySystemBackground
  }
  
  @objc
  func handleTap() {
    viewInput?.openApp()
  }
  
  @objc
  func hideKeyboard() {
    endEditing(true)
  }
}

extension ProfileCreationView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
    }
  }
}

//import UIKit
//import Combine
//import Agrume
//
//class ProfileCreationView: UIView {
//  
////  override var bounds: CGRect {
////    didSet {
////      print("ProfileCreationView.frame.bounds", bounds)
////    }
////  }
//  
//  // MARK: - Private properties
//  private var observers: [NSKeyValueObservation] = []
//  private var subscriptions = Set<AnyCancellable>()
//  private var tasks: [Task<Void, Never>?] = []
//  ///**UI**
//  private let padding: CGFloat = 8
//  public private(set) lazy var userSettingsView: UserSettingsCollectionView = {
//    let instance = UserSettingsCollectionView(mode: .Creation,
//                                              userprofile: Userprofiles.shared.current!)
//    
//    Userprofiles.shared.current!.$gender
//      .filter { $0 != .Unassigned }
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] _ in
//        guard let self = self else { return }
//        
//        guard !Userprofiles.shared.current!.city.isNil else { return }
//        
//        if #available(iOS 15, *) {
//          self.actionButton.getSubview(type: UIButton.self)!.configuration?.baseBackgroundColor = Colors.main
//        } else {
//          self.actionButton.backgroundColor = Colors.main
//        }
//      }
//      .store(in: &subscriptions)
//    
//    Userprofiles.shared.current!.$city
//      .filter { !$0.isNil }
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] _ in
//        guard let self = self else { return }
//        
//        guard Userprofiles.shared.current!.gender != .Unassigned else { return }
//        
//        if #available(iOS 15, *) {
//          self.actionButton.getSubview(type: UIButton.self)!.configuration?.baseBackgroundColor = Colors.main
//        } else {
//          self.actionButton.backgroundColor = Colors.main
//        }
//      }
//      .store(in: &subscriptions)
//    
//    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//    
//    instance.publisher(for: \.bounds, options: .new)
//      .sink { rect in
//        instance.cornerRadius = rect.width * 0.05
//      }
//      .store(in: &subscriptions)
//    
//    instance.$userprofileDescription
//      .filter { !$0.isNil }
//      .sink { [unowned self] in
//        self.viewInput?.updateDescription($0!)
//      }
//      .store(in: &self.subscriptions)
//    
//    //            .sink { style in
//    //                instance.backgroundColor = style == .dark ? .secondarySystemBackground : .systemBackground
//    //            }
//    //            .store(in: &subscriptions)
//    //        traitCollection.publisher(for: \.userInterfaceStyle)
//    //            .sink { style in
//    //                instance.backgroundColor = style == .dark ? .secondarySystemBackground : .systemBackground
//    //            }
//    //            .store(in: &subscriptions)
//    
//    instance.namePublisher
//      .sink { [unowned self] in
//        guard let dict = $0 else { return }
//        
//        self.viewInput?.updateUsername(dict)
//      }
//      .store(in: &subscriptions)
//    
//    instance.datePublisher
//      .sink { [unowned self] in
//        guard let date = $0 else { return }
//        
//        self.viewInput?.updateBirthDate(date)
//      }
//      .store(in: &subscriptions)
//    
//    instance.genderPublisher
//      .sink { [unowned self] in
//        guard let gender = $0 else { return }
//        
//        self.viewInput?.updateGender(gender)
//      }
//      .store(in: &subscriptions)
//    
//    instance.cameraPublisher
//      .sink { [unowned self] in
//        guard !$0.isNil else { return }
//        
//        self.viewInput?.openCamera()
//      }
//      .store(in: &subscriptions)
//    
//    instance.galleryPublisher
//      .sink { [unowned self] in
//        guard !$0.isNil else { return }
//        
//        self.viewInput?.openGallery()
//      }
//      .store(in: &subscriptions)
//    
//    instance.previewPublisher
//      .sink { [unowned self] in
//        guard let image = $0,
//              let controller = self.viewInput
//        else { return }
//        
//        let agrume = Agrume(images: [image], startIndex: 0, background: .colored(.black))
//        agrume.show(from: controller)
//        
//      }
//      .store(in: &subscriptions)
//    
//    instance.cityFetchPublisher
//      .sink { [unowned self] in
//        guard let string = $0,
//              let userprofile = Userprofiles.shared.current
//        else { return }
//        
//        self.viewInput?.fetchCity(userprofile: userprofile, string: string)
//      }
//      .store(in: &self.subscriptions)
//    
//    instance.citySelectionPublisher
//      .sink { [unowned self] in
//
//        self.viewInput?.updateCity($0)
//      }
//      .store(in: &self.subscriptions)
//    
//    instance.facebookPublisher
//      .sink { [unowned self] in
//        guard let url = $0 else { return }
//        
//        self.viewInput?.updateFacebook(url)
//      }
//      .store(in: &self.subscriptions)
//    
//    instance.instagramPublisher
//      .sink { [unowned self] in
//        guard let url = $0 else { return }
//        
//        self.viewInput?.updateInstagram(url)
//      }
//      .store(in: &self.subscriptions)
//    
//    instance.tiktokPublisher
//      .sink { [unowned self] in
//        guard let url = $0 else { return }
//        
//        self.viewInput?.updateTiktok(url)
//      }
//      .store(in: &self.subscriptions)
//    
//    instance.openURLPublisher
//      .sink { [unowned self] in
//        guard let url = $0 else { return }
//        
//        self.viewInput?.openURL(url)
//      }
//      .store(in: &self.subscriptions)
//    
//    return instance
//  }()
//  public private(set) lazy var actionButton: UIView = {
//    let opaque = UIView.opaque()
//    opaque.layer.masksToBounds = false
//    
//    let instance = UIButton()
//    instance.addTarget(self,
//                       action: #selector(self.handleTap),
//                       for: .touchUpInside)
//    if #available(iOS 15, *) {
//      var config = UIButton.Configuration.filled()
//      config.cornerStyle = .capsule
//      config.baseBackgroundColor = Colors.main
//      config.attributedTitle = AttributedString("getStartedButton".localized.capitalized,
//                                                attributes: AttributeContainer([
//                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
//                                                  .foregroundColor: UIColor.white as Any
//                                                ]))
//      instance.configuration = config
//    } else {
//      instance.backgroundColor = Colors.main
//      instance.publisher(for: \.bounds)
//        .sink { instance.cornerRadius = $0.height/2 }
//        .store(in: &subscriptions)
//      instance.setAttributedTitle(NSAttributedString(string: "getStartedButton".localized.capitalized,
//                                                     attributes: [
//                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
//                                                      .foregroundColor: UIColor.white as Any
//                                                     ]),
//                                  for: .normal)
//    }
//    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 52/188).isActive = true
//    opaque.publisher(for: \.bounds)
//      .filter { $0 != .zero && opaque.layer.shadowPath?.boundingBox != $0 }
//      .sink { [unowned self] in
//        opaque.layer.shadowOpacity = 1
//        opaque.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
//        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
//        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
//        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
//      }
//      .store(in: &subscriptions)
//    instance.place(inside: opaque)
//    
//    return opaque
//  }()
//  private lazy var gradient: CAGradientLayer = {
//    let instance = CAGradientLayer()
//    let clear = UIColor.systemBackground.withAlphaComponent(0).cgColor
//    let feathered = UIColor.systemBackground.cgColor
//    instance.colors = [clear, clear, feathered]
//    instance.locations = [0.0, 0.875, 0.935]
////    instance.frame = frame
////    publisher(for: \.bounds)
////      .sink { instance.bounds = $0 }
////      .store(in: &subscriptions)
//    
//    return instance
//  }()
//  
//  
//  // MARK: - Public properties
//  weak var viewInput: (UIViewController & ProfileCreationViewInput)? {
//    didSet {
//      guard !viewInput.isNil else { return }
//      
//      setupUI()
//    }
//  }
//  
//  
//  
//  // MARK: - Destructor
//  deinit {
//    observers.forEach { $0.invalidate() }
//    tasks.forEach { $0?.cancel() }
//    subscriptions.forEach { $0.cancel() }
//    NotificationCenter.default.removeObserver(self)
//#if DEBUG
//    print("\(String(describing: type(of: self))).\(#function)")
//#endif
//  }
//  
//  
//  
//  // MARK: - Initialization
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//  
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    
//    gradient.frame = bounds
//  }
//}
//
//extension ProfileCreationView: ProfileCreationControllerOutput {
//  
//}
//
//private extension ProfileCreationView {
//  @MainActor
//  func setupUI() {
//    backgroundColor = .systemBackground
//    
//    userSettingsView.place(inside: self)
//    layer.addSublayer(gradient)
//    
//    delay(seconds: 0.25) { [weak self] in
//      guard let self = self else { return }
//      
//      self.present()
//    }
//    
//    addSubview(actionButton)
//    actionButton.translatesAutoresizingMaskIntoConstraints = false
//    actionButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
//    actionButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//    actionButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//    let constraint = actionButton.bottomAnchor.constraint(equalTo: bottomAnchor)//, constant: -tabBarHeight)
//    constraint.identifier = "top"
//    constraint.constant = 100
//    constraint.isActive = true
//    
//    let touch = UITapGestureRecognizer(target: self, action:#selector(self.hideKeyboard))
//    addGestureRecognizer(touch)
//  }
//  
//  @objc
//  func handleTap() {
//    func checkNecessaryData() -> Bool {
//      guard let userprofile = Userprofiles.shared.current else { return false }
//      
//      var errors = [String]()
//      if userprofile.gender == .Unassigned {
//        errors.append("gender".localized.lowercased())
//      }
//      if userprofile.city.isNil {
//        errors.append("cityTF".localized.lowercased())
//      }
//      
//      guard errors.isEmpty else {
//        let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
//                                                              text: String(errors.reduce("fill_necessary_fields".localized, { $0 + "\n  - \($1), " }).dropLast(2)),
//                                                              tintColor: .systemRed,
//                                                              fontName: Fonts.Regular,
//                                                              textStyle: .subheadline,
//                                                              textAlignment: .natural),
//                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                               isModal: false,
//                               useContentViewHeight: true,
//                               shouldDismissAfter: 2)
//        banner.didDisappearPublisher
//          .sink { _ in banner.removeFromSuperview() }
//          .store(in: &self.subscriptions)
//        
//        return false
//      }
//      
//      return true
//    }
//    
//    guard checkNecessaryData(),
//          let viewInput = viewInput,
//          let titleView = viewInput.navigationController?.navigationBar.subviews.filter({ $0 is UIStackView }).first as? UIStackView,
//          let logoIcon = titleView.arrangedSubviews.filter({ $0 is Logo }).first as? Logo,
//          let logoText = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "opaque" }).first?.subviews.filter({ $0 is LogoText }).first as? LogoText,
//          let window = appDelegate.window,
//          let constraint = actionButton.getConstraint(identifier: "top")
//    else { return }
//    
//    let opaque = PassthroughView()
//    opaque.frame = UIScreen.main.bounds
//    opaque.place(inside: window)
//
//    let tempLogo = Logo()
//    let tempLogoText = LogoText()
//    let loadingStack: UIStackView = {
//      let opaque = UIView.opaque()
//      tempLogo.placeInCenter(of: opaque, topInset: 0, bottomInset: 0)
//      let instance = UIStackView(arrangedSubviews: [
//        opaque,
//        tempLogoText,
//      ])
//      instance.axis = .vertical
//      instance.spacing = 30
//      tempLogo.alpha = 0
//      tempLogoText.alpha = 0
//      
//      return instance
//    }()
//    
//    loadingStack.placeInCenter(of: opaque)
//    
//    tempLogo.translatesAutoresizingMaskIntoConstraints = false
//    tempLogo.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.31).isActive = true
//    tempLogoText.translatesAutoresizingMaskIntoConstraints = false
//    tempLogoText.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
//    opaque.setNeedsLayout()
//    opaque.layoutIfNeeded()
//    
//    ///Fake icons to animate
//    let fakeLogo = Logo(frame: CGRect(origin: logoIcon.superview!.convert(logoIcon.frame.origin, to: self),
//                                                                    size: logoIcon.bounds.size))
//    let fakeLogoText = LogoText(frame: CGRect(origin: logoText.superview!.convert(logoText.frame.origin, to: self),
//                                                                    size: logoText.bounds.size))
//    fakeLogo.removeConstraints(fakeLogo.getAllConstraints())
//    fakeLogoText.removeConstraints(fakeLogoText.getAllConstraints())
//    opaque.addSubviews([fakeLogo, fakeLogoText])
//    logoIcon.alpha = 0
//    logoText.alpha = 0
//    
//    let spiral = Icon(frame: .zero,
//                      category: .Spiral,
//                      scaleMultiplicator: 1,
//                      iconColor: traitCollection.userInterfaceStyle == .dark ? Colors.spiralDark : Colors.spiralLight)
//    opaque.insertSubview(spiral, belowSubview: loadingStack)
//    spiral.translatesAutoresizingMaskIntoConstraints = false
//    spiral.heightAnchor.constraint(equalTo: spiral.widthAnchor).isActive = true
//    spiral.widthAnchor.constraint(equalTo: opaque.heightAnchor, multiplier: 1.5).isActive = true
//    spiral.centerXAnchor.constraint(equalTo: fakeLogo.centerXAnchor).isActive = true
//    spiral.centerYAnchor.constraint(equalTo: fakeLogo.centerYAnchor).isActive = true
//    spiral.alpha = 0
//
//    UIView.animate(withDuration: 0.2) { [weak self] in
//      guard let self = self else { return }
//      
//      self.userSettingsView.alpha = 0
//      self.userSettingsView.transform = .init(scaleX: 0.85, y: 0.85)
//    }
//    
//    setNeedsLayout()
//    UIView.animate(withDuration: 0.6,
//                   delay: 0,
//                   usingSpringWithDamping: 0.8,
//                   initialSpringVelocity: 0.3,
//                   options: [.curveEaseInOut],
//                   animations: { [weak self] in
//      guard let self = self else { return }
//      
//      constraint.constant = 100
//      self.layoutIfNeeded()
//      opaque.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
//      spiral.alpha = 1
//      
//      fakeLogo.frame = CGRect(origin: loadingStack.convert(tempLogo.frame.origin,
//                                                                      to: opaque),
//                                  size: tempLogo.bounds.size)
//      fakeLogoText.frame = CGRect(origin: loadingStack.convert(tempLogoText.frame.origin,
//                                                                      to: opaque),
//                                  size: tempLogoText.bounds.size)
//      
//    }) { _ in
//      tempLogo.alpha = 1
//      tempLogoText.alpha = 1
//      fakeLogoText.removeFromSuperview()
//      fakeLogo.removeFromSuperview()
//      viewInput.openApp()
//    }
//  }
//  
//  func present() {
//    guard let constraint = actionButton.getConstraint(identifier: "top") else { return }
//    
//    delay(seconds: 0.5) {[weak self] in
//      guard let self = self else { return }
//      
//      setNeedsLayout()
//      //      layoutIfNeeded()
//      //      setNeedsLayout()
//      UIView.animate(
//        withDuration: 0.35,
//        delay: 0,
//        usingSpringWithDamping: 0.8,
//        initialSpringVelocity: 0.3,
//        options: [.curveEaseInOut],
//        animations: { [weak self] in
//          guard let self = self else { return }
//          
//          self.actionButton.transform = .identity
//          self.actionButton.alpha = 1
//          constraint.constant = -self.actionButton.bounds.height/2
//          self.layoutIfNeeded()
//        }) { _ in }
//    }
//  }
//  
//  @objc
//  func hideKeyboard() {
//    endEditing(true)
//  }
//}
//
//extension ProfileCreationView: CAAnimationDelegate {
//  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
//      completionBlocks()
//    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
//      initialLayer.path = path as! CGPath
//    }
//  }
//}
