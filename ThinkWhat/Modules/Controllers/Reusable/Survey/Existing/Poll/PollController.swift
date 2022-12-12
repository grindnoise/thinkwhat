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
    
    enum Mode { case ReadOnly, Write }
    
    // MARK: - Public properties
    var controllerOutput: PollControllerOutput?
    var controllerInput: PollControllerInput?
    public private(set) var mode: Mode = .Write
    public private(set) var survey: Survey?
    public private(set) var surveyReference: SurveyReference
//    public private(set) var showNext: Bool = false
    
    
    
    // MARK: - Private properties
    private var userHasVoted = false
    private var observers: [NSKeyValueObservation] = []
    private var tasks: [Task<Void, Never>?] = []
    private var subscriptions = Set<AnyCancellable>()
    //UI
    private lazy var avatar: Avatar = { Avatar() }()
    private lazy var topicIcon: Icon = {
        let instance = Icon(category: surveyReference.topic.iconCategory)
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
        instance.text = surveyReference.topic.title.uppercased()
        instance.textColor = .white
        instance.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        return instance
    }()
    private lazy var topicView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            topicIcon,
            topicTitle
        ])
        instance.backgroundColor = surveyReference.topic.tagColor
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
    
    
    
    // MARK: - Overriden properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    
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
        self.surveyReference = surveyReference
        
        super.init(nibName: nil, bundle: nil)
        
        self.survey = surveyReference.survey
//        self.showNext = showNext
        self.mode = (surveyReference.isComplete || surveyReference.isOwn) ? .ReadOnly : .Write
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
        
        //        setupUI()
        setTasks()
        setSubscriptions()
        setObservers()
        setUpdaters()
        
        performChecks()
//        navigationController?.delegate = self
//        navigationController?.navigationBar.alpha = 1
        
        setupUI()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
//        navigationController?.delegate = appDelegate.transitionCoordinator
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        view.setNeedsLayout()
//        view.layoutIfNeeded()
        
//        navigationController?.navigationBar.alpha = 1
//        delayAsync(delay: 1) {
//            self.toggleTopicView(on: true)
//        }
        avatar.userprofile = surveyReference.owner
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        toggleTopicView(on: false)
//    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard parent.isNil else { return }
        
//        toggleTopicView(on: false)
        clearNavigationBar(clear: true)
//        tabBarController?.setTabBarVisible(visible: true, animated: true)
        
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        
    }
}

// MARK: - Private
private extension PollController {
    @MainActor
    func setupUI() {
//        edgesForExtendedLayout = [.bottom]
        if !survey.isNil { controllerOutput?.onLoadCallback() }
        
        
//        clearNavigationBar(clear: false)
        setNavigationBarTintColor(surveyReference.topic.tagColor)
//        navigationItem.title = ""
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatar)
//
//        navigationBar.addSubview(topicView)
//        topicView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            topicView.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 100, font: topicTitle.font)),
//            topicView.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
//        ])
//
//        navigationBar.setNeedsLayout()
//        navigationBar.layoutIfNeeded()
//
//        let centerX = topicView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor)
//        centerX.identifier = "centerX"
//        centerX.isActive = true
        navigationItem.titleView = topicView
        
    }
    
    func setObservers() {
        
    }
    
    func setUpdaters() {
        guard surveyReference.isComplete else { return }
        
        //Set timer to request stats updates
        //Update survey stats every n seconds
        Timer
            .publish(every: 5, on: .current, in: .common)
            .autoconnect()
            .sink { [weak self] seconds in
                guard let self = self else { return }
                
                self.controllerInput?.updateResultsStats(self.surveyReference)
            }
            .store(in: &subscriptions)
        
        //        let events = EventEmitter().emit(every: 5)
        //        tasks.append(Task { [weak self] in
        //            for await _ in events {
        //                guard let self = self else { return }
        //
        //                self.controllerInput?.updateResultsStats(self._surveyReference)
        //            }
        //        })
    }
    
    func setSubscriptions() {
        
    }
    
    func setTasks() {
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
    
    func performChecks() {
        guard surveyReference.survey.isNil else {
            controllerInput?.addView()
            return
        }
        
        controllerInput?.loadPoll(surveyReference, incrementViewCounter: true)
    }
    
    @objc
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let sender = recognizer.view else { return }
        if sender.isKind(of: CircleButton.self) {
            let popup = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: 0.5)
            popup.present(content: UIView(), dismissAfter: 1)
        }
    }
    
    func setBarButtonItem() {
//        var actionButton: UIBarButtonItem!
//        let image =  UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline, scale: .large))
//        let shareAction : UIAction = .init(title: "share".localized, image: image, identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
//            guard let self = self, !self._survey.isNil else { return }
//            // Setting description
//            let firstActivityItem = self._surveyReference.title
//
//            // Setting url
//            let queryItems = [URLQueryItem(name: "hash", value: self._survey.shareHash), URLQueryItem(name: "enc", value: self._survey.shareEncryptedString)]
//            var urlComps = URLComponents(string: API_URLS.Surveys.share!.absoluteString)!
//            urlComps.queryItems = queryItems
//
//            let secondActivityItem: URL = urlComps.url!
//
//            // If you want to use an image
//            let image : UIImage = UIImage(named: "anon")!
//            let activityViewController : UIActivityViewController = UIActivityViewController(
//                activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
//
//            // This lines is for the popover you need to show in iPad
//            activityViewController.popoverPresentationController?.sourceView = self.view
//
//            // This line remove the arrow of the popover to show in iPad
//            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
//            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
//
//            // Pre-configuring activity items
//            activityViewController.activityItemsConfiguration = [
//                UIActivity.ActivityType.message
//            ] as? UIActivityItemsConfigurationReading
//
//            // Anything you want to exclude
//            activityViewController.excludedActivityTypes = [
//                UIActivity.ActivityType.postToWeibo,
//                UIActivity.ActivityType.print,
//                UIActivity.ActivityType.assignToContact,
//                UIActivity.ActivityType.saveToCameraRoll,
//                UIActivity.ActivityType.addToReadingList,
//                UIActivity.ActivityType.postToFlickr,
//                UIActivity.ActivityType.postToVimeo,
//                UIActivity.ActivityType.postToTencentWeibo,
//                UIActivity.ActivityType.postToFacebook
//            ]
//
//            activityViewController.isModalInPresentation = false
//            self.present(activityViewController,
//                         animated: true,
//                         completion: nil)
//        })
//
//        if _survey.isOwn {
//            let image =  UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline, scale: .large))
//            actionButton = UIBarButtonItem(title: "share".localized, image: image, primaryAction: shareAction, menu: nil)
//            navigationItem.rightBarButtonItem = actionButton
//        } else {
//            let watchAction : UIAction = .init(title: _survey.isFavorite ? "don't_watch".localized : "watch".localized, image: UIImage(systemName: "binoculars.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
//                guard let self = self else { return }
//                guard let instance = self._survey,
//                      instance.isComplete else {
//                    showBanner(bannerDelegate: self, text: "finish_poll".localized, content: UIImageView(image: UIImage(systemName: "exclamationmark.icloud.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemOrange.withAlphaComponent(1))
//                    return }
//                self.controllerInput?.addFavorite(!instance.isFavorite)
//            })
//            watchAction.accessibilityIdentifier = "watch"
//
//            let claimAction : UIAction = .init(title: "make_claim".localized, image: UIImage(systemName: "exclamationmark.triangle.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { (action) in
//                //                    self.addButtonActionPressed(action: .advanced)
//            })
//
//            let actions = [watchAction, shareAction, claimAction]
//            let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
//            let image =  UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline, scale: .large))
//
//            actionButton = UIBarButtonItem(title: "", image: image, primaryAction: nil, menu: menu)
//        }
//        navigationItem.rightBarButtonItem = actionButton
    }
    
//    func toggleTopicView(on: Bool) {
//        guard let navigationBar = navigationController?.navigationBar,
//              let constraint = topicView.getConstraint(identifier: "centerX")
//        else { return }
//
//        topicView.backgroundColor = surveyReference.topic.tagColor
//        topicTitle.text = surveyReference.topic.title.uppercased()
//        topicIcon.category = surveyReference.topic.iconCategory
////        navigationBar.setNeedsLayout()
//        constraint.constant = -(navigationBar.bounds.width - topicView.bounds.width)/2
////        navigationBar.layoutIfNeeded()
////
////        navigationBar.setNeedsLayout()
//        UIView.animate(
//            withDuration: 0.3,
//            delay: 0,
//            usingSpringWithDamping: 0.8,
//            initialSpringVelocity: 0.3,
//            options: [.curveEaseInOut],
//            animations: { [weak self] in
//                guard let self = self else { return }
//
//                self.topicView.alpha = on ? 1 : 0
//                constraint.constant = on ? 0 : -(navigationBar.bounds.width - self.topicView.bounds.width)/2//-(10 + self.topicView.bounds.width)
//                navigationBar.layoutIfNeeded()
//            }) { _ in
//                guard !on else { return }
//
//                self.topicView.removeFromSuperview()
//            }
//
//        UIView.animate(withDuration: on ? 0.1 : 0.3,
//                       delay: 0.1) { [unowned self] in
//            self.topicView.alpha = on ? 1 : 0
//        }
//    }
}


// MARK: - View Input
extension PollController: PollViewInput {
    func deleteComment(_ comment: Comment) {
        controllerInput?.deleteComment(comment)
    }
    
    func onCommentClaim(comment: Comment, reason: Claim) {
        controllerInput?.commentClaim(comment: comment, reason: reason)
    }
    
    func openCommentThread(_ comment: Comment) {
        navigationController?.pushViewController(CommentsController(comment), animated: true)
    }
    
    func requestComments(_ comments: [Comment]) {
        controllerInput?.requestComments(comments)
    }
    
    func postComment(body: String, replyTo: Comment? = nil, username: String? = nil) {
        controllerInput?.postComment(body: body, replyTo: replyTo, username: username)
    }
    
    func onVotersTapped(answer: Answer, color: UIColor) {
        navigationController?.pushViewController(UserprofilesController(mode: .Voters, answer: answer), animated: true)
    }
    
    func onURLTapped(_ url: URL) {
        var vc: SFSafariViewController!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    func onVote(_ choice: Answer) {
        controllerInput?.vote(choice)
//        delayAsync(delay: 0.5) {
//            self._mode = .ReadOnly
//            self.controllerOutput?.onVoteCallback(.success(true))
//        }
    }
    
    func onClaim(_ claim: Claim) {
        controllerInput?.claim(claim)
    }
    
    func onAddFavorite(_ mark: Bool) {
        controllerInput?.addFavorite(mark)
    }
}

// MARK: - Model Output
extension PollController: PollModelOutput {
    func commentDeleteError() {
        controllerOutput?.commentDeleteError()
    }
    
    func commentPostCallback(_ result: Result<Comment, Error>) {
        controllerOutput?.commentPostCallback(result)
    }
    
    func onExitWithSkip() {
        Task {
            try await Task.sleep(nanoseconds: UInt64(0.25 * 1_000_000_000))
            await MainActor.run {
                if let vc = previousController as? HotController {
                    vc.shouldSkipCurrentCard = true
                }
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func onVoteCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            mode = .ReadOnly
            userHasVoted = true
            //Show edu info
#if DEBUG
            delayAsync(delay: 1) {
                fatalError()
//                let popup = Popup(callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: 0.4)
//                popup.present(content: VoteEducation(topic: .Bankruptcy, color: .systemRed, callbackDelegate: popup))
            }
#else
            delayAsync(delay: 1) {
                guard UserDefaults.App.hasSeenPollVoteIntroduction.isNil else { return }
                
                let popup = Popup(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: 0.4)
                popup.present(content: VoteEducation(topic: .Bankruptcy, color: .systemRed, callbackDelegate: popup))
                
                UserDefaults.App.hasSeenPollVoteIntroduction = true
            }
#endif
        default:
#if DEBUG
            print("")
#endif
        }
        controllerOutput?.onVoteCallback(result)
    }
    
    func onAddFavoriteCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success(let mark):
            guard mark else { return }
            controllerOutput?.onAddFavoriteCallback()
//            setBarButtonItem()
        case .failure:
#if DEBUG
            print("")
#endif
        }
    }
    
    func onLoadCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            survey = surveyReference.survey
            controllerOutput?.onLoadCallback()
        case .failure:
            showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: ImageSigns.exclamationMark)
        }
    }
}

// MARK: - BannerObservable
extension PollController: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let banner = sender as? Popup {
            banner.removeFromSuperview()
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

// MARK: - CallbackObservable
extension PollController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
//        if sender is ChoiceCell, mode == .ReadOnly {
//            print("")
//        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PollController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
