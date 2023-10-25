//
//  TopicsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class TopicsController: UIViewController, TintColorable {
  var counter = 0
  enum Mode {
    case Default, Topic//Parent, Child, List, Search
  }
  
  // MARK: - Public properties
  var controllerOutput: TopicsControllerOutput?
  var controllerInput: TopicsControllerInput?
  var mode: Mode = .Default {
    didSet {
      guard oldValue != mode else { return }
      
      // Update back button
      setLeftBarItems()
      // Toggle nav bar title view
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        self.toggleTopicView()
      }
      
      // Toggle filters
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        self.controllerOutput?.setFiltersHidden(mode == .Topic ? false : true)
      }
      
      // Go back to topic selection
      if oldValue == .Topic, mode == .Default {
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          self.controllerOutput?.showTopics()
        }
      }
      
      // If search mode was on then show search search button in nav bar again
      if searchMode == .on {
        searchMode = .off
      }
    }
  }
  public var searchMode = Enums.SearchMode.off {
    didSet {
      guard oldValue != searchMode else { return }
      
      setRightBarItems()
      controllerOutput?.setSearchModeEnabled(enabled: searchMode == .on ? true : false, delay: 0.05)
    }
  }
  ///**Logic**
  public var isDataReady = false
  public var tintColor: UIColor = .clear {
    didSet {
      guard oldValue != tintColor else { return }
      
      navigationController?.setBarTintColor(tintColor)
      controllerOutput?.setColor(tintColor)
    }
  }
  ///**UI**
  public var isOnScreen = false
  public var filter = SurveyFilter(main: .disabled, additional: .period, period: .unlimited)
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private lazy var titleView: TagCapsule = {
    TagCapsule(text: "T",
               padding: padding/2,
               textPadding: .init(top: padding/1.5, left: 0, bottom: padding/1.5, right: padding),
               color: .systemGray,
               font: UIFont(name: Fonts.Rubik.Medium, size: 14)!,
               isShadowed: false,
               iconCategory: .Null)
  }()
  private let padding: CGFloat = 8
  
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
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let model = TopicsModel()
    
    self.controllerOutput = view as? TopicsView
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    ProtocolSubscriptions.subscribe(self)
    setTasks()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    //        barButton.alpha = 1
    tabBarController?.setTabBarVisible(visible: true, animated: true)
    navigationController?.navigationBar.alpha = 1
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.navigationBar.prefersLargeTitles = false//true
    navigationController?.setBarColor()
    navigationItem.largeTitleDisplayMode = .never//.always
    
//    if mode == .GlobalSearch || mode == .TopicSearch {
//      searchField.alpha = 1
//    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    isOnScreen = true
    if mode == .Topic {
      toggleTopicView()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // If topic mode, than hide topic tag
    if searchMode == .off, mode == .Topic {
      guard let constraint = titleView.getConstraint(identifier: "centerY") else { return }
      
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut]) { [weak self] in
          guard let self = self else { return }
          
          self.navigationController?.navigationBar.setNeedsLayout()
          constraint.constant = -100
          self.navigationController?.navigationBar.layoutIfNeeded()
        }
      
      
      UIView.animate(withDuration: 0.1) { [weak self] in
        guard let self = self else { return }
        
        self.navigationController?.navigationBar.setNeedsLayout()
        constraint.constant = -100
        self.navigationController?.navigationBar.layoutIfNeeded()
      }
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    isOnScreen = false
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    navigationController?.setBarShadow(on: false)
  }
}

private extension TopicsController {
  @MainActor
  func setupUI() {
    navigationItem.title = ""
    setRightBarItems(animated: false)
    setLeftBarItems(animated: false)
    
    // Add topic tag view
    guard let navigationBar = navigationController?.navigationBar, navigationBar.getSubview(type: TagCapsule.self).isNil else { return }
    
    navigationBar.addSubview(titleView)
    titleView.centerXToSuperview()
    let constraint = titleView.centerYToSuperview(offset: -100)
    constraint.identifier = "centerY"
  }
  
  func setTasks() {
    filter.topicPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        // Set nav bar tint color
        self.tintColor = $0?.tagColor ?? Constants.UI.Colors.main
        
        // Update mode
        self.mode = $0.isNil ? .Default : .Topic
      }
      .store(in: &subscriptions)
    
    
//    filter.changePublisher
//      .receive(on: DispatchQueue.main)
////      .filter { [unowned self] _ in !self.filter.topic.isNil}
////      .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: false)
//      .sink { [weak self] _ in
//        guard let self = self else { return }
//        
//        // Set nav bar tint color
//        self.tintColor = self.filter.topic?.tagColor ?? Constants.UI.Colors.main
//        
//        // Update mode
//        self.mode = self.filter.topic.isNil ? .Default : .Topic
//      }
//      .store(in: &subscriptions)
    
    //Filter bug fix
    Timer.publish(every: 10, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        guard let self = self,
              self.isOnScreen,
              self.mode == .Default
        else { return }
        
        self.controllerInput?.updateTopicsStats()
      }
      .store(in: &subscriptions)
    
    Notifications.UIEvents.tabItemPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        self.isOnScreen = $0.keys.first == .Topics
        
        // Back to topics list
        if $0.values.first == .Topics && $0.keys.first == .Topics, self.mode == .Topic {
//          self.mode = .Default
          self.showTopics(animated: true)
        }
        
        // Switch off search mode
        if self.searchMode == .on {
          self.searchMode = .off
        }
      }
      .store(in: &subscriptions)
    
//    tasks.append(Task { @MainActor [weak self] in
//      for await _ in NotificationCenter.default.notifications(for: UIApplication.didEnterBackgroundNotification) {
//        guard let self = self,
//              self.isOnScreen
//        else { return }
//        
//        self.isOnScreen = false
//      }
//    })
//    tasks.append(Task { @MainActor [weak self] in
//      for await _ in NotificationCenter.default.notifications(for: UIApplication.didBecomeActiveNotification) {
//        guard let self = self,
//              let main = self.tabBarController as? MainController,
//              main.selectedIndex == 3
//        else { return }
//        
//        self.isOnScreen = true
//      }
//    })
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.didEnterBackgroundNotification) {
        guard let self = self else { return }
        
        self.isOnScreen = false
      }
    })
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.willEnterForegroundNotification) {
        guard let self = self else { return }
        
        self.navigationController?.setBarShadow(on: false)
        if let main = self.tabBarController as? MainController, main.selectedIndex == 3 {
          self.isOnScreen = true
        }
      }
    })
    
    controllerOutput?.searchPublisher
      .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
      .eraseToAnyPublisher()
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.controllerInput?.search(substring: $0,
                                     localized: false,
                                     filter: self.filter)
      }
      .store(in: &subscriptions)
    
    
  }
  
  func getGradientColors() -> [CGColor] {
    [
      traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : Constants.UI.Colors.main.cgColor,
      traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : Constants.UI.Colors.main.cgColor,
      traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.lighter(0.2).cgColor : Constants.UI.Colors.main.lighter(0.2).cgColor,
    ]
  }
  
  @MainActor
  func setRightBarItems(animated: Bool = true) {
    // Set right button if search  is off
//    if searchMode == .off && navigationItem.rightBarButtonItem.isNil || searchMode == .on {
      navigationItem.setRightBarButton(searchMode == .on ? nil : UIBarButtonItem(title: "",
                                                                                 image: UIImage(systemName: "magnifyingglass",
                                                                                                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                                                                 primaryAction: UIAction { [unowned self] _ in
        self.searchMode = .on
      }, menu: nil), animated: animated)
//    }
  }
  
  func setLeftBarItems(animated: Bool = true) {
    guard mode == .Topic else { return }
    
    navigationItem.setLeftBarButton(UIBarButtonItem(title: nil,
                                                    image: UIImage(systemName: "chevron.left",
                                                                   withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                                    primaryAction: UIAction { [weak self] _ in
      guard let self = self else { return }
      
      self.showTopics(animated: animated)
    }, menu: nil), animated: animated)
  }
  
  func showTopics(animated: Bool) {
    // Set default mode
    self.mode = .Default
    
    // Delay a bit
    delay(seconds: 0.5) {
      // Reset filter
      self.resetFilter()
//        self.filter.setBoth(main: .disabled, topic: nil, additional: .disabled, period: .unlimited)
      
      // Hide scroll to top button
      self.controllerOutput?.scrollToTop()
    }
    
    // Reset filters cells
    self.controllerOutput?.resetFilters()
    
    // Clear button
    self.navigationItem.setLeftBarButton(nil, animated: animated)
  }

  func toggleTopicView() {
//    guard searchMode == .off,
    guard let topic = filter.topic,
          let navigationBar = navigationController?.navigationBar,
          let constraint = titleView.getConstraint(identifier: "centerY"),
          let main = tabBarController as? MainController
    else { return }
    
    counter += 1
    
//    debugPrint("toggleTopicView", to: &logger)
    func toggle(on: Bool, completion: Closure? = nil) {
      UIView.animate(
        withDuration: 0.3,
        delay: 0.1,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [weak self] in
          guard let self = self else { return }
          
          self.titleView.alpha = on ? 1 : 0
          navigationBar.setNeedsLayout()
          constraint.constant = on ? 0 : -100
          navigationBar.layoutIfNeeded()
        }) { _ in completion?() }
    }
    
    // If topic mode
    if mode == .Topic {
      updateTitleView(topic)
      
      // If app logo is not on screen (back from survey transition)
      if !main.logoIsOnScreen {
        toggle(on: true)
      } else {
        // Hide app logo and after that show topic tag
        main.toggleLogo(on: false) { toggle(on: true) }
      }
    } else if mode == .Default {
      // Hide topic tag and after that show app logo
      toggle(on: false) { main.toggleLogo(on: true) }
    }
  }
  
  /// Resets filters
  func resetFilter() {
    filter.setBoth(main: .disabled, topic: nil, additional: .disabled, period: .unlimited)
  }
  
  /// Update title view UI
  /// - Parameter topic: specific topic
  func updateTitleView(_ topic: Topic) {
    func getAttributedString() -> NSAttributedString {
      let attrString = NSMutableAttributedString(string: topic.isOther ? "\(topic.parent!.title.uppercased()) (\(topic.title.uppercased())):" : "\(topic.title.uppercased()):",
                                                 attributes: [
                                                  .font: UIFont(name: Fonts.Rubik.Medium, size: 14)!,
                                                  .foregroundColor: UIColor.white
                                                ])
      attrString.append(NSAttributedString(string: " " + String(describing: topic.activeCount), attributes: [
        .font: UIFont(name: Fonts.Rubik.Regular, size: 14)!,
        .foregroundColor: UIColor.white
      ]))
      
      return attrString
    }
    
    titleView.color = topic.tagColor
    titleView.setAttributedText(getAttributedString())
    titleView.iconCategory = topic.isOther ? topic.parent?.iconCategory : topic.iconCategory
  }
}

extension TopicsController: TopicsViewInput {
  func subscribe(topic: Topic, subscribe: Bool) {
    controllerInput?.subscribe(topic: topic, subscribe: subscribe)
  }
  
  func getDataItems(excludeList: [SurveyReference]) {
    controllerInput?.getDataItems(filter: filter, excludeList: excludeList)
  }
  
  func unsubscribe(from userprofile: Userprofile) {
    controllerInput?.unsubscribe(from: userprofile)
  }
  
  func subscribe(to userprofile: Userprofile) {
    controllerInput?.subscribe(to: userprofile)
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
  
  func share(_ surveyReference: SurveyReference) {
    fatalError()
//    // Setting description
//    let firstActivityItem = surveyReference.title
//    
//    // Setting url
//    let queryItems = [URLQueryItem(name: "hash", value: surveyReference.shareHash), URLQueryItem(name: "enc", value: surveyReference.shareEncryptedString)]
//    var urlComps = URLComponents(string: API_URLS.Surveys.share!.absoluteString)!
//    urlComps.queryItems = queryItems
//    
//    let secondActivityItem: URL = urlComps.url!
//    
//    // If you want to use an image
//    let image : UIImage = UIImage(named: "anon")!
//    let activityViewController : UIActivityViewController = UIActivityViewController(
//      activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
//    
//    // This lines is for the popover you need to show in iPad
//    activityViewController.popoverPresentationController?.sourceView = self.view
//    
//    // This line remove the arrow of the popover to show in iPad
//    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
//    activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
//    
//    // Pre-configuring activity items
//    activityViewController.activityItemsConfiguration = [
//      UIActivity.ActivityType.message
//    ] as? UIActivityItemsConfigurationReading
//    
//    // Anything you want to exclude
//    activityViewController.excludedActivityTypes = [
//      UIActivity.ActivityType.postToWeibo,
//      UIActivity.ActivityType.print,
//      UIActivity.ActivityType.assignToContact,
//      UIActivity.ActivityType.saveToCameraRoll,
//      UIActivity.ActivityType.addToReadingList,
//      UIActivity.ActivityType.postToFlickr,
//      UIActivity.ActivityType.postToVimeo,
//      UIActivity.ActivityType.postToTencentWeibo,
//      UIActivity.ActivityType.postToFacebook
//    ]
//    
//    activityViewController.isModalInPresentation = false
//    self.present(activityViewController,
//                 animated: true,
//                 completion: nil)
  }
  
  func claim(_ dict: [SurveyReference: Claim]) {
    controllerInput?.claim(dict)
  }
  
  func addFavorite(_ surveyReference: SurveyReference) {
    controllerInput?.addFavorite(surveyReference: surveyReference)
  }
  
  func updateSurveyStats(_ instances: [SurveyReference]) {
    guard isOnScreen, mode != .Default else { return }
    
    controllerInput?.updateSurveyStats(instances)
  }
  
  func openSettings() {
    tabBarController?.selectedIndex = 4
  }
  
  func onSurveyTapped(_ instance: SurveyReference) {
    //        if let nav = navigationController as? CustomNavigationController {
    //            nav.transitionStyle = .Default
    //            nav.duration = 0.5
    ////            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
    //        }
    let backItem = UIBarButtonItem()
    backItem.title = ""
    
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(PollController(surveyReference: instance, mode: instance.isComplete ? .Read : .Vote), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let main = tabBarController as? MainController else { return }
    
    main.toggleLogo(on: false)
  }
}

// MARK: - Model Output
extension TopicsController: TopicsModelOutput {
  func onRequestCompleted(_ result: Result<Bool, Error>) {
    controllerOutput?.onRequestCompleted(result)
  }
  
  func onSearchCompleted(_ instances: [SurveyReference], localSearch: Bool) {
    controllerOutput?.onSearchCompleted(instances, localSearch: localSearch)
  }
}

extension TopicsController: DataObservable {
  func onDataLoaded() {
    isDataReady = true
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
}

extension TopicsController: ScreenVisible {
  func setActive(_ flag: Bool) {
    guard flag else {
      isOnScreen = false
      
      return
    }
    isOnScreen = mode == .Topic ? true : false
  }
}
