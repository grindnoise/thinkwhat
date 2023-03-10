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
  ///**Logic**
  public private(set) var queue = QueueArray<Survey>()
  public var currentSurvey: Survey? { controllerOutput?.currentSurvey }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  ///**UI**
  private var isViewLayedOut = false
  private var isNetworking = false
  private var timer: Timer?
  private var initialColor: UIColor = .clear
  
  
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
    
    setNavigationBarTintColor(initialColor)
    
    guard isDataReady else { return }
    
    tabBarController?.setTabBarVisible(visible: true, animated: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    isOnScreen = true
    controllerOutput?.didAppear()
    
    guard let navigationBar = navigationController?.navigationBar,
          let tabBarController = tabBarController as? MainController
    else { return }
    
    tabBarController.setLogoInitialFrame(size: navigationBar.bounds.size,
                                         y: abs(navigationBar.center.y))
    
    tabBarController.toggleLogo(on: true)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    isOnScreen = false
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
      self.navigationController?.pushViewController(SurveyCreationController(), animated: true)
      self.tabBarController?.setTabBarVisible(visible: false, animated: true)
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
      .map { array in array.filter { $0.isHot && !$0.isRejected && !$0.isClaimed }}
      .sink { [unowned self] in self.queue.enqueue($0) }
      .store(in: &subscriptions)
    
    SurveyReferences.shared.bannedPublisher
      .receive(on: DispatchQueue.main)
      .filter { !$0.survey.isNil }
      .sink { [unowned self] in self.queue.remove($0.survey!) }
      .store(in: &subscriptions)
    
    Timer.publish(every: 5, on: .main, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in self.isOnScreen }
      .sink { [unowned self] _ in self.controllerInput?.updateData() }
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
              main.selectedIndex == 0
        else { return }
        
        self.isOnScreen = true
      }
    })
  }
  
  func setData() {
    queue.enqueue(Surveys.shared.hot)
  }
}

// MARK: - View Input
extension HotController: HotViewInput {
  func reject(_ survey: Survey) {
    self.controllerInput?.reject(survey)
  }
  
  func vote(_ instance: Survey) {
//    navigationController?.delegate = appDelegate.transitionCoordinator
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
    isDataReady = true
    navigationController?.setNavigationBarHidden(false, animated: true)
    
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

    
    setData()
    setTasks()
    controllerOutput?.setSurvey(queue.dequeue())
  }
}

// MARK: - Observers
private extension HotController {

}

