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
//        navigationController?.setNavigationBarHidden(true, animated: true)
        addObservers()
//        title = "hot".localized
//        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !isViewLayedOut else { return }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        controllerOutput?.onDidLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        isMakingStackPaused = false
//        delay(seconds: 0.2) {
//            self.makePreviewStack()
//        }
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
//    var surveyStack: [Survey] = []
    private var isViewLayedOut = false
//    private var isMakingStackPaused = false
//    private var surveyPreview: SurveyPreview!
//    private var nextSurveyPreview: SurveyPreview?
    private var timer: Timer?
    
}

// MARK: - View Input
extension HotController: HotViewInput {
    func onVote(survey: Survey) {
        if let nav = navigationController as? CustomNavigationController {
            nav.transitionStyle = .Default
            nav.duration = 0.5
        }
        navigationController?.pushViewController(PollController(), animated: true)
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

