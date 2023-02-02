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
  
  // MARK: - Overridden properties
//  override var preferredStatusBarStyle: UIStatusBarStyle {
//    return mode == .Topic ? .lightContent : .default
//  }
  
  
  
  // MARK: - Public properties
  var controllerOutput: SurveysControllerOutput?
  var controllerInput: SurveysControllerInput?
  public private(set) var topic: Topic?
  public private(set) var userprofile: Userprofile?
  public private(set) var mode: Survey.SurveyCategory
  //UI
  public var tintColor: UIColor = .clear
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private lazy var topicIcon: Icon = {
    let instance = Icon(category: topic.isNil ? .Null : topic!.iconCategory)
    instance.iconColor = .white
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.65
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var topicTitle: InsetLabel = {
    let instance = InsetLabel()
    instance.font = UIFont(name: Fonts.Bold, size: 20)
    instance.text = topic.isNil ? "" : topic!.title.uppercased()
    instance.textColor = .white
    instance.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    return instance
  }()
  private lazy var topicView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      topicIcon,
      topicTitle
    ])
    instance.backgroundColor = topic.isNil ? .secondaryLabel : topic!.tagColor
    instance.axis = .horizontal
    instance.spacing = 2
    instance.alpha = 0
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    
    return instance
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
  init(_ topic: Topic, color: UIColor = .clear) {
    self.mode = .Topic
    self.topic = topic
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  init(_ mode: Survey.SurveyCategory, color: UIColor = .clear) {
    self.mode = mode
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  init(_ userprofile: Userprofile, color: UIColor = .clear) {
    self.userprofile = userprofile
    self.mode = .ByOwner
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
  
//  override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//
//    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) { [weak self] in
//      guard let self = self else { return }
//
//      self.titleLabel.alpha = 0
//      self.titleLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//    }
//  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationController?.navigationBar.setNeedsLayout()
    navigationItem.largeTitleDisplayMode = .never
    //Set bar visible
    navigationController?.navigationBar.alpha = 1
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    controllerOutput?.viewDidDisappear()
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
  
  func onDataSourceRequest(source: Survey.SurveyCategory, dateFilter: Period?, topic: Topic?, userprofile: Userprofile?) {
    controllerInput?.onDataSourceRequest(source: source, dateFilter: dateFilter, topic: topic, userprofile: userprofile)
  }
}

extension SurveysController: SurveysModelOutput {
  func onRequestCompleted(_ result: Result<Bool, Error>) {
    controllerOutput?.onRequestCompleted(result)
  }
}

private extension SurveysController {
  @MainActor
  func setupUI() {
    switch mode {
    case .Topic:
      navigationItem.titleView = topicView
    case .ByOwner:
      guard let userprofile = userprofile else { return }
      
      let avatar = Avatar(userprofile: userprofile)
      avatar.heightAnchor.constraint(equalToConstant: 40).isActive = true
      avatar.tapPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          let banner = NewBanner(contentView: UserBannerContentView(mode: .Username,
                                                                      userprofile: userprofile),
                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                 isModal: false,
                                 useContentViewHeight: true,
                                 shouldDismissAfter: 1)
          banner.didDisappearPublisher
            .sink { _ in banner.removeFromSuperview() }
            .store(in: &self.subscriptions)
        }
        .store(in: &subscriptions)
      
      navigationItem.titleView = avatar
    case .Own:
      title = "my_publications".localized
    case .Favorite:
      title = "watching".localized
    default:
#if DEBUG
      print("")
#endif
    }
    
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
    default:
      color = tintColor
    }
    setNavigationBarTintColor(color)
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
    
    let button = UIBarButtonItem(title: "",
                    image: UIImage(systemName: "slider.horizontal.3",
                                              withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                    primaryAction: nil,
                    menu: prepareMenu())
    
    navigationItem.setRightBarButton(button, animated: true)
  }
  
  func prepareMenu() -> UIMenu {
      let shareAction: UIAction = .init(title: "share".localized, image: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline, scale: .large)), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
          guard let self = self//,
//                let instance = self.item
          else { return }

//          self.shareSubject.send(instance)
      })
      
      let watchAction : UIAction = .init(title: "watch".localized, image: UIImage(systemName: "binoculars.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
          guard let self = self//,
//                let instance = self.item
          else { return }
          
//          self.watchSubject.send(instance)
      })
      watchAction.accessibilityIdentifier = "watch"

      
      let claimAction : UIAction = .init(title: "make_claim".localized, image: UIImage(systemName: "exclamationmark.triangle.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { [weak self] action in
          guard let self = self//,
//                let instance = self.item
          else { return }
          
//          self.claimSubject.send(instance)
      })
      
      var actions: [UIAction] = []//[claimAction, watchAction, shareAction]
      
//      if !item.isOwn {
          actions.append(claimAction)
          actions.append(watchAction)
//      }
      actions.append(shareAction)
      
      return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
  }
}
