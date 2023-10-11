//
//  ListController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class ListController: UIViewController, TintColorable {
  
  // MARK: - Public properties
  var controllerOutput: ListControllerOutput?
  var controllerInput: ListControllerInput?
  ///**Logic**
  public var filter = SurveyFilter(main: .new, additional: .period, period: .unlimited)
  public var isDataReady: Bool = false
  public var tintColor: UIColor = Colors.main
  public var searchMode = Enums.SearchMode.off {
    didSet {
      guard oldValue != searchMode else { return }
      
      onBarModeChanged(searchMode == .on ? true : false)
    }
  }
  ///**UI**
  public private(set) var isOnScreen = false // {
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  
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
  
  // MARK: - Overridden methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let model = ListModel()
    //        let view = ListView()
    
    self.controllerOutput = view as? ListView
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    //        self.view = view as UIView
    
    ProtocolSubscriptions.subscribe(self)
    setupUI()
    setTasks()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.prefersLargeTitles = false//true
    navigationItem.largeTitleDisplayMode = .never//.always
    navigationController?.setNavigationBarHidden(false, animated: true)
    navigationController?.setBarShadow(on: false)
    navigationController?.setBarTintColor(tintColor)
    navigationController?.setBarColor(.systemBackground)
    tabBarController?.setTabBarVisible(visible: true, animated: true)
    
    //        guard let main = tabBarController as? MainController else { return }
    //
    //        main.toggleLogo(on: true)
    isOnScreen = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    isOnScreen = true
    controllerOutput?.didAppear()
    
    guard let main = tabBarController as? MainController else { return }
    
    main.toggleLogo(on: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    controllerOutput?.didDisappear()
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

// MARK: - View Input
extension ListController: ListViewInput {
  func openSettings() {
    tabBarController?.selectedIndex = 4
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
    //        navigationController?.pushViewController(TestViewController(), animated: true)
    navigationController?.pushViewController(PollController(surveyReference: instance, mode: instance.isComplete ? .Read : .Vote), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let controller = tabBarController as? MainController else { return }
    
    controller.toggleLogo(on: false)
  }
  
  func getDataItems(excludeList: [SurveyReference]) {
    controllerInput?.getDataItems(filter: filter, excludeList: excludeList)
  }
}

private extension ListController {
  func setTasks() {
    Notifications.UIEvents.tabItemPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        self.isOnScreen = $0.keys.first == .Feed
        
        if $0.values.first == .Feed && $0.keys.first == .Feed {
          self.controllerOutput?.scrollToTop()
        }
      }
      .store(in: &subscriptions)
    
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.didEnterBackgroundNotification) {
        guard let self = self else { return }
        
        self.controllerOutput?.didDisappear()
      }
    })

    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.willEnterForegroundNotification) {
        guard let self = self else { return }
        
        self.navigationController?.setBarShadow(on: false)
      }
    })
    controllerOutput?.searchPublisher
      .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
//      .filter { $0.count > 2 }
      .eraseToAnyPublisher()
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.controllerInput?.search(substring: $0,
                                     localized: false,
                                     filter: self.filter)
      }
      .store(in: &subscriptions)
  }
  
  @MainActor
  func setupUI() {
    navigationItem.title = ""
    navigationController?.navigationBar.prefersLargeTitles = false//deviceType == .iPhoneSE ? false : true
    setBarItems()
  }
  
  func setBarItems() {
    var button: UIBarButtonItem!
    
    if searchMode == .off {
      let action = UIAction { [unowned self] _ in
        self.searchMode = .on
      }
      
      button = UIBarButtonItem(title: "",
                               image: UIImage(systemName: "magnifyingglass",
                                              withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                               primaryAction: action,
                               menu: nil)
    }
    
    navigationItem.setRightBarButton(button, animated: false)
  }
  
  @MainActor
  func onBarModeChanged(_ searchMode: Bool) {
    setBarItems()
    controllerOutput?.setSearchModeEnabled(searchMode)
  }
  
  @objc
  func hideKeyboard() {
    if let recognizer = view.gestureRecognizers?.first {
      view.removeGestureRecognizer(recognizer)
    }
  }
}

extension ListController: ListModelOutput {
  func onSearchCompleted(_ instances: [SurveyReference], localSearch: Bool) {
    controllerOutput?.onSearchCompleted(instances, localSearch: localSearch)
  }

  func onRequestCompleted(_ result: Result<Bool, Error>) {
    controllerOutput?.onRequestCompleted(result)
  }
}

extension ListController: DataObservable {
  func onDataLoaded() {
    isDataReady = true
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
}

extension ListController: ScreenVisible {
  func setActive(_ flag: Bool) {
    isOnScreen = flag
  }
}

