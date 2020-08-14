//
//  SurveyStackViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyStackViewController: UIViewController {
    
    var isPause = false
    var delegate: SurveysViewController!
    var surveyPreview: SurveyPreview!
//    fileprivate var isRequesting = false //Don't overlap requests
    fileprivate var isFirstAppearance = true
    fileprivate var removePreview:  SurveyPreview!
    fileprivate var nextPreview:    SurveyPreview?
    fileprivate var timer:          Timer?
    fileprivate lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
    fileprivate lazy var loadingView: EmptySurvey = self.createLoadingView()
    fileprivate var previewSurveys: [FullSurvey] = []
    fileprivate var isRequestingStack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SurveyStackViewController.generatePreviews),
                                               name: Notifications.Surveys.SurveysStackReceived,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SurveyStackViewController.didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(SurveyStackViewController.profileImageReceived),
//                                               name: kNotificationProfileImageReceived,
//                                               object: nil)
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(SurveyStackViewController.didEnterBackground),
//                                               name: UIApplication.didEnterBackgroundNotification,
//                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isPause = false
        delay(seconds: 0.2) {
            self.generatePreviews()
        }
        if isFirstAppearance  {
            isFirstAppearance = false
        }
    }
    
    @objc fileprivate func didBecomeActive() {
        if Surveys.shared.stackObjects.isEmpty {
            startTimer()
        }
    }
    
    @objc fileprivate func didEnterBackground() {
        stopTimer()
    }
    
    @objc fileprivate func generatePreviews() {
        if !isPause {
            if surveyPreview == nil {
                if let _nextPreview = createSurveyPreview() {
                    stopTimer()
                    nextPreview = _nextPreview
                    nextSurvey(nextPreview!)
                } else {
                    loadingView.setEnabled(true) { _ in }
                }
            }
        }
    }
    
    @objc fileprivate func createSurveyPreview() -> SurveyPreview? {
        if !Surveys.shared.stackObjects.isEmpty {
//            if let survey = Surveys.shared.stackObjects.remove(at: 0) as? FullSurvey {
            
            if let survey = Surveys.shared.stackObjects.filter({$0 != self.previewSurveys.map({$0}).last}).first {//Set(Surveys.shared.stackObjects).symmetricDifference(Set(previewSurveys)).first {//zip(Surveys.shared.stackObjects, previewSurveys).filter({ $0.0.hashValue != $0.1.hashValue}).fir {//Surveys.shared.stackObjects.//.filter({$0.hashValue != self.previewSurveys.map({$0.hashValue}).f}).first {
//                previewSurveys.addUnique(object: survey)
                if previewSurveys.filter({ $0.hashValue == survey.hashValue }).isEmpty {
                    previewSurveys.append(survey)
                }
                let multiplier: CGFloat = 0.95
                var _rect = CGRect.zero
                if tabBarController!.tabBar.isHidden {
                    _rect = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.size.width * multiplier, height: view.frame.size.height/* * multiplier*/ - tabBarController!.tabBar.frame.height))
                } else {
                    _rect = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.size.width * multiplier, height: view.frame.size.height/* * multiplier*/))
                }
                let _surveyPreview = SurveyPreview(frame: _rect, survey: survey, delegate: self)
                _surveyPreview.setNeedsLayout()
                _surveyPreview.layoutIfNeeded()
                _surveyPreview.voteButton.layer.cornerRadius = _surveyPreview.voteButton.frame.height / 2
                _surveyPreview.center = view.center
                _surveyPreview.center.x += view.frame.width

                if let userProfile = survey.userProfile {
                    _surveyPreview.userName.text = userProfile.name
                    if userProfile.image != nil {
                        _surveyPreview.userImage.image = userProfile.image!.circularImage(size: _surveyPreview.userImage.frame.size, frameColor: K_COLOR_RED)
                    } else {
                        let postImageNotification = self.nextPreview === _surveyPreview//Notify only if current preview is on screen
                        _surveyPreview.userImage.image = UIImage(named: "user")!.circularImage(size: _surveyPreview.userImage.frame.size, frameColor: K_COLOR_RED)
                        apiManager.downloadImage(url: userProfile.imageURL) {
                            image, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                            if image != nil {
                                userProfile.image = image!
                                if postImageNotification {
                                    NotificationCenter.default.post(name: Notifications.UI.ProfileImageReceived, object: image)
                                }
                                UIView.transition(with: _surveyPreview.userImage,
                                                  duration: 0.75,
                                                  options: .transitionCrossDissolve,
                                                  animations: { _surveyPreview.userImage.image = userProfile.image!.circularImage(size: _surveyPreview.userImage.frame.size, frameColor: K_COLOR_RED) },
                                                  completion: nil)
                            }
                        }
                    }
                }
                return _surveyPreview
            }
        }
//        Surveys.shared.currentHotSurvey = nil
//        if !isFirstAppearance {
            startTimer()
//        }
        return nil
    }
    
    fileprivate func createLoadingView() -> EmptySurvey {
        let multiplier: CGFloat = 0.95
        let loadingView = EmptySurvey(frame: CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.size.width * multiplier, height: view.frame.size.height * multiplier)), delegate: self)
        loadingView.alpha = 0
        loadingView.center = view.center
//        loadingView.addEquallyTo(to: view)
        loadingView.setNeedsLayout()
        loadingView.layoutIfNeeded()
        loadingView.createButton.layer.cornerRadius = loadingView.createButton.frame.height / 2
        view.addSubview(loadingView)
//        loadingView.startingPoint = loadingView.createButton.convert(loadingView.createButton.center, to: tabBarController?.view)
        return loadingView
    }
    
    fileprivate func nextSurvey(_ _surveyPreview: SurveyPreview?) {
        func nextFrame() {
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
                if self.removePreview != nil {
                    self.removePreview.alpha = 0
                    self.removePreview.voteButton.backgroundColor = K_COLOR_GRAY
                    self.removePreview.nextButton.tintColor = K_COLOR_GRAY
                    self.removePreview.center.x -= self.view.frame.width
//                    self.removePreview.frame.origin = self.view.frame.origin
                    self.removePreview.transform = self.removePreview.transform.scaledBy(x: 0.85, y: 0.85)
                }
                //            _surveyPreview.alpha = 1
                _surveyPreview!.transform  = .identity
                _surveyPreview!.center = self.view.center
                if self.tabBarController!.tabBar.isHidden {
                    _surveyPreview!.center.y -= self.tabBarController!.tabBar.frame.height
                }
            }) {
                _ in
                self.surveyPreview = _surveyPreview
                if self.removePreview != nil {
                    self.removePreview.removeFromSuperview()
                }
                
                if let _nextPreview = self.createSurveyPreview() {
                    self.nextPreview = _nextPreview
                } else {
                    self.nextPreview = nil
                }
            }
        }
        
        if _surveyPreview != nil {
            _surveyPreview!.transform = _surveyPreview!.transform.scaledBy(x: 0.85, y: 0.85)
            view.addSubview(_surveyPreview!)
            self.loadingView.setEnabled(false) {
                completed in
                nextFrame()
            }

//            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
//                if self.removePreview != nil {
//                    self.removePreview.alpha = 0
//                    self.removePreview.voteButton.backgroundColor = K_COLOR_GRAY
//                    self.removePreview.nextButton.tintColor = K_COLOR_GRAY
//                    self.removePreview.center.x -= self.view.frame.width
//                    self.removePreview.transform = self.removePreview.transform.scaledBy(x: 0.85, y: 0.85)
//                }
//                //            _surveyPreview.alpha = 1
//                _surveyPreview!.transform  = .identity
//                _surveyPreview!.center = self.view.center
//            }) {
//                _ in
//                self.surveyPreview = _surveyPreview
//                if self.removePreview != nil {
//                    self.removePreview.removeFromSuperview()
//                }
//
//                if let _nextPreview = self.createSurveyPreview() {
//                    self.nextPreview = _nextPreview
//                } else {
//                    self.nextPreview = nil
//                }
//            }
        } else {
            //Start timer
            
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
                if self.removePreview != nil {
                    self.removePreview.alpha = 0
                    self.removePreview.voteButton.backgroundColor = K_COLOR_GRAY
                    self.removePreview.nextButton.tintColor = K_COLOR_GRAY
                    self.removePreview.center.x -= self.view.frame.width
                    self.removePreview.transform = self.removePreview.transform.scaledBy(x: 0.85, y: 0.85)
                }
            }) {
                _ in
                self.removePreview.removeFromSuperview()
                self.surveyPreview.removeFromSuperview()
                self.surveyPreview = nil
                Surveys.shared.stackObjects.removeAll()
                self.startTimer()
                self.loadingView.setEnabled(true) {
                    completed in
                    self.loadingView.createButton.layer.cornerRadius = self.loadingView.createButton.frame.height / 2
                }
            }
        }
    }
    
//    @objc func profileImageReceived() {
//        
//    }
    
    fileprivate func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(SurveyStackViewController.requestSurveys), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    fileprivate func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.App.FeedToSurveyFromTop, let destinationVC = segue.destination as? SurveyViewController {
            destinationVC.delegate = self
        }
     }
}




extension SurveyStackViewController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if let button = sender as? UIButton, let accessibilityIdentifier = button.accessibilityIdentifier {
            if accessibilityIdentifier == "Vote" {//Vote
                delegate.performSegue(withIdentifier: Segues.App.FeedToSurveyFromTop, sender: self)
            } else if accessibilityIdentifier == "Reject" {//Reject
                Surveys.shared.rejectedSurveys.append(surveyPreview.survey)
                apiManager.rejectSurvey(survey: surveyPreview.survey) {
                    json, error in
                    if error != nil {
                        print(error.debugDescription)
                    }
                    if json != nil {
                        Surveys.shared.importSurveys(json!)
//                        print("Surveys.shared.stackObjects \(Surveys.shared.stackObjects.count)")
//                        if Surveys.shared.stackObjects.isEmpty { self.startTimer() }
                    }
                }
                removePreview = surveyPreview
                nextSurvey(nextPreview)
            }
//            } else if accessibilityIdentifier == "Next" {
//                removePreview = surveyPreview
//                nextSurvey(nextPreview)
//            }
        } else if sender is UserProfile {
            delegate.performSegue(withIdentifier: Segues.App.FeedToUser, sender: sender)
        } else if let _view = sender as? EmptySurvey  {
            isPause = true
            _view.startingPoint = view.convert(_view.createButton.center, to: tabBarController?.view)

            delegate.performSegue(withIdentifier: Segues.App.FeedToNewSurvey, sender: _view)
        } else if sender is ClaimCategory { //Claim
            removePreview = surveyPreview
            delay(seconds: 0.5) {
                self.nextSurvey(self.nextPreview)
            }
        } else if sender is FullSurvey { //Voted
            delay(seconds: 0.4) {
                self.removePreview = self.surveyPreview
                self.nextSurvey(self.nextPreview)
            }
        }
    }
}

extension SurveyStackViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol {
        return (tabBarController as! TabBarController).apiManager
    }
    
    @objc fileprivate func requestSurveys() {
        apiManager.loadSurveys(type: .Hot) {
            json, error in
            if error != nil {
                print(error.debugDescription)
            }
            if json != nil {
                Surveys.shared.importSurveys(json!)
            }
        }
    }
}
