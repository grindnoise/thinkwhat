//
//  SurveysViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveysController: UIViewController, TintColorable {
  
  enum BarMode {
    case Search, Default
  }
  // MARK: - Overridden properties
//  override var preferredStatusBarStyle: UIStatusBarStyle {
//    return mode == .Topic ? .lightContent : .default
//  }
  
  
  
  // MARK: - Public properties
  var controllerOutput: SurveysControllerOutput?
  var controllerInput: SurveysControllerInput?
  public private(set) var topic: Topic?
  public private(set) var userprofile: Userprofile?
  public private(set) var compatibility: TopicCompatibility?
  public private(set) var mode: Survey.SurveyCategory {
    didSet {
      print("mode", mode)
      controllerOutput?.setMode(mode)
//      controllerOutput?.toggleSearchMode(mode == .Search ? true : false)
    }
  }
  //UI
  public var tintColor: UIColor = .clear
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //Logic
  private let initialMode: Survey.SurveyCategory
  private var isSearching = false
  private var searchString = ""
  private var barMode = BarMode.Default {
    didSet {
      guard oldValue != barMode else { return }
      
      onBarModeChanged()
    }
  }
  private var willMoveToParent = false
  //UI
  private lazy var titleView: UIStackView = {
    let topicTitle = InsetLabel()
    topicTitle.font = UIFont(name: Fonts.Bold, size: 20)
    topicTitle.textColor = .white
    topicTitle.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    topicTitle.insets.right = 8
    
    var instance: UIStackView!
    
    switch mode {
    case .Compatibility:
      guard let compatibility = compatibility,
            let userprofile = compatibility.userprofile
      else { return UIStackView() }
      
      let opaque = UIView.opaque()
      opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 1/1).isActive = true
      let avatar = Avatar(userprofile: userprofile,
                          isBordered: true,
                          lightBorderColor: .white,
                          darkBorderColor: .white)
      avatar.placeInCenter(of: opaque, heightMultiplier: 0.75)
      
      topicTitle.text = compatibility.topic.title.uppercased()
      instance = UIStackView(arrangedSubviews: [
        opaque,
        topicTitle
      ])
      instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: topicTitle.font)).isActive = true
      instance.backgroundColor = compatibility.topic.tagColor
    case .ByOwner:
      guard let userprofile = userprofile else { return UIStackView() }
      
      let opaque = UIView.opaque()
      opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 1/1).isActive = true
      let avatar = Avatar(userprofile: userprofile,
                          isBordered: true,
                          lightBorderColor: .white,
                          darkBorderColor: .white)
      avatar.placeInCenter(of: opaque, heightMultiplier: 0.75)
      
      topicTitle.text = "publications".localized.uppercased()
      instance = UIStackView(arrangedSubviews: [
        opaque,
        topicTitle
      ])
      instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: topicTitle.font)).isActive = true
      instance.backgroundColor = tintColor
    case .Own:
      topicTitle.text = "my_publications".localized.uppercased()
      instance = UIStackView(arrangedSubviews: [ topicTitle ])
      instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: topicTitle.font)).isActive = true
      instance.backgroundColor = tintColor
    case .Favorite:
      topicTitle.text = "watching".localized.uppercased()
      instance = UIStackView(arrangedSubviews: [topicTitle])
      instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: topicTitle.font)).isActive = true
      instance.backgroundColor = tintColor
    default:
      guard let topic = topic else { return UIStackView() }
      
      topicTitle.text = topic.title.uppercased()
//      topicTitle.insets.right = 8
      
      let topicIcon = Icon(category: topic.iconCategory)
      topicIcon.iconColor = .white
      topicIcon.isRounded = false
      topicIcon.clipsToBounds = false
      topicIcon.scaleMultiplicator = 1.65
      topicIcon.heightAnchor.constraint(equalTo: topicIcon.widthAnchor, multiplier: 1/1).isActive = true
      instance = UIStackView(arrangedSubviews: [
        topicIcon,
        topicTitle
      ])
      instance.backgroundColor = topic.tagColor
    }
    
    instance.axis = .horizontal
    instance.spacing = 2
//      instance.alpha = 0
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var searchField: InsetTextField = {
    let instance = InsetTextField()
    instance.autocorrectionType = .no
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
  
  
  
  // MARK: - Deinitialization
  deinit {
    titleView.removeFromSuperview()
    searchField.removeFromSuperview()
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  // MARK: - Initialization
  init(_ topic: Topic, color: UIColor = .clear) {
    self.mode = .Topic
    self.initialMode = self.mode
    self.topic = topic
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  init(_ mode: Survey.SurveyCategory, color: UIColor = .clear) {
    self.mode = mode
    self.initialMode = self.mode
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  init(_ userprofile: Userprofile, color: UIColor = .clear) {
    self.userprofile = userprofile
    self.mode = .ByOwner
    self.initialMode = self.mode
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  init(_ compatibility: TopicCompatibility, color: UIColor = .clear) {
    self.compatibility = compatibility
    self.mode = .Compatibility
    self.initialMode = self.mode
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  // MARK: - Private methods
  
  // MARK: - Overridden methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = SurveysView()
    let model = SurveysModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationController?.navigationBar.setNeedsLayout()
    navigationItem.largeTitleDisplayMode = .never
    //Set bar visible
    navigationController?.navigationBar.alpha = 1
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    switch barMode {
    case .Search:
      guard let constraint = searchField.getConstraint(identifier: "centerY") else { return }
      
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut]) { [weak self] in
          guard let self = self else { return }
        
        self.navigationController?.navigationBar.setNeedsLayout()
        constraint.constant = 0
        self.navigationController?.navigationBar.layoutIfNeeded()
      }
    case .Default:
      guard let constraint = titleView.getConstraint(identifier: "centerY") else { return }
      
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut]) { [weak self] in
          guard let self = self else { return }
        
        self.navigationController?.navigationBar.setNeedsLayout()
        constraint.constant = 0
        self.navigationController?.navigationBar.layoutIfNeeded()
      }
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    controllerOutput?.viewDidDisappear()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    switch barMode {
    case .Search:
      guard let constraint = searchField.getConstraint(identifier: "centerY") else { return }
      
      UIView.animate(withDuration: 0.1) { [weak self] in
        guard let self = self else { return }
        
        self.navigationController?.navigationBar.setNeedsLayout()
        constraint.constant = -100
        self.navigationController?.navigationBar.layoutIfNeeded()
      }
    case .Default:
      guard let constraint = titleView.getConstraint(identifier: "centerY") else { return }
      
      UIView.animate(withDuration: 0.1) { [weak self] in
        guard let self = self else { return }
        
        self.navigationController?.navigationBar.setNeedsLayout()
        constraint.constant = -100
        self.navigationController?.navigationBar.layoutIfNeeded()
      }
    }
  }
  
  override func willMove(toParent parent: UIViewController?) {
      willMoveToParent = parent.isNil ? true : false
      super.willMove(toParent: parent)
  }
}

extension SurveysController: SurveysViewInput {
  func openUserprofile(_ userprofile: Userprofile) {
    guard mode != .ByOwner else { return }
    
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    
    navigationController?.pushViewController(UserprofileController(userprofile: userprofile, color: tintColor), animated: true)
  }
  
  func unsubscribe(from userprofile: Userprofile) {
    controllerInput?.unsubscribe(from: userprofile)
  }
  
  func subscribe(to userprofile: Userprofile) {
    controllerInput?.subscribe(to: userprofile)
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
    controllerInput?.updateSurveyStats(instances)
  }
  
  func onSurveyTapped(_ instance: SurveyReference) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(PollController(surveyReference: instance, showNext: false), animated: true)
    //        tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
  
  func onDataSourceRequest(source: Survey.SurveyCategory,
                           dateFilter: Period?,
                           topic: Topic?,
                           userprofile: Userprofile?,
                           substring: String,
                           except: [SurveyReference],
                           ownersIds: [Int],
                           topicsIds: [Int]) {
    if source == .Search {
      controllerInput?.search(substring: searchString,
                              localized: false,
                              except: except,
                              ownersIds: ownersIds,
                              topicsIds: topicsIds)
    } else {
      controllerInput?.onDataSourceRequest(source: source,
                                           dateFilter: dateFilter,
                                           topic: topic,
                                           userprofile: userprofile)
    }
  }
}

extension SurveysController: SurveysModelOutput {
  func onSearchCompleted(_ instances: [SurveyReference]) {
    controllerOutput?.onSearchCompleted(instances)
    isSearching = false
  }
  
  func onRequestCompleted(_ result: Result<Bool, Error>) {
    controllerOutput?.onRequestCompleted(result)
  }
}

private extension SurveysController {
  @MainActor
  func setupUI() {
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    setBarItems()

    guard let navigationBar = self.navigationController?.navigationBar else { return }

    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.shadowColor = nil
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.prefersLargeTitles = false

    if #available(iOS 15.0, *) {
      navigationBar.compactScrollEdgeAppearance = appearance
    }

    var color: UIColor = .secondaryLabel

    switch mode {
    case .Topic:
      guard let topic = topic else { return }

      color = topic.tagColor
    case .Compatibility:
      guard let compatibility = compatibility else { return }

      color = compatibility.topic.tagColor
    default:
      color = tintColor
    }
    setNavigationBarTintColor(color)
    
    navigationBar.addSubview(searchField)
    navigationBar.addSubview(titleView)
    searchField.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      searchField.heightAnchor.constraint(equalToConstant: 40),
      searchField.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 44 + 4),
//      titleView.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
      titleView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor)
    ])
    
    let constraint = searchField.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor)
    constraint.identifier = "centerY"
    constraint.isActive = true
    
    let widthConstraint = searchField.widthAnchor.constraint(equalToConstant: 20)
    widthConstraint.identifier = "width"
    widthConstraint.isActive = true
    
    let centerY = titleView.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor,
                                                     constant: -100)
    centerY.identifier = "centerY"
    centerY.isActive = true
    
    navigationBar.setNeedsLayout()
    navigationBar.layoutIfNeeded()
  }
  
  @MainActor
  func onBarModeChanged() {
    func toggleSearchField(on: Bool) {
      guard let navigationBar = navigationController?.navigationBar,
            let constraint = searchField.getConstraint(identifier: "width")
      else { return }
      
      navigationBar.setNeedsLayout()
      searchField.text = ""
      
      if on {
        let touch = UITapGestureRecognizer(target:self, action:#selector(SurveysController.hideKeyboard))
        view.addGestureRecognizer(touch)
        
        let _ = searchField.becomeFirstResponder()
//        controllerOutput?.toggleSearchMode(true)
        
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
          constraint.constant = on ? navigationBar.frame.width - (10*2 + (44 + 4)*2) : 20
          navigationBar.layoutIfNeeded()
        }) { _ in }
    }
    
    func toggleTopicView(on: Bool) {
      guard let navigationBar = navigationController?.navigationBar,
            let constraint = titleView.getConstraint(identifier: "centerY")
      else { return }
      
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [weak self] in
          guard let self = self else { return }
          
          self.titleView.alpha = on ? 1 : 0
          constraint.constant = on ? 0 : -100
          navigationBar.layoutIfNeeded()
        }) { _ in }
      
      UIView.animate(withDuration: on ? 0.1 : 0.3,
                     delay: 0.1) { [unowned self] in self.titleView.alpha = on ? 1 : 0 }
    }
    
    setBarItems()
    
    searchString = barMode == .Search ? searchString: "" 
    toggleSearchField(on: barMode == .Search ? true : false)
    toggleTopicView(on: barMode != .Search ? true : false)
  }
  
  @objc
  func handleTap() {}
  
  func setNavigationBarAppearance(largeTitleColor: UIColor, smallTitleColor: UIColor) {
    guard let navigationBar = navigationController?.navigationBar else { return }
    
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.largeTitleTextAttributes = [
      .foregroundColor: largeTitleColor,
      .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .largeTitle) as Any
    ]
    appearance.titleTextAttributes = [
      .foregroundColor: smallTitleColor,
      .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .title3) as Any
    ]
    appearance.shadowColor = nil
    
    switch mode {
    case .Topic:
      guard let topic = topic else { return }
      
      appearance.backgroundColor = topic.tagColor
      navigationBar.tintColor = .white
      navigationBar.barTintColor = .white
    case .Own:
      navigationBar.tintColor = .label
      navigationBar.barTintColor = .label
    default:
#if DEBUG
      print("")
#endif
    }
    
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.prefersLargeTitles = true
    
    if #available(iOS 15.0, *) {
      navigationBar.compactScrollEdgeAppearance = appearance
    }
  }
  
  func setBarItems() {
    var button: UIBarButtonItem!
    
    switch barMode {
    case .Search:
      let action = UIAction { [unowned self] _ in
//        self.controllerOutput?.toggleSearchMode(false)
        self.mode = initialMode
        self.barMode = .Default
      }
      
      button = UIBarButtonItem(title: "",
                               image: UIImage(systemName: "arrow.left",
                                              withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                               primaryAction: action,
                               menu: nil)
      
    case .Default:
      let action = UIAction { [unowned self] _ in
//        self.controllerOutput?.toggleSearchMode(true)
        self.mode = .Search
        self.barMode = .Search
      }
      
      button = UIBarButtonItem(title: "",
                               image: UIImage(systemName: "magnifyingglass",
                                              withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                               primaryAction: action,
                               menu: nil)
    }
    
    navigationItem.setRightBarButton(button, animated: true)
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

extension SurveysController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if let recognizers = view.gestureRecognizers, recognizers.isEmpty {
      let touch = UITapGestureRecognizer(target:self, action:#selector(SurveysController.hideKeyboard))
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
    controllerOutput?.beginSearchRefreshing()
    isSearching = true
    searchString = text
    
    let ownerPredicate: [Int] = {
      guard initialMode == .ByOwner,
            let userprofile = userprofile
      else { return [] }
      
      return [userprofile.id]
    }()
    
    let topicPredicate: [Int] = {
      guard initialMode == .Topic,
            let topic = topic
      else { return [] }
      
      return [topic.id]
    }()
    
    controllerInput?.search(substring: text,
                            localized: false,
                            except: [],
                            ownersIds: ownerPredicate,
                            topicsIds: topicPredicate)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let recognizer = view.gestureRecognizers?.first {
      view.removeGestureRecognizer(recognizer)
    }
    textField.resignFirstResponder()
    return true
  }
}
