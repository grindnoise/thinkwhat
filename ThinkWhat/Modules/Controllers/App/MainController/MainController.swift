//
//  MainController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

import UIKit
import UserNotifications
import SwiftyJSON
import Combine

class MainController: UITabBarController {//}, StorageProtocol {
  
  // MARK: - Overridden properties
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return selectedViewController?.preferredStatusBarStyle ?? .lightContent
  }
  override var childForStatusBarStyle: UIViewController? {
    return selectedViewController
  }
  
  // MARK: - Public properties
  @Published public private(set) var currentTab: Enums.Tab = .Hot {
    didSet {
      Notifications.UIEvents.tabItemPublisher.send([currentTab: oldValue])
//      NotificationCenter.default.post(name: Notifications.System.Tab, object: [currentTab: oldValue])
    }
  }
  public private(set) lazy var logoStack: UIStackView = {
    let opaque = UIView.opaque()
    logoIcon.translatesAutoresizingMaskIntoConstraints = false
    opaque.translatesAutoresizingMaskIntoConstraints = false
    logoText.place(inside: opaque, insets: UIEdgeInsets(top: NavigationController.Constants.NavBarHeightSmallState * 0.175, left: 0, bottom: NavigationController.Constants.NavBarHeightSmallState * 0.175, right: 0))
    
    let opaque2 = UIView.opaque()
    logoIcon.translatesAutoresizingMaskIntoConstraints = false
    opaque2.translatesAutoresizingMaskIntoConstraints = false
    logoIcon.place(inside: opaque2, insets: .uniform(size: NavigationController.Constants.NavBarHeightSmallState * 0.1))
    
    let instance = UIStackView(arrangedSubviews: [
      opaque2,
      opaque
    ])
    passthroughView.addSubview(instance)
    instance.axis = .horizontal
    instance.spacing = 0
    instance.alpha = 0
    
    return instance
  }()
  public private(set) var logoIsOnScreen = true
  public private(set) lazy var loadingText: LogoText = { LogoText() }()
  public private(set) lazy var loadingIcon: Logo = { Logo() }()
  public private(set) lazy var loadingStack: UIStackView = {
    let opaque = UIView.opaque()
    loadingIcon.placeInCenter(of: opaque, topInset: 0, bottomInset: 0)
    let instance = UIStackView(arrangedSubviews: [
      opaque,
      loadingText
    ])
    instance.axis = .vertical
    instance.spacing = 30

    return instance
  }()
  public private(set) lazy var spiral: Icon = { Icon(frame: .zero, category: .Spiral, scaleMultiplicator: 1, iconColor: traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.spiralDark : Constants.UI.Colors.spiralLight) }()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private let profileUpdater = PassthroughSubject<Date, Never>()
  private var shouldTerminate = false
  /// **Logic**
  private var tasksReady = false // Tasks setup flag
  private var dataLoaded = false {
    didSet {
      guard dataLoaded else { return }
      
      // Shared link or default launch
      shareLink.isNil ? launch() : loadSharedLink()
    }
  }
  private var appLaunched = false
  // Banners handlers
  private var bannersQueue: QueueArray<NewBanner> = QueueArray() // Store banners in queue
  private var isBannerOnScreen = false // Prevent banner overlay
  
  // These properties are received from push notifications
  private var surveyId: Int?  // Used when app was opened from push notification in closed state
  private var replyId: Int?   // Used when app was opened from push notification in closed state
  private var threadId: Int?  // Used when app was opened from push notification in closed state
  private var replyToId: Int? // Used when app was opened from push notification in closed state
  /// **UI**
  private var currentController: UIViewController? { UIApplication.topViewController() }
  private var logoCenterY: CGFloat = .zero
  private lazy var logoIcon: Logo = { Logo() }()
  private lazy var logoText: LogoText = { LogoText() }()
  private lazy var passthroughView: PassthroughView = {
    let instance = PassthroughView(color: .clear)
    instance.frame = appDelegate.window!.bounds //??  UIScreen.main.bounds
    instance.layer.zPosition = 99
    
    return instance
  }()
  private var shareLink: ShareLink?
  
  //    private lazy var logo: AppLogoWithText = {
  //        let instance = AppLogoWithText(color: Constants.UI.Colors.Logo.Flame.main,
  //                                       minusToneColor: Constants.UI.Colors.Logo.Flame.minusTone)
  //        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 6/1).isActive = true
  //        instance.isOpaque = false
  //        instance.layer.zPosition = 100
  //        view.addSubview(instance)
  //
  ////        let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
  ////        constraint.isActive = true
  ////
  ////        navigationController?.navigationBar.publisher(for: \.bounds)
  ////            .sink { rect in
  ////                constraint.constant = rect.height * 0.75
  ////            }
  ////            .store(in: &subscriptions)
  //
  //        return instance
  //    }()
  
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
  /// Init from push notification with survey id arrives when app is closed
  /// - Parameter surveyId: id of the survey extracted from push notification
  /// - Parameter replyId: reply id extracted from push notification
  /// - Parameter threadId: thread id extracted from push notification
  /// - Parameter replyToId: reply corresponding comment id extracted from push notification
  init(surveyId: Int? = nil,
       replyId: Int? = nil,
       threadId: Int? = nil,
       replyToId: Int? = nil) {
    self.surveyId = surveyId
    self.replyId = replyId
    self.threadId = threadId
    self.replyToId = replyToId
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  
  // MARK: - Public methods
  func setLogoInitialFrame(size: CGSize, y: CGFloat) {
    guard logoStack.frame == .zero else { return }
    
    logoStack.translatesAutoresizingMaskIntoConstraints = false
    logoStack.heightAnchor.constraint(equalToConstant: size.height * 0.65).isActive = true
    
    let leading = logoStack.leadingAnchor.constraint(equalTo: passthroughView.leadingAnchor)
    leading.identifier = "leading"
    leading.isActive = true
    
    let top = logoStack.topAnchor.constraint(equalTo: passthroughView.topAnchor)
    top.identifier = "top"
    top.isActive = true
    
    passthroughView.setNeedsLayout()
    passthroughView.layoutIfNeeded()
    
    logoCenterY = y  - self.logoStack.bounds.height/2
    
    passthroughView.setNeedsLayout()
    top.constant = logoCenterY//-logoStack.bounds.height
    leading.constant = (passthroughView.bounds.width - logoStack.bounds.width)/2
    passthroughView.layoutIfNeeded()
    
    UIView.animate(withDuration: 0.15) { [unowned self] in
      self.passthroughView.setNeedsLayout()
      //            self.logoStack.alpha = 1
      top.constant = y - self.logoStack.bounds.height/2
      self.passthroughView.layoutIfNeeded()
    }
    //        guard logoStack.frame == .zero else { return }
    //
    //        logoStack.translatesAutoresizingMaskIntoConstraints = false
    //        logoStack.heightAnchor.constraint(equalToConstant: size.height * 0.65).isActive = true
    //
    //        let leading = logoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    //        leading.identifier = "leading"
    //        leading.isActive = true
    //
    //        let top = logoStack.topAnchor.constraint(equalTo: view.topAnchor)
    //        top.identifier = "top"
    //        top.isActive = true
    //
    //        view.setNeedsLayout()
    //        view.layoutIfNeeded()
    //
    //        logoCenterY = y  - self.logoStack.bounds.height/2
    //
    //        view.setNeedsLayout()
    //        top.constant = logoCenterY//-logoStack.bounds.height
    //        leading.constant = (view.bounds.width - logoStack.bounds.width)/2
    //        view.layoutIfNeeded()
    //
    //        UIView.animate(withDuration: 0.15) { [unowned self] in
    //            self.view.setNeedsLayout()
    //            self.logoStack.alpha = 1
    //            top.constant = y - self.logoStack.bounds.height/2
    //            self.view.layoutIfNeeded()
    //        }
  }
  
  /// Changes vertical position of logo
  /// - Parameters:
  ///   - on: visible flag
  ///   - animated: animations flag
  ///   - completion: block of code to run after completion
  func toggleLogo(on: Bool, animated: Bool = true, completion: Closure? = nil) {
    guard let constraint = logoStack.getConstraint(identifier: "top") else { return }
    
    if on, constraint.constant > 0 { return }
    if !on, constraint.constant < 0 { return }
    
    logoIsOnScreen = on
    
    passthroughView.setNeedsLayout()
    
    guard animated else {
      constraint.constant = on ? logoCenterY : -logoStack.bounds.height
      logoStack.alpha = on ? 1 : 0
      passthroughView.layoutIfNeeded()
      
      return
    }
    
    UIView.animate(
      //      withDuration: 0.5,
      //      delay: 0,
      //      usingSpringWithDamping: 0.7,
      //      initialSpringVelocity: 0.4,
      withDuration: tabAnimationDuration,
      delay: 0.0,
      usingSpringWithDamping: 2.0,
      initialSpringVelocity: 0.5,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        self.logoStack.alpha = on ? 1 : 0
        constraint.constant = on ? self.logoCenterY : -self.logoStack.bounds.height
        self.passthroughView.layoutIfNeeded()
      }) { _ in completion?() }
  }
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setSubscriptions()
    setViewControllers()
    setTasks()
    setupUI()
    loadData()
    
    // Clear tmp directory if file is incomplete AF download/upload
    do {
      let tmpDirURL = FileManager.default.temporaryDirectory
      let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: tmpDirURL.path)
      try tmpDirectory.forEach { file in
        let fileUrl = tmpDirURL.appendingPathComponent(file)
        if file.contains("Alamofire_CFNetwork") {
          try FileManager.default.removeItem(atPath: fileUrl.path)
        }
      }
    } catch {
      debugPrint(error.localizedDescription)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    appDelegate.center.requestAuthorization(options: options) {
      (granted, error) in
      if !granted {
        print("Something went wrong")
      }
    }
    
    appDelegate.window?.addSubview(self.passthroughView)
  }
  
  
  // MARK: - Public methods
  public func setLogoLeading(constant: CGFloat, animated: Bool = false) {
    guard let leading = logoStack.getConstraint(identifier: "leading") else { return }
    
    passthroughView.setNeedsLayout()
    if animated {
      UIView.animate(
        withDuration: tabAnimationDuration,
        delay: 0.0,
        usingSpringWithDamping: 2.0,
        initialSpringVelocity: 0.5,
//        withDuration: 0.25,
//                     delay: 0,
                     options: .curveEaseInOut)  { [unowned self] in
        leading.constant = constant
        self.passthroughView.layoutIfNeeded()
      }
    } else {
      leading.constant = constant
      passthroughView.layoutIfNeeded()
    }
  }
  
  public func setLogoCentered(animated: Bool = false) {
    guard let leading = logoStack.getConstraint(identifier: "leading") else { return }
    
    let constant = (passthroughView.bounds.width - logoStack.bounds.width)/2
    
    view.setNeedsLayout()
    if animated {
      UIView.animate(withDuration: tabAnimationDuration,
                     delay: 0.0,
                     usingSpringWithDamping: 2.0,
                     initialSpringVelocity: 0.5,
//                     withDuration: 0.25,
//                     delay: 0,
                     options: .curveEaseInOut)  { [unowned self] in
        leading.constant = constant
        self.passthroughView.layoutIfNeeded()
      }
    } else {
      leading.constant = constant
      passthroughView.layoutIfNeeded()
    }
  }
  
  @MainActor
  public func deleteAccount() {
    Task { [weak self] in
      guard let self = self else { return }
      
      try await API.shared.profiles.deleteAccount()
      self.subscriptions.forEach { $0 .cancel() }
//      self.loadingIcon.icon.removeAllAnimations()
//      self.loadingText.icon.removeAllAnimations()
      self.passthroughView.removeFromSuperview()
      UserDefaults.clear()
      Surveys.clear()
      AppData.isEmailVerified = false
      if let token = PushNotifications.loadToken() {
        Task {
          PushNotifications.unregisterDevice(token: token) {
            KeychainService.deleteData()
          }
        }
      }
      Userprofiles.clear()
      appDelegate.window?.rootViewController = UINavigationController(rootViewController: StartViewController())
    }
  }
  
  @MainActor
  public func logout() {
    subscriptions.forEach { $0 .cancel() }
//    loadingIcon.icon.removeAllAnimations()
//    loadingText.icon.removeAllAnimations()
    passthroughView.removeFromSuperview()
    API.shared.cancelAllRequests()
    UserDefaults.clear()
    Surveys.clear()
    AppData.isEmailVerified = false
    AppData.isSocialAuth = true
    if let token = PushNotifications.loadToken() {
      Task {
        defer { KeychainService.deleteData() }
        PushNotifications.unregisterDevice(token: token)
      }
    } else {
      KeychainService.deleteData()
    }
    Userprofiles.clear()
    appDelegate.window?.rootViewController = UINavigationController(rootViewController: StartViewController())
  }
  
  /// Request publication with share link data
  /// - Parameters:
  ///   - shareLink: base64 hash
  public func requestPublication(shareLink: ShareLink) {
    self.shareLink = shareLink
    
    guard dataLoaded else { return }
    
    loadSharedLink()
  }
}

private extension MainController {
  func setTasks() {
    guard !tasksReady else { return }
    
    tasksReady = true
    
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
//          if !banner.isModal {
//            banner.dismiss()
//          }
          banner.didDisappearPublisher
            .sink { [unowned self] _ in
              banner.removeFromSuperview()
              self.isBannerOnScreen = false
//              self.bannersQueue.dequeue()
            }
            .store(in: &self.subscriptions)
        }
      }
      .store(in: &subscriptions)
    
    // Tab item listener to animate tab
    Notifications.UIEvents.tabItemPublisher
      .receive(on: DispatchQueue.main)
      .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: false)
      .sink { [unowned self] in 
        self.animateTab($0.keys.first!)
      }
      .store(in: &subscriptions)
    
    // Show banner on topic subscription/error
    Notifications.UIEvents.topicSubscriptionPublisher
      .receive(on: DispatchQueue.main)
      .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: false)
      .sink(receiveCompletion: { [weak self] in
        guard let self = self,
              case .failure(let error) = $0
        else { return }
        
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        self.bannersQueue.enqueue(NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                                                                           text: AppError.server.localizedDescription),
                                            contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                            isModal: false,
                                            useContentViewHeight: true,
                                            shouldPresent: false,
                                            shouldDismissAfter: 2))
      }, receiveValue: { [weak self] in
        guard let self = self else { return }
        
        self.bannersQueue.enqueue(NewBanner(contentView: TextBannerContent(icon: Icon.init(category: $0.iconCategory, scaleMultiplicator: 1.5, iconColor: self.traitCollection.userInterfaceStyle == .dark ? .white : $0.tagColor),
                                                                           text: "topics_subscription_added_start".localized + "\"\($0.title.capitalized)\"" + "topics_subscription_added_end".localized,
                                                                           textAlignment: .natural),
                                            contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                            isModal: false,
                                            useContentViewHeight: true,
                                            shouldPresent: false,
                                            shouldDismissAfter: 2))
      })
      .store(in: &subscriptions)
    
    tasks.append(Task {@MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.didBecomeActiveNotification) {
        guard let self = self, !self.dataLoaded else { return }
        
        self.spiral.startRotating(duration: 5)
      }
    })
    
    guard let userprofile = Userprofiles.shared.current else { return }

    ///Subscription push notifications
    userprofile.notificationPublisher
      .throttle(for: .seconds(0.1), scheduler: DispatchQueue.main, latest: false)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self,
              let user = $0.keys.first,
              let notify = $0.values.first
        else { return }
        
        self.bannersQueue.enqueue(NewBanner(contentView: UserBannerContentView(mode: notify ? .NotifyOnPublication : .DontNotifyOnPublication, userprofile: user),
                                            isModal: false,
                                            useContentViewHeight: true,
                                            shouldDismissAfter: 1))
      }
      .store(in: &subscriptions)
    
    Userprofiles.shared.newSubscriptionPublisher
      .throttle(for: .seconds(0.1), scheduler: DispatchQueue.main, latest: false)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.bannersQueue.enqueue(NewBanner(contentView: UserBannerContentView(mode: .Subscribe, userprofile: $0),
                                            isModal: false,
                                            useContentViewHeight: true,
                                            shouldDismissAfter: 1))
      }
      .store(in: &subscriptions)

    Userprofiles.shared.removeSubscriptionPublisher
      .throttle(for: .seconds(0.1), scheduler: DispatchQueue.main, latest: false)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.bannersQueue.enqueue(NewBanner(contentView: UserBannerContentView(mode: .Unsubscribe, userprofile: $0),
                                            isModal: false,
                                            useContentViewHeight: true,
                                            shouldDismissAfter: 1))
      }
      .store(in: &subscriptions)
    
//    userprofile.subscriptionsPublisher
//      .filter { !$0.isEmpty }
//      .first()
//      .receive(on: DispatchQueue.main)
//      .sink(receiveCompletion: {
//        if case .failure(let error) = $0 {
//#if DEBUG
//          print(error)
//#endif
//        }
//      }, receiveValue: { [unowned self] in
//        guard let new = $0.first else { return }
//
//        let banner = NewBanner(contentView: UserBannerContentView(mode: .Subscribe,
//                                                                    userprofile: new),
//                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                               isModal: false,
//                               useContentViewHeight: true,
//                               shouldDismissAfter: 1)
//        banner.didDisappearPublisher
//          .sink { _ in banner.removeFromSuperview() }
//          .store(in: &self.subscriptions)
//      })
//      .store(in: &subscriptions)

//    userprofile.subscriptionsRemovePublisher
//      .filter { !$0.isEmpty }
//      .first()
//      .receive(on: DispatchQueue.main)
//      .sink(receiveCompletion: {
//        if case .failure(let error) = $0 {
//#if DEBUG
//          print(error)
//#endif
//        }
//      }, receiveValue: { [unowned self] in
//        guard let new = $0.first else { return }
//
//        let banner = NewBanner(contentView: UserBannerContentView(mode: .Unsubscribe,
//                                                                    userprofile: new),
//                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                               isModal: false,
//                               useContentViewHeight: true,
//                               shouldDismissAfter: 1)
//        banner.didDisappearPublisher
//          .sink { _ in banner.removeFromSuperview() }
//          .store(in: &self.subscriptions)
//      })
//      .store(in: &subscriptions)

    
    ///Notify when survey is marked favorite
    SurveyReferences.shared.markedFavoritePublisher
    //      .filter { [unowned self] _ in !self.isBannerOnScreen }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.bannersQueue.enqueue(NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "binoculars.fill")!,
                                                                           text: "watch_survey_notification",
                                                                           tintColor: .label),
                                            isModal: false,
                                            useContentViewHeight: true,
                                            shouldDismissAfter: 2))
      }
      .store(in: &subscriptions)
  }
  
  func updateUserData() {
    Task {
      do {
        try await API.shared.profiles.updateCurrentUserStatistics()
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func setSubscriptions() {
    
    subscriptions.insert(
      Timer
        .publish(every: 60, on: .main, in: .common)
        .autoconnect()
        .subscribe(profileUpdater)
    )
    
    profileUpdater
      .sink { [unowned self] _ in
        
        self.updateUserData()
      }
      .store(in: &subscriptions)
    
  }
  
  // Set user's email confirmed
  func emailConfirmed() {
    AppData.isEmailVerified = true
    Task {
      do {
        let data = try await API.shared.profiles.updateUserprofileAsync(data: ["is_email_verified": true], uploadProgress: { progress in
#if DEBUG
          print(progress)
#endif
        })
        let instance = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode(Userprofile.self, from: data)
        Userprofiles.shared.current?.update(from: instance)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func sendVerificationCode(_ completion: @escaping (Result<[String : Any], Error>) -> ()) {
    Task {
      do {
        let dict = try await API.shared.auth.sendEmailVerificationCode()
        await MainActor.run {
          completion(.success(dict))
        }
      } catch {
        completion(.failure(error))
      }
    }
  }
  
  func loadData() {
    Task {
      do {
        let json = try await API.shared.system.appLaunch()
        //            API.shared.setWaitsForConnectivity()
        //            if let balance = json[DjangoVariables.UserProfile.balance].int {
        //                Userprofiles.shared.current!.balance = balance
        //            }
        
        await MainActor.run { [weak self] in
          guard let self = self else { return }
          
          do {
            guard let appData = json["app_data"] as? JSON,
                  let surveys = json["surveys"] as? JSON,
//                  let current = json["current_user"] as? JSON
                  let userData = json["user_data"] as? JSON,
                  let userprofile = userData["userprofile"] as? JSON
            else { throw AppError.server }

            do {
              try AppData.loadData(appData)

              if Userprofiles.shared.current.isNil {
                Userprofiles.shared.current = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode(Userprofile.self, from: try userprofile.rawData())
              }
            } catch {
              self.shouldTerminate = true
              switch error {
              case AppError.apiNotSupported:
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                self.present(alert, animated: true)
              default:
                print(error.localizedDescription)
#if DEBUG
                fatalError()
#endif
              }
            }

            guard !self.shouldTerminate else { return }

            try Userprofiles.updateUserData(userData)
            try? Surveys.shared.load(surveys)

            // If user hasn't verified email if he/she has resgistered via email
            if !AppData.isEmailVerified,
               !AppData.isSocialAuth,
               let email = UserDefaults.Profile.email,
               let components = email.components(separatedBy: "@") as? [String],
               let username = components.first,
               let firstLetter = username.first,
               let lastLetter = username.last,
               let code = AppData.emailVerificationCode {
              
              let banner = NewPopup(padding: 16,
                                    contentPadding: .uniform(size: 16))
              let content = EmailVerificationPopupContent(code: code,
                                                          retryTimeout: 60,
                                                          email: email.replacingOccurrences(of: username, with: "\(firstLetter)\(String.init(repeating: "*", count: username.count-2))\(lastLetter)"),
                                                          color: Constants.UI.Colors.main)
              content.verifiedPublisher
                .delay(for: .seconds(0.25), scheduler: DispatchQueue.main)
                .sink { [weak self] in
                  guard let self = self else { return }
                  
                  self.emailConfirmed()
                  banner.dismiss()
                }
                .store(in: &banner.subscriptions)
              content.retryPublisher
                .sink { [weak self] in
                  guard let self = self else { return }
                  
                  // Resend code via email
                  self.sendVerificationCode { [unowned self] in
                    
                    switch $0 {
                    case .success(let dict):
                      guard let code = dict["confirmation_code"] as? Int else { return }
                      
                      content.onEmailSent(code)
                    case.failure(let error):
#if DEBUG
                      error.printLocalized(class: type(of: self), functionName: #function)
#endif
                      self.bannersQueue.enqueue(NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                                                                                         text: AppError.server.localizedDescription),
                                                          isModal: false,
                                                          useContentViewHeight: true,
                                                          shouldDismissAfter: 2))
                    }
                  }}
                .store(in: &banner.subscriptions)
              banner.setContent(content)
              banner.didDisappearPublisher
                .sink { [unowned self] _ in
                  self.dataLoaded = true
                  banner.removeFromSuperview()
                }
                .store(in: &self.subscriptions)
              
              return
            }

            self.dataLoaded = true
            self.setTasks()
          } catch {
            self.loadData()
#if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
#endif
          }
        }
      } catch {
        self.loadData()
      }
    }
  }
  
  func pushController(_ controller: UIViewController, animated: Bool = true) {
    guard let currentController = currentController else { return }
    
    setTabBarVisible(visible: false, animated: true)
    toggleLogo(on: false)
    if currentController is NavigationController {
      (currentController as! UINavigationController).pushViewController(controller, animated: animated)
    } else {
      currentController.navigationController?.pushViewController(controller, animated: animated)
    }
  }
  
  func setLoadingSpinner(on: Bool) {
    if on {
      let bgView = UIView()
      let spinner = Logo()
      let spiral = Icon(frame: .zero, category: .Spiral,
                        scaleMultiplicator: 1,
                        iconColor: traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.spiralDark : Constants.UI.Colors.spiralLight)
      
      bgView.alpha = 0
      bgView.layer.zPosition = 2000
      bgView.accessibilityIdentifier = "loadingSpinner"
      bgView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground
      bgView.addSubview(spiral)
      bgView.addSubview(spinner)
      bgView.layer.masksToBounds = true
      appDelegate.window?.addSubview(bgView)
      bgView.edgesToSuperview()
      
      spiral.aspectRatio(1)
      spiral.widthToHeight(of: bgView, multiplier: 1.5)
      spiral.centerInSuperview()
      spiral.transform = .init(scaleX: 0.75, y: 0.75)
      spiral.alpha = 0
      spinner.centerXToSuperview()
      spinner.centerYToSuperview()
      spinner.widthToSuperview(multiplier: 0.31)
      spinner.transform = .init(scaleX: 0.75, y: 0.75)
      spinner.alpha = 0
      
      // Animations
      UIView.animate(withDuration: 0.3,
                     delay: 0,
                     options: .curveEaseInOut) {
        bgView.alpha = 1
      } completion: { _ in
        // Spiral presentation anim
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseInOut) {
          spiral.alpha = 1
          spiral.transform = .identity
        } completion: { _ in spiral.startRotating(duration: 5) }
        
        // Spinner presentation anim
        UIView.animate(withDuration: 0.15,
                       delay: 0.15,
                       options: .curveEaseInOut) {
          spinner.alpha = 1
          spinner.transform = .identity
        } completion: { _ in
          UIView.animate(withDuration: 1,
                         delay: 0,
                         options: [.autoreverse, .repeat, .curveEaseInOut]) { spinner.transform = .init(scaleX: 0.95, y: 0.95) }
        }
      }
    } else {
      guard let bgView = appDelegate.window?.getSubview(type: UIView.self, identifier: "loadingSpinner"),
            let spiral = bgView.getSubview(type: Icon.self),
            let spinner = bgView.getSubview(type: Logo.self)
      else { return }
      
      // Animations
      UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
        bgView.alpha = 0
      }) { _ in bgView.removeFromSuperview() }
      
      UIView.animate(withDuration: 0.3,
                     delay: 0,
                     options: .curveEaseInOut,
                     animations: {
//        bgView.alpha = 0
        spiral.transform = .init(scaleX: 1.25, y: 1.25)
        spiral.alpha = 0
        spinner.alpha = 0
        spinner.transform =  CGAffineTransform(scaleX: 0.25, y: 0.25)
      }) { _ in
        spinner.layer.removeAllAnimations()
        spinner.removeFromSuperview()
        spiral.stopRotating()
        spiral.removeFromSuperview()
      }
    }
  }
  
  /// Request publication by share link
  func loadSharedLink() {
    
    guard let shareLink = shareLink else { return }
    
    // Try to find existing publication to prevent api request
    if let instance = SurveyReferences.shared.findInstanceByShareLink(shareLink) {
      // Check if current controller is not the same controller we want to show
      if let pollController = currentController as? PollController,
         pollController.item == instance {
        return
      }
      
      // Reset share link
      self.shareLink = nil
      // Launch app if not started
      if !appLaunched {
        launch() { [weak self] in
          guard let self = self else { return }

          self.pushController(PollController(surveyReference: instance))
        }
      } else {
        pushController(PollController(surveyReference: instance))
      }
      
      return
    }
    
    // Api request
    Task { [weak self] in
      guard let self = self else { return }
      
      do {
        // Show loading spinner if app was launched
        if self.appLaunched { self.setLoadingSpinner(on: true) }
        
        // Request data
        let instance = try await API.shared.surveys.getSurvey(shareLink)
        instance.reference.tempShareLinks.append(shareLink)
        
        // Check if current controller is not the same controller we want to show
        if let pollController = currentController as? PollController,
           pollController.item == instance.reference {
          return
        }
        
        // Reset share link
        self.shareLink = nil
        if !self.appLaunched {
          self.launch() { [weak self] in
            guard let self = self else { return }
            
            // After launch animation present controller
            self.pushController(PollController(surveyReference: instance.reference))
          }
        } else {
          // Push controller in background
          self.pushController(PollController(surveyReference: instance.reference), animated: false)
          
          // Hide spinner with smooth delay
          delay(seconds: 0.3) {
            self.setLoadingSpinner(on: false)
          }
        }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        // Reset share link
        self.shareLink = nil
      }
    }
  }
  
  func setViewControllers() {
    func createNavigationController<C: UIViewController>(for rootViewController: C,
                                                         title: String,
                                                         image: UIImage?,
                                                         selectedImage: UIImage?,
                                                         color: UIColor) -> UIViewController where C: TintColorable {
      let navigationController = NavigationController(rootViewController: rootViewController)
      navigationController.title = title.localized
      navigationController.tabBarItem.title = title.localized
      navigationController.modalPresentationCapturesStatusBarAppearance = true
      navigationController.tabBarItem.image = image
      navigationController.tabBarItem.selectedImage = selectedImage
//      navigationController.navigationBar.prefersLargeTitles = false
//      navigationController.navigationItem.largeTitleDisplayMode = .never
      navigationController.setNavigationBarHidden(true, animated: false)
      //            navigationController.delegate = appDelegate.transitionCoordinator
      rootViewController.navigationItem.title = title.localized
      rootViewController.tintColor = color
      
      navigationController.viewControllers.forEach({ print($0) })
      
      return navigationController
    }
    
//    viewControllers = [UIViewController]()
//      // Init from push notification with survey id arrives when app is closed
//      if !surveyId.isNil {
//        viewControllers?.append(createNavigationController(for: HotController(surveyId: surveyId),
//                                   title: "hot",
//                                   image: UIImage(systemName: "flame"),
//                                   selectedImage: UIImage(systemName: "flame.fill"),
//                                   color: Constants.UI.Colors.main))//Logo.Flame.rawValue),
//      } else {
//        viewControllers?.append(createNavigationController(for: HotController(surveyId: commentId),
//                                   title: "hot",
//                                   image: UIImage(systemName: "flame"),
//                                   selectedImage: UIImage(systemName: "flame.fill"),
//                                   color: Constants.UI.Colors.main))//Logo.Flame.rawValue),
//      }
//    viewControllers?.append(createNavigationController(for: SubscriptionsController(),
//                                 title: "subscriptions",
//                                 image: UIImage(systemName: "bell"),
//                                 selectedImage: UIImage(systemName: "bell.fill"),
//                                 color: Constants.UI.Colors.main))//Constants.UI.Colors.Logo.CoolGray.rawValue),
//    viewControllers?.append(createNavigationController(for: ListController(), title: "list",
//                                 image: UIImage(systemName: "square.stack.3d.up"),
//                                 selectedImage: UIImage(systemName: "square.stack.3d.up.fill"),
//                                 color: Constants.UI.Colors.main))//Constants.UI.Colors.Logo.GreenMunshell.rawValue),
//    viewControllers?.append(createNavigationController(for: TopicsController(), title: "topics",
//                                 image: UIImage(systemName: "chart.bar.doc.horizontal"),
//                                 selectedImage: UIImage(systemName: "chart.bar.doc.horizontal.fill"),
//                                 color: Constants.UI.Colors.main))//Constants.UI.Colors.Logo.Marigold.rawValue),
//    viewControllers?.append(createNavigationController(for: SettingsController(), title: "settings",
//                                 image: UIImage(systemName: "gearshape"),
//                                 selectedImage: UIImage(systemName: "gearshape.fill"),
//                                 color: Constants.UI.Colors.main))//Constants.UI.Colors.Logo.AirBlue.rawValue),
    
    viewControllers = [
//      createNavigationController(for: surveyId.isNil ? HotController(surveyId: surveyId,
//                                                                     replyId: replyId,
//                                                                     threadId: threadId,
//                                                                     replyToId: replyToId) : HotController(surveyId: surveyId),
      createNavigationController(for: HotController(surveyId: surveyId,
                                                    replyId: replyId,
                                                    threadId: threadId,
                                                    replyToId: replyToId),
                                 title: "hot",
                                 image: UIImage(systemName: "flame", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),//
                                 selectedImage: UIImage(systemName: "flame.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),
                                 color: Constants.UI.Colors.main),//Logo.Flame.rawValue),
      createNavigationController(for: SubscriptionsController(),
                                 title: "subscriptions",
                                 image: UIImage(systemName: "bell", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),//),
                                 selectedImage: UIImage(systemName: "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),//),
                                 color: Constants.UI.Colors.main),//Constants.UI.Colors.Logo.CoolGray.rawValue),
      createNavigationController(for: ListController(), title: "list",
                                 image: UIImage(systemName: "square.stack.3d.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),//),
                                 selectedImage: UIImage(systemName: "square.stack.3d.up.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),//),
                                 color: Constants.UI.Colors.main),//Constants.UI.Colors.Logo.GreenMunshell.rawValue),
      createNavigationController(for: TopicsController(), title: "topics",
                                 image: UIImage(systemName: "chart.bar.doc.horizontal", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),//),
                                 selectedImage: UIImage(systemName: "chart.bar.doc.horizontal.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),//),
                                 color: Constants.UI.Colors.main),//Constants.UI.Colors.Logo.Marigold.rawValue),
      createNavigationController(for: SettingsController(), title: "settings",
                                 image: UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),//),
                                 selectedImage: UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 0, weight: .regular, scale: .medium)),//),
                                 color: Constants.UI.Colors.main),//Constants.UI.Colors.Logo.AirBlue.rawValue),
    ]
  }
  
  @MainActor
  func setupUI() {
    spiral.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground
    
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationController?.navigationItem.largeTitleDisplayMode = .never
//    tabBarController?.view.backgroundColor = .white
    view.isUserInteractionEnabled = false
    tabBar.backgroundColor = .systemBackground
    tabBar.tintColor = Constants.UI.Colors.Logo.Flame.rawValue
    tabBar.shadowImage = UIImage()
    tabBar.backgroundImage = UIImage()
    tabBar.clipsToBounds = true
    
    if #available(iOS 15, *) {
      let tabBarAppearance = UITabBarAppearance()
      tabBarAppearance.backgroundColor = .systemBackground
      tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.font: UIFont(name: Fonts.Rubik.Regular, size: 11) as Any]
//      tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.font: UIFont(name: Fonts.Rubik.Medium, size: 11) as Any]
      tabBar.standardAppearance = tabBarAppearance
      tabBar.scrollEdgeAppearance = tabBarAppearance
    } else {
      UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont(name: Fonts.Rubik.Regular, size: 11) as Any],
                                                       for: .normal)
//      UITabBarItem.appearance().setTitleTextAttributes([.font: StringAttributes.font(name: Fonts.Rubik.SemiBold, size: 11)],
//                                                       for: .selected)
    }
    
    delegate = self
    navigationItem.setHidesBackButton(true, animated: false)
    UITabBar.appearance().barTintColor = .systemBackground
    
    ///Fix visibility while loading
    tabBar.alpha = 0
    setTabBarVisible(visible: false, animated: false)
    
    appDelegate.window?.addSubview(passthroughView)
    
    loadingStack.placeInCenter(of: passthroughView)
    
    passthroughView.insertSubview(spiral, belowSubview: loadingStack)
    spiral.translatesAutoresizingMaskIntoConstraints = false
    spiral.heightAnchor.constraint(equalTo: spiral.widthAnchor).isActive = true
    spiral.widthAnchor.constraint(equalTo: passthroughView.heightAnchor, multiplier: 1.5).isActive = true
    spiral.centerXAnchor.constraint(equalTo: loadingIcon.centerXAnchor).isActive = true
    spiral.centerYAnchor.constraint(equalTo: loadingIcon.centerYAnchor).isActive = true
    spiral.startRotating(duration: 5)
    
    loadingIcon.translatesAutoresizingMaskIntoConstraints = false
    loadingIcon.widthAnchor.constraint(equalTo: passthroughView.widthAnchor, multiplier: 0.31).isActive = true
    loadingText.translatesAutoresizingMaskIntoConstraints = false
    loadingText.widthAnchor.constraint(equalTo: passthroughView.widthAnchor, multiplier: 0.5).isActive = true
    
//    loadingIcon.backgroundColor = .black
//    loadingStack.placeInCenter(of: passthroughView,
//                               widthMultiplier: 0.6)//,
////                               yOffset: -NavigationController.Constants.NavBarHeightSmallState)
////    animateLoaderColor(from: Constants.UI.Colors.Logo.Main, to: Constants.UI.Colors.Logo.Main.next())
    
  }
  
  func onServerUnavailable() {
    loadData()
    //        apiUnavailableView = APIUnavailableView(frame: view.frame, delegate: self)
    //        apiUnavailableView?.alpha = 0
    //        apiUnavailableView?.addEquallyTo(to: view)
    //        view.isUserInteractionEnabled = true
    //        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseInOut) {
    //            self.loadingIndicator?.alpha = 0
    //        } completion: { _ in
    //            self.loadingIndicator?.removeAllAnimations()
    //            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
    //                self.apiUnavailableView?.alpha = 1
    //            } completion: { _ in
    //                self.loadingIndicator?.removeFromSuperview()
    //            }
    //        }
  }
  
  @MainActor
  func launch(_ completion: Closure? = nil) {
    appLaunched = true
    // Add temp logo
    let fakeLogoIcon = Logo(frame: CGRect(origin: loadingIcon.superview!.convert(loadingIcon.frame.origin,
                                                                            to: passthroughView),
                                   size: loadingIcon.bounds.size))
//    fakeLogoIcon.backgroundColor = .black
    fakeLogoIcon.removeConstraints(fakeLogoIcon.getAllConstraints())
    passthroughView.addSubview(fakeLogoIcon)

    // Add temp logo text
    let fakeLogoText = LogoText(frame: CGRect(origin: loadingText.superview!.convert(loadingText.frame.origin,
                                                                               to: passthroughView),
                                      size: loadingText.bounds.size))
    fakeLogoText.removeConstraints(fakeLogoText.getAllConstraints())
    passthroughView.addSubview(fakeLogoText)
    
//    // Logo path animation
//    let anim1 = Animations.get(property: .Path,
//                               fromValue: (loadingIcon.icon.icon as! CAShapeLayer).path as Any,
//                               toValue: (logoIcon.icon.icon as! CAShapeLayer).path?.boundingBox as Any,
//                               duration: 0.3,
//                               delay: 0,
//                               repeatCount: 0,
//                               autoreverses: false,
//                               timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                               delegate: nil,
//                               isRemovedOnCompletion: false)
//    let anim2 = Animations.get(property: .Path,
//                               fromValue: (loadingIcon.background.icon as! CAShapeLayer).path as Any,
//                               toValue: (logoIcon.background.icon as! CAShapeLayer).path as Any,
//                               duration: 0.3,
//                               delay: 0,
//                               repeatCount: 0,
//                               autoreverses: false,
//                               timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                               delegate: nil,
//                               isRemovedOnCompletion: false)
//    fakeLogoIcon.icon.icon.add(anim1, forKey: nil)
//    fakeLogoIcon.background.icon.add(anim2, forKey: nil)
    
    // Hide loading icon & text
    loadingIcon.alpha = 0
    loadingText.alpha = 0
    
    // Animate
    //    spiral.startRotating(duration: 1)
    UIView.animate(withDuration: 0.3,
                   delay: 0,
                   options: .curveEaseIn,
                   animations: { [weak self] in
      guard let self = self else { return }
      self.spiral.transform = .init(scaleX: 1.25, y: 1.25)
      self.spiral.alpha = 0
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.spiral.removeFromSuperview()
      // Reveal tab bar
      tabBar.alpha = 1
      setTabBarVisible(visible: true, animated: true)
      tabBarHeight = tabBar.bounds.height
      self.view.isUserInteractionEnabled = true
      self.viewControllers?.forEach {
        guard let nav = $0 as? UINavigationController,// CustomNavigationController,
              let target = nav.viewControllers.first as? DataObservable else { return }
        target.onDataLoaded()
      }
      self.loadingStack.removeFromSuperview()
    }
    
    UIView.animate(
      withDuration: 0.6,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 0.3,
      options: [.curveEaseOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        fakeLogoIcon.frame = CGRect(origin: self.logoIcon.superview!.convert(self.logoIcon.frame.origin,
                                                                             to: self.passthroughView),
                                    size: self.logoIcon.bounds.size)
        fakeLogoText.frame = CGRect(origin: self.logoText.superview!.convert(logoText.frame.origin,
                                                                        to: self.passthroughView),
                                    size: self.logoText.bounds.size)
      }) { _ in
        self.logoStack.alpha = 1
        fakeLogoIcon.removeFromSuperview()
        fakeLogoText.removeFromSuperview()
        completion?()
      }
    
//
//    let destinationLogoSize = logoIcon.frame.size
//    let destinationLogoOrigin = logoStack.convert(logoIcon.frame.origin, to: view)
//
//    UIView.animate(
//      withDuration: 0.5,
//      delay: 0,
//      usingSpringWithDamping: 0.8,
//      initialSpringVelocity: 0.3,
//      options: [.curveEaseInOut],
//      animations: {
////        icon.frame.origin = destinationLogoOrigin
////        text.frame.origin = destinationTextOrigin
////        icon.frame.size = destinationLogoSize
////        text.frame.size = destinationTextSize
//      }) { [weak self] _ in
//        guard let self = self else { return }
//
////        icon.removeFromSuperview()
////        text.removeFromSuperview()
//        self.logoStack.alpha = 1
//        self.view.isUserInteractionEnabled = true
//        self.viewControllers?.forEach {
//          guard let nav = $0 as? UINavigationController,// CustomNavigationController,
//                let target = nav.viewControllers.first as? DataObservable else { return }
//          target.onDataLoaded()
//        }
//        self.loadingStack.removeFromSuperview()
//      }
  }
  
  @MainActor
  func animateTab(_ tab: Enums.Tab) {
    let buttons = tabBar.subviews.filter { $0.isKind(of: NSClassFromString("UITabBarButton")!) }
    guard tab.rawValue <= buttons.count-1 else { return }
    
    let color = tab.getColor(traitCollection: traitCollection).withAlphaComponent(0.5)
    
    buttons[tab.rawValue].layer.masksToBounds = false
    
    Animations.tapCircled(layer: tabBar.layer,
                          fillColor: color.cgColor,
                          location: buttons[tab.rawValue].center,
                          size: .uniform(size: tabBar.bounds.height*0.4),
                          duration: 0.2,
                          timingFunction: .easeOut)
    
  }
}

extension MainController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ScrollingTransitionAnimator(tabBarController: tabBarController, lastIndex: tabBarController.selectedIndex)
  }
  
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    func setActiveScreen(_ controller: UIViewController) {
      tabBarController.viewControllers?.forEach {
        guard let contr = $0 as? (ScreenVisible & UIViewController) else { return }
        
        contr.setActive(contr === controller ? true : false)
      }
    }
  
    tabBar.tintColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.tabBarDark : Constants.UI.Colors.tabBarLight//Constants.UI.Colors.bannerDark
    if let nav = viewController as? UINavigationController,
       let controller = nav.viewControllers.first {
      switch controller.self {
      case is HotController:
        tabBar.tintColor = Constants.UI.Colors.Logo.Flame.rawValue
//        setColors(Constants.UI.Colors.main)//.Logo.Flame.rawValue)
        if controller is TabBarTappable { (controller as! TabBarTappable).tabBarTapped(currentTab == .Hot ? .Repeat : .Primary ) }
        currentTab = .Hot
        setLogoCentered(animated: true)
        toggleLogo(on: true)
      case is SubscriptionsController:
//        setColors(Constants.UI.Colors.main)
//        setColors(Constants.UI.Colors.Logo.CoolGray.rawValue)
        if controller is TabBarTappable { (controller as! TabBarTappable).tabBarTapped(currentTab == .Subscriptions ? .Repeat : .Primary ) }
        currentTab = .Subscriptions
        let controller = controller as! SubscriptionsController
        controller.isUserSelected ? { setLogoCentered(animated: true) }() : { setLogoLeading(constant: 10, animated: true) }() 
        toggleLogo(on: true)
      case is ListController:
        if controller is TabBarTappable { (controller as! TabBarTappable).tabBarTapped(currentTab == .Feed ? .Repeat : .Primary ) }
        currentTab = .Feed
        setLogoCentered(animated: true)
        toggleLogo(on: true)
      case is TopicsController:
        if controller is TabBarTappable { (controller as! TabBarTappable).tabBarTapped(currentTab == .Topics ? .Repeat : .Primary ) }
        currentTab = .Topics
//        setColors(Constants.UI.Colors.main)
//setColors(Constants.UI.Colors.Logo.Marigold.rawValue)
        setLogoCentered(animated: true)
        guard let instance = controller as? TopicsController,
              instance.mode != .Default
//              (instance.mode == .Search || instance.mode == .Topic)
        else { return }
        
        toggleLogo(on: false)
      case is SettingsController:
        if controller is TabBarTappable { (controller as! TabBarTappable).tabBarTapped(currentTab == .Settings ? .Repeat : .Primary ) }
        currentTab = .Settings
//        setColors(Constants.UI.Colors.main)
//setColors(Constants.UI.Colors.Logo.AirBlue.rawValue)
        setLogoCentered(animated: true)
        //                setLogoLeading(constant: 10, animated: true)
        toggleLogo(on: true)
      default: return }
    }
    
    guard let vc = navigationController?.viewControllers.first else { return }
    if viewController.isKind(of: HotController.self) {
      navigationController?.title = "hot".localized
      vc.navigationItem.title = "hot".localized
    } else if vc.isKind(of: SubscriptionsController.self) {
      navigationController?.title = "subscriptions".localized
      vc.navigationItem.title = "subscriptions".localized
    }
  }
}

extension MainController: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
    }
  }
}
