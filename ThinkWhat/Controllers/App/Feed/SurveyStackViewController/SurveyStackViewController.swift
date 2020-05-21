//
//  SurveyStackViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyStackViewController: UIViewController {
    
    var delegate: SurveysViewController!
    var surveyPreview: SurveyPreview!
    fileprivate var isRequesting = false //Don't overlap requests
    fileprivate var removePreview:  SurveyPreview!
    fileprivate var nextPreview:    SurveyPreview?
    fileprivate var timer:          Timer?
    fileprivate lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SurveyStackViewController.generatePreviews),
                                               name: kNotificationSurveysStackReceived,
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        generatePreviews()
    }
    
    @objc fileprivate func generatePreviews() {
        if surveyPreview == nil {
            if let _nextPreview = createSurveyPreview() {
                stopTimer()
                nextPreview = _nextPreview
                nextSurvey(nextPreview!)
            }
        }
    }
    
    @objc fileprivate func createSurveyPreview() -> SurveyPreview? {
        if !Surveys.shared.stackObjects.isEmpty {
            if let survey = Surveys.shared.stackObjects.remove(at: 0) as? FullSurvey {
                let _surveyPreview = SurveyPreview(frame: CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.size.width * 0.95, height: view.frame.size.height * 0.95)), survey: survey, delegate: self)
                _surveyPreview.setNeedsLayout()
                _surveyPreview.layoutIfNeeded()
                _surveyPreview.voteButton.cornerRadius = _surveyPreview.voteButton.frame.height / 2
                _surveyPreview.center = view.center
                _surveyPreview.center.x += view.frame.width
                //            _surveyPreview.alpha = 0
                if let userProfile = survey.userProfile as? UserProfile {
                    _surveyPreview.userName.text = userProfile.name
                    if userProfile.image != nil {
                        _surveyPreview.userImage.image = userProfile.image!.circularImage(size: _surveyPreview.userImage.frame.size, frameColor: K_COLOR_RED)
                    } else {
                        _surveyPreview.userImage.image = UIImage(named: "user")!.circularImage(size: _surveyPreview.userImage.frame.size, frameColor: K_COLOR_RED)
                        apiManager.downloadImage(url: userProfile.imageURL) {
                            image, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                            if image != nil {
                                userProfile.image = image!
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
        startTimer()
        return nil
    }
    
    fileprivate func nextSurvey(_ _surveyPreview: SurveyPreview?) {
        if _surveyPreview != nil {
            _surveyPreview!.transform = _surveyPreview!.transform.scaledBy(x: 0.85, y: 0.85)
            view.addSubview(_surveyPreview!)
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
                if self.removePreview != nil {
                    self.removePreview.alpha = 0
                    self.removePreview.voteButton.backgroundColor = K_COLOR_GRAY
                    self.removePreview.nextButton.tintColor = K_COLOR_GRAY
                    self.removePreview.center.x -= self.view.frame.width
                    self.removePreview.transform = self.removePreview.transform.scaledBy(x: 0.85, y: 0.85)
                }
                //            _surveyPreview.alpha = 1
                _surveyPreview!.transform  = .identity
                _surveyPreview!.center = self.view.center
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
            }
        }
    }
    
    fileprivate func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(SurveyStackViewController.requestSurveys), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    fileprivate func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}




extension SurveyStackViewController: ButtonDelegate {
    func signalReceived(_ sender: AnyObject) {
        if sender is UIButton {
            let button = sender as! UIButton
            if button.tag == 0 {//Vote
                delegate.performSegue(withIdentifier: Segues.App.FeedToSurvey, sender: self)
            } else {//Next
                //Reject
                apiManager.rejectSurvey(survey: surveyPreview.survey)
                removePreview = surveyPreview
                nextSurvey(nextPreview)
            }
        } else if sender is UIImageView {
            if let userProfile = sender.value(forKey: "userProfile") as? UserProfile {
                print(userProfile)
            }
            delegate.performSegue(withIdentifier: Segues.App.FeedToUser, sender: self)
        }
    }
}

extension SurveyStackViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol {
        return (tabBarController as! TabBarController).apiManager
    }
    
    @objc fileprivate func requestSurveys() {
        print("-------requestSurveys()-------")
        if !isRequesting {
            isRequesting = true
            apiManager.loadSurveys(type: .Hot) {
                json, error in
                if error != nil {
                    print(error.debugDescription)
                }
                if json != nil {
                    Surveys.shared.importSurveys(json!)
                }
                self.isRequesting = false
            }
        }
    }
}
