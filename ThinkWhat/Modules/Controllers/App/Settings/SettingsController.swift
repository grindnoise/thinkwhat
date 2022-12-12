//
//  SettingsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SafariServices
import Combine

class SettingsController: UIViewController, UINavigationControllerDelegate, TintColorable {
    
    enum Mode: String {
        case Profile = "profile"
        case Settings = "settings"
    }
    
    
    
    // MARK: - Public properties
    var controllerOutput: SettingsControllerOutput?
    var controllerInput: SettingsControllerInput?
    var mode: SettingsController.Mode = .Profile {
        didSet {
            guard oldValue != mode else { return }
            
//            setTitle()
            
            switch mode {
            case .Settings:
                controllerOutput?.onAppSettings()
            case .Profile:
                controllerOutput?.onUserSettings()
            }
        }
    }
    public var tintColor: UIColor = .clear {
        didSet {
            setNavigationBarTintColor(tintColor)
            settingsSwitch.color = tintColor
        }
    }
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private var isOnScreen = true
    private lazy var titleStack: UIStackView = {
        let opaque = UIView()
        opaque.backgroundColor = .clear
        
        let instance = UIStackView(arrangedSubviews: [
            opaque,
            settingsSwitch
        ])
        instance.axis = .horizontal
        instance.spacing = 0
        
        return instance
    }()
//    private lazy var titleLabel: UILabel = {
//       let instance = UILabel()
//        instance.font = UIFont(name: Fonts.Bold,
//                               size: 32)
//        instance.textAlignment = .left
//        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .label
//        instance.text = ""
//
//        return instance
//    }()
    private lazy var settingsSwitch: SettingsSwitch = {
        let instance = SettingsSwitch()
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 2.1).isActive = true
        instance.statePublisher
            .sink { [weak self] in
                guard let self = self,
                      let state = $0
                else { return }
                
                self.mode = state
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var imagePicker: UIImagePickerController = {
        let instance = UIImagePickerController()
        instance.delegate = self
        instance.allowsEditing = true
        
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
    
    
    
    // MARK: - Overridden properties
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = SettingsModel()
               
        self.controllerOutput = view as? SettingsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        navigationItem.title = "profile".localized
        
        setupUI()
        setTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label)
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        titleStack.alpha = 1
        self.navigationController?.navigationBar.alpha = 1
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) { [weak self] in
            guard let self = self else { return }

            self.titleStack.alpha = 0
            self.navigationController?.navigationBar.alpha = 0
//            self.settingsSwitch.transform = .identity
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
//        titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .label
    }
}

private extension SettingsController {
    @MainActor
    func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = ""
        
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        navigationBar.addSubview(titleStack)
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStack.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            titleStack.heightAnchor.constraint(equalToConstant: 40),
            titleStack.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 10),
            titleStack.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -10)
        ])
        
//        setTitle()
    }
    
    func setTasks() {
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.System.Tab) {
                guard let self = self,
                      let tab = notification.object as? Tab
                else { return }
                
                self.isOnScreen = tab == .Settings
            }
        })
        tasks.append(Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: UIApplication.didEnterBackgroundNotification) {
                guard let self = self,
                      self.isOnScreen
                else { return }
                
                self.isOnScreen = false
            }
        })
        tasks.append(Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: UIApplication.didBecomeActiveNotification) {
                guard let self = self,
                      let main = self.tabBarController as? MainController,
                      main.selectedIndex == 4
                else { return }
                
                self.isOnScreen = true
            }
        })
    }
    
//    @MainActor
//    func setTitle(animated: Bool = true) {
//        guard animated else {
//            titleLabel.text = mode.rawValue.localized
//            return
//        }
//
//        UIView.transition(with: titleLabel,
//                          duration: 0.15,
//                          options: .transitionCrossDissolve) { [weak self] in
//            guard let self = self else { return }
//
//            self.titleLabel.text = self.mode.rawValue.localized
//        }
//    }
}

// MARK: - View Input
extension SettingsController: SettingsViewInput {
    func showLicense() {
        var vc: SFSafariViewController!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        vc = SFSafariViewController(url: API_URLS.System.licenses!, configuration: config)
        present(vc, animated: true)
    }
    
    func showTerms() {
        var vc: SFSafariViewController!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        vc = SFSafariViewController(url: API_URLS.System.termsOfUse!, configuration: config)
        present(vc, animated: true)
    }
    
    func feedback() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(FeedbackViewController(), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onContentLanguageTap() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(LanguageListViewController(), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func updateAppSettings(_ settings: [AppSettings : Any]) {
        controllerInput?.updateAppSettings(settings)
    }
    
    func onWatchingSelected() {
        guard let userprofile = Userprofiles.shared.current,
            userprofile.favoritesTotal != 0
        else { return }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(SurveysController(.Favorite), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onSubscriptionsSelected() {
        guard let userprofile = Userprofiles.shared.current,
            userprofile.subscriptionsTotal != 0
        else { return }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(UserprofilesController(mode: .Subscriptions, userprofile: userprofile), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onSubscribersSelected() {
        guard let userprofile = Userprofiles.shared.current,
            userprofile.subscribersTotal != 0
        else { return }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(UserprofilesController(mode: .Subscribers, userprofile: userprofile), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onPublicationsSelected() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(SurveysController(.Own), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onTopicSelected(_ topic: Topic) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(SurveysController(topic), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
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
    
    func onCitySearch(_ instance: String) {
        controllerInput?.fetchCity(instance)
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
        controllerInput?.saveCity(instance) { [weak self] _ in
            Userprofiles.shared.current?.city = instance
//            guard let self = self else { return }
//
//            let parameters = API.prepareUserData(city: instance)
//            self.controllerInput?.updateUserprofile(parameters: parameters, image: nil)
        }
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
    }
}

// MARK: - Model Output
extension SettingsController: SettingsModelOutput {
    
    func onError(_ error: Error) {
        controllerOutput?.onError(error)
    }
}

extension SettingsController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension SettingsController: UIImagePickerControllerDelegate {
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
