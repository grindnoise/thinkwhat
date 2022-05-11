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
        performChecks()
        navigationController?.delegate = self
    }
    
    private func setupUI() {
//        //Set icon category in title
        let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        icon.backgroundColor = .clear
        icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : _surveyReference.topic.tagColor
        icon.isRounded = false
        icon.scaleMultiplicator = 1.4
        icon.category = Icon.Category(rawValue: _surveyReference.topic.id) ?? .Null
        navigationItem.titleView = icon

        navigationItem.titleView?.clipsToBounds = false
//        navigationItem.backBarButtonItem?.title = ""
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
//            nc.isShadowed = true
            nc.navigationBar.isTranslucent = false
        }
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(PollController.updateViewsCount(notification:)),
//                                               name: Notifications.UI.SuveyViewsCountReceived,
//                                               object: nil)
        navigationItem.largeTitleDisplayMode = .never
        guard _surveyReference.isOwn else {
            
            if Surveys.shared.favoriteReferences.filter({ (ref, date) in
                ref == _surveyReference
            }).isEmpty {
                UIView.transition(with: watchButton, duration: 0.2, options: [.transitionCrossDissolve]) {
                    self.watchButton.image = ImageSigns.binoculars.image
                } completion: { _ in}
                isAddedToFavorite = false
            } else {
                UIView.transition(with: watchButton, duration: 0.2, options: [.transitionCrossDissolve]) {
                    self.watchButton.image = ImageSigns.binocularsFilled.image
                } completion: { _ in}
                isAddedToFavorite = true
            }
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: watchButton)]
            return
        }
    }
    
    private func performChecks() {
        guard surveyReference.survey.isNil else {
            controllerInput?.addView()
            return
        }
        controllerOutput?.startLoading()
        controllerInput?.loadPoll(surveyReference, incrementViewCounter: true)
    }
//
//    @objc private func updateViewsCount(notification: Notification) {
//        controllerOutput?.onCountUpdated()
//    }

    @objc private func addFavorite() {
        guard !isLoading, !survey.isNil else { return }
        guard survey!.isComplete else {
            showBanner(bannerDelegate: self, text: "finish_poll".localized, imageContent: ImageSigns.exclamationMark, shouldDismissAfter: 1)
            return
        }
//        isLoading = true
        var mark = true
        if !isAddedToFavorite {
            UIView.transition(with: watchButton, duration: 0.3, options: [.transitionCrossDissolve]) {
                self.watchButton.image = ImageSigns.binocularsFilled.image
            } completion: { _ in}
            mark = true
            if Array(Surveys.shared.favoriteReferences.keys).filter( {$0.id == _surveyReference.id }).isEmpty { Surveys.shared.favoriteReferences[self._surveyReference] = Date() }
        } else {
            UIView.transition(with: watchButton, duration: 0.2, options: [.transitionCrossDissolve]) {
                self.watchButton.image = ImageSigns.binoculars.image
            } completion: { _ in}
            mark = false
            if let key = Surveys.shared.favoriteReferences.keys.filter({ $0.id == _surveyReference.id }).first {
                Surveys.shared.favoriteReferences.removeValue(forKey: key)
            }
        }
        isAddedToFavorite = !isAddedToFavorite
        NotificationCenter.default.post(name: Notifications.Surveys.UpdateFavorite, object: nil)
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
        tabBarController?.setTabBarVisible(visible: true, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if let icon = navigationItem.titleView as? Icon {
            icon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : _surveyReference.topic.tagColor)
        }
        if isAddedToFavorite {
            watchButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        } else {
            watchButton.tintColor = .systemGray
        }
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
        v.contentMode = .scaleAspectFill
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
}

// MARK: - View Input
extension PollController: PollViewInput {
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
        controllerOutput?.onClaim(result)
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
        controllerOutput?.onVote(result)
    }
    
    func onAddFavoriteCallback(_ result: Result<Bool, Error>) {
        isLoading = false
        switch result {
        case .success(let mark):
            guard mark else { return }
            controllerOutput?.onAddFavorite()
        case .failure:
#if DEBUG
            print("")
#endif
        }
    }
    
    func onLoadCallback(_ result: Result<Bool, Error>) {
        controllerOutput?.onLoad(result)
    }
    
    func onCountUpdateCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            controllerOutput?.onCountUpdated()
        case .failure(let error):
#if DEBUG
            print(error.localizedDescription)
#endif
        }
    }
}

extension PollController: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        guard let banner = sender as? Banner else { return }
        banner.removeFromSuperview()
    }
}

extension PollController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? HotController, controllerOutput?.hasVoted == true {
            vc.shouldSkipCurrentCard = true
        }
    }
}
