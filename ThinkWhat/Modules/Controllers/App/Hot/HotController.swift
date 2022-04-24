//
//  HotController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class HotController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = HotModel()
               
        self.controllerOutput = view as? HotView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        addObservers()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(barButton)
        barButton.layer.cornerRadius = UINavigationController.Constants.ImageSizeForLargeState / 2
        barButton.clipsToBounds = true
        barButton.translatesAutoresizingMaskIntoConstraints = false
        barButton.image = ImageSigns.plusFilled.image
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        NSLayoutConstraint.activate([
            barButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            barButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
            barButton.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            barButton.widthAnchor.constraint(equalTo: barButton.heightAnchor)
            ])
    }
    
    private func addObservers() {
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
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    // MARK: - Properties
    var controllerOutput: HotControllerOutput?
    var controllerInput: HotControllerInput?
    var shouldSkipCurrentCard = false
    private var isViewLayedOut = false
    private let barButton: UIImageView = {
        let v = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = true
        return v
    }()
    ///Indicates that request is in progress, so another one shouldn't be fired
    private var isNetworking = false
    private var timer: Timer?
}

// MARK: - View Input
extension HotController: HotViewInput {
    
    func onVote(survey: Survey) {
        if let nav = navigationController as? CustomNavigationController {
            nav.transitionStyle = .Default
            nav.duration = 0.5
//            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
        }
//        let backItem = UIBarButtonItem()
//            backItem.title = ""
//            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(PollController(surveyReference: survey.reference, showNext: true), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onEmptyStack() {
        startTimer()
    }
}

// MARK: - Model Output
extension HotController: HotModelOutput {
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
                                               name: Notifications.Surveys.UpdateHotSurveys,
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

