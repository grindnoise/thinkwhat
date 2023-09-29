//
//  PollController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SafariServices
import Combine
import TinyConstraints

class PollController: UIViewController {
  
  enum Mode { case Read, Vote, Preview }
  
  // MARK: - Public properties
  var controllerOutput: PollControllerOutput?
  var controllerInput: PollControllerInput?
  public private(set) var item: SurveyReference!
  public private(set) var mode: Mode
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var tasks: [Task<Void, Never>?] = []
  private var subscriptions = Set<AnyCancellable>()
  ///**Logic**
  private var surveyId: Int? // For push notification
  private var threadId: Int? // For push notification
  private var replyId: Int? // For push notification
  private var replyToId: Int? // For push notification
  private var userHasVoted = false
  private var isOnScreen = false
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var avatar: Avatar = { Avatar() }()
  private lazy var titleView: TagCapsule = {
    TagCapsule(text: item.topic.title.uppercased(),
               padding: padding/2,
               textPadding: .init(top: padding/1.5, left: 0, bottom: padding/1.5, right: padding),
               color: item.topic.tagColor,
               font: UIFont(name: Fonts.Rubik.Medium, size: 14)!,
               isShadowed: false,
               iconCategory: item.topic.iconCategory)
  }()
  private var spinner: SpiralSpinner!
  public private(set) lazy var spiral: Icon = { Icon(frame: .zero, category: .Spiral, scaleMultiplicator: 1, iconColor: traitCollection.userInterfaceStyle == .dark ? Colors.spiralDark : Colors.spiralLight) }()
  
  
  // MARK: - Destructor
  deinit {
    //        topicView.removeFromSuperview()
    tasks.forEach { $0?.cancel() }
    NotificationCenter.default.removeObserver(self)
    subscriptions.forEach{ $0.cancel() }
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  // MARK: - Initialization
  // Init from lists/hot view
  init(surveyReference: SurveyReference, mode: Mode = .Vote) {
    self.item = surveyReference
    self.mode = mode
    
    super.init(nibName: nil, bundle: nil)
  }
  
  // Init from push notification
  init(surveyId: Int, mode: Mode = .Vote) {
    self.surveyId = surveyId
    self.mode = mode
    
    super.init(nibName: nil, bundle: nil)
  }
  
  init(surveyId: Int,
       threadId: Int? = nil,
       replyId: Int? = nil,
       replyToId: Int? = nil) {
    self.surveyId = surveyId
    self.threadId = threadId
    self.replyId = replyId
    self.replyToId = replyToId
    self.mode = .Read
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = PollView()
    let model = PollModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    self.view = view as UIView
    
    // Check if init is from push notification
    if item.isNil {
      if let surveyId = surveyId, let threadId = threadId, let replyId = replyId {
        // Check if survey already exists
        if let survey = Surveys.shared.all.filter({ $0.id == Int(surveyId) }).first {
          // Check if root comment is loaded
          if let root = Comments.shared.all.filter({ $0.id == threadId }).first {
            loadThread(root: root, replyId: replyId)
          } else {
            loadData(threadId: threadId, replyId: replyId)
          }
          item = survey.reference
          controllerOutput?.item = item.survey
          
          // Increment view counter
          guard mode != .Preview else { return }
          
          controllerInput?.incrementViewCounter()
        } else {
          loadData(surveyId: surveyId, threadId: threadId, replyId: replyId)
        }
      } else if let surveyId = surveyId {
        // Check if survey already exists
        guard let survey = Surveys.shared.all.filter({ $0.id == surveyId }).first else {
          loadData(surveyID: surveyId)
          
          return
        }
        
        item = survey.reference
      }
      return
    }
    
    guard item.isBanned else {
      loadData()
      setTasks()
      return
    }
    Banners.error(container: &self.subscriptions, text: "survey_banned_notification")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.setBarShadow(on: false, animated: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    isOnScreen = true
    
    tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark, animated: true)
    navigationController?.setBarColor(traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground)
    
    guard !item.isNil else { return }
    
    setupUI()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    isOnScreen = false
  }
  
//  override func willMove(toParent parent: UIViewController?) {
//    super.willMove(toParent: parent)
//
//    guard parent.isNil else { return }
//
//    clearNavigationBar(clear: true)
//  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    navigationController?.setBarColor(traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground)
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark, animated: true)
  }
  
  // MARK: - Public methods
  public func setThreadAndReplyFromPushNotification(threadId: Int, replyId: Int, replyToId: Int) {
    self.threadId = threadId
    self.replyId = replyId
    self.replyToId = replyToId
    
    // Check if thread is already loaded
    if let thread = Comments.shared.all.filter({ $0.id == threadId }).first {
      controllerInput?.loadThread(root: thread,
                                  includeList: [replyId, replyToId],
                                  threshold: 100)
    } else {
      controllerInput?.loadThread(threadId: threadId,
                                  excludeList: [],
                                  includeList: [replyId, replyToId],
                                  includeSelf: true,
                                  threshold: 100)
    }
  }
}

// MARK: - Private
private extension PollController {
  @MainActor
  func setupUI() {
    navigationController?.interactivePopGestureRecognizer?.delegate = self
//    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark, animated: true)
    navigationController?.setBarTintColor(item.topic.tagColor)
    navigationController?.setBarColor(traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground)
    navigationItem.titleView = titleView
    setBarButtonItems()
  }
  
  func setTasks() {
    // Update stats and state in vote/preview mode
    Timer.publish(every: AppSettings.TimeIntervals.updateStatsComments, on: .current, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in self.isOnScreen && self.mode != .Read }
      .sink { [weak self] seconds in
        guard let self = self else { return }
        
        self.controllerInput?.updateSurveyStats([self.item])
      }
      .store(in: &subscriptions)
    
    // Update stats/state/results in read mode
    Timer
      .publish(every: 10, on: .current, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in self.isOnScreen && self.mode == .Read }
      .sink { [weak self] seconds in
        guard let self = self,
              let survey = self.item.survey,
              survey.isComplete
        else { return }
        
        self.controllerInput?.getCommentsSurveyStateCommentsUpdates(survey)
      }
      .store(in: &subscriptions)
    
    item.$isBanned
      .receive(on: DispatchQueue.main)
      .filter { $0 }
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.controllerOutput?.setBanned { self.navigationController?.popViewController(animated: true) }
          
        }
      .store(in: &subscriptions)
    
    // Watch for favorite status
    item.isFavoritePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        delayAsync(delay: 0.5) {
          self.setBarButtonItems()
        }
      }
      .store(in: &subscriptions)
    
    // Watch for active status
    item.isActivePublisher
      .receive(on: DispatchQueue.main)
      .filter { !$0 }
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        let banner = NewBanner(contentView: TextBannerContent(icon: Icon.init(category: self.item.topic.iconCategory, scaleMultiplicator: 1.5, iconColor: self.item.topic.tagColor),
                                                              text: self.item.isComplete ? "survey_finished_notification" : "survey_finished_vote_notification"),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
      .store(in: &subscriptions)
    
    item.isCompletePublisher
      .receive(on: DispatchQueue.main)
      .filter { $0 }
      .sink { [weak self] _ in
        guard let self = self else { return }

        self.setBarButtonItems()
      }
      .store(in: &subscriptions)
  }
  
  func loadData() {
    spinner = SpiralSpinner(color: item.topic.tagColor)
    
    guard item.survey.isNil else {
      controllerOutput?.item = item.survey
      
      // Increment view counter
      guard mode != .Preview else { return }
      
      controllerInput?.incrementViewCounter()
      return
    }
    
    navigationController?.setNavigationBarHidden(true, animated: false)
    view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    controllerInput?.load(item, incrementViewCounter: true)
    
    view.addSubview(spiral)
    view.addSubview(spinner)
    
    spiral.aspectRatio(1)
    spiral.widthToHeight(of: view, multiplier: 1.5)
    spiral.centerInSuperview()
    spinner.centerXToSuperview()
    spinner.centerYToSuperview()
    spinner.widthToSuperview(multiplier: 0.25)
//    spinner.placeInCenter(of: view,
//                          widthMultiplier: 0.25,
//                          yOffset: -NavigationController.Constants.NavBarHeightSmallState)
    spinner.start(duration: 1)
    spiral.startRotating(duration: 5)
  }
  
  /// Loads survey by id from push notification
  /// - Parameter surveyID: survey id extracted from push notification
  func loadData(surveyID: Int) {
    spinner = SpiralSpinner(color: Colors.main)
    spiral.startRotating(duration: 5)
    navigationController?.setNavigationBarHidden(true, animated: false)
    view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    spinner.placeInCenter(of: view,
                          widthMultiplier: 0.25,
                          yOffset: -NavigationController.Constants.NavBarHeightSmallState)
    controllerInput?.loadSurvey(surveyID)
    spinner.start(duration: 1)
  }
  
  /// Loads survey by id and comments thread by root comment id from push notification
  /// - Parameter surveyId: survey id
  /// - Parameter threadId: root comment id
  /// - Parameter replyId: reply comment id
  func loadData(surveyId: Int, threadId: Int, replyId: Int) {
    spinner = SpiralSpinner(color: Colors.main)
    spiral.startRotating(duration: 5)
    navigationController?.setNavigationBarHidden(true, animated: false)
    view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    spinner.placeInCenter(of: view,
                          widthMultiplier: 0.25,
                          yOffset: -NavigationController.Constants.NavBarHeightSmallState)
    controllerInput?.loadSurveyAndThread(surveyId: surveyId,
                                         threadId: threadId,
                                         includeList: [replyId],
                                         threshold: 100)
    spinner.start(duration: 1)
  }
  
  /// Loads survey by id and comments thread by root comment id from push notification
  /// - Parameter surveyId: survey id
  /// - Parameter threadId: root comment id
  /// - Parameter replyId: reply comment id
  func loadData(threadId: Int, replyId: Int) {
    spinner = SpiralSpinner(color: Colors.main)
    spiral.startRotating(duration: 5)
    navigationController?.setNavigationBarHidden(true, animated: false)
    view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    spinner.placeInCenter(of: view,
                          widthMultiplier: 0.25,
                          yOffset: -NavigationController.Constants.NavBarHeightSmallState)
    controllerInput?.loadThread(threadId: threadId,
                                excludeList: [],
                                includeList: [replyId],
                                includeSelf: true,
                                threshold: 100)
    spinner.start(duration: 1)
  }
  
  
  /// Loads thread child comments, when root is already loaded
  /// - Parameter root: root comment
  func loadThread(root: Comment, replyId: Int) {
    controllerInput?.loadThread(root: root, includeList: [replyId], threshold: 100)
  }
  
  func setBarButtonItems() {
    guard mode != .Preview else { return }
    
    let shareAction: UIAction = .init(title: "share".localized,
                                      image: UIImage(systemName: "square.and.arrow.up",
                                                     withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline,
                                                                                                    scale: .large)),
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .init(),
                                      state: .off,
                                      handler: { [unowned self] _ in
      // Setting description
      let firstActivityItem = self.item.title
      
      // Setting url
      let queryItems = [URLQueryItem(name: "hash", value: self.item.shareHash),
                        URLQueryItem(name: "enc", value: self.item.shareEncryptedString)]
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
    })
    
    var actionButton: UIBarButtonItem!
    
    guard item.isOwn else {
      let watchAction : UIAction = .init(title: item.isFavorite ? "don't_watch".localized : "watch".localized,
                                         image: UIImage(systemName: "binoculars.fill"),
                                         identifier: nil,
                                         discoverabilityTitle: nil,
                                         attributes: .init(),
                                         state: .off,
                                         handler: { [unowned self] _ in
        guard item.isComplete else {
          let banner = NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemOrange),
                                                                text: "finish_poll"),
                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                 isModal: false,
                                 useContentViewHeight: true,
                                 shouldDismissAfter: 2)
          banner.didDisappearPublisher
            .sink { _ in banner.removeFromSuperview() }
            .store(in: &self.subscriptions)
          return
        }
        self.controllerInput?.toggleFavorite(!self.item.isFavorite)
      })
      
      watchAction.accessibilityIdentifier = "watch"

      var actions = [watchAction, shareAction]
      
      if !item.isComplete {
        let claimAction : UIAction = .init(title: "make_claim".localized,
                                           image: UIImage(systemName: "exclamationmark.triangle.fill"),
                                           identifier: nil,
                                           discoverabilityTitle: nil,
                                           attributes: .destructive,
                                           state: .off,
                                           handler: { [unowned self] _ in
          
          let popup = NewPopup(padding: self.padding,
                               contentPadding: .uniform(size: self.padding*2))
          let content = ClaimPopupContent(parent: popup,
                                          object: self.item)
//                                          surveyReference: self.item)
          content.$claim
            .filter { !$0.isNil && !$0!.isEmpty && $0!.keys.first is SurveyReference }
            .map { [$0!.keys.first as! SurveyReference: $0!.values.first!] }
            .sink { [unowned self] in self.controllerInput?.claim($0!) }
            .store(in: &popup.subscriptions)
          popup.setContent(content)
          popup.didDisappearPublisher
            .sink {[unowned self] _ in
              popup.removeFromSuperview()
              delayAsync(delay: 0.5) { [unowned self] in
                self.navigationController?.popViewController(animated: true)
              }
            }
            .store(in: &self.subscriptions)
        })
        actions.append(claimAction)
      }
      let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
      let image =  UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline, scale: .large))
      
      actionButton = UIBarButtonItem(title: "",
                                     image: image,
                                     primaryAction: nil,
                                     menu: menu)
      
      navigationItem.rightBarButtonItem = actionButton
      
      return
    }
    
    actionButton = UIBarButtonItem(title: "share".localized,
                                   image: UIImage(systemName: "square.and.arrow.up",
                                                  withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline,
                                                                                                 scale: .large)),
                                   primaryAction: shareAction,
                                   menu: nil)
    navigationItem.rightBarButtonItem = actionButton
  }
}


// MARK: - Input
extension PollController: PollViewInput {
  func reportComment(_ comment: Comment) {
    let popup = NewPopup(padding: self.padding,
                         contentPadding: .uniform(size: self.padding*2))
    let content = ClaimPopupContent(parent: popup,
                                    object: comment)
    content.$claim
      .filter { !$0.isNil && !$0!.isEmpty && $0!.keys.first is Comment }
      .map { [$0!.keys.first as! Comment: $0!.values.first!] as! [Comment: Claim] }
      .sink { [unowned self] in self.controllerInput?.reportComment(comment: $0.keys.first!, reason: $0.values.first!) }
      .store(in: &popup.subscriptions)
    popup.setContent(content)
    popup.didDisappearPublisher
      .sink { _ in popup.removeFromSuperview() }
      .store(in: &self.subscriptions)
  }
  
  func post() {
    guard let survey = item.survey else { return }
    
    controllerInput?.post(survey)
  }
  
//  func updateCommentsStats(_ comments: [Comment]) {
//    guard isOnScreen else { return }
//
//    controllerInput?.updateCommentsStats(comments)
//  }
  
  func openUserprofile() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    
    navigationController?.pushViewController(UserprofileController(userprofile: item.owner,
                                                                   color: item.topic.tagColor), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
  
  func onCommentClaim(comment: Comment, reason: Claim) {
    
  }
  
  func onAddFavorite(_: Bool) {
    
  }
  
  func vote(_ item: Answer) {
    self.controllerInput?.vote(item)
  }
  
  func openURL(_ url: URL) {
      var vc: SFSafariViewController!
      let config = SFSafariViewController.Configuration()
      config.entersReaderIfAvailable = true
      vc = SFSafariViewController(url: url, configuration: config)
      present(vc, animated: true)
  }
  
  func onExitWithSkip() {
    
  }
  
  func showVoters(for answer: Answer) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    
    navigationController?.pushViewController(UserprofilesController(mode: .Voters, answer: answer), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
  
  func postComment(body: String, replyTo: Comment?, username: String?) {
    controllerInput?.postComment(body: body, replyTo: replyTo, username: username)
  }
  
//  func updateComments(excludeList: [Comment]) {
//    controllerInput?.updateComments(excludeList: excludeList)
//  }
  
  func openCommentThread(root: Comment, reply: Comment? = nil, shouldRequest: Bool, _ completion: Closure?) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    
    navigationController?.pushViewController(CommentsController(root: root, shouldRequest: shouldRequest, reply: reply), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
    
    guard !completion.isNil else { return }
    
    delay(seconds: 0.4) { completion?() }
  }
  
  func deleteComment(_ comment: Comment) {
    controllerInput?.deleteComment(comment)
  }
}

// MARK: - Output
extension PollController: PollModelOutput {
  func commentReportError() {
    Banners.error(container: &subscriptions)
  }
  
  func loadThreadCallback(_ result: Result<Comment?, Error>) {
    switch result {
    case .success(let root):
      guard let comment = root else { return }
      
      openCommentThread(root: comment,
                        reply: replyId.isNil ? nil : Comments.shared.all.filter({ [unowned self] in $0.id == Int(self.replyId!) }).first,
                        shouldRequest: false) {}
    case .failure(_):
      Banners.error(container: &subscriptions)
    }
  }
  
  // Push notification action
  func loadSurveyAndThreadCallback(_ result: Result<Survey, Error>) {
    switch result {
    case .success(let survey):
      item = survey.reference
      setTasks()
      // Push to comments thread
      guard !threadId.isNil,
            let root = Comments.shared.all.filter({ $0.id == threadId! }).first,
            !replyId.isNil,
            let reply = Comments.shared.all.filter({ $0.id == replyId! }).first
      else {
        navigationController?.popViewController(animated: true)
        
        return
      }
//      Surveys.shared.all.filter({ $0.id == root.surveyId })
      openCommentThread(root: root, reply: reply, shouldRequest: false) { [weak self] in
        guard let self = self else { return }
        
        self.controllerOutput?.presentView(item: survey, animated: false)
        self.spinner.stop()
        self.spinner.removeFromSuperview()
      }
    case .failure(let error):
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
      // Go back
      navigationController?.popViewController(animated: true)
    }
  }
  
  @MainActor
  func loadCallback(_ result: Result<Survey, Error>) {
    switch result {
    case .success(let instance):
      if item.isNil {
        item = instance.reference
//        setTasks()
        setupUI()
      }
//      navigationController?.setNavigationBarHidden(false, animated: true)
      delay(seconds: 0.75) { [weak self] in
        guard let self = self else { return }
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
          guard let self = self else { return }
          
          self.spiral.transform = .init(scaleX: 1.25, y: 1.25)
          self.spiral.alpha = 0
          self.spinner.alpha = 0
          self.spinner.transform =  CGAffineTransform(scaleX: 0.25, y: 0.25)
        }) { [weak self] _ in
          guard let self = self,
                let survey = self.item.survey
          else { return }
          
          self.navigationController?.setNavigationBarHidden(false, animated: true)
          self.controllerOutput?.presentView(item: survey, animated: true)
          self.spinner.stop()
          self.spinner.removeFromSuperview()
          self.spiral.stopRotating()
          self.spiral.removeFromSuperview()
        }
      }
    case .failure:
      Banners.error(container: &subscriptions)
      
      return
    }
  }
  
  func favoriteCallback(_: Result<Bool, Error>) {
    
  }
  
  func voteCallback(_ result: Result<Bool, Error>) {
    controllerOutput?.voteCallback(result)
    
    switch result {
    case .success:
      guard let survey = self.item.survey,
            let details = survey.resultDetails
      else { return }
      
      self.mode = .Read
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        guard let self = self else { return }
        
        if details.isPopular {
          self.controllerOutput?.showCongratulations()
          let banner = NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemGreen),
                                                                text: "most_popular_choice".localized + "🚀\n" + "got_points".localized + "\(String(describing: details.points)) " + "\("points".localized) 🥳"),
                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                 isModal: false,
                                 useContentViewHeight: true,
                                 shouldDismissAfter: 2)
          
          banner.didDisappearPublisher
            .sink { _ in banner.removeFromSuperview() }
            .store(in: &self.subscriptions)
        } else {
          let banner = NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: .systemGreen),
                                                                text: "got_points".localized + "\(String(describing: details.points)) " + "points".localized),
                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                 isModal: false,
                                 useContentViewHeight: true,
                                 shouldDismissAfter: 2)
          banner.didDisappearPublisher
            .sink { _ in banner.removeFromSuperview() }
            .store(in: &self.subscriptions)
        }
      }
    case .failure(let error):
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
    }
  }
  
  func commentPostCallback(_ result: Result<Comment, Error>) {
    controllerOutput?.commentPostCallback(result)
  }
  
  func commentDeleteError() {
    
  }
  
  func postCallback(_ result: Result<Bool, Error>) {
    controllerOutput?.postCallback(result)
    
    switch result {
    case .success:
      let banner = NewPopup(padding: padding*5,
                            contentPadding: .uniform(size: padding*3),
                            shouldDismissAfter: 3)
      
      banner.setContent(PollPostedPopupContent(сategory: item.topic.iconCategory,
                                               color: item.topic.tagColor,
                                               padding: padding))
      banner.didDisappearPublisher
        .sink { [weak self] _ in
          guard let self = self,
                let controller = self.navigationController?.viewControllers.filter({ $0 is HotController }).first
          else { return }
          
          banner.removeFromSuperview()
          self.navigationController?.popToViewController(controller, animated: true)
        }
        .store(in: &self.subscriptions)
    case .failure(let error):
      Banners.error(container: &self.subscriptions, text: error.localizedDescription)
    }
  }
}


// MARK: - UINavigationControllerDelegate
extension PollController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if let vc = viewController as? HotController, userHasVoted {
      vc.shouldSkipCurrentCard = true
    }
  }
}

// MARK: - UIGestureRecognizerDelegate
extension PollController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

extension PollController: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
    }
  }
}
