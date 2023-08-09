//
//  HotController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine



class HotController: UIViewController, TintColorable {
  
  // MARK: - Public properties
  var controllerOutput: HotControllerOutput?
  var controllerInput: HotControllerInput?
  var shouldSkipCurrentCard = false
  var tintColor: UIColor = .clear {
    didSet {
      initialColor = tintColor
    }
  }
  var isDataReady: Bool = false
  ///**UI**
  public private(set) var isOnScreen = true
  public private(set) var tabBarHeight: CGFloat = .zero
  public private(set) var navBarHeight: CGFloat = .zero
  /// **Logic**
  private var surveyId: String?  // Used when app was opened from push notification in closed state
  private var commentId: String? //
  public private(set) var queue = QueueArray<Survey>() // Store elements in queue
  public var currentSurvey: Survey? { controllerOutput?.currentSurvey } // Survey on screen
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var isFirstLaunch = true
  ///**UI**
  private var isViewLayedOut = false
  private var isNetworking = false
  private var initialColor: UIColor = .clear
  
  
  
  // MARK: - Initialization
  /// Init from push notification with survey id arrives when app is closed
  /// - Parameter surveyId: key extracted from push notification
  init(surveyId: String? = nil) {
    self.surveyId = surveyId
    super.init(nibName: nil, bundle: nil)
  }
  
  /// Init from push notification with survey id arrives when app is closed
  /// - Parameter commentId: key extracted from push notification
  init(commentId: String? = nil) {
    self.commentId = commentId
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let model = HotModel()
    
    self.controllerOutput = view as? HotView
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
//    setNavigationBarTintColor(initialColor)
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.setBarTintColor(initialColor)
    navigationController?.setBarShadow(on: false)
    
//    controllerOutput?.willAppear()
    
    guard isDataReady, isFirstLaunch else { return }

    tabBarController?.setTabBarVisible(visible: true, animated: surveyId.isNil ? true : false)
    isFirstLaunch = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    isOnScreen = true
    
    controllerOutput?.willAppear()
    
    guard let navigationBar = navigationController?.navigationBar,
          let tabBarController = tabBarController as? MainController
    else { return }
    
    tabBarController.toggleLogo(on: true)
//    tabBarController.setTabBarVisible(visible: true, animated: surveyId.isNil ? true : false)
    tabBarController.setLogoInitialFrame(size: navigationBar.bounds.size,
                                         y: abs(navigationBar.center.y))
    guard isDataReady, !isFirstLaunch else { return }

    tabBarController.setTabBarVisible(visible: true, animated: surveyId.isNil ? true : false)
    
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    isOnScreen = false
    controllerOutput?.didDisappear()
//    tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
}

private extension HotController {
  @MainActor
  func setupUI() {
    let action = UIAction(handler: { [weak self] _ in
      guard let self = self else { return }
      
      let backItem = UIBarButtonItem()
      backItem.title = ""
      self.navigationItem.backBarButtonItem = backItem
      self.createPost()
    })
    
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationItem.title = ""
    navigationItem.setRightBarButton(UIBarButtonItem(title: nil,
                                                     image: UIImage(systemName: "megaphone.fill",
                                                                    withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                                     primaryAction: action,
                                                     menu: nil),
                                     animated: true)
  }
  
  func setTasks() {
    Surveys.shared.instancesPublisher
      .filter { !$0.isEmpty }
      .receive(on: DispatchQueue.main)
      .map { array in array.filter { $0.isHot && !$0.isRejected && !$0.isClaimed && !$0.isComplete && $0.id != Survey.fakeId }}
      .sink { [unowned self] in
        
        $0.forEach { $0.media.forEach { $0.downloadImage() }}
        self.queue.enqueue($0)
        
        guard let controllerOutput = controllerOutput,
              controllerOutput.currentSurvey.isNil
        else { return }
        
        controllerOutput.next(queue.dequeue())
      }
      .store(in: &subscriptions)
    
    SurveyReferences.shared.bannedPublisher
      .receive(on: DispatchQueue.main)
      .filter { !$0.survey.isNil }
      .sink { [unowned self] in self.queue.remove($0.survey!) }
      .store(in: &subscriptions)
    
    // Update survey stats - views, is_banned, rating, etc.
    Timer.publish(every: 10, on: .main, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in
        guard self.isOnScreen,
              let controllerOutput = self.controllerOutput,
              !self.queue.isEmpty || !controllerOutput.currentSurvey.isNil
        else { return false }

        return true
      }
      .sink { [unowned self] _ in self.controllerInput?.updateData() }
      .store(in: &subscriptions)
    
    // Request new chunk of surveys if stack is empty
    Timer.publish(every: 5, on: .main, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in
        guard self.isOnScreen,
              let controllerOutput = self.controllerOutput,
              queue.isEmpty && controllerOutput.currentSurvey.isNil
        else { return false }
      
        return true
      }
      .sink { [unowned self] _ in self.controllerInput?.getSurveys([])}
      .store(in: &subscriptions)
    
    tasks.append(Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.System.Tab) {
        guard let self = self,
              let tab = notification.object as? Tab
        else { return }
        
        self.isOnScreen = tab == .Hot
      }
    })
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.didEnterBackgroundNotification) {
        guard let self = self else { return }
        
        self.isOnScreen = false
        self.controllerOutput?.didDisappear()
      }
    })
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.willEnterForegroundNotification) {
        guard let self = self,
              let main = self.tabBarController as? MainController,
              main.selectedIndex == 0
        else { return }
        
        self.isOnScreen = true
        self.controllerOutput?.willAppear()
      }
    })
    
//    guard let userprofile = Userprofiles.shared.current else { return }
//
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
  }
  
  func setData() {
    Surveys.shared.hot.forEach { $0.media.forEach { $0.downloadImage() }}
    queue.enqueue(Surveys.shared.hot)
  }
}

// MARK: - View Input
extension HotController: HotViewInput {
  func createPost() {
    self.navigationController?.pushViewController(NewPollController(color: self.tintColor), animated: true)
    self.tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let main = self.tabBarController as? MainController else { return }
    
    main.toggleLogo(on: false)
  }
  
  func reject(_ survey: Survey) {
    self.controllerInput?.reject(survey)
  }
  
  func vote(_ instance: Survey) {
    navigationController?.delegate = nil//appDelegate.transitionCoordinator
    navigationController?.navigationBar.backItem?.title = ""
    navigationController?.pushViewController(PollController(surveyReference: instance.reference), animated: true)
    navigationController?.delegate = nil
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let main = tabBarController as? MainController else { return }
    
    main.toggleLogo(on: false)
  }
  
  func claim(_ dict: [SurveyReference: Claim]) {
    controllerInput?.claim(dict)
  }
  
  func deque() -> Survey? {
    guard let instance = queue.dequeue() else {
      controllerInput?.getSurveys([])
      
      return nil
    }
    
    return instance
  }
}

// MARK: - Model Output
extension HotController: HotModelOutput {

}

extension HotController: DataObservable {
  func onDataLoaded() {
//    delay(seconds: 2) {
//      let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "binoculars.fill")!,
//                                                            text: "watch_survey_notification",
//                                                            tintColor: .label),
//                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                             isModal: false,
//                             useContentViewHeight: true,
//                             shouldDismissAfter: 20)
//      banner.didDisappearPublisher
//        .sink { _ in banner.removeFromSuperview() }
//        .store(in: &self.subscriptions)
//    }
    
    isDataReady = true
    navigationController?.setNavigationBarHidden(false, animated: surveyId.isNil ? true : false)
    
    if tabBarHeight.isZero,
       let height = tabBarController?.tabBar.bounds.height,
       !height.isZero {
      tabBarHeight = height
    }
    
    if navBarHeight.isZero,
       let height = navigationController?.navigationBar.bounds.height,
       !height.isZero {
      navBarHeight = height
    }

    controllerOutput?.didLoad()
    setData()
    setTasks()
    controllerOutput?.setSurvey(queue.dequeue())
    
    // If app was opened from notification with survey id
    if let surveyId = surveyId {
      navigationController?.navigationBar.backItem?.title = ""
      navigationController?.pushViewController(PollController(surveyId: surveyId), animated: true)
      tabBarController?.setTabBarVisible(visible: false, animated: true)
      
      guard let main = tabBarController as? MainController else { return }
      
      main.toggleLogo(on: false)
      self.surveyId = nil
    }
  }
}

extension HotController: ScreenVisible {
  func setActive(_ flag: Bool) {
    isOnScreen = flag
  }
}
