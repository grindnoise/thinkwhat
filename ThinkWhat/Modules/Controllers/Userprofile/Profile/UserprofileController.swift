//
//  UserprofileController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import Agrume
import SafariServices

class UserprofileController: UIViewController, TintColorable {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  var controllerOutput: UserprofileControllerOutput?
  var controllerInput: UserprofileControllerInput?
  //Logic
  public private(set) var userprofile: Userprofile
  //UI
  var tintColor: UIColor
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private var isRightButtonSpinning = false {
    didSet {
      let spinner = UIActivityIndicatorView()
      spinner.color = .label
      spinner.style = .medium
      spinner.startAnimating()
      navigationItem.setRightBarButton(isRightButtonSpinning ? UIBarButtonItem(customView: spinner) : nil,
                                       animated: true)
    }
  }
  private let padding: CGFloat = 8
  private lazy var titleView: TagCapsule = {
    TagCapsule(text: "profile".localized.uppercased(),
               padding: padding/2,
               textPadding: .init(top: padding/1.5, left: 0, bottom: padding/1.5, right: padding),
               color: tintColor,
               font: UIFont(name: Fonts.Rubik.Medium, size: 14)!,
               isShadowed: false,
               image: UIImage(systemName: "person.fill"))
  }()
  
  
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
  init(userprofile: Userprofile,
       color: UIColor = .systemGray) {
    self.userprofile = userprofile
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  
  
  
  // MARK: - Overridden methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = UserprofileView()//color: tintColor)
    let model = UserprofileModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    
    setupUI()
    setTasks()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setBarColor()
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark, animated: true)
    navigationController?.setBarTintColor(tintColor)
    navigationController?.navigationBar.alpha = 1
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.setBarShadow(on: false, animated: true)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark, animated: true)
  }
}

private extension UserprofileController {
  
  @MainActor
  func setupUI() {
    navigationItem.titleView = titleView
    setBarItems()
    //        navigationController?.navigationBar.alpha = 1
    guard let navigationBar = self.navigationController?.navigationBar else { return }

    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = .systemBackground
    appearance.shadowColor = nil
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.prefersLargeTitles = false

    if #available(iOS 15.0, *) { navigationBar.compactScrollEdgeAppearance = appearance }
  }
  
  func setTasks() {
    controllerInput?.compatibility(with: userprofile)
    
    ///On notifications switch server callback
    userprofile.notificationPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.isRightButtonSpinning = false
        self.setBarItems()
      }
      .store(in: &subscriptions)
//    tasks.append(Task { @MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NotifyOnPublications) {
//        guard let self = self,
//              let userprofile = notification.object as? Userprofile,
//              self.userprofile == userprofile
//        else { return }
//
//        self.isRightButtonSpinning = false
//        self.setBarItems()
//      }
//    })
    
//    //On notifications switch server failure callback
//    tasks.append(Task { @MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NotifyOnPublicationsFailure) {
//        guard let self = self,
//              let userprofile = notification.object as? Userprofile,
//              self.userprofile == userprofile
//        else { return }
//
//        self.isRightButtonSpinning = false
//        self.setBarItems()
//      }
//    })
    
    //Subscriptions
    userprofile.$subscribedAt
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in self.setBarItems() }
      .store(in: &subscriptions)
    
    userprofile.subscriptionsPublisher
//      .filter { }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: {
        if case .failure(let error) = $0 {
#if DEBUG
          print(error)
#endif
        }
      }, receiveValue: { instances in
        print(instances)
      })
      .store(in: &subscriptions)
    
//      .sink(receiveCompletion: {
//        if case .failure(let error) = $0 {
//#if DEBUG
//          print(error)
//#endif
//        }
//      }, receiveValue: { [unowned self] in
//        fatalError()
//      }
//      .store(in: &subscriptions)
    
//    tasks.append(Task { [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsAppend) {
//        guard let self = self,
//              let dict = notification.object as? [Userprofile: Userprofile],
//              let userprofile = dict.values.first,
//              self.userprofile == userprofile
//        else { return }
//
//        self.setBarItems()
//      }
//    })
//    tasks.append(Task { @MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
//        guard let self = self,
//              let dict = notification.object as? [Userprofile: Userprofile],
//              let userprofile = dict.values.first,
//              self.userprofile == userprofile
//        else { return }
//
//        self.setBarItems()
//      }
//    })
  }
  
  @MainActor
  func setBarItems() {
    guard !isRightButtonSpinning else { return }
    
    guard userprofile.subscribedAt else {
      navigationItem.setRightBarButton(UIBarButtonItem(title: nil), animated: true)
      return
    }
    
    let action = UIAction { [weak self] _ in
      guard let self = self else { return }
      
      self.isRightButtonSpinning = true
      self.controllerInput?.switchNotifications(userprofile: self.userprofile,
                                                notify: !self.userprofile.notifyOnPublication)
    }
    
    navigationItem.setRightBarButton(UIBarButtonItem(title: nil,
                                                     image: UIImage(systemName: userprofile.notifyOnPublication ? "bell.fill" : "bell.slash.fill",
                                                                    withConfiguration: UIImage.SymbolConfiguration(weight: .regular)),
                                                     primaryAction: action,
                                                     menu: nil),
                                     animated: true)
  }
}

extension UserprofileController: UserprofileViewInput {
  func onSubscribersSelected() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(UserprofilesController(mode: .Subscribers, userprofile: userprofile, color: tintColor), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let controller = tabBarController as? MainController else { return }
    
    controller.toggleLogo(on: false)
  }
  
  func onSubscriptionsSelected() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(UserprofilesController(mode: .Subscriptions, userprofile: userprofile, color: tintColor), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let controller = tabBarController as? MainController else { return }
    
    controller.toggleLogo(on: false)
  }
  func crossingSurveys(_ compatibility: TopicCompatibility) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
//    navigationController?.pushViewController(SurveysController(compatibility, color: compatibility.topic.tagColor), animated: true)
    navigationController?.pushViewController(SurveysController(filter: SurveyFilter(main: .compatible, compatibility: compatibility),
                                                               color: compatibility.topic.tagColor),
                                             animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let controller = tabBarController as? MainController else { return }
    
    controller.toggleLogo(on: false)
  }
  
  func compatibility(with userprofile: Userprofile) {
    controllerInput?.compatibility(with: userprofile)
  }
  
  func publications() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
//    navigationController?.pushViewController(SurveysController(userprofile, color: tintColor), animated: true)
    navigationController?.pushViewController(SurveysController(filter: SurveyFilter(main: .user, userprofile: userprofile),
                                                               color: tintColor),
                                             animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let controller = tabBarController as? MainController else { return }
    
    controller.toggleLogo(on: false)
  }
  
  func subscribers() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(UserprofilesController(mode: .Subscribers, userprofile: userprofile, color: tintColor), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let controller = tabBarController as? MainController else { return }
    
    controller.toggleLogo(on: false)
  }
  
  func comments() {
    fatalError()
    //    let backItem = UIBarButtonItem()
    //    backItem.title = ""
    //    navigationItem.backBarButtonItem = backItem
    //    navigationController?.pushViewController(SurveysController(topic), animated: true)
    //    tabBarController?.setTabBarVisible(visible: false, animated: true)
    //
    //    guard let controller = tabBarController as? MainController else { return }
    //
    //    controller.toggleLogo(on: false)
  }
  
  func onTopicSelected(_ topic: Topic) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
//    navigationController?.pushViewController(SurveysController(topic), animated: true)
    navigationController?.pushViewController(SurveysController(filter: SurveyFilter(main: .user, topic: topic),
                                                               color: topic.tagColor),
                                             animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let controller = tabBarController as? MainController else { return }
    
    controller.toggleLogo(on: false)
  }
  
  func unsubscribe() {
    controllerInput?.unsubscribe(from: userprofile)
  }
  
  func subscribe() {
    controllerInput?.subscribe(to: userprofile)
  }
  
  func openImage(_ image: UIImage) {
    let agrume = Agrume(images: [image], startIndex: 0, background: .colored(.black))
    agrume.show(from: self)
  }
  
  func openURL(_ url: URL) {
    var vc: SFSafariViewController!
    let config = SFSafariViewController.Configuration()
    config.entersReaderIfAvailable = true
    vc = SFSafariViewController(url: url, configuration: config)
    present(vc, animated: true)
  }
}

extension UserprofileController: UserprofileModelOutput {
  // Implement methods
}
