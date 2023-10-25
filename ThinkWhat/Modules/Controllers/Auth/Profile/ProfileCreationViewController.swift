//
//  ProfileCreationViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import SafariServices

class ProfileCreationViewController: UIViewController, UINavigationControllerDelegate {

  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private lazy var imagePicker: UIImagePickerController = {
    let instance = UIImagePickerController()
    instance.delegate = self
    instance.allowsEditing = true
    
    return instance
  }()
  ///**Logic**
  private var username: String
  private var gender: Enums.Gender
  // Banners
  private var bannersQueue: QueueArray<NewBanner> = QueueArray() // Store banners in queue
  private var isBannerOnScreen = false // Prevent banner overlay
  
  // MARK: - Public properties
  var controllerOutput: ProfileCreationControllerOutput?
  var controllerInput: ProfileCreationControllerInput?
  ///**Logic**
  public private(set) var userprofile: Userprofile
  ///**UI**
  public private(set) lazy var logoStack: UIStackView = {
    let logoIcon: Icon = {
      let instance = Icon(category: Icon.Category.Logo)
      instance.accessibilityIdentifier = "logoIcon"
      instance.iconColor = Constants.UI.Colors.main
      instance.isRounded = false
      instance.clipsToBounds = false
      instance.scaleMultiplicator = 1.2
      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
      instance.heightAnchor.constraint(equalToConstant: NavigationController.Constants.NavBarHeightSmallState * 0.65).isActive = true
      
      return instance
    }()
    let logoText: Icon = {
      let instance = Icon(category: Icon.Category.LogoText)
      instance.accessibilityIdentifier = "logoText"
      instance.iconColor = Constants.UI.Colors.main
      instance.isRounded = false
      instance.clipsToBounds = false
      instance.scaleMultiplicator = 1.1
      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.8).isActive = true
      
      return instance
    }()
    
    let instance = UIStackView(arrangedSubviews: [
      logoIcon,
      logoText
    ])
//    instance.alpha = 0
    instance.axis = .horizontal
    instance.spacing = 0
    instance.clipsToBounds = false
    
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
  init(userprofile: Userprofile) {
    self.userprofile = userprofile
    self.username = userprofile.username
    self.gender = userprofile.gender
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overridden Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = ProfileCreationView()
    let model = ProfileCreationModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView

    setTasks()
    setupUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
//    delay(seconds: 0.5) { [weak self] in
//      guard let self = self else { return }
//      
//      let banner = NewBanner(contentView: TextBannerContent(icon: Icon(category: .Logo, iconColor: Constants.UI.Colors.main),
//                                                            text: "account_fill_in".localized,
//                                                            tintColor: Constants.UI.Colors.main,
//                                                            fontName: Fonts.Regular,
//                                                            textStyle: .headline,
//                                                            textAlignment: .natural),
//                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                             isModal: false,
//                             useContentViewHeight: true,
//                             shouldDismissAfter: 5)
//      banner.didDisappearPublisher
//        .sink { _ in banner.removeFromSuperview() }
//        .store(in: &self.subscriptions)
//    }
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    updateTraits()
  }
}

private extension ProfileCreationViewController {
  @MainActor
  func setupUI() {
    navigationItem.setHidesBackButton(true, animated: false)
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.setBarShadow(on: false)
    
    // Traits listener
    if #available(iOS 17.0, *) {
      registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(self.updateTraits))
    }
    
    guard let navBar = navigationController?.navigationBar,
          navBar.subviews.filter({ $0 is UIStackView }).isEmpty
    else { return }
                              
    logoStack.placeInCenter(of: navBar)
  }
  
  func setTasks() {
    // Banner queue listener
    Timer
      .publish(every: 0.5, on: .main, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in !self.isBannerOnScreen}
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        if let banner = self.bannersQueue.dequeue() {
          self.isBannerOnScreen = true
          banner.present()
          banner.didDisappearPublisher
            .sink { [unowned self] _ in
              banner.removeFromSuperview()
              self.isBannerOnScreen = false
            }
            .store(in: &self.subscriptions)
        }
      }
      .store(in: &subscriptions)
  }
  
  @objc
  func updateTraits() {
    navigationController?.setBarShadow(on: false)
  }
  
//  func enqueueBanner(image: UIImage? = nil,
//                     icon: Icon? = nil,
//                     text: String,
//                     attributedText: NSAttributedString? = nil,
//                     isModal: Bool = false,
//                     shouldPresent: Bool = false,
//                     shouldDismissAfter: Double = 2.0) {
//    bannersQueue.enqueue(NewBanner(contentView: TextBannerContent(image: image, icon: icon, text: text, attributedText: attributedText),
//                                   contentPadding: UIEdgeInsets(top: Constants.UI.padding*2, left: Constants.UI.padding, bottom: Constants.UI.padding*2, right: Constants.UI.padding),
//                                   isModal: isModal,
//                                   useContentViewHeight: true,
//                                   shouldPresent: shouldPresent,
//                                   shouldDismissAfter: shouldDismissAfter))
//  }
}

extension ProfileCreationViewController: ProfileCreationViewInput {
  func setUsername(_ username: String) {
    self.username = username
  }
  
  func setGender(_ gender: Enums.Gender) {
    self.gender = gender
  }
  
  func showBanner(_ banner: NewBanner) {
    bannersQueue.enqueue(banner)
  }
  
  func checkUsernameAvailability(_ username: String) {
    controllerInput?.checkUsernameAvailability(username)
  }
  
  func onContentLanguageTap() {
    
  }
  
  func openApp() {
    appDelegate.window?.rootViewController = MainController(surveyId: nil)
  }
  
  func updateDescription(_ string: String) {
//    let parameters = API.prepareUserData(description: string)
//    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func openCamera() {
    imagePicker.sourceType = UIImagePickerController.SourceType.camera
    present(imagePicker, animated: true, completion: nil)
  }
  
  func openGallery() {
    imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    present(imagePicker, animated: true, completion: nil)
  }
  
  func updateGender(_ gender: Enums.Gender) {
//    let parameters = API.prepareUserData(gender: gender)
//    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func updateBirthDate(_ date: Date) {
//    let parameters = API.prepareUserData(birthDate: dateFormatter.string(from: date))
//    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func updateUsername(_ dict: [String : String]) {
//    let parameters = API.prepareUserData(firstName: dict.keys.first, lastName: dict.values.first)
//    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
}

extension ProfileCreationViewController: ProfileCreationModelOutput {
  func usernameLoadingCallback() {
    controllerOutput?.usernameLoadingCallback()
  }
  
  func usernameAvailabilityCallback(_ res: Result<Bool, Error>) {
    controllerOutput?.usernameAvailabilityCallback(res)
  }
}

extension ProfileCreationViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let origImage = info[.editedImage] as? UIImage,
          let resizedImage = origImage.resized(to: CGSize(width: 200, height: 200)) as? UIImage,
          let imageData = resizedImage.jpegData(compressionQuality: 0.4),
          let compressedImage = UIImage(data: imageData),
          let userprofile = Userprofiles.shared.current
    else { return }
    
    let parameters = API.prepareUserData(image: compressedImage)
//    controllerInput?.updateUserprofile(parameters: parameters, image: compressedImage)
    NotificationCenter.default.post(name: Notifications.System.ImageUploadStart, object: [userprofile: compressedImage])
    
    dismiss(animated: true)
  }
}
