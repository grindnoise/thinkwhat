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
  
  
  // MARK: - Public properties
  var controllerOutput: ProfileCreationControllerOutput?
  var controllerInput: ProfileCreationControllerInput?
  
  
  
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
    navigationItem.setHidesBackButton(true, animated: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let banner = NewBanner(contentView: TextBannerContent(icon: Icon(category: .Logo, iconColor: Colors.main),
                                                          text: "account_fill_in".localized,
                                                          tintColor: Colors.main,
                                                          fontName: Fonts.Regular,
                                                          textStyle: .headline,
                                                          textAlignment: .natural),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: false,
                           useContentViewHeight: true,
                           shouldDismissAfter: 5)
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &self.subscriptions)
  }
}

extension ProfileCreationViewController: ProfileCreationViewInput {
  func onContentLanguageTap() {
    
  }
  
  func openApp() {
    appDelegate.window?.rootViewController = MainController()
  }
  
  func updateDescription(_ string: String) {
    let parameters = API.prepareUserData(description: string)
    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func updateFacebook(_ string: String) {
    guard let userprofile = Userprofiles.shared.current else { return }
    
    guard string != (userprofile.facebookURL?.absoluteString ?? "") else { return }
    
    let parameters = API.prepareUserData(facebookURL: string)
    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func updateInstagram(_ string: String) {
    guard let userprofile = Userprofiles.shared.current else { return }
    
    guard string != (userprofile.instagramURL?.absoluteString ?? "") else { return }
    
    let parameters = API.prepareUserData(instagramURL: string)
    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func updateTiktok(_ string: String) {
    guard let userprofile = Userprofiles.shared.current else { return }
    
    guard string != (userprofile.tiktokURL?.absoluteString ?? "") else { return }
    
    let parameters = API.prepareUserData(tiktokURL: string)
    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func fetchCity(userprofile: Userprofile, string: String) {
    controllerInput?.fetchCity(userprofile: userprofile, string: string)
  }
  
  func openCamera() {
    imagePicker.sourceType = UIImagePickerController.SourceType.camera
    present(imagePicker, animated: true, completion: nil)
  }
  
  func openGallery() {
    imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    present(imagePicker, animated: true, completion: nil)
  }
  
  func updateGender(_ gender: Gender) {
    let parameters = API.prepareUserData(gender: gender)
    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func updateBirthDate(_ date: Date) {
    let parameters = API.prepareUserData(birthDate: dateFormatter.string(from: date))
    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func updateUsername(_ dict: [String : String]) {
    let parameters = API.prepareUserData(firstName: dict.keys.first, lastName: dict.values.first)
    controllerInput?.updateUserprofile(parameters: parameters, image: nil)
  }
  
  func updateCity(_ instance: City) {
    controllerInput?.saveCity(instance) { _ in  }//Userprofiles.shared.current?.city = instance }//[weak self] _ in
//      Userprofiles.shared.current?.city = instance
      //            guard let self = self else { return }
      //
      //            let parameters = API.prepareUserData(city: instance)
      //            self.controllerInput?.updateUserprofile(parameters: parameters, image: nil)
//    }
  }
  
  func onSocialTapped(_ url: URL) {
    var vc: SFSafariViewController!
    let config = SFSafariViewController.Configuration()
    config.entersReaderIfAvailable = true
    vc = SFSafariViewController(url: url, configuration: config)
    present(vc, animated: true)
  }
  
  func openURL(_ url: URL) {
    var vc: SFSafariViewController!
    let config = SFSafariViewController.Configuration()
    config.entersReaderIfAvailable = true
    vc = SFSafariViewController(url: url, configuration: config)
    present(vc, animated: true)
    
    guard let main = tabBarController as? MainController else { return }
    
    main.toggleLogo(on: false)
  }
}

extension ProfileCreationViewController: ProfileCreationModelOutput {
  
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
    controllerInput?.updateUserprofile(parameters: parameters, image: compressedImage)
    NotificationCenter.default.post(name: Notifications.System.ImageUploadStart, object: [userprofile: compressedImage])
    
    dismiss(animated: true)
  }
}
