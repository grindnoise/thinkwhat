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
  public private(set) var currentTab: Tab = .Hot {
    didSet {
      guard oldValue != currentTab else { return }
      
      NotificationCenter.default.post(name: Notifications.System.Tab, object: currentTab)
    }
  }
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private let profileUpdater = PassthroughSubject<Date, Never>()
  private var shouldTerminate = false
  //    private var loadingIndicator: LoadingIndicator?
  /// **Logic**
  private var surveyId: String?  // Used when app was opened from push notification in closed state
  private var commentId: String? //
  /// **UI**
  private var logoCenterY: CGFloat = .zero
  private lazy var loadingIcon: Icon = {
    let instance = Icon(category: Icon.Category.Logo)
    instance.iconColor = Colors.main//.Logo.Flame.rawValue
    instance.scaleMultiplicator = 1.2
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var loadingText: Icon = {
    let instance = Icon(category: Icon.Category.LogoText)
    instance.iconColor = Colors.main//.Logo.Flame.rawValue
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.1
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.5).isActive = true
    
    return instance
  }()
  private lazy var loadingStack: UIStackView = {
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
    view.addSubview(instance)
    
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
  //    private var apiUnavailableView: APIUnavailableView?
  private lazy var logoIcon: Icon = {
    let instance = Icon(category: Icon.Category.Logo)
    instance.iconColor = Colors.main//.Logo.Flame.rawValue
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.2
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var logoText: Icon = {
    let instance = Icon(category: Icon.Category.LogoText)
    instance.iconColor = Colors.main//.Logo.Flame.rawValue
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.1
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.8).isActive = true
    
    return instance
  }()
  private lazy var passthroughView: PassthroughView = {
    let instance = PassthroughView(color: .clear)
    instance.frame = UIScreen.main.bounds
    instance.layer.zPosition = 99
    
    return instance
  }()
  private lazy var logoStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      logoIcon,
      logoText
    ])
    instance.alpha = 0
    instance.axis = .horizontal
    instance.spacing = 0
    instance.clipsToBounds = false
    //        instance.layer.zPosition = 100
    passthroughView.addSubview(instance)
    //        view.addSubview(instance)
    
    return instance
  }()
  private var isDataLoaded = false
  //    private lazy var logo: AppLogoWithText = {
  //        let instance = AppLogoWithText(color: Colors.Logo.Flame.main,
  //                                       minusToneColor: Colors.Logo.Flame.minusTone)
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
  /// - Parameter commentId: id of the survey extracted from push notification
  init(surveyId: String? = nil,
       commentId: String? = nil) {
    self.surveyId = surveyId
    self.commentId = commentId
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
  
  func toggleLogo(on: Bool, animated: Bool = true) {
    guard let constraint = logoStack.getConstraint(identifier: "top") else { return }
    
    if on, constraint.constant > 0 { return }
    if !on, constraint.constant < 0 { return }
    
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
      options: [.curveEaseInOut]) { [weak self] in
        guard let self = self else { return }
        
        self.logoStack.alpha = on ? 1 : 0
        constraint.constant = on ? self.logoCenterY : -self.logoStack.bounds.height
        self.passthroughView.layoutIfNeeded()
      }
  }
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
//    var logger = TimeLogger(sinceOrigin: true)
//    let subject = PassthroughSubject<Int,Never>()
//    // 43
//    let publisher = subject
//      .print("shareReplay")
//      .shareReplay(capacity: 2)
//    // 44
//    subject.send(0)
//
//    let subscription1 = publisher.sink(
//      receiveCompletion: {
//        print("subscription1 completed: \($0)", to: &logger)
//      },
//      receiveValue: {
//        print("subscription1 received \($0)", to: &logger)
//      }
//    )
//
//    subject.send(1)
//    subject.send(2)
//    subject.send(3)
//
//    let subscription2 = publisher.sink(
//      receiveCompletion: {
//        print("subscription2 completed: \($0)", to: &logger)
//      },
//      receiveValue: {
//        print("subscription2 received \($0)", to: &logger)
//      }
//    )
//
//    subject.send(4)
//    subject.send(5)
//    subject.send(completion: .finished)
//
//    var subscription3: Cancellable? = nil
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//      print("Subscribing to shareReplay after upstream completed")
//      subscription3 = publisher.sink(
//        receiveCompletion: {
//          print("subscription3 completed: \($0)", to: &logger)
//        },
//        receiveValue: {
//          print("subscription3 received \($0)", to: &logger)
//        }
//      )
//    }
    
    
    setSubscriptions()
    setViewControllers()
    setTasks()
    setupUI()
    loadData()
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
    
//    delay(seconds: 3) { [weak self] in
//      guard let self = self else { return }
//
//      self.launch()
////      self.logout()
//    }
    
//    delay(seconds: 7) { [weak self] in
//      guard let self = self else { return }
//
//      self.logout()
//    }
//    var test = LoadingIndicator(color: Colors.System.Red.rawValue)
//    test.didDisappearPublisher
//      .sink { _ in
//        test.removeFromSuperview()
//      }
//      .store(in: &subscriptions)
//
//    delayAsync(delay: 4) {[weak self] in
//      guard let self = self else { return }
//
//      test.placeInCenter(of: self.view,
//                         widthMultiplier: 0.33)
//      test.start()
//
//
//
//    }
//
//    delayAsync(delay: 8) {[weak self] in
//      guard let self = self else { return }
//      test.stop()
//    }
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
//    UserDefaults.clear()
//    subscriptions.forEach { $0 .cancel() }
//    loadingIcon.icon.removeAllAnimations()
//    loadingText.icon.removeAllAnimations()
//    passthroughView.removeFromSuperview()
//    API.shared.cancelAllRequests()
//    appDelegate.window?.rootViewController = GetStartedViewController()
  }
  
  @MainActor
  public func logout() {
    subscriptions.forEach { $0 .cancel() }
    loadingIcon.icon.removeAllAnimations()
    loadingText.icon.removeAllAnimations()
    passthroughView.removeFromSuperview()
    API.shared.cancelAllRequests()
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

private extension MainController {
  func setTasks() {
    guard let userprofile = Userprofiles.shared.current else { return }

    ///Subscription push notifications
    userprofile.notificationPublisher
      .throttle(for: .seconds(0.1), scheduler: DispatchQueue.main, latest: false)
      .receive(on: DispatchQueue.main)
      .sink {
        guard let user = $0.keys.first,
              let notify = $0.values.first
        else { return }
        
        let banner = NewBanner(contentView: UserBannerContentView(mode: notify ? .NotifyOnPublication : .DontNotifyOnPublication,
                                                                  userprofile: user),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 1)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
      .store(in: &subscriptions)
    
    Userprofiles.shared.newSubscriptionPublisher
      .throttle(for: .seconds(0.1), scheduler: DispatchQueue.main, latest: false)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        let banner = NewBanner(contentView: UserBannerContentView(mode: .Subscribe,
                                                                  userprofile: $0),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 1)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
      .store(in: &subscriptions)

    Userprofiles.shared.removeSubscriptionPublisher
      .throttle(for: .seconds(0.1), scheduler: DispatchQueue.main, latest: false)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        let banner = NewBanner(contentView: UserBannerContentView(mode: .Unsubscribe,
                                                                  userprofile: $0),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 1)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
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
      .receive(on: DispatchQueue.main)
      .sink { _ in
        
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "binoculars.fill")!,
                                                              text: "watch_survey_notification",
                                                              tintColor: .label),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
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
                let data = try userprofile.rawData()
                Userprofiles.shared.current = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode(Userprofile.self,
                                                                                                              from: data)
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


            //                        hideLogo()
            self.isDataLoaded = true
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
//                                   color: Colors.main))//Logo.Flame.rawValue),
//      } else {
//        viewControllers?.append(createNavigationController(for: HotController(surveyId: commentId),
//                                   title: "hot",
//                                   image: UIImage(systemName: "flame"),
//                                   selectedImage: UIImage(systemName: "flame.fill"),
//                                   color: Colors.main))//Logo.Flame.rawValue),
//      }
//    viewControllers?.append(createNavigationController(for: SubscriptionsController(),
//                                 title: "subscriptions",
//                                 image: UIImage(systemName: "bell"),
//                                 selectedImage: UIImage(systemName: "bell.fill"),
//                                 color: Colors.main))//Colors.Logo.CoolGray.rawValue),
//    viewControllers?.append(createNavigationController(for: ListController(), title: "list",
//                                 image: UIImage(systemName: "square.stack.3d.up"),
//                                 selectedImage: UIImage(systemName: "square.stack.3d.up.fill"),
//                                 color: Colors.main))//Colors.Logo.GreenMunshell.rawValue),
//    viewControllers?.append(createNavigationController(for: TopicsController(), title: "topics",
//                                 image: UIImage(systemName: "chart.bar.doc.horizontal"),
//                                 selectedImage: UIImage(systemName: "chart.bar.doc.horizontal.fill"),
//                                 color: Colors.main))//Colors.Logo.Marigold.rawValue),
//    viewControllers?.append(createNavigationController(for: SettingsController(), title: "settings",
//                                 image: UIImage(systemName: "gearshape"),
//                                 selectedImage: UIImage(systemName: "gearshape.fill"),
//                                 color: Colors.main))//Colors.Logo.AirBlue.rawValue),
    
    viewControllers = [
      createNavigationController(for: surveyId.isNil ? HotController(commentId: commentId) : HotController(surveyId: surveyId),
                                 title: "hot",
                                 image: UIImage(systemName: "flame"),
                                 selectedImage: UIImage(systemName: "flame.fill"),
                                 color: Colors.main),//Logo.Flame.rawValue),
      createNavigationController(for: SubscriptionsController(),
                                 title: "subscriptions",
                                 image: UIImage(systemName: "bell"),
                                 selectedImage: UIImage(systemName: "bell.fill"),
                                 color: Colors.main),//Colors.Logo.CoolGray.rawValue),
      createNavigationController(for: ListController(), title: "list",
                                 image: UIImage(systemName: "square.stack.3d.up"),
                                 selectedImage: UIImage(systemName: "square.stack.3d.up.fill"),
                                 color: Colors.main),//Colors.Logo.GreenMunshell.rawValue),
      createNavigationController(for: TopicsController(), title: "topics",
                                 image: UIImage(systemName: "chart.bar.doc.horizontal"),
                                 selectedImage: UIImage(systemName: "chart.bar.doc.horizontal.fill"),
                                 color: Colors.main),//Colors.Logo.Marigold.rawValue),
      createNavigationController(for: SettingsController(), title: "settings",
                                 image: UIImage(systemName: "gearshape"),
                                 selectedImage: UIImage(systemName: "gearshape.fill"),
                                 color: Colors.main),//Colors.Logo.AirBlue.rawValue),
    ]
  }
  
  @MainActor
  func setupUI() {
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationController?.navigationItem.largeTitleDisplayMode = .never
//    tabBarController?.view.backgroundColor = .white
    view.isUserInteractionEnabled = false
    tabBar.backgroundColor = .systemBackground
    tabBar.tintColor = Colors.main//.Logo.Flame.rawValue
    tabBar.shadowImage = UIImage()
    tabBar.backgroundImage = UIImage()
    tabBar.clipsToBounds = true
    
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 11)], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11)], for: .selected)
    
    delegate = self
    navigationItem.setHidesBackButton(true, animated: false)
    UITabBar.appearance().barTintColor = .systemBackground
    
    ///Fix visibility while loading
    tabBar.alpha = 0
    setTabBarVisible(visible: false, animated: false)
    loadingStack.placeInCenter(of: passthroughView,
                               widthMultiplier: 0.6)//,
//                               yOffset: -NavigationController.Constants.NavBarHeightSmallState)
    animateLoaderColor(from: Colors.Logo.Main, to: Colors.Logo.Main.next())
    
            appDelegate.window?.addSubview(passthroughView)
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
  func launch() {
    let icon = loadingIcon.replicate()
    let text = loadingText.replicate()
    icon.frame.origin = loadingStack.convert(loadingIcon.frame.origin, to: view)
    text.frame.origin = loadingStack.convert(loadingText.frame.origin, to: view)
    view.addSubview(icon)
    view.addSubview(text)
    loadingIcon.alpha = 0
    loadingText.alpha = 0
    ///Fix visibility while loading
    tabBar.alpha = 1
    setTabBarVisible(visible: true, animated: true)
    tabBarHeight = tabBar.bounds.height
    
    let destinationLogoSize = logoIcon.frame.size
    let destinationLogoOrigin = logoStack.convert(logoIcon.frame.origin, to: view)
    let destinationLogoPath = (logoIcon.icon as! CAShapeLayer).path
    let logoPathAnim = Animations.get(property: .Path,
                                      fromValue: (icon.icon as! CAShapeLayer).path as Any,
                                      toValue: destinationLogoPath as Any,
                                      duration: 0.25,
                                      delay: 0,
                                      repeatCount: 0,
                                      autoreverses: false,
                                      timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                      delegate: nil,
                                      isRemovedOnCompletion: false)
    let logoColorAnim = Animations.get(property: .FillColor,
                                       fromValue: loadingIcon.iconColor.cgColor as Any,
                                       toValue: logoIcon.iconColor.cgColor as Any,
                                       duration: 0.5,
                                       delay: 0,
                                       repeatCount: 0,
                                       autoreverses: false,
                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                       delegate: nil,
                                       isRemovedOnCompletion: false)
    icon.icon.add(logoColorAnim, forKey: nil)
    icon.icon.add(logoPathAnim, forKey: nil)

    let destinationTextSize = logoText.frame.size
    let destinationTextOrigin = logoStack.convert(logoText.frame.origin, to: view)
    let destinationTextPath = (logoText.icon as! CAShapeLayer).path
    let textPathAnim = Animations.get(property: .Path,
                                      fromValue: (text.icon as! CAShapeLayer).path as Any,
                                      toValue: destinationTextPath as Any,
                                      duration: 0.25,
                                      delay: 0,
                                      repeatCount: 0,
                                      autoreverses: false,
                                      timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                      delegate: nil,
                                      isRemovedOnCompletion: false)
    let textColorAnim = Animations.get(property: .FillColor,
                                       fromValue: loadingText.iconColor.cgColor as Any,
                                       toValue: logoText.iconColor.cgColor as Any,
                                       duration: 0.5,
                                       delay: 0,
                                       repeatCount: 0,
                                       autoreverses: false,
                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                       delegate: nil,
                                       isRemovedOnCompletion: false)
    text.icon.add(textColorAnim, forKey: nil)
    text.icon.add(textPathAnim, forKey: nil)

    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut],
      animations: {
        icon.frame.origin = destinationLogoOrigin
        text.frame.origin = destinationTextOrigin
        icon.frame.size = destinationLogoSize
        text.frame.size = destinationTextSize
      }) { [weak self] _ in
        guard let self = self else { return }
        
        icon.removeFromSuperview()
        text.removeFromSuperview()
        self.logoStack.alpha = 1
        self.view.isUserInteractionEnabled = true
        self.viewControllers?.forEach {
          guard let nav = $0 as? UINavigationController,// CustomNavigationController,
                let target = nav.viewControllers.first as? DataObservable else { return }
          target.onDataLoaded()
        }
        self.loadingStack.removeFromSuperview()
      }
  }
  
  func animateLoaderColor(from: Colors.Logo, to: Colors.Logo) {
    let anim_1 = Animations.get(property: .FillColor,
                                fromValue: from.rawValue.cgColor as Any,
                                toValue: to.rawValue.cgColor as Any,
                                duration: 1,
                                delay: 0,
                                repeatCount: 0,
                                autoreverses: false,
                                timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                delegate: self,
                                isRemovedOnCompletion: false,
                                completionBlocks: [
                                  {[weak self] in
                                    guard let self = self else { return }
                                    
                                    guard self.isDataLoaded else {
                                      delayAsync(delay: 0.75) {
                                        self.animateLoaderColor(from: to, to: to.next())
                                      }
                                      return
                                    }
                                    
                                    self.launch()
                                  }])
    let anim_2 = Animations.get(property: .FillColor,
                                fromValue: from.rawValue.cgColor as Any,
                                toValue: to.rawValue.cgColor as Any,
                                duration: 1,
                                delay: 0,
                                repeatCount: 0,
                                autoreverses: false,
                                timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                delegate: nil,
                                isRemovedOnCompletion: false)
    loadingIcon.icon.add(anim_1, forKey: nil)
    loadingText.icon.add(anim_2, forKey: nil)
//    (loadingIcon.icon as! CAShapeLayer).fillColor = to.rawValue.cgColor
//    (loadingText.icon as! CAShapeLayer).fillColor = to.rawValue.cgColor
    loadingIcon.iconColor = to.rawValue
        loadingText.iconColor = to.rawValue
  }
}

extension MainController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ScrollingTransitionAnimator(tabBarController: tabBarController, lastIndex: tabBarController.selectedIndex)
  }
  
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    func setActiveScreen(_ controller: UIViewController) {
      tabBarController.viewControllers?.forEach {
        guard var contr = $0 as? (ScreenVisible & UIViewController) else { return }
        
        contr.setActive(contr === controller ? true : false)
      }
    }
    
    func setColors(_ color: UIColor) {
      tabBar.tintColor = color
      let logoColorAnim = Animations.get(property: .FillColor,
                                         fromValue: logoIcon.iconColor.cgColor as Any,
                                         toValue: color.cgColor as Any,
                                         duration: tabAnimationDuration,
                                         delay: 0,
                                         repeatCount: 0,
                                         autoreverses: false,
                                         timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                         delegate: nil,
                                         isRemovedOnCompletion: false)
      self.logoIcon.icon.add(logoColorAnim, forKey: nil)
      self.logoIcon.iconColor = color
      
      let textColorAnim = Animations.get(property: .FillColor,
                                         fromValue: logoText.iconColor.cgColor as Any,
                                         toValue: color.cgColor as Any,
                                         duration: tabAnimationDuration,
                                         delay: 0,
                                         repeatCount: 0,
                                         autoreverses: false,
                                         timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                         delegate: nil,
                                         isRemovedOnCompletion: false)
      self.logoText.icon.add(textColorAnim, forKey: nil)
      self.logoText.iconColor = color
    }
    
    if let nav = viewController as? UINavigationController,
       let controller = nav.viewControllers.first {
      switch controller.self {
      case is HotController:
        currentTab = .Hot
        setColors(Colors.main)//.Logo.Flame.rawValue)
        setLogoCentered(animated: true)
        toggleLogo(on: true)
      case is SubscriptionsController:
        setColors(Colors.main)
//        setColors(Colors.Logo.CoolGray.rawValue)
        let controller = controller as! SubscriptionsController
        controller.isUserSelected ? { setLogoCentered(animated: true) }() : { setLogoLeading(constant: 10, animated: true) }() 
        toggleLogo(on: true)
      case is ListController:
        currentTab = .Feed
        setColors(Colors.main)
//setColors(Colors.Logo.GreenMunshell.rawValue)
        setLogoLeading(constant: 10, animated: true)
        toggleLogo(on: true)
      case is TopicsController:
        currentTab = .Topics
        setColors(Colors.main)
//setColors(Colors.Logo.Marigold.rawValue)
        setLogoCentered(animated: true)
        guard let instance = controller as? TopicsController,
              instance.mode != .Default
//              (instance.mode == .Search || instance.mode == .Topic)
        else { return }
        
        toggleLogo(on: false)
      case is SettingsController:
        currentTab = .Settings
        setColors(Colors.main)
//setColors(Colors.Logo.AirBlue.rawValue)
        setLogoCentered(animated: true)
        //                setLogoLeading(constant: 10, animated: true)
        toggleLogo(on: true)
      default:
        print("")
#if DEBUG
        fatalError()
#endif
      }
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
