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
  public private(set) var mode: Enums.SurveyFilterMode {
    didSet {
      controllerOutput?.setMode(mode)
    }
  }
  ///**Logic**
  public private(set) var isOnScreen: Bool = true
  ///**UI**
  public var tintColor: UIColor = .clear
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //Logic
  private let initialMode: Enums.SurveyFilterMode
  private var isSearching = false
  private var searchString = ""
  private var barMode = BarMode.Default {
    didSet {
      guard oldValue != barMode else { return }
      
      onBarModeChanged()
      
      guard barMode == .Search else { return }
      
      if initialMode == .topic, let topic = topic {
        searchField.placeholder = "search_topic".localized + " \"\(topic.title)" + "\(topic.isOther ? "/" + topic.parent!.title : "")\""
      } else {
        searchField.placeholder = "search".localized
      }
    }
  }
  private var willMoveToParent = false
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var titleView: TagCapsule = {
    var image: UIImage?
    var iconCategory: Icon.Category?
    var user: Userprofile?
    var text: String = ""
    
    switch mode {
    case .compatible:
      if let compatibility = compatibility,
         let userprofile = compatibility.userprofile
      {
        text = "userprofile_compatibility".localized.uppercased()
        user = userprofile
//        image = UIImage(systemName: "person.2.fill")
      }
    case .user:
      if let userprofile = userprofile {
        user = userprofile
        text = "publications".localized.uppercased()
      }
    case .own:
      image = Userprofiles.shared.current?.image
      text = "my_publications".localized.uppercased()
    case .favorite:
      text = "watching".localized.uppercased()
      image = UIImage(systemName: "binoculars.fill")
    default:
      if let topic = topic  {
        text = topic.title.uppercased()
        iconCategory = topic.iconCategory
      }
    }
    
    return TagCapsule(text: text,
                      padding: padding/2,
                      textPadding: .init(top: padding/2, left: 0, bottom: padding/2, right: padding),
                      color: tintColor,
                      font: UIFont(name: Fonts.Rubik.SemiBold, size: 20)!,
                      isShadowed: false,
                      iconCategory: iconCategory,
                      image: image,
                      userprofile: user)
  }()
  private lazy var searchField: InsetTextField = {
    let instance = InsetTextField()
    instance.autocorrectionType = .no
    instance.attributedPlaceholder = NSAttributedString(string: "search".localized, attributes: [
      .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote) as Any,
      .foregroundColor: UIColor.secondaryLabel,
    ])
    instance.alpha = 0
    instance.delegate = self
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.backgroundColor = .secondarySystemBackground//traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.tintColor = tintColor//traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
    instance.addTarget(self, action: #selector(TopicsController.textFieldDidChange(_:)), for: .editingChanged)
    instance.returnKeyType = .done
    instance.publisher(for: \.bounds)
      .sink { rect in
        instance.cornerRadius = rect.width*0.025
        
        guard instance.insets == .zero else { return }
        
        instance.insets = UIEdgeInsets(top: instance.insets.top,
                                       left: rect.height/2.25,
                                       bottom: instance.insets.top,
                                       right: rect.height/2.25)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  ///**Publishers**
  private let searchPublisher = PassthroughSubject<[String:Any], Never>()
  
  
  
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
    self.mode = .topic
    self.initialMode = self.mode
    self.topic = topic
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  init(_ mode: Enums.SurveyFilterMode, color: UIColor = .clear) {
    self.mode = mode
    self.initialMode = self.mode
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  init(_ userprofile: Userprofile, color: UIColor = .clear) {
    self.userprofile = userprofile
    self.mode = .user
    self.initialMode = self.mode
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  init(_ compatibility: TopicCompatibility, color: UIColor = .clear) {
    self.compatibility = compatibility
    self.mode = .compatible
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
    setTasks()
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
  func getDataItems(excludeList: [SurveyReference]) {
    fatalError()
  }
  
  func openUserprofile(_ userprofile: Userprofile) {
    guard mode != .user else { return }
    
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
  
  func claim(_ dict: [SurveyReference: Claim]) {
    controllerInput?.claim(dict)
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
    navigationController?.pushViewController(PollController(surveyReference: instance, mode: instance.isComplete ? .Read : .Vote), animated: true)
    //        tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
  
//  func onDataSourceRequest(source: Enums.SurveyFilterMode,
//                           dateFilter: Enums.Period?,
//                           topic: Topic?,
//                           userprofile: Userprofile?,
//                           compatibility: TopicCompatibility?,
//                           substring: String,
//                           except: [SurveyReference],
//                           ownersIds: [Int],
//                           topicsIds: [Int],
//                           ids: [Int]) {
//    if source == .search {
//      controllerInput?.search(substring: searchString,
//                              localized: false,
//                              except: except,
//                              ownersIds: ownersIds,
//                              topicsIds: topicsIds)
//    } else {
//      controllerInput?.onDataSourceRequest(source: source,
//                                           dateFilter: dateFilter,
//                                           topic: topic,
//                                           userprofile: userprofile,
//                                           compatibility: compatibility,
//                                           ids: ids)
//    }
//  }
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
    case .topic:
      guard let topic = topic else { return }

      color = topic.tagColor
    case .compatible:
      guard let compatibility = compatibility else { return }

      color = compatibility.topic.tagColor
    default:
      color = tintColor
    }
//    setNavigationBarTintColor(color)
    navigationController?.setBarTintColor(color)
    navigationBar.addSubview(searchField)
    navigationBar.addSubview(titleView)
    searchField.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      searchField.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.NavBarHeightSmallState - padding),
      searchField.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 44 + 4),
//      titleView.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
      titleView.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: titleView.font) + padding),
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
  
  func setTasks() {
    searchPublisher
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
      .eraseToAnyPublisher()
      .sink { [weak self] in
        guard let self = self,
              let substring = $0["substring"] as? String,
              let ownersIds = $0["ownersIds"] as? [Int],
              let topicsIds = $0["topicsIds"] as? [Int]
        else { return }
        
        self.controllerInput?.search(substring: substring.lowercased(),
                                     localized: false,
                                     except: [],
                                     ownersIds: ownersIds,
                                     topicsIds: topicsIds)
      }
      .store(in: &subscriptions)
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
        options: [.curveEaseInOut]) { [weak self] in
          guard let self = self else { return }
          
          self.titleView.alpha = on ? 1 : 0
          constraint.constant = on ? 0 : -100
          navigationBar.layoutIfNeeded()
        }
    }
    
    setBarItems()
    
    searchString = barMode == .Search ? searchString: "" 
    toggleSearchField(on: barMode == .Search ? true : false)
    toggleTopicView(on: barMode != .Search ? true : false)
  }
  
  @objc
  func handleTap() {}
  
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
                               image: UIImage(systemName: "xmark",
                                              withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                               primaryAction: action,
                               menu: nil)
      
    case .Default:
      let action = UIAction { [unowned self] _ in
//        self.controllerOutput?.toggleSearchMode(true)
        self.mode = .search
        self.barMode = .Search
      }
      
      button = UIBarButtonItem(title: "",
                               image: UIImage(systemName: "magnifyingglass",
                                              withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                               primaryAction: action,
                               menu: nil)
    }
    
    navigationItem.setRightBarButton(button, animated: false)
  }
  
  @objc
  func hideKeyboard() {
    if let recognizer = view.gestureRecognizers?.first {
      view.removeGestureRecognizer(recognizer)
    }
    if mode == .search {
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
      guard initialMode == .user,
            let userprofile = userprofile
      else { return [] }
      
      return [userprofile.id]
    }()
    
    let topicPredicate: [Int] = {
      guard initialMode == .topic,
            let topic = topic
      else { return [] }
      
      return [topic.id]
    }()
    
    searchPublisher.send([
      "substring": text,
      "ownersIds": ownerPredicate,
      "topicsIds": topicPredicate
    ])
//    controllerInput?.search(substring: text,
//                            localized: false,
//                            except: [],
//                            ownersIds: ownerPredicate,
//                            topicsIds: topicPredicate)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let recognizer = view.gestureRecognizers?.first {
      view.removeGestureRecognizer(recognizer)
    }
    textField.resignFirstResponder()
    return true
  }
}

extension SurveysController: ScreenVisible {
  func setActive(_ flag: Bool) {
    isOnScreen = flag
  }
}
