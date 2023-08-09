//
//  SubsciptionsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SubscriptionsController: UIViewController, TintColorable {
  
  
  private enum Mode {
    case Default, Userprofile
  }
  
  // MARK: - Public properties
  public var controllerOutput: SubsciptionsControllerOutput?
  public var controllerInput: SubsciptionsControllerInput?
  ///**Logic**
  var isDataReady = false
  public private(set) var isOnScreen = false
  public private(set) var isUserSelected = false {
    didSet {
      guard oldValue != isUserSelected,
            let controller = tabBarController as? MainController
      else { return }
      
      guard isUserSelected else {
        controller.setLogoLeading(constant: 10,
                                  animated: true)
        
        return
      }
      controller.setLogoCentered(animated: true)
    }
  }
  ///**UI**
  public var tintColor: UIColor = .clear

  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let padding: CGFloat = 8
  private var userprofile: Userprofile? {
    didSet {
      guard let userprofile = userprofile else { return }
      
      mode = .Userprofile
      
      ///On notifications switch server callback
      userprofile.notificationPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.isRightButtonSpinning = false
          self.setBarItems()
        }
        .store(in: &subscriptions)
    }
  }
  private var mode: Mode = .Default {
    didSet {
      guard oldValue != mode else { return }
      
      onModeChanged()
    }
  }
  //    private var period: Period = .AllTime {
  //        didSet {
  //            guard oldValue != period else { return }
  //
  //            controllerOutput?.setPeriod(period)
  ////            setTitle()
  ////            navigationItem.title = "subscriptions".localized + (period == .AllTime ? "" : " " + "per".localized.lowercased() + " \(period.rawValue.localized.lowercased())")
  //
  //            guard let button = navigationItem.rightBarButtonItem else { return }
  //
  //            button.menu = prepareMenu()
  //        }
  //    }
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
    
    let model = SubscriptionsModel()
    
    self.controllerOutput = view as? SubscriptionsView
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    ProtocolSubscriptions.subscribe(self)
    
    setupUI()
    setTasks()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
//    clearNavigationBar(clear: true)
//    setNavigationBarTintColor(tintColor)
//    navigationController?.setBarOpaque()
    navigationController?.setBarColor()
    navigationController?.setBarTintColor(tintColor)
    navigationController?.setBarShadow(on: false, animated: true)
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationItem.largeTitleDisplayMode = .never
    controllerOutput?.onWillAppear()
    tabBarController?.setTabBarVisible(visible: true, animated: true)
    //        titleLabel.alpha = 1
//    guard let main = tabBarController as? MainController else { return }
//
//    main.toggleLogo(on: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    controllerOutput?.didAppear()
    
    isOnScreen = true
    
    guard let main = tabBarController as? MainController else { return }
    
    main.toggleLogo(on: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    //        titleLabel.alpha = 0
    //        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) { [weak self] in
    //            guard let self = self else { return }
    //
    //            self.navigationController?.navigationBar.alpha = 0
    //        }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    isOnScreen = false
    controllerOutput?.didDisappear()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if let shadow = navigationItem.rightBarButtonItems?.filter({ $0.customView?.accessibilityIdentifier == "subscribers" }).first?.customView,
       let btn = shadow.getSubview(type: UIButton.self) {
      shadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
      btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .white
      btn.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : Colors.main
      btn.setAttributedTitle(NSAttributedString(string: "subscribers".localized,
                                                attributes: [
                                                  .font: UIFont(name: Fonts.Rubik.Medium, size: 16) as Any,
                                                  .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.white : Colors.main as Any
                                                ]),
                             for: .normal)
    }
  }
  
  //    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
  //        super.traitCollectionDidChange(previousTraitCollection)
  //
  //        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray)
  ////        titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .label
  //    }
}

private extension SubscriptionsController {
  func setTasks() {
    tasks.append(Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.System.Tab) {
        guard let self = self,
              let tab = notification.object as? Tab
        else { return }
        
        self.isOnScreen = tab == .Subscriptions
      }
    })
    
    
    
//    tasks.append(Task { @MainActor [weak self] in
//      for await _ in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NotifyOnPublications) {
//        guard let self = self,
//              self.mode == .Userprofile
//        else { return }
//
//        self.isRightButtonSpinning = false
//        self.setBarItems()
//      }
//    })
//
//    //On notifications switch server failure callback
//    tasks.append(Task { @MainActor [weak self] in
//      for await _ in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NotifyOnPublicationsFailure) {
//        guard let self = self else { return }
//
//        showBanner(bannerDelegate: self,
//                   text: AppError.server.localizedDescription,
//                   content: UIImageView(
//                    image: UIImage(systemName: "exclamationmark.triangle.fill",
//                                   withConfiguration: UIImage.SymbolConfiguration(scale: .small))),
//                   color: UIColor.white,
//                   textColor: .white,
//                   dismissAfter: 0.75,
//                   backgroundColor: UIColor.systemOrange.withAlphaComponent(1))
//        self.isRightButtonSpinning = false
//        self.setBarItems()
//      }
//    })
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.didEnterBackgroundNotification) {
        guard let self = self,
              self.isOnScreen
        else { return }
        
        self.isOnScreen = false
        self.controllerOutput?.didDisappear()
      }
    })
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.didBecomeActiveNotification) {
        guard let self = self,
              let main = self.tabBarController as? MainController,
              main.selectedIndex == 1
        else { return }
        
        self.isOnScreen = true
        self.controllerOutput?.didAppear()
      }
    })
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.willEnterForegroundNotification) {
        guard let self = self else { return }
        
        self.navigationController?.setBarShadow(on: false)
      }
    })
  }
  
  @MainActor
  func setupUI() {
    navigationItem.title = ""
    //        navigationItem.titleView = logo
    //        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray)
    
//    guard let navigationBar = self.navigationController?.navigationBar else { return }
    
    //        navigationBar.addSubview(titleLabel)
    //        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    //
    //        NSLayoutConstraint.activate([
    //            titleLabel.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -2),
    //            titleLabel.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 2),
    //            titleLabel.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -(44+10)),
    //        ])
    //
    //        let constraint = titleLabel.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 10)
    //        constraint.identifier = "leading"
    //        constraint.isActive = true
    
    setBarItems()
    //        setTitle(animated: false)
  }
  
  @MainActor
  func setBarItems(zeroSubscriptions: Bool = false) {
    guard !isRightButtonSpinning else { return }
    var rightButton: UIBarButtonItem!
    switch mode {
    case .Default:
      let button: UIView = { let shadowView = UIView.opaque()
        shadowView.layer.masksToBounds = false
        shadowView.accessibilityIdentifier = "subscribers"
        shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        shadowView.publisher(for: \.bounds)
          .sink {
            shadowView.layer.shadowRadius = $0.height/8
            shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2.25).cgPath
          }
          .store(in: &subscriptions)
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: "subscribers".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.Medium, size: 14) as Any,
                                                      .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.white : Colors.main as Any
                                                     ]),
                                  for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        button.accessibilityIdentifier = "profileButton"
        button.imageEdgeInsets.left = padding/2
        button.imageEdgeInsets.right = padding/2
        button.semanticContentAttribute = .forceRightToLeft
        button.adjustsImageWhenHighlighted = false
        button.setImage(UIImage(systemName: ("arrow.right"), withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
        button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
        button.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : Colors.main
        button.addTarget(self, action: #selector(self.onSubscribersTapped), for: .touchUpInside)
        button.publisher(for: \.bounds)
          .sink { button.cornerRadius = $0.height/2 }
          .store(in: &subscriptions)
        button.place(inside: shadowView)
        
        return shadowView
      }()
      
//      let button = UIButton()
//      button.setAttributedTitle(NSAttributedString(string: "subscribers".localized,
//                                                   attributes: [
//                                                    .font: UIFont(name: Fonts.Rubik.SemiBold, size: 16) as Any,
//                                                    .foregroundColor: tintColor as Any
//                                                   ]),
//                                for: .normal)
//      button.addTarget(self,
//                       action: #selector(self.onSubscribersTapped),
//                       for: .touchUpInside)
      
      //      rightButton = UIBarButtonItem(title: "subscribers".localized.capitalized,
//                                    image: UIImage(systemName: "person.3.sequence.fill",
//                                                   withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
//                                    primaryAction: {
//        let action = UIAction { [weak self] _ in
//          guard let self = self else { return }
//
//          self.onSubscribersTapped()
//        }
//
//        return action
//      }(),
//                                    menu: nil)
      navigationItem.setRightBarButton(UIBarButtonItem(customView: button),
                                       animated: true)
      navigationItem.setLeftBarButton(nil,
                                      animated: true)
      
      //            guard let leading = titleLabel.getConstraint(identifier: "leading") else { return }
      //
      //            let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15,
      //                                                                   delay: 0) { [weak self] in
      //                guard let self = self,
      //                      let navigationBar = self.navigationController?.navigationBar
      //                else { return }
      //
      //                navigationBar.setNeedsLayout()
      //                leading.constant = 10
      //                navigationBar.layoutIfNeeded()
      //            }
    case .Userprofile:
      guard let userprofile = userprofile//,
              //                  let leading = titleLabel.getConstraint(identifier: "leading")
      else { return }
      
      //            let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15,
      //                                                                   delay: 0) { [weak self] in
      //                guard let self = self,
      //                      let navigationBar = self.navigationController?.navigationBar
      //                else { return }
      //
      //                navigationBar.setNeedsLayout()
      //                leading.constant = 44+10
      //                navigationBar.layoutIfNeeded()
      //            }
      
      let notify = userprofile.notifyOnPublication
      let notifyAction = UIAction { [weak self] _ in
        guard let self = self else { return }
        
        self.isRightButtonSpinning = true
        self.controllerInput?.switchNotifications(userprofile: userprofile,
                                                  notify: !notify)
      }
      
      
      rightButton = UIBarButtonItem(title: nil,
                                    image: UIImage(systemName: notify ? "bell.fill" : "bell.slash.fill",
                                                   withConfiguration: UIImage.SymbolConfiguration(weight: .regular)),
                                    primaryAction: notifyAction,
                                    menu: nil)
      rightButton.tintColor = tintColor
      
      let action = UIAction { [weak self] _ in
        guard let self = self else { return }
        
        self.mode = .Default
      }
      
      let leftButton = UIBarButtonItem(title: "actions".localized.capitalized,
                                       image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                       primaryAction: action,
                                       menu: nil)
      
      delayAsync(delay: 0.1) { [weak self] in
        guard let self = self else { return }
        
        self.navigationItem.setLeftBarButton(leftButton, animated: true)
        self.navigationItem.setRightBarButton(rightButton, animated: true)
      }
    }
  }
  
  @MainActor
  func setTitle(animated: Bool = true) {
    //        var text = ""
    //
    //        switch mode {
    //        case .Userprofile:
    //            guard let userprofile = userprofile else { return }
    //
    //            text = userprofile.name
    //        case .Default:
    //            text = "subscriptions".localized + (period == .AllTime ? "" : " (\(period.rawValue.localized.lowercased()))")
    //        }
    //
    //        guard animated else {
    //            titleLabel.text = text
    //            return
    //        }
    //
    //        UIView.transition(with: titleLabel,
    //                          duration: 0.15,
    //                          options: .transitionCrossDissolve) { [weak self] in
    //            guard let self = self else { return }
    //
    //            self.titleLabel.text = text
    //            self.titleLabel.textAlignment = self.mode == .Userprofile ? .center : .left
    //        }
  }
  
  //    @MainActor
  //    func prepareMenu(zeroSubscriptions: Bool = false) -> UIMenu {
  //        let perDay: UIAction = .init(title: Period.PerDay.rawValue.localized,
  //                                     image: nil,
  //                                     identifier: nil,
  //                                     discoverabilityTitle: nil,
  //                                     attributes: .init(),
  //                                     state: period == .PerDay ? .on : .off,
  //                                     handler: { [weak self] _ in
  //            guard let self = self else { return }
  //
  //            self.period = .PerDay
  //        })
  //
  //        let perWeek: UIAction = .init(title: Period.PerWeek.rawValue.localized,
  //                                      image: nil,
  //                                      identifier: nil,
  //                                      discoverabilityTitle: nil,
  //                                      attributes: .init(),
  //                                      state: period == .PerWeek ? .on : .off,
  //                                      handler: { [weak self] _ in
  //            guard let self = self else { return }
  //
  //            self.period = .PerWeek
  //        })
  //
  //        let perMonth: UIAction = .init(title: Period.PerMonth.rawValue.localized,
  //                                       image: nil,
  //                                       identifier: nil,
  //                                       discoverabilityTitle: nil,
  //                                       attributes: .init(),
  //                                       state: period == .PerMonth ? .on : .off,
  //                                       handler: { [weak self] _ in
  //            guard let self = self else { return }
  //
  //            self.period = .PerMonth
  //        })
  //
  //        let allTime: UIAction = .init(title: Period.AllTime.rawValue.localized,
  //                                      image: nil,
  //                                      identifier: nil,
  //                                      discoverabilityTitle: nil,
  //                                      attributes: .init(),
  //                                      state: period == .AllTime ? .on : .off,
  //                                      handler: { [weak self] _ in
  //            guard let self = self else { return }
  //
  //            self.period = .AllTime
  //        })
  //
  //        let inlineMenu = UIMenu(title: "publications_per".localized,
  //                                image: nil,
  //                                identifier: nil,
  //                                options: .displayInline,
  //                                children: [
  //                                    perDay,
  //                                    perWeek,
  //                                    perMonth,
  //                                    allTime
  //                                ])
  //
  //        var subscribersCount = ""
  //        if let userprofile = Userprofiles.shared.current {
  //            subscribersCount  = " (\(userprofile.subscribers.count))"
  //        }
  //
  //        let filter: UIAction = .init(title: "my_subscribers".localized + subscribersCount,
  //                                     image: UIImage(systemName: "person.crop.circle.fill.badge.checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
  //                                     identifier: nil,
  //                                     discoverabilityTitle: nil,
  //                                     attributes: .init(),
  //                                     state: .off,
  //                                     handler: { [weak self] _ in
  //            guard let self = self,
  //                  let userprofile = Userprofiles.shared.current
  //            else { return }
  //
  //            let backItem = UIBarButtonItem()
  //                backItem.title = ""
  //            self.navigationItem.backBarButtonItem = backItem
  //            self.navigationController?.pushViewController(UserprofilesController(mode: .Subscribers, userprofile: userprofile), animated: true)
  //            self.tabBarController?.setTabBarVisible(visible: false, animated: true)
  //
  //            guard let main = self.tabBarController as? MainController else { return }
  //
  //            main.toggleLogo(on: false)
  //        })
  //
  //        var children: [UIMenuElement] = []
  //
  //        if !zeroSubscriptions {
  //            children.append(inlineMenu)
  //        }
  //        children.append(filter)
  //
  //        return UIMenu(title: "", children: children)
  //    }
  
  @objc
  func onBarButtonTap() {
    if mode == .Userprofile {
      mode = .Default
    }
  }
  
  @MainActor
  func onModeChanged() {
    if mode == .Default {//, isOnScreen {
      toggleUserSelected(false)
      controllerOutput?.hideUserCard(nil)
    }
    
    setBarItems()
    //        setTitle()
  }
  
  func getGradientColors() -> [CGColor] {
    return [
      traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
      traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
      traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.lighter(0.2).cgColor : K_COLOR_RED.lighter(0.2).cgColor,
    ]
  }
}

extension SubscriptionsController: SubscriptionsViewInput {
  func toggleUserSelected(_ selected: Bool) { isUserSelected = selected }
  
  func setDefaultMode() {
    mode = .Default
  }
  
  func onSubcriptionsCountEvent(zeroSubscriptions: Bool) {
    if !zeroSubscriptions, mode == .Userprofile {
      mode = .Default
    }
    setBarItems(zeroSubscriptions: zeroSubscriptions)
  }
  
  func unsubscribe(from userprofile: Userprofile) {
    controllerInput?.unsubscribe(from: userprofile)
    //        mode = .Default
  }
  
  func openUserprofile(_ userprofile: Userprofile) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(UserprofileController(userprofile: userprofile, color: tintColor), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let controller = tabBarController as? MainController else { return }
    
    controller.toggleLogo(on: false)
  }
  
  func setUserprofileFilter(_ userprofile: Userprofile) {
    self.userprofile = userprofile
  }
  
  func share(_ surveyReference: SurveyReference) {
    // Setting description
    let firstActivityItem = surveyReference.title
    
    // Setting url
    let queryItems = [URLQueryItem(name: "hash", value: surveyReference.shareHash), URLQueryItem(name: "enc", value: surveyReference.shareEncryptedString)]
    var urlComps = URLComponents(string: API_URLS.Surveys.share!.absoluteString)!
    urlComps.queryItems = queryItems
    
    let secondActivityItem: URL = urlComps.url!
    
    // If you want to use an image
    let image : UIImage = UIImage(named: "anon")!
    let activityViewController : UIActivityViewController = UIActivityViewController(
      activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
    
    // This lines is for the popover you need to show in iPad
    activityViewController.popoverPresentationController?.sourceView = self.view
    
    // This line remove the arrow of the popover to show in iPad
    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
    activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
    
    // Pre-configuring activity items
    activityViewController.activityItemsConfiguration = [
      UIActivity.ActivityType.message
    ] as? UIActivityItemsConfigurationReading
    
    // Anything you want to exclude
    activityViewController.excludedActivityTypes = [
      UIActivity.ActivityType.postToWeibo,
      UIActivity.ActivityType.print,
      UIActivity.ActivityType.assignToContact,
      UIActivity.ActivityType.saveToCameraRoll,
      UIActivity.ActivityType.addToReadingList,
      UIActivity.ActivityType.postToFlickr,
      UIActivity.ActivityType.postToVimeo,
      UIActivity.ActivityType.postToTencentWeibo,
      UIActivity.ActivityType.postToFacebook
    ]
    
    activityViewController.isModalInPresentation = false
    self.present(activityViewController,
                 animated: true,
                 completion: nil)
  }
  
  func claim(_ dict: [SurveyReference: Claim]) {
    controllerInput?.claim(dict)
  }
  
  func addFavorite(_ surveyReference: SurveyReference) {
    controllerInput?.addFavorite(surveyReference: surveyReference)
  }
  
  func updateSurveyStats(_ instances: [SurveyReference]) {
    guard isOnScreen else { return }
    
    controllerInput?.updateSurveyStats(instances)
  }
  
  func onSurveyTapped(_ instance: SurveyReference) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(PollController(surveyReference: instance, mode: instance.isComplete ? .Read : .Vote), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let controller = tabBarController as? MainController else { return }
    
    controller.toggleLogo(on: false)
  }
  
  func onDataSourceRequest(source: Survey.SurveyCategory, dateFilter: Period?, topic: Topic?, userprofile: Userprofile?) {
    guard isOnScreen else { return }
    
    controllerInput?.onDataSourceRequest(source: source, dateFilter: dateFilter, topic: topic, userprofile: userprofile)
  }
  
  @objc
  func onSubscribersTapped() {
    
    guard let userprofile = Userprofiles.shared.current,
          userprofile.subscribersTotal != 0
    else { return }
    
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(UserprofilesController(mode: .Subscribers, userprofile: userprofile, color: tintColor), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let main = tabBarController as? MainController else { return }
    
    main.toggleLogo(on: false)
  }
  
  func onSubscpitionsTapped() {
    //        let backItem = UIBarButtonItem()
    //            backItem.title = ""
    //            navigationItem.backBarButtonItem = backItem
    //        navigationController?.pushViewController(SubscribersController(mode: .Subscriptions), animated: true)
  }
  
  //    @objc
  //    func toggleBarButton() {
  //        controllerOutput?.onUpperContainerShown(isBarButtonOn)
  //        UIView.animate(withDuration: 0.3,
  //                       delay: 0,
  //                       options: .curveEaseOut) {
  //            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
  //            self.barButton.transform = self.isBarButtonOn ? upsideDown :.identity
  //        } completion: { _ in
  //            self.isBarButtonOn = !self.isBarButtonOn
  //        }
  //    }
  func onAllUsersTapped(mode: UserprofilesViewMode) {
    guard let userprofile = Userprofiles.shared.current else { return }
    
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(UserprofilesController(mode:  mode, userprofile: userprofile, color: tintColor), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let main = tabBarController as? MainController else { return }
    
    main.toggleLogo(on: false)
  }
}

extension SubscriptionsController: SubsciptionsModelOutput {
  func onRequestCompleted(_ result: Result<Bool, Error>) {
    controllerOutput?.onRequestCompleted(result)
  }
}

extension SubscriptionsController: DataObservable {
  func onDataLoaded() {
    isDataReady = true
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
}

//extension SubscriptionsController: BannerObservable {
//  func onBannerWillAppear(_ sender: Any) {}
//  
//  func onBannerWillDisappear(_ sender: Any) {}
//  
//  func onBannerDidAppear(_ sender: Any) {}
//  
//  func onBannerDidDisappear(_ sender: Any) {
//    if let banner = sender as? Banner {
//      banner.removeFromSuperview()
//    } else if let popup = sender as? Popup {
//      popup.removeFromSuperview()
//    }
//  }
//}

/// Set/unset current active screen
extension SubscriptionsController: ScreenVisible {
  func setActive(_ flag: Bool) {
    isOnScreen = flag
  }
}

/// If user taps current tab, then hide user card
extension SubscriptionsController: TabBarTappable {
  func tabBarTapped(_ mode: TabBarTapMode) {
    guard mode == .Repeat && self.mode == .Userprofile else { return }
    
    // Set default mode & hide user card
    self.mode = .Default
  }
}
