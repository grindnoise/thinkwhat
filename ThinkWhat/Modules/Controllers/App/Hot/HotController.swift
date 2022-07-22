//
//  HotController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class HotController: UIViewController {

    
    // MARK: - Properties
    var controllerOutput: HotControllerOutput?
    var controllerInput: HotControllerInput?
    var shouldSkipCurrentCard = false
    
    private var observers: [NSKeyValueObservation] = []
    private var isViewLayedOut = false
    private lazy var barButton: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        instance.layer.shadowRadius = 7
        instance.layer.shadowOffset = .zero
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.layer.shadowPath = UIBezierPath(ovalIn: newValue).cgPath
        })
        
        let button = UIButton()
        observers.append(button.observe(\UIButton.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.size.height/2
            let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height * 0.65, weight: .semibold, scale: .medium)
            let image = UIImage(systemName: "plus", withConfiguration: largeConfig)
            view.setImage(image, for: .normal)
        })
        button.addTarget(self, action: #selector(self.onCreate), for: .touchUpInside)
        button.accessibilityIdentifier = "button"
        button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        button.imageView?.contentMode = .center
        button.imageView?.tintColor = .white
        button.addEquallyTo(to: instance)

        return instance
    }()
    private var isNetworking = false
    private var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = HotModel()
               
        self.controllerOutput = view as? HotView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        setObservers()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationItem.title = "New Order"
//            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode =  .always
        guard !isViewLayedOut else { return }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        controllerOutput?.onDidLayout()
        barButton.alpha = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controllerOutput?.onDidAppear()
        if shouldSkipCurrentCard {
            Task {
                try await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
                await MainActor.run {
                    controllerOutput?.skipCard()
                    shouldSkipCurrentCard = false
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barButton.alpha = 0
        guard let navigationBar = self.navigationController?.navigationBar,
              let button = navigationBar.subviews.filter({ $0.isKind(of: UIImageView.self)}).first as? UIImageView else { return }
        button.alpha = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(barButton)
        barButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            barButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            barButton.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            barButton.widthAnchor.constraint(equalTo: barButton.heightAnchor)
            ])
        barButton.frame = .zero
    }
    
    @objc
    private func onCreate() {
        if let nav = navigationController as? CustomNavigationController {
            nav.transitionStyle = .Default
            nav.duration = 0.5
//            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
        }
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(SurveyCreationController(), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    private func setObservers() {
//        let remove      = [Notifications.Surveys.Claimed,
//                           Notifications.Surveys.Completed,
//                           Notifications.Surveys.Rejected]
//        remove.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.onRemove), name: $0, object: nil) }
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(HotController.makePreviewStack),
//                                               name: Notifications.Surveys.UpdateHotSurveys,
//                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(SurveyStackViewController.didBecomeActive),
//                                               name: UIApplication.didBecomeActiveNotification,
//                                               object: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        barButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
        button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        button.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
    }
    
    
    
    
//    private let barButton: UIImageView = {
//        let v = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
//        v.contentMode = .scaleAspectFill
//        v.isUserInteractionEnabled = true
//        return v
//    }()
    ///Indicates that request is in progress, so another one shouldn't be fired
    
}

// MARK: - View Input
extension HotController: HotViewInput {
    func onReject(_ survey: Survey) {
        controllerInput?.reject(survey)
    }
    
    
    func onClaim(survey: Survey, reason: Claim) {
        controllerInput?.claim(survey: survey, reason: reason)
    }
    
    func onVote(survey: Survey) {
        if let nav = navigationController as? CustomNavigationController {
            nav.transitionStyle = .Default
            nav.duration = 0.5
//            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
        }
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(PollController(surveyReference: survey.reference, showNext: true), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onEmptyStack() {
        startTimer()
    }
}

// MARK: - Model Output
extension HotController: HotModelOutput {
    func onClaimCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
#if DEBUG
            print("")
#endif
        case .failure(let error):
#if DEBUG
            print(error.localizedDescription)
#endif
        }
    }
    
    func onRequestCompleted() {
        isNetworking = false
    }
}

extension HotController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        controllerOutput?.populateStack()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HotController.populateStack),
                                               name: Notifications.Surveys.SwitchHot,
                                               object: nil)
    }
}

// MARK: - Observers
extension HotController {
    @objc
    private func populateStack() {
        controllerOutput?.populateStack()
        stopTimer()
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(HotController.requestSurveys), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc
    private func requestSurveys() {
        guard !isNetworking else { return }
        isNetworking = true
        controllerInput?.loadSurveys()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

