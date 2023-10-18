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
  
  // MARK: - Public properties
  var controllerOutput: SurveysControllerOutput?
  var controllerInput: SurveysControllerInput?
  public private(set) var filter: SurveyFilter
  ///**Logic**
  public private(set) var isOnScreen: Bool = true
  ///**UI**
  public var tintColor: UIColor = .clear
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var searchString = ""
  private var searchMode = Enums.SearchMode.off {
    didSet {
      guard oldValue != searchMode else { return }
      
      onBarModeChanged()
      
      guard searchMode == .on else {
        searchString = ""
        return
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
    
    switch filter.getMain() {
    case .compatible:
      if let compatibility = filter.compatibility,
         let userprofile = compatibility.userprofile
      {
        text = "userprofile_compatibility".localized.uppercased()
        user = userprofile
//        image = UIImage(systemName: "person.2.fill")
      }
    case .user:
      if let userprofile = filter.userprofile {
        user = userprofile
        text = "publications".localized.uppercased()
      }
    case .own:
      image = Userprofiles.shared.current?.image
      text = "my_publications".localized.uppercased()
//    case .favorite:
//      text = "watching".localized.uppercased()
//      image = UIImage(systemName: "binoculars.fill")
    default:
      if let topic = filter.topic  {
        text = topic.title.uppercased()
        iconCategory = topic.iconCategory
      }
    }
    
    switch filter.getAdditional() {
    case .watchlist:
      text = "watching".localized.uppercased()
      image = UIImage(systemName: "binoculars.fill")
    default: debugPrint("")
    }
    
    return TagCapsule(text: text,
                      padding: padding/2,
                      textPadding: .init(top: padding/1.5, left: 0, bottom: padding/1.5, right: padding),
                      color: tintColor,
                      font: UIFont(name: Fonts.Rubik.Medium, size: 14)!,
                      isShadowed: false,
                      iconCategory: iconCategory,
                      image: image,
                      userprofile: user)
  }()
  private lazy var searchField: InsetTextField = {
    let instance = InsetTextField(rightViewVerticalScaleFactor: 1.25)
    instance.autocorrectionType = .no
    let v = UIActivityIndicatorView()
    v.color = Colors.main
    v.alpha = 0
    instance.rightView = v
    instance.rightViewMode = .always
    instance.attributedPlaceholder = NSAttributedString(string: "search".localized, attributes: [
      .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote) as Any,
      .foregroundColor: UIColor.secondaryLabel,
    ])
    instance.alpha = 0
    instance.delegate = self
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.backgroundColor = .secondarySystemBackground//traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.tintColor = tintColor//traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
    instance.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
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
  private let searchPublisher = PassthroughSubject<String, Never>()
  
  // MARK: - Deinitialization
  deinit {
    titleView.removeFromSuperview()
    searchField.removeFromSuperview()
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
    debugPrint("\(String(describing: type(of: self))).\(#function) \(DebuggingIdentifiers.destructing)")
  }
  
  // MARK: - Initialization
  init(filter: SurveyFilter, color: UIColor = .clear) {
    self.filter = filter
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
    navigationController?.setBarColor(traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    switch searchMode {
    case .on:
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
    case .off:
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
    
    switch searchMode {
    case .on:
      guard let constraint = searchField.getConstraint(identifier: "centerY") else { return }
      
      UIView.animate(withDuration: 0.1) { [weak self] in
        guard let self = self else { return }
        
        self.navigationController?.navigationBar.setNeedsLayout()
        constraint.constant = -100
        self.navigationController?.navigationBar.layoutIfNeeded()
      }
    case .off:
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
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    navigationController?.setBarColor(traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground)
  }
}

extension SurveysController: SurveysViewInput {
  func getDataItems(excludeList: [SurveyReference]) {
    if searchMode == .on {
      searchPublisher.send(searchString)
    } else {
      controllerInput?.getDataItems(filter: filter, excludeList: excludeList, substring: searchString)
    }
  }
  
  func openUserprofile(_ userprofile: Userprofile) {
//    guard mode != .user else { return }
//
//    let backItem = UIBarButtonItem()
//    backItem.title = ""
//    navigationItem.backBarButtonItem = backItem
//
//    navigationController?.pushViewController(UserprofileController(userprofile: userprofile, color: tintColor), animated: true)
  }
  
  func unsubscribe(from userprofile: Userprofile) {
    controllerInput?.unsubscribe(from: userprofile)
  }
  
  func subscribe(to userprofile: Userprofile) {
    controllerInput?.subscribe(to: userprofile)
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
  func onSearchCompleted(_ instances: [SurveyReference], localSearch: Bool) {
    controllerOutput?.onSearchCompleted(instances)
    
    if !localSearch {
      setSearchSpinnerEnabled(enabled: false, animated: true)
    }

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

    switch filter.getMain() {
    case .topic:
      guard let topic = filter.topic else { return }

      color = topic.tagColor
    case .compatible:
      guard let compatibility = filter.compatibility else { return }

      color = compatibility.topic.tagColor
    default:
      color = tintColor
    }

    navigationController?.setBarTintColor(color)
    navigationBar.addSubview(searchField)
    navigationBar.addSubview(titleView)
    searchField.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      searchField.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.NavBarHeightSmallState - padding),
      searchField.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 44 + 4),
//      titleView.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
//      titleView.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: titleView.font) + padding*2),
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
      .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
      .filter { $0.count > 2 }
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
  func onBarModeChanged() {
    func toggleSearchField(on: Bool) {
      guard let navigationBar = navigationController?.navigationBar,
            let constraint = searchField.getConstraint(identifier: "width")
      else { return }
      
      navigationBar.setNeedsLayout()
      searchField.text = ""
      
      controllerOutput?.setSearchModeEnabled(on)
      
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
          constraint.constant = on ? navigationBar.frame.width - ((44 + 4)*2) : 20
//          constraint.constant = on ? navigationBar.frame.width - (10*2 + (44 + 4)*2) : 20
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
    
    searchString = searchMode == .on ? searchString: ""
    toggleSearchField(on: searchMode == .on ? true : false)
    toggleTopicView(on: searchMode != .on ? true : false)
  }
  
  @objc
  func handleTap() {}
  
  func setBarItems() {
    var button: UIBarButtonItem!
    
    switch searchMode {
    case .on:
      let action = UIAction { [unowned self] _ in
        self.searchMode = .off
      }
      
      button = UIBarButtonItem(title: "",
                               image: UIImage(systemName: "xmark",
                                              withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                               primaryAction: action,
                               menu: nil)
      
    case .off:
      let action = UIAction { [unowned self] _ in
//        self.mode = .search
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
  
  @objc
  func hideKeyboard() {
    if let recognizer = view.gestureRecognizers?.first {
      view.removeGestureRecognizer(recognizer)
    }
    view.endEditing(true)
  }
  
  func setSearchSpinnerEnabled(enabled: Bool, animated: Bool) {
    guard let spinner = searchField.rightView as? UIActivityIndicatorView else { return }
    
    if enabled && !spinner.alpha.isZero || !enabled && spinner.alpha.isZero {
      return
    }
    
    if enabled {
      spinner.startAnimating()
    }
    
    switch animated {
    case true:
      spinner.alpha = !enabled ? 1 : 0
      spinner.transform = enabled ? .init(scaleX: 0.5, y: 0.5) : .identity
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: enabled ? 0 : 0.25, options: .curveEaseInOut, animations: {
        spinner.alpha = enabled ? 1 : 0
        spinner.transform = enabled ? .identity : .init(scaleX: 0.5, y: 0.5)
      }) { _ in
        if !enabled {
          spinner.stopAnimating()
        }
      }
    case false:
      spinner.alpha = enabled ? 1 : 0
      if !enabled {
        spinner.stopAnimating()
      }
    }
  }
}

extension SurveysController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if let recognizers = view.gestureRecognizers, recognizers.isEmpty {
      let touch = UITapGestureRecognizer(target:self, action:#selector(SurveysController.hideKeyboard))
      view.addGestureRecognizer(touch)
    }
    return true
  }
  
  @objc
  func textFieldDidChange(_ textField: UITextField) {
    guard let text = textField.text else { return }
    
    if text.isEmpty {
      onSearchCompleted([], localSearch: false)
      setSearchSpinnerEnabled(enabled: false, animated: true)
    } else if text.count > 2 {
      setSearchSpinnerEnabled(enabled: true, animated: true)
      searchPublisher.send(text)
    }
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
