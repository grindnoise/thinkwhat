//
//  TopicsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TopicsController: UIViewController, TintColorable {
  
  enum Mode {
    case Search, Default, Topic//Parent, Child, List, Search
  }
  
  // MARK: - Public properties
  var controllerOutput: TopicsControllerOutput?
  var controllerInput: TopicsControllerInput?
  var mode: Mode = .Default {
    didSet {
      guard oldValue != mode else { return }
      
      onModeChanged()
      
      guard mode == .Default else { return }
      
      var color = UIColor.systemGray
      
      switch oldValue {
      case .Topic:
        if let topic = topic  {
          color = topic.tagColor
        }
      default:
        color = tintColor//traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white
      }
      
      controllerOutput?.onDefaultMode(color: color)
    }
  }
  public var tintColor: UIColor = .clear {
    didSet {
      setNavigationBarTintColor(tintColor)
    }
  }
  ///`UI`
  public private(set) var isOnScreen = false
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`Logic`
  private var topic: Topic? {
    didSet {
      guard !topic.isNil else { return }
      
      mode = .Topic
    }
  }
  ///`Publishers`
  private var searchPublisher = CurrentValueSubject<String?, Never>(nil)
  
  //    private lazy var gradient: CAGradientLayer = {
  //        let instance = CAGradientLayer()
  //        instance.type = .radial
  //        instance.colors = getGradientColors()
  //        instance.locations = [0, 0.5, 1.15]
  //        instance.setIdentifier("radialGradient")
  //        instance.startPoint = CGPoint(x: 0.5, y: 0.5)
  //        instance.endPoint = CGPoint(x: 1, y: 1)
  //        instance.publisher(for: \.bounds)
  //            .sink { rect in
  //                instance.cornerRadius = rect.height/2
  //            }
  //            .store(in: &subscriptions)
  //
  //        return instance
  //    }()
  private lazy var searchField: InsetTextField = {
    let instance = InsetTextField()
    instance.placeholder = "search".localized
    instance.alpha = 0
    instance.delegate = self
    instance.backgroundColor = .secondarySystemBackground//traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.tintColor = tintColor//traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
    instance.addTarget(self, action: #selector(TopicsController.textFieldDidChange(_:)), for: .editingChanged)
    instance.returnKeyType = .done
    instance.publisher(for: \.bounds, options: .new)
      .sink { rect in
        instance.cornerRadius = rect.height/2.25
        
        guard instance.insets == .zero else { return }
        
        instance.insets = UIEdgeInsets(top: instance.insets.top,
                                       left: rect.height/2.25,
                                       bottom: instance.insets.top,
                                       right: rect.height/2.25)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var topicIcon: Icon = {
    let instance = Icon(category: Icon.Category.Logo)
    instance.iconColor = .white//Colors.Logo.Flame.rawValue
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.65
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var topicTitle: InsetLabel = {
    let instance = InsetLabel()
    instance.font = UIFont(name: Fonts.Bold, size: 20)//.scaledFont(fontName: Fonts.Semibold, forTextStyle: .title2)
    instance.text = "Test"
    instance.textColor = .white
    instance.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    return instance
  }()
  private lazy var topicView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      topicIcon,
      topicTitle
    ])
    instance.axis = .horizontal
    instance.spacing = 2
    instance.alpha = 0
    
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    //        instance.addSubview(stack)
    //        stack.translatesAutoresizingMaskIntoConstraints = false
    //
    //        NSLayoutConstraint.activate([
    //            stack.topAnchor.constraint(equalTo: instance.topAnchor),
    //            stack.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
    //            stack.bottomAnchor.constraint(equalTo: instance.bottomAnchor)
    //        ])
    
    return instance
  }()
  private var textFieldIsSetup = false
  private var isSearching = false //{
  //        didSet {
  //            searchField.isShowingSpinner = isSearching
  //        }
  //    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let model = TopicsModel()
    
    self.controllerOutput = view as? TopicsView
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    //        title = "topics".localized
    ProtocolSubscriptions.subscribe(self)
    setTasks()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    //        barButton.alpha = 1
    tabBarController?.setTabBarVisible(visible: true, animated: true)
    self.navigationController?.navigationBar.alpha = 1
    navigationController?.navigationBar.prefersLargeTitles = false//true
    navigationItem.largeTitleDisplayMode = .never//.always
    
    if mode == .Search {
      searchField.alpha = 1
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    isOnScreen = true
    switch mode {
    case .Topic:
      toggleTopicView(on: true)
    case .Search:
      toggleSearchField(on: true)
    default:
#if DEBUG
      print("")
#endif
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    switch mode {
    case .Topic:
      toggleTopicView(on: false)
    case .Search:
      toggleSearchField(on: false)
    default:
#if DEBUG
      print("")
#endif
    }
//    //        barButton.alpha = 0
//
//    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) { [weak self] in
//      guard let self = self else { return }
//
//      self.navigationController?.navigationBar.alpha = 0
//    }
//    if mode == .Search {
//      searchField.alpha = 0
//      searchField.resignFirstResponder()
//    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    isOnScreen = false
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    //        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    //        searchField.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
    //        searchField.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    //        barButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    //        gradient.colors = getGradientColors()
    //        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray)
  }
}

private extension TopicsController {
  @MainActor
  func setupUI() {
    navigationItem.title = ""
    guard let navigationBar = self.navigationController?.navigationBar else { return }
    
    navigationBar.addSubview(searchField)
    navigationBar.addSubview(topicView)
    searchField.translatesAutoresizingMaskIntoConstraints = false
    topicView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      searchField.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
      searchField.heightAnchor.constraint(equalToConstant: 40),
      searchField.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 10),
//      topicView.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 100, font: topicTitle.font)),//searchField.heightAnchor),
//      topicView.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
      topicView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor)
    ])
    let constraint = searchField.widthAnchor.constraint(equalToConstant: 20)
    constraint.identifier = "width"
    constraint.isActive = true
    
    navigationBar.setNeedsLayout()
    navigationBar.layoutIfNeeded()
    
    //        let leading = topicView.leadingAnchor.constraint(equalTo: searchField.leadingAnchor, constant: -(10 + topicView.bounds.width))
    //        leading.identifier = "leading"
    //        leading.isActive = true
    
//    let centerX = topicView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor, constant: -(navigationBar.bounds.width - topicView.bounds.width)/2)
//    centerX.identifier = "centerX"
//    centerX.isActive = true
    
    let centerY = topicView.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor,
                                                     constant: -50)
    centerY.identifier = "centerY"
    centerY.isActive = true
    
    setBarItems()
  }
  
  func setTasks() {
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
    
    tasks.append(Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.System.Tab) {
        guard let self = self,
              let tab = notification.object as? Tab
        else { return }
        
        self.isOnScreen = tab == .Feed
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
              main.selectedIndex == 3
        else { return }
        
        self.isOnScreen = true
      }
    })
    
    let debounced = searchPublisher
      .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
    
    debounced
      .filter { !$0.isNil }
      .sink { [unowned self] in self.controllerInput?.search(substring: $0!, excludedIds: []) }
      .store(in: &subscriptions)
  }
  
  @objc
  func handleTap() {
    switch mode {
    case .Topic:
      mode = .Default
    case .Search:
      mode = .Default
    case .Default:
      mode = .Search
    }
  }
  
  func getGradientColors() -> [CGColor] {
    return [
      traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
      traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
      traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.lighter(0.2).cgColor : K_COLOR_RED.lighter(0.2).cgColor,
    ]
  }
  
  @MainActor
  func setBarItems(zeroSubscriptions: Bool = false) {
    var rightButton: UIBarButtonItem!
    
    switch mode {
    case .Default:
      rightButton = UIBarButtonItem(title: nil,
                                    image: UIImage(systemName: "magnifyingglass",
                                                   withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                    primaryAction: {
        let action = UIAction { [weak self] _ in
          guard let self = self else { return }
          
          self.mode = .Search
        }
        
        return action
      }(),
                                    menu: nil)
      navigationItem.setRightBarButton(rightButton, animated: true)
      navigationItem.setLeftBarButton(nil, animated: true)
      
    case .Search:
      rightButton = UIBarButtonItem(title: nil,
                                    image: UIImage(systemName: "arrow.left",
                                                   withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                    primaryAction: {
        let action = UIAction { [weak self] _ in
          guard let self = self else { return }
          
          self.mode = .Default
        }
        
        return action
      }(),
                                    menu: nil)
      navigationItem.setRightBarButton(rightButton, animated: true)
      navigationItem.setLeftBarButton(nil, animated: true)
      
    case .Topic:
      rightButton = UIBarButtonItem(title: nil,
                                    image: UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                    primaryAction: {
        let action = UIAction { [weak self] _ in
          guard let self = self else { return }
          
          self.mode = .Default
        }
        
        return action
      }(),
                                    menu: nil)
      navigationItem.setRightBarButton(rightButton, animated: true)
      navigationItem.setLeftBarButton(nil, animated: true)
    }
  }
  
  @MainActor
  func onModeChanged() {
    setBarItems()
    
    guard let mainController = tabBarController as? MainController else { return }
    
    switch mode {
    case .Search:
      mainController.toggleLogo(on: false)
      toggleSearchField(on: true)
      
    case .Topic:
      mainController.toggleLogo(on: false)
      toggleTopicView(on: true)
      
    default:
      setNavigationBarTintColor(tintColor)
      mainController.toggleLogo(on: true)
      toggleSearchField(on: false)
      toggleTopicView(on: false)
    }
  }
  
  func toggleSearchField(on: Bool) {
    guard let navigationBar = navigationController?.navigationBar,
          let constraint = searchField.getConstraint(identifier: "width")
    else { return }
    
    navigationBar.setNeedsLayout()
    searchField.text = ""
    
    if on {
      let touch = UITapGestureRecognizer(target:self, action:#selector(TopicsController.hideKeyboard))
      view.addGestureRecognizer(touch)
      
      let _ = searchField.becomeFirstResponder()
      controllerOutput?.onSearchMode()
      
      //Clear previous fetch request
      controllerOutput?.onSearchCompleted([])
      
    } else {
      if let recognizer = view.gestureRecognizers?.first {
        view.removeGestureRecognizer(recognizer)
      }
      
      let _ = searchField.resignFirstResponder()
    }
    navigationItem.title = ""
    
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 0.9,
      initialSpringVelocity: 0.2,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        self.searchField.alpha = on ? 1 : 0
        constraint.constant = on ? navigationBar.frame.width - (10*2 + 44 + 4) : 20
        navigationBar.layoutIfNeeded()
      }) { _ in }
  }
  
  func toggleTopicView(on: Bool) {
    guard let topic = topic,
          let navigationBar = navigationController?.navigationBar,
          let constraint = topicView.getConstraint(identifier: "centerY")
    else { return }
    
    topicView.backgroundColor = topic.tagColor
    topicTitle.text = topic.title.uppercased()
    topicIcon.category = topic.iconCategory
    navigationBar.setNeedsLayout()
    navigationBar.layoutIfNeeded()
    
    UIView.animate(
      withDuration: 0.3,
      delay: on ? 0.2 : 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut]) { [weak self] in
        guard let self = self else { return }
        
        self.topicView.alpha = on ? 1 : 0
        constraint.constant = on ? 0 : -50
        navigationBar.layoutIfNeeded()
      }
  }
}

extension TopicsController: TopicsViewInput {
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
  
  func claim(surveyReference: SurveyReference, claim: Claim) {
    controllerInput?.claim(surveyReference: surveyReference, claim: claim)
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
  
  func onTopicSelected(_ instance: Topic) {
    topic = instance
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
    navigationController?.pushViewController(PollController(surveyReference: instance, showNext: false), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard let main = tabBarController as? MainController else { return }
    
    main.toggleLogo(on: false)
  }
  
  func onDataSourceRequest(dateFilter: Period, topic: Topic) {
    guard isOnScreen else { return }
    
    controllerInput?.onDataSourceRequest(dateFilter: dateFilter, topic: topic)
  }
  
  @objc
  func hideKeyboard() {
    if let recognizer = view.gestureRecognizers?.first {
      view.removeGestureRecognizer(recognizer)
    }
    if mode == .Search {
      searchField.resignFirstResponder()
    }
  }
}

// MARK: - Model Output
extension TopicsController: TopicsModelOutput {
  //    func onRequestCompleted(_ result: Result<Bool, Error>) {
  //        switch result {
  //        case .success:
  //            controllerOutput?.onRequestCompleted(result)
  //        case .failure(let error):
  //#if DEBUG
  //            error.printLocalized(class: type(of: self), functionName: #function)
  //#endif
  //        }
  //    }
  
  func onSearchCompleted(_ instances: [SurveyReference]) {
    controllerOutput?.onSearchCompleted(instances)
    isSearching = false
  }
}

extension TopicsController: DataObservable {
  func onDataLoaded() {
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
}

extension TopicsController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if let recognizers = view.gestureRecognizers, recognizers.isEmpty {
      let touch = UITapGestureRecognizer(target:self, action:#selector(TopicsController.hideKeyboard))
      view.addGestureRecognizer(touch)
    }
    return !isSearching
  }
  
  @objc
  func textFieldDidChange(_ textField: UITextField) {
    guard !isSearching, let text = textField.text, text.count > 3 else {
      onSearchCompleted([])
      
      return
    }
    
    searchPublisher.send(text)
    controllerOutput?.beginSearchRefreshing()
    isSearching = true
//    controllerInput?.search(substring: text, excludedIds: [])
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let recognizer = view.gestureRecognizers?.first {
      view.removeGestureRecognizer(recognizer)
    }
    textField.resignFirstResponder()
    return true
  }
  
  //    private func setupTextField(textField: UnderlinedSignTextField) {
  //        guard !textFieldIsSetup else { return }
  //        textFieldIsSetup = true
  //        textField.delegate = self
  //        textField.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
  //        textField.activeLineColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
  //        textField.line.layer.strokeColor = UIColor.systemGray.cgColor
  //        textField.color = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
  //        textField.addTarget(self, action: #selector(TopicsController.textFieldDidChange(_:)), for: .editingChanged)
  //    }
}
