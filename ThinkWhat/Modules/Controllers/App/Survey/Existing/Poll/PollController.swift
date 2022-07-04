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
    
    // MARK: - Properties
    var controllerOutput: PollControllerOutput?
    var controllerInput: PollControllerInput?
    private var _mode: Mode = .Write
    var mode: Mode {
        return _mode
    }
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
    
    // MARK: - Initialization
    deinit {
        print("PollController deinit")
    }
    
    init(surveyReference: SurveyReference, showNext __showNext: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self._surveyReference = surveyReference
        self._survey = surveyReference.survey
        self._showNext = __showNext
        self._mode = surveyReference.isComplete ? .ReadOnly : .Write
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
//        navigationController?.delegate = self
        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupUI() {
        if !_survey.isNil { controllerOutput?.onLoadCallback(.success(true)) }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
                    self.navigationController?.navigationBar.standardAppearance = appearance
                    self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        guard deviceType != .iPhoneSE else {
                    ///Set icon category in title
                    let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
                    icon.backgroundColor = .clear
                    icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : _surveyReference.topic.tagColor
                    icon.isRounded = false
                    icon.scaleMultiplicator = 1.4
                    icon.category = Icon.Category(rawValue: _surveyReference.topic.id) ?? .Null
                    navigationItem.titleView = icon
            
                    navigationItem.titleView?.clipsToBounds = false
                    navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(PollController.addFavorite))
                    watchButton.addGestureRecognizer(gesture)
            
                    if isAddedToFavorite {
                        watchButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
                    } else {
                        watchButton.tintColor = .systemGray
                    }
            
                    if let nc = navigationController as? NavigationControllerPreloaded {
                        nc.setNavigationBarHidden(false, animated: false)
//                        nc.navigationBar.isTranslucent = false
                    }
                    navigationItem.largeTitleDisplayMode = .never
                    watchButton.image = _surveyReference.isFavorite ? ImageSigns.binocularsFilled.image : ImageSigns.binoculars.image
                    isAddedToFavorite = _surveyReference.isFavorite ? true : false
                    navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: watchButton)]
            return
        }
        
        navigationBar.addSubview(avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            avatar.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
            avatar.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
            avatar.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: UINavigationController.Constants.ImageBottomMarginForLargeState),
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1.0/1.0)
            ])
        
        stackView.axis = .horizontal
        navigationBar.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: navigationBar.leftAnchor, constant: UINavigationController.Constants.ImageBottomMarginForLargeState),
            stackView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
            stackView.heightAnchor.constraint(equalToConstant: 52 - UINavigationController.Constants.ImageBottomMarginForLargeState),
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
        
//        navigationBar.set

//        navigationBar.addSubview(progressIndicator)
//        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            progressIndicator.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState*2),
//            progressIndicator.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0),// -UINavigationController.Constants.ImageBottomMarginForSmallState),
//            progressIndicator.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: UINavigationController.Constants.ImageBottomMarginForLargeState*3.5),
//            progressIndicator.widthAnchor.constraint(equalTo: progressIndicator.heightAnchor, multiplier: 1.0/1.0)
//            ])
//        progressIndicator.layer.masksToBounds = false
//        progressIndicator.lineWidth = progressIndicator.frame.width * 0.1
        

    }
    
    private func setObservers() {
        observers.append(stackView.observe(\UIStackView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard !self.isNil,
                  let newValue = change.newValue,
                  let label = view.arrangedSubviews.filter({ $0.isKind(of: UILabel.self) }).first as? UILabel else { return }
            label.font = UIFont(name: Fonts.Bold, size: newValue.width * 0.1)
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
//
//    @objc private func updateViewsCount(notification: Notification) {
//        controllerOutput?.onCountUpdated()
//    }

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

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////                navigationController?.navigationBar.prefersLargeTitles = false
//        navigationItem.largeTitleDisplayMode = .never
//
//    }
    
 
    
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
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let sender = recognizer.view else { return }
        if sender.isKind(of: CircleButton.self) {
            let popup = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: 0.5)
            popup.present(content: UIView(), dismissAfter: 1)
        }
    }
}

// MARK: - View Input
extension PollController: PollViewInput {
    func onImageTapped(mediafile: Mediafile) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(ImageViewer(mediafile: mediafile), animated: true)
    }
    
    var showNext: Bool {
        return _showNext
    }
    
    func onVotersTapped(answer: Answer, indexPath: IndexPath, color: UIColor) {
        navigationController?.pushViewController(VotersController(answer: answer, indexPath: indexPath, color: color), animated: true)
    }
    
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
    
    func onCountUpdateCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            controllerOutput?.onCountUpdatedCallback()
        case .failure(let error):
#if DEBUG
            print(error.localizedDescription)
#endif
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
//        if let vc = viewController as? HotController, controllerOutput?.hasVoted == true {
//            vc.shouldSkipCurrentCard = true
//        }
    }
}

// MARK: - CallbackObservable
extension PollController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        
    }
}
