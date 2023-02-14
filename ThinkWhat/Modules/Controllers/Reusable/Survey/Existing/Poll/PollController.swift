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

class PollController: UIViewController {
  
  enum Mode { case Read, Vote }
  
  // MARK: - Public properties
  var controllerOutput: PollControllerOutput?
  var controllerInput: PollControllerInput?
  public private(set) var item: SurveyReference {
    didSet {
      //            func update() {
      //                //Update survey stats every n seconds
      //                Timer
      //                    .publish(every: 5, on: .current, in: .common)
      //                    .autoconnect()
      //                    .sink { [weak self] seconds in
      //                        guard let self = self else { return }
      //
      //                        self.controllerInput?.updateResultsStats(self.surveyReference)
      //                    }
      //                    .store(in: &subscriptions)
      //            }
      //
      //            guard surveyReference.isComplete else {
      //                surveyReference.isCompletePublisher
      //                    .filter { $0 }
      //                    .sink { _ in update() }
      //                    .store(in: &subscriptions)
      //
      //                return
      //            }
      //
      //            update()
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var tasks: [Task<Void, Never>?] = []
  private var subscriptions = Set<AnyCancellable>()
  //Logic
  private var userHasVoted = false
  private var isOnScreen = false
  private var surveyStateUpdater: AnyCancellable?
  //UI
  private lazy var avatar: Avatar = { Avatar() }()
  private lazy var topicIcon: Icon = {
    let instance = Icon(category: item.topic.iconCategory)
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
    instance.text = item.topic.title.uppercased()
    instance.textColor = .white
    instance.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    return instance
  }()
  private lazy var topicView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      topicIcon,
      topicTitle
    ])
    instance.backgroundColor = item.topic.tagColor
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
  private lazy var loadingIndicator: LoadingIndicator = {
    let instance = LoadingIndicator(color: item.topic.tagColor)
    instance.didDisappearPublisher
      .sink { [weak self] _ in
        guard let self = self,
              let survey = self.item.survey
        else { return }
        
        self.controllerOutput?.presentView(survey)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  
  
  
  
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
  init(surveyReference: SurveyReference, showNext: Bool = false) {
    self.item = surveyReference
    
    super.init(nibName: nil, bundle: nil)
    
    self.item.isBannedPublisher
      .receive(on: DispatchQueue.main)
      .filter { $0 }
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                              text: "survey_banned_notification",
                                                              textColor: .systemRed,
                                                              tintColor: .systemRed,
                                                              fontName: Fonts.Semibold,
                                                              textStyle: .headline),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: true,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { [weak self] _ in
            guard let self = self else { return }
            
            self.navigationController?.popViewController(animated: true)
            banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
      .store(in: &subscriptions)
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
    
    setTasks()
//    setupUI()
    guard item.isBanned else {
      loadData()
      return
    }
    
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                          text: "survey_banned_notification",
                                                          textColor: .systemRed,
                                                          tintColor: .systemRed,
                                                          fontName: Fonts.Semibold,
                                                          textStyle: .headline),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: true,
                           useContentViewHeight: true,
                           shouldDismissAfter: 2)
    banner.didDisappearPublisher
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.navigationController?.popViewController(animated: true)
        banner.removeFromSuperview() }
      .store(in: &self.subscriptions)
    //        navigationController?.delegate = appDelegate.transitionCoordinator
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    isOnScreen = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
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
    
    
  }
}

// MARK: - Private
private extension PollController {
  @MainActor
  func setupUI() {
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    setNavigationBarTintColor(item.topic.tagColor)
    navigationItem.titleView = topicView
    setBarButtonItems()
    
//    guard let navigationBar = navigationController?.navigationBar else { return }
//
//    let appearance = UINavigationBarAppearance()
//    appearance.configureWithOpaqueBackground()
//    appearance.largeTitleTextAttributes = [
//      .foregroundColor: tintColor,
//      .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .largeTitle) as Any
//    ]
//    appearance.titleTextAttributes = [
//      .foregroundColor: tintColor,
//      .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .title3) as Any
//    ]
//    appearance.shadowColor = nil
//
//    navigationBar.standardAppearance = appearance
//    navigationBar.scrollEdgeAppearance = appearance
//    navigationBar.prefersLargeTitles = false
//
//    if #available(iOS 15.0, *) {
//      navigationBar.compactScrollEdgeAppearance = appearance
//    }
    guard let navigationBar = self.navigationController?.navigationBar else { return }

    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = .systemBackground
    appearance.shadowColor = nil
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.prefersLargeTitles = false

    if #available(iOS 15.0, *) { navigationBar.compactScrollEdgeAppearance = appearance }
  }
  
  func setTasks() {
//    func updateResultsStats() {
//      //Update survey stats every n seconds
//      Timer
//        .publish(every: 5, on: .current, in: .common)
//        .autoconnect()
//        .sink { [weak self] seconds in
//          guard let self = self,
//                let survey = self.item.survey
//          else { return }
//
//          guard self.isOnScreen else { return }
//
//          self.controllerInput?.updateResultsStats(survey)
//        }
//        .store(in: &subscriptions)
//    }
    
    item.isFavoritePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        delayAsync(delay: 0.5) {
          self.setBarButtonItems()
        }
      }
      .store(in: &subscriptions)
    
    item.isActivePublisher
      .receive(on: DispatchQueue.main)
      .filter { !$0 }
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "flag.checkered.2.crossed")!,
                                                              text: self.item.isComplete ? "survey_finished_notification" : "survey_finished_vote_notification",
                                                              tintColor: self.traitCollection.userInterfaceStyle == .dark ? .white : .black,
                                                              fontName: Fonts.Bold,
                                                              textStyle: .headline),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
      .store(in: &subscriptions)
    
    guard item.isComplete else {
      updateSurveyState()
      
      item.isCompletePublisher
        .receive(on: DispatchQueue.main)
        .filter { $0 }
//        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self,
                self.isOnScreen
          else { return }
          
          self.updateResultsStats()
          
          guard !self.surveyStateUpdater.isNil else { return }
          
          self.surveyStateUpdater?.cancel()
        }
        .store(in: &subscriptions)
      
      return
    }
    
    updateResultsStats()
    
    
    //        tasks.append(Task { [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SwitchFavorite) {
    //                guard let self = self,
    //                      let instance = notification.object as? SurveyReference,
    //                      self._surveyReference == instance
    //                else { return }
    //
    //                await MainActor.run {
    //                    self.setBarButtonItem()
    //
    //                    switch instance.isFavorite {
    //                    case true:
    //                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
    //                              marksStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isFavorite"}).isEmpty
    //                        else { return }
    //
    //                        let container = UIView()
    //                        container.backgroundColor = .clear
    //                        container.accessibilityIdentifier = "isFavorite"
    //                        container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
    //
    //                        let instance = UIImageView(image: UIImage(systemName: "binoculars.fill"))
    ////                        instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
    //                        instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? self.surveyReference.topic.tagColor : .darkGray
    //                        instance.contentMode = .scaleAspectFit
    //                        instance.addEquallyTo(to: container)
    //                        marksStackView.insertArrangedSubview(container,
    //                                                             at: marksStackView.arrangedSubviews.isEmpty ? 0 : marksStackView.arrangedSubviews.count > 1 ? marksStackView.arrangedSubviews.count-1 : marksStackView.arrangedSubviews.count)
    //                    case false:
    //                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
    //                              let mark = marksStackView.getSubview(type: UIView.self, identifier: "isFavorite") else { return }
    //                        marksStackView.removeArrangedSubview(mark)
    //                        mark.removeFromSuperview()
    //                    }
    //                }
    //            }
    //        })
    
    //        tasks.append(Task { [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Completed) {
    //                await MainActor.run {
    //                    guard let self = self,
    //                          let instance = notification.object as? SurveyReference,
    //                          self._surveyReference == instance
    //                    else { return }
    //
    //                    switch instance.isComplete {
    //                    case true:
    //                        let _anim = Animations.get(property: .Opacity, fromValue: 0, toValue: 1, duration: 0.5, delegate: nil)
    //                        self.titleView.oval.add(_anim, forKey: nil)
    //                        self.titleView.ovalBg.add(_anim, forKey: nil)
    //                        self.titleView.oval.opacity = 1
    //                        self.titleView.ovalBg.opacity = 1
    //
    //                        if let indicator = self.stackView.getSubview(type: CircleButton.self, identifier: "progress") {
    //                            let anim = Animations.get(property: .Opacity, fromValue: 0, toValue: 1, duration: 0.5, delegate: nil)
    //                            indicator.oval.add(anim, forKey: nil)
    //                            indicator.ovalBg.add(anim, forKey: nil)
    //                            indicator.oval.opacity = 1
    //                            indicator.ovalBg.opacity = 1
    //                        }
    //
    //                        self.setUpdaters()
    //
    //                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
    //                              marksStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isComplete"}).isEmpty
    //                        else { return }
    //
    //                        let container = UIView()
    //                        container.backgroundColor = .clear
    //                        container.accessibilityIdentifier = "isComplete"
    //                        container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
    //
    //                        let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
    //                        instance.contentMode = .center
    ////                        instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self._surveyReference.topic.tagColor
    //                        instance.tintColor = self._surveyReference.topic.tagColor
    //                        instance.contentMode = .scaleAspectFit
    //                        instance.addEquallyTo(to: container)
    //
    //                        marksStackView.insertArrangedSubview(container, at: 0)
    //
    //                        self.observers.append(instance.observe(\UIImageView.bounds, options: .new) { view, change in
    //                            guard let newValue = change.newValue else { return }
    //                            view.cornerRadius = newValue.size.height/2
    //                            let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height * 1.9, weight: .semibold, scale: .medium)
    //                            let image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: largeConfig)
    //                            view.image = image
    //                        })
    //                    case false:
    //                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
    //                              let mark = marksStackView.getSubview(type: UIView.self, identifier: "isComplete") else { return }
    //                        marksStackView.removeArrangedSubview(mark)
    //                        mark.removeFromSuperview()
    //                    }
    //                }
    //            }
    //        })
    
    //        tasks.append(Task { [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SwitchHot) {
    //                await MainActor.run {
    //                    guard let self = self,
    //                          let instance = notification.object as? SurveyReference,
    //                          self._surveyReference == instance
    //                    else { return }
    //
    //                    switch instance.isHot {
    //                    case true:
    //                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
    //                              marksStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isHot"}).isEmpty
    //                        else { return }
    //
    //                        let container = UIView()
    //                        container.backgroundColor = .clear
    //                        container.accessibilityIdentifier = "isHot"
    //                        container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
    //
    //                        let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
    //                        instance.contentMode = .center
    //                        instance.tintColor = .systemRed
    //                        instance.contentMode = .scaleAspectFit
    //                        instance.addEquallyTo(to: container)
    //
    //                        marksStackView.insertArrangedSubview(container, at: marksStackView.arrangedSubviews.count == 0 ? 0 : marksStackView.arrangedSubviews.count)
    //
    //                        self.observers.append(instance.observe(\UIImageView.bounds, options: .new) { view, change in
    //                            guard let newValue = change.newValue else { return }
    //                            view.cornerRadius = newValue.size.height/2
    //                            let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height * 1.9, weight: .semibold, scale: .medium)
    //                            let image = UIImage(systemName: "flame.fill", withConfiguration: largeConfig)
    //                            view.image = image
    //                        })
    //                    case false:
    //                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
    //                              let mark = marksStackView.getSubview(type: UIView.self, identifier: "isHot") else { return }
    //                        marksStackView.removeArrangedSubview(mark)
    //                        mark.removeFromSuperview()
    //                    }
    //                }
    //            }
    //        })
    
    //        //Observe progress
    //        tasks.append(Task { @MainActor [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Progress) {
    //                guard let self = self,
    //                      let instance = notification.object as? SurveyReference,
    //                      self._surveyReference == instance
    //                else { return }
    //
    //                if let indicator = self.stackView.getSubview(type: CircleButton.self, identifier: "progress") {
    //                    indicator.oval.strokeStart = CGFloat(1) - CGFloat(instance.progress)/100
    //                }
    //                self.titleView.oval.strokeStart = CGFloat(1) - CGFloat(instance.progress)/100
    //            }
    //        })
  }
  
  func updateResultsStats() {
    //Update survey stats every n seconds
    Timer
      .publish(every: 5, on: .current, in: .common)
      .autoconnect()
      .sink { [weak self] seconds in
        guard let self = self,
              let survey = self.item.survey,
              survey.isComplete
        else { return }
        
        guard self.isOnScreen else { return }
        
        self.controllerInput?.updateResultsStats(survey)
      }
      .store(in: &subscriptions)
  }
  
  //Check completion & ban state
  func updateSurveyState() {
    surveyStateUpdater = Timer
      .publish(every: 5, on: .current, in: .common)
      .autoconnect()
      .sink { [weak self] seconds in
        guard let self = self else { return }
        
        guard self.isOnScreen else { return }
        
        self.controllerInput?.updateSurveyState(self.item)
      }
  }
  
  func loadData() {
    
    guard item.survey.isNil else {
      controllerOutput?.item = item.survey
      controllerInput?.addView()
      return
    }
    
    navigationController?.setNavigationBarHidden(true, animated: false)
    loadingIndicator.placeInCenter(of: view, widthMultiplier: 0.25, yOffset: -NavigationController.Constants.NavBarHeightSmallState)
    controllerInput?.load(item, incrementViewCounter: true)
    loadingIndicator.start()
  }
  
  func setBarButtonItems() {
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
          let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                                text: "finish_poll",
                                                                tintColor: .systemOrange,
                                                                fontName: Fonts.Semibold,
                                                                textStyle: .title3,
                                                                textAlignment: .natural),
                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                 isModal: false,
                                 useContentViewHeight: true,
                                 shouldDismissAfter: 1)
          banner.didDisappearPublisher
            .sink { _ in banner.removeFromSuperview() }
            .store(in: &self.subscriptions)
//
//          let banner = Banner(fadeBackground: false)
//          banner.present(content: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
//                                                    text: "finish_poll",
//                                                    tintColor: .systemOrange),
//                         dismissAfter: 0.75)
//          banner.didDisappearPublisher
//            .sink { _ in banner.removeFromSuperview() }
//            .store(in: &self.subscriptions)
          return
        }
        self.controllerInput?.toggleFavorite(!self.item.isFavorite)
      })
      
      watchAction.accessibilityIdentifier = "watch"
      
      let claimAction : UIAction = .init(title: "make_claim".localized,
                                         image: UIImage(systemName: "exclamationmark.triangle.fill"),
                                         identifier: nil,
                                         discoverabilityTitle: nil,
                                         attributes: .destructive,
                                         state: .off,
                                         handler: { [unowned self] _ in
        let banner = Popup()
        let claimContent = ClaimPopupContent(parent: banner, surveyReference: item)
        
        claimContent.claimPublisher
          .sink { [weak self] in
            guard let self = self else { return }
            
            self.controllerInput?.claim($0)
          }
          .store(in: &self.subscriptions)
        
        banner.present(content: claimContent)
        banner.didDisappearPublisher
          .sink { [weak self] _ in
            banner.removeFromSuperview()
            
            
            guard let self = self,
                  self.item.isClaimed
            else { return }
            
            self.navigationController?.popViewController(animated: true)
          }
          .store(in: &self.subscriptions)
      })
      
      let actions = [watchAction, shareAction, claimAction]
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
  func updateCommentsStats(_ comments: [Comment]) {
    guard isOnScreen else { return }
    
    controllerInput?.updateCommentsStats(comments)
  }
  
  func openUserprofile() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    
    navigationController?.pushViewController(UserprofileController(userprofile: item.owner, color: item.topic.tagColor), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
  
  func onClaim(_: Claim) {
    
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
  
  func requestComments(_: [Comment]) {
    
  }
  
  func openCommentThread(_ comment: Comment) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    
    navigationController?.pushViewController(CommentsController(comment), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
  
  func deleteComment(_ comment: Comment) {
    controllerInput?.deleteComment(comment)
  }
}

// MARK: - Output
extension PollController: PollModelOutput {
  func onLoadCallback(_ result: Result<Bool, Error>) {
    switch result {
    case .success:
      navigationController?.setNavigationBarHidden(false, animated: true)
      loadingIndicator.stop()
    case .failure:
      let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                            text: AppError.server.localizedDescription,
                                                            tintColor: .systemRed,
                                                            fontName: Fonts.Semibold,
                                                            textStyle: .subheadline,
                                                            textAlignment: .natural),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 1)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
      
      return
    }
  }
  
  func onAddFavoriteCallback(_: Result<Bool, Error>) {
    
  }
  
  func onVoteCallback(_ result: Result<Bool, Error>) {
    switch result {
    case .success:
      guard let survey = self.item.survey,
            let details = survey.resultDetails
      else { return }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        guard let self = self else { return }
        
        if details.isPopular {
          let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "dollarsign")!,
                                                                text: "most_popular_choice".localized + "🚀\n" + "got_points".localized + "\(String(describing: details.points)) " + "\("points".localized) 🥳",
                                                                tintColor: .systemGreen,
                                                                fontName: Fonts.Semibold,
                                                                textStyle: .headline,
                                                                textAlignment: .center),
                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                 isModal: false,
                                 useContentViewHeight: true,
                                 shouldDismissAfter: 2)
          banner.didDisappearPublisher
            .sink { _ in banner.removeFromSuperview() }
            .store(in: &self.subscriptions)
        } else {
          let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "dollarsign")!,
                                                                text: "got_points".localized + "\(String(describing: details.points)) " + "points".localized,
                                                                tintColor: .systemGreen,
                                                                fontName: Fonts.Semibold,
                                                                textStyle: .headline,
                                                                textAlignment: .center),
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
    switch result {
    case .failure(let error):
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
      let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                            text: AppError.server.localizedDescription,
                                                            tintColor: .systemRed,
                                                            fontName: Fonts.Semibold,
                                                            textStyle: .title3,
                                                            textAlignment: .natural),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 1)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
    default:
#if DEBUG
      print("")
#endif
    }
  }
  
  func commentDeleteError() {
    
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
    if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
      if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
        completionBlock()
      }
    }
  }
}
