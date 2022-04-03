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
    
    // MARK: - Properties
    var controllerOutput: HotControllerOutput?
    var controllerInput: HotControllerInput?
    private var isViewLayedOut = false
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
        navigationController?.pushViewController(PollController(survey: survey), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onEmptyStack() {
        startTimer()
    }
}

// MARK: - Model Output
extension HotController: HotModelOutput {}

extension HotController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        controllerOutput?.pushStack()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HotController.pushStack),
                                               name: Notifications.Surveys.UpdateHotSurveys,
                                               object: nil)
    }
}

// MARK: - Observers
extension HotController {
    @objc
    private func pushStack() {
        controllerOutput?.pushStack()
        stopTimer()
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(HotController.requestSurveys), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc
    private func requestSurveys() {
        controllerInput?.loadSurveys()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

