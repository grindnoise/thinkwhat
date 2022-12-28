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
  //UI
  private var logoCenterY: CGFloat = .zero
  private lazy var loadingIcon: Icon = {
    let instance = Icon(category: Icon.Category.Logo)
    instance.iconColor = Colors.Logo.Flame.rawValue
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.2
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var loadingText: Icon = {
    let instance = Icon(category: Icon.Category.LogoText)
    instance.iconColor = Colors.Logo.Flame.rawValue
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
    instance.iconColor = Colors.Logo.Flame.rawValue
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.2
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var logoText: Icon = {
    let instance = Icon(category: Icon.Category.LogoText)
    instance.iconColor = Colors.Logo.Flame.rawValue
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.1
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.8).isActive = true
    
    return instance
  }()
  private lazy var passthroughView: PassthroughView = {
    let instance = PassthroughView(frame: UIScreen.main.bounds)
    instance.backgroundColor = .clear
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
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 0.4,
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
    
    setSubscriptions()
    setViewControllers()
    //        setTasks()
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
    
    delayAsync(delay: 2) {
      //        let banner = Banner(fadeBackground: false)
      //        banner.present(content: TextBannerContent(image: UIImage(systemName: "binoculars.fill")!,
      //                                                  text: "watch_survey_notification",
      //                                                  tintColor: .label),
      //                       dismissAfter: 10.75)
      //        banner.didDisappearPublisher
      //            .sink { _ in banner.removeFromSuperview() }
      //            .store(in: &self.subscriptions)
      
      
      //        let banner = NewBanner(contentView: SelectSideApp(app: .Youtube),
      //                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
      //                               isModal: false,
      ////                               useShadows: false,
      //                               useContentViewHeight: true,
      //                               shouldDismissAfter: 2)
      //        banner.didDisappearPublisher
      //          .sink { _ in banner.removeFromSuperview() }
      //          .store(in: &self.subscriptions)
    }
  }
}

private extension MainController {
  func setTasks() {
    //Subscription push notifications
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NotifyOnPublications) {
        guard let self = self,
              let userprofile = notification.object as? Userprofile,
              let notify = userprofile.notifyOnPublication
        else { return }
        
        let banner = Banner(fadeBackground: false)
        banner.present(content: UserNotificationContent(mode: notify ? .NotifyOnPublication : .DontNotifyOnPublication,
                                                        userprofile: userprofile),
                       dismissAfter: 0.75)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
    })
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsAppend) {
        guard let self = self,
              let dict = notification.object as? [Userprofile: Userprofile],
              let userprofile = dict.values.first
        else { return }
        
        let banner = Banner(fadeBackground: false)
        banner.present(content: UserNotificationContent(mode: .Subscribe,
                                                        userprofile: userprofile),
                       dismissAfter: 0.75)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
      }
    })
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
        guard let self = self,
              let dict = notification.object as? [Userprofile: Userprofile],
              let userprofile = dict.values.first
        else { return }
        
        let banner = Banner(fadeBackground: false)
        banner.present(content: UserNotificationContent(mode: .Unsubscribe,
                                                        userprofile: userprofile),
                       dismissAfter: 0.75)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
    })
    tasks.append(Task {@MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: Notifications.Surveys.FavoriteAppend) {
        guard let self = self else { return }
        
        let banner = Banner(fadeBackground: false)
        banner.present(content: TextBannerContent(image: UIImage(systemName: "binoculars.fill")!,
                                                  text: "watch_survey_notification",
                                                  tintColor: .label),
                       dismissAfter: 0.75)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
    })
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
        await MainActor.run {
          do {
            guard let appData = json["app_data"] as? JSON,
                  let surveys = json["surveys"] as? JSON,
                  let userData = json["user_data"] as? JSON
            else { throw AppError.server }
            
            do {
              try AppData.loadData(appData)
            } catch {
              shouldTerminate = true
              switch error {
              case AppError.apiNotSupported:
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                present(alert, animated: true)
              default:
                print(error.localizedDescription)
#if DEBUG
                fatalError()
#endif
              }
            }
            
            guard !shouldTerminate else { return }
            
            try Userprofiles.loadUserData(userData)
            Surveys.shared.load(surveys)
            
            
            //                        hideLogo()
            isDataLoaded = true
            setTasks()
          } catch {
            loadData()
#if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
#endif
          }
        }
      } catch {
        loadData()
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
      navigationController.navigationBar.prefersLargeTitles = true
      navigationController.setNavigationBarHidden(true, animated: false)
      //            navigationController.delegate = appDelegate.transitionCoordinator
      rootViewController.navigationItem.title = title.localized
      rootViewController.tintColor = color
      
      return navigationController
    }
    
    viewControllers = [
      createNavigationController(for: HotController(),
                                 title: "hot",
                                 image: UIImage(systemName: "flame"),
                                 selectedImage: UIImage(systemName: "flame.fill"),
                                 color: Colors.Logo.Flame.rawValue),
      createNavigationController(for: SubscriptionsController(),
                                 title: "subscriptions",
                                 image: UIImage(systemName: "bell"),
                                 selectedImage: UIImage(systemName: "bell.fill"),
                                 color: Colors.Logo.CoolGray.rawValue),
      createNavigationController(for: ListController(), title: "list",
                                 image: UIImage(systemName: "square.stack.3d.up"),
                                 selectedImage: UIImage(systemName: "square.stack.3d.up.fill"),
                                 color: Colors.Logo.GreenMunshell.rawValue),
      createNavigationController(for: TopicsController(), title: "topics",
                                 image: UIImage(systemName: "circle.grid.3x3"),
                                 selectedImage: UIImage(systemName: "circle.grid.3x3.fill"),
                                 color: Colors.Logo.Marigold.rawValue),
      createNavigationController(for: SettingsController(), title: "settings",
                                 image: UIImage(systemName: "gearshape"),
                                 selectedImage: UIImage(systemName: "gearshape.fill"),
                                 color: Colors.Logo.AirBlue.rawValue),
    ]
  }
  
  @MainActor
  func setupUI() {
    view.isUserInteractionEnabled = false
    tabBar.backgroundColor = .systemBackground
    tabBar.tintColor = Colors.Logo.Flame.rawValue
    
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 11)], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11)], for: .selected)
    
    delegate = self
    navigationItem.setHidesBackButton(true, animated: false)
    UITabBar.appearance().barTintColor = .systemBackground
    
    setTabBarVisible(visible: false, animated: false)
    loadingStack.placeInCenter(of: view, widthMultiplier: 0.6, yOffset: -NavigationController.Constants.NavBarHeightSmallState)
    animateLoaderColor(from: Colors.Logo.Flame, to: Colors.Logo.Flame.next())
    
    //        appDelegate.window?.addSubview(passthroughView)
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
      animations: { [weak self] in
        icon.frame.origin = destinationLogoOrigin
        text.frame.origin = destinationTextOrigin
        icon.frame.size = destinationLogoSize
        text.frame.size = destinationTextSize
      }) { _ in
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
                                timingFunction: CAMediaTimingFunctionName.linear,
                                delegate: self,
                                isRemovedOnCompletion: false)
    loadingIcon.icon.add(anim_1, forKey: nil)
    loadingText.icon.add(anim_2, forKey: nil)
    loadingIcon.iconColor = to.rawValue
    loadingText.iconColor = to.rawValue
  }
  
  func setLogoLeading(constant: CGFloat, animated: Bool = false) {
    guard let leading = logoStack.getConstraint(identifier: "leading") else { return }
    
    passthroughView.setNeedsLayout()
    if animated {
      UIView.animate(withDuration: 0.25,
                     delay: 0,
                     options: .curveEaseInOut)  { [unowned self] in
        leading.constant = constant
        self.passthroughView.layoutIfNeeded()
      }
    } else {
      leading.constant = constant
      passthroughView.layoutIfNeeded()
    }
  }
  
  func setLogoCentered(animated: Bool = false) {
    guard let leading = logoStack.getConstraint(identifier: "leading") else { return }
    
    let constant = (passthroughView.bounds.width - logoStack.bounds.width)/2
    
    view.setNeedsLayout()
    if animated {
      UIView.animate(withDuration: 0.25,
                     delay: 0,
                     options: .curveEaseInOut)  { [unowned self] in
        leading.constant = constant
        self.passthroughView.layoutIfNeeded()
      }
    } else {
      leading.constant = constant
      passthroughView.layoutIfNeeded()
    }
  }
}

extension MainController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ScrollingTransitionAnimator(tabBarController: tabBarController, lastIndex: tabBarController.selectedIndex)
  }
  
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    func setColors(_ color: UIColor) {
      tabBar.tintColor = color
      let logoColorAnim = Animations.get(property: .FillColor,
                                         fromValue: logoIcon.iconColor.cgColor as Any,
                                         toValue: color.cgColor as Any,
                                         duration: 0.35,
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
                                         duration: 0.25,
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
        setColors(Colors.Logo.Flame.rawValue)
        setLogoCentered(animated: true)
        toggleLogo(on: true)
      case is SubscriptionsController:
        setColors(Colors.Logo.CoolGray.rawValue)
        setLogoCentered(animated: true)
        toggleLogo(on: true)
      case is ListController:
        currentTab = .Feed
        setColors(Colors.Logo.GreenMunshell.rawValue)
        setLogoLeading(constant: 10, animated: true)
        toggleLogo(on: true)
      case is TopicsController:
        currentTab = .Topics
        setColors(Colors.Logo.Marigold.rawValue)
        setLogoCentered(animated: true)
        guard let instance = controller as? TopicsController,
              (instance.mode == .Search || instance.mode == .Topic)
        else { return }
        
        toggleLogo(on: false)
      case is SettingsController:
        currentTab = .Settings
        setColors(Colors.Logo.AirBlue.rawValue)
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

//extension MainController: CallbackObservable {
//    func callbackReceived(_ sender: Any) {
//        if sender is APIUnavailableView {
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
//                self.apiUnavailableView?.alpha = 0
//            } completion: { _ in
//                self.loadData()
//            }
//        }
//    }
//}

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

//extension MainController: BannerObservable {
//    func onBannerWillAppear(_ sender: Any) {}
//
//    func onBannerWillDisappear(_ sender: Any) {}
//
//    func onBannerDidAppear(_ sender: Any) {}
//
//    func onBannerDidDisappear(_ sender: Any) {
//        if let banner = sender as? TestBanner {
//            banner.removeFromSuperview()
//        } else if let popup = sender as? Popup {
//            popup.removeFromSuperview()
//        }
//    }
//}
