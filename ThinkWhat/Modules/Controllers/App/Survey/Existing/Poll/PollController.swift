//
//  PollController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SafariServices

class PollController: UIViewController {
    
    enum Mode {
        case ReadOnly, Write
    }
    
    // MARK: - Public properties
    var controllerOutput: PollControllerOutput?
    var controllerInput: PollControllerInput?
    var mode: Mode {
        return _mode
    }
    
    // MARK: - Private properties
    private var _mode: Mode = .Write
    private var userHasVoted = false
    private var _survey: Survey!
    private var _surveyReference: SurveyReference!
    private var _showNext: Bool = false
    private var isLoading = false
    private let watchButton: UIImageView = {
        let v = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
        v.contentMode = .center
        return v
    }()
    private var isAddedToFavorite = false {
        didSet {
            if isAddedToFavorite {
                watchButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
            } else {
                watchButton.tintColor = .systemGray
            }
        }
    }
    private lazy var stackView: UIStackView = {
        let v = UIStackView()
        v.spacing = 8
        return v
    }()
    private lazy var avatar: Avatar = {
        return Avatar(gender: surveyReference.owner.gender, image: surveyReference.owner.image)
    }()
    private lazy var progressIndicator: CircleButton = {
        let customTitle = CircleButton(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)), useAutoLayout: true)
        customTitle.color = .clear
        customTitle.icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        customTitle.icon.backgroundColor = .clear
        customTitle.layer.masksToBounds = false
        customTitle.icon.layer.masksToBounds = false
        customTitle.oval.masksToBounds = false
        customTitle.icon.scaleMultiplicator = 1.7
        customTitle.category = Icon.Category(rawValue: surveyReference.topic.id) ?? .Null
        customTitle.state = .Off
        customTitle.contentView.backgroundColor = .clear
        customTitle.oval.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : surveyReference.topic.tagColor.cgColor
        customTitle.oval.lineCap = .round
        customTitle.oval.strokeStart = survey.isNil ? 0 : CGFloat(survey!.progress)
        return customTitle
    }()
    private var observers: [NSKeyValueObservation] = []
    private var notifications: [Task<Void, Never>?] = []
    
    // MARK: - Destructor
    deinit {
        notifications.forEach { $0?.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    init(surveyReference: SurveyReference, showNext __showNext: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self._surveyReference = surveyReference
        self._survey = surveyReference.survey
        self._showNext = __showNext
        self._mode = (surveyReference.isComplete || surveyReference.isOwn) ? .ReadOnly : .Write
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Private methods
    private func setupUI() {
        if !_survey.isNil { controllerOutput?.onLoadCallback(.success(true)) }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
                    self.navigationController?.navigationBar.standardAppearance = appearance
                    self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        guard let navigationBar = self.navigationController?.navigationBar else { return }

        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        let watchAction : UIAction = .init(title: "watch".localized, image: UIImage(systemName: "binoculars"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { (action) in
            //                    self.addButtonActionPressed(action: .simple)
        })
        
        let shareAction : UIAction = .init(title: "share".localized, image: UIImage(systemName: "square.and.arrow.up"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
            guard let self = self else { return }
            // Setting description
            let firstActivityItem = self._surveyReference.title

                // Setting url
                let secondActivityItem: URL = URL(string: "http://your-url.com/")!
                
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
                
                activityViewController.isModalInPresentation = true
                self.present(activityViewController, animated: true, completion: nil)
        })
        let claimAction : UIAction = .init(title: "make_claim".localized, image: UIImage(systemName: "exclamationmark.triangle.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { (action) in
            //                    self.addButtonActionPressed(action: .advanced)
        })
        
        let actions = [watchAction, shareAction, claimAction]
        
        let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
        
        let actionButton = UIBarButtonItem(title: "", image: UIImage(systemName: "ellipsis"), primaryAction: nil, menu: menu)
        navigationItem.rightBarButtonItem = actionButton
        navigationBar.addSubview(avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false

//        NSLayoutConstraint.activate([
//            avatar.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
//            avatar.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
//            avatar.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.NavBarHeightLargeState - UINavigationController.Constants.ImageBottomMarginForLargeState*2),
//            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1.0/1.0)
//            ])
        NSLayoutConstraint.activate([
            avatar.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            avatar.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            avatar.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor)
            ])
        
        stackView.axis = .horizontal
        navigationBar.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

//        NSLayoutConstraint.activate([
//            stackView.leftAnchor.constraint(equalTo: navigationBar.leftAnchor, constant: UINavigationController.Constants.ImageBottomMarginForLargeState),
//            stackView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
//            stackView.heightAnchor.constraint(equalToConstant: 52 - UINavigationController.Constants.ImageBottomMarginForLargeState),
//            stackView.trailingAnchor.constraint(equalTo: avatar.leadingAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForSmallState)
//        ])
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: navigationBar.leftAnchor, constant: UINavigationController.Constants.ImageRightMargin),
            stackView.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            stackView.heightAnchor.constraint(equalTo: avatar.heightAnchor),
            stackView.trailingAnchor.constraint(equalTo: avatar.leadingAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForSmallState)
        ])
        
        let indicator = CircleButton(frame: .zero)
        indicator.color = surveyReference.topic.tagColor
        indicator.oval.strokeStart = CGFloat(1) - CGFloat(surveyReference.progress)/100
        indicator.oval.lineCap = .round
        indicator.ovalBg.strokeStart = 0
        indicator.icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        indicator.icon.backgroundColor = .clear
        indicator.backgroundColor = .clear
        indicator.icon.scaleMultiplicator = 1.5
        indicator.category = Icon.Category(rawValue: surveyReference.topic.id) ?? .Null
        indicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        stackView.addArrangedSubview(indicator)
        
        let label = UILabel()
        label.textColor = traitCollection.userInterfaceStyle == .dark ? .label : surveyReference.topic.tagColor
        label.text = surveyReference.topic.title
        stackView.addArrangedSubview(label)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.widthAnchor.constraint(equalTo: indicator.heightAnchor, multiplier: 1.0/1.0).isActive = true
    }
    
    private func setObservers() {
        observers.append(stackView.observe(\UIStackView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard !self.isNil,
                  let newValue = change.newValue,
                  let label = view.arrangedSubviews.filter({ $0.isKind(of: UILabel.self) }).first as? UILabel else { return }
            label.font = UIFont(name: Fonts.Bold, size: newValue.width * 0.1)
        })
        guard let navBar = navigationController?.navigationBar else { return }
        observers.append(navBar.observe(\UINavigationBar.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue else { return }
//                  let titleView = self.navigationItem.titleView else { return }
            
            if self.navigationItem.titleView.isNil {
                let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
                icon.backgroundColor = .clear
                icon.iconColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self._surveyReference.topic.tagColor
                icon.isRounded = false
                icon.scaleMultiplicator = 1.4
                icon.category = Icon.Category(rawValue: self._surveyReference.topic.id) ?? .Null
                self.navigationItem.titleView = icon
                self.navigationItem.titleView?.alpha = 0

                self.navigationItem.titleView?.clipsToBounds = false
            }

            
            var largeAlpha: CGFloat = CGFloat(1) - max(CGFloat(UINavigationController.Constants.NavBarHeightLargeState - newValue.height), 0)/52
            let smallAlpha: CGFloat = max(CGFloat(UINavigationController.Constants.NavBarHeightLargeState - newValue.height), 0)/52
            
            largeAlpha = largeAlpha < 0.28 ? 0 : largeAlpha
            self.navigationItem.titleView?.alpha = smallAlpha
            self.avatar.alpha = largeAlpha
            self.stackView.alpha = largeAlpha
        })

    }
    
    private func performChecks() {
        guard surveyReference.survey.isNil else {
            controllerInput?.addView()
            return
        }
//        controllerOutput?.startLoading()
        controllerInput?.loadPoll(surveyReference, incrementViewCounter: true)
    }

    @objc private func addFavorite() {
        guard !isLoading, !survey.isNil else { return }
        guard survey!.isComplete else {
            showBanner(bannerDelegate: self, text: "finish_poll".localized, content: ImageSigns.exclamationMark, dismissAfter: 1)
            return
        }
//        isLoading = true
        var mark = true
        if !isAddedToFavorite {
            UIView.transition(with: watchButton, duration: 0.3, options: [.transitionCrossDissolve]) {
                self.watchButton.image = ImageSigns.binocularsFilled.image
            } completion: { _ in}
            mark = true
            if Surveys.shared.favoriteReferences.filter({ $0.id == _surveyReference.id }).isEmpty { Surveys.shared.favoriteReferences.append(_surveyReference)
            }
//            if Array(Surveys.shared.favoriteReferences.keys).filter( {$0.id == _surveyReference.id }).isEmpty { Surveys.shared.favoriteReferences[self._surveyReference] = Date() }
        } else {
            UIView.transition(with: watchButton, duration: 0.2, options: [.transitionCrossDissolve]) {
                self.watchButton.image = ImageSigns.binoculars.image
            } completion: { _ in}
            mark = false
            if Surveys.shared.favoriteReferences.filter({ $0.id == _surveyReference.id }).isEmpty { Surveys.shared.favoriteReferences.remove(object: _surveyReference)
            }
//            if let key = Surveys.shared.favoriteReferences.keys.filter({ $0.id == _surveyReference.id }).first {
//                Surveys.shared.favoriteReferences.removeValue(forKey: key)
//            }
        }
        isAddedToFavorite = !isAddedToFavorite
//        NotificationCenter.default.post(name: Notifications.Surveys.UpdateFavorite, object: nil)
        controllerInput?.addFavorite(mark)
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let sender = recognizer.view else { return }
        if sender.isKind(of: CircleButton.self) {
            let popup = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: 0.5)
            popup.present(content: UIView(), dismissAfter: 1)
        }
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////                navigationController?.navigationBar.prefersLargeTitles = false
//        navigationItem.largeTitleDisplayMode = .never
//
//    }
    
 
    // MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = PollModel()
               
        self.controllerOutput = view as? PollView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        setupUI()
        setObservers()
        performChecks()
        navigationController?.delegate = self
        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard parent.isNil else { return }
        clearNavigationBar(clear: true)
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.stackView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.avatar.alpha = 0
            self.stackView.alpha = 0
        } completion: { _ in
            self.avatar.removeFromSuperview()
            self.stackView.removeFromSuperview()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor)
        if let label = stackView.get(all: UILabel.self).first {
            label.textColor = traitCollection.userInterfaceStyle == .dark ? .label : surveyReference.topic.tagColor
        }
        
        if let indicator = stackView.get(all: CircleButton.self).first {
            indicator.icon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor)
        }
        
        if let icon = navigationItem.titleView as? Icon {
            icon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : _surveyReference.topic.tagColor)
        }
        if isAddedToFavorite {
            watchButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        } else {
            watchButton.tintColor = .systemGray
        }
    }
}

// MARK: - View Input
extension PollController: PollViewInput {
    func onVotersTapped(answer: Answer, color: UIColor) {
        navigationController?.pushViewController(VotersController(answer: answer, color: color), animated: true)
//        navigationController?.pushViewController(VotersController(answer: answer, indexPath: indexPath, color: color), animated: true)
    }
    
    func onImageTapped(mediafile: Mediafile) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(ImageViewer(mediafile: mediafile), animated: true)
    }
    
    var showNext: Bool {
        return _showNext
    }
    
//    func onVotersTapped(answer: Answer, indexPath: IndexPath, color: UIColor) {
//        navigationController?.pushViewController(VotersController(answer: answer, indexPath: indexPath, color: color), animated: true)
//    }
    
    func onURLTapped(_ url: URL) {
        var vc: SFSafariViewController!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    func onImageTapped(image: UIImage, title: String) {
        navigationController?.pushViewController(ImageController(image: image, title: title), animated: true)
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
    
    var survey: Survey? {
        get {
            return _surveyReference.survey
        }
    }
    
    var surveyReference: SurveyReference {
        get {
            return _surveyReference
        }
    }
}

// MARK: - Model Output
extension PollController: PollModelOutput {
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
    
    func onClaimCallback(_ result: Result<Bool, Error>) {
        controllerOutput?.onClaimCallback(result)
    }
    
    func onVoteCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            _mode = .ReadOnly
            userHasVoted = true
        default:
#if DEBUG
            print("")
#endif
        }
        controllerOutput?.onVoteCallback(result)
    }
    
    func onAddFavoriteCallback(_ result: Result<Bool, Error>) {
        isLoading = false
        switch result {
        case .success(let mark):
            guard mark else { return }
            controllerOutput?.onAddFavoriteCallback()
        case .failure:
#if DEBUG
            print("")
#endif
        }
    }
    
    func onLoadCallback(_ result: Result<Bool, Error>) {
        controllerOutput?.onLoadCallback(result)
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
        
    }
}
