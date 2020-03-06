//
//  SurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController {
    
    @IBOutlet weak var surveyTitle: UILabel!
    fileprivate var requestAttempt = 0 {
        didSet {
            if oldValue != requestAttempt {
                if requestAttempt > MAX_REQUEST_ATTEMPTS {
                    requestAttempt = 0
                }
            }
        }
    }
    private var isRequesting = false
    private lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
    private let requestAttempts = 3
    private var loadingIndicator: LoadingTextIndicator!
    private let likeButton = HeartView(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
    var surveyLink: SurveyLink! {
        didSet {
            likeButton.removeAllAnimations()
            title = surveyLink.category!.title//"Опрос №\(surveyLink.ID)"
            likeButton.state = Array(Surveys.shared.favoriteSurveys.keys).filter( {$0.ID == surveyLink.ID }).isEmpty ? .disabled : .enabled
        }
    }
    var survey: Survey?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
//        DispatchQueue.main.async {
            self.loadingIndicator = LoadingTextIndicator(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.width)))
            self.loadingIndicator.layoutCentered(in: self.view, multiplier: 0.8)
//        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SurveyViewController.likeTapped(gesture:)))
        likeButton.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        surveyTitle.text = surveyLink.title
        if let _survey = Surveys.shared[surveyLink.ID] {
            survey = _survey
            loadingIndicator.alpha = 0
            for subview in view.subviews {
                if !(subview is LoadingTextIndicator) {
                    subview.alpha = 1
                }
            }
        } else {
            for subview in view.subviews {
                if !(subview is LoadingTextIndicator) {
                    subview.alpha = 0
                }
            }
            loadingIndicator.alpha = 1
            loadingIndicator.addEnableAnimation()
            loadData()
        }
    }
    
    @objc fileprivate func likeTapped(gesture: UITapGestureRecognizer) {
        if !isRequesting {
            isRequesting = true
            if gesture.state == .ended {
                var mark = true
                if likeButton.state == .disabled {
                    likeButton.state = .enabled
                    mark = true
                    if Array(Surveys.shared.favoriteSurveys.keys).filter( {$0.ID == surveyLink.ID }).isEmpty { Surveys.shared.favoriteSurveys[self.surveyLink] = Date() }
                } else {
                    likeButton.state = .disabled
                    mark = false
                    if let key = Surveys.shared.favoriteSurveys.keys.filter({ $0.ID == surveyLink.ID }).first {
                        Surveys.shared.favoriteSurveys.removeValue(forKey: key)
                    }
                    //                Surveys.shared.favoriteSurveys.removeValue(forKey: self.surveyLink)
                    NotificationCenter.default.post(name: kNotificationFavoriteSurveysUpdated, object: nil)
                }
                apiManager.markFavorite(mark: mark, survey: surveyLink!) {
                    _, error in
                    self.isRequesting = false
                    if error != nil {
                        showAlert(type: CustomAlertView.AlertType.Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], title: "Ошибка", body: "Опрос не добавлен в любимые. \(error!.localizedDescription)")
                    }
                }
            }
        }
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

extension SurveyViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol {
        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).apiManager
    }
}

extension SurveyViewController {
    public func loadData() {
        
        requestAttempt += 1
        apiManager.loadSurvey(survey: surveyLink) {
            json, error in
            if error != nil {
                if self.requestAttempt > MAX_REQUEST_ATTEMPTS {
                showAlert(type: .Ok, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { UIView.animate(withDuration: 0.3, animations: {
                    self.loadingIndicator.alpha = 0
                }) { _ in self.loadingIndicator.removeAllAnimations() } }]]], text: "Ошибка: \(error!.localizedDescription)")
                } else {
                    //Retry
                    self.loadData()
                }
            }
            if json != nil {
                
                if let _survey = Survey(json!) {
                    Surveys.shared.downloadedSurveys.append(_survey)
                    self.survey = _survey
                    self.requestAttempt = 0
                }
                UIView.animate(withDuration: 0.3, animations: {
                    for subview in self.view.subviews {
                        if subview is LoadingTextIndicator {
                            subview.alpha = 0
                        } else {
                            UIView.animate(withDuration: 0.6, delay: 0.3, options: [.curveEaseIn], animations: {
                                subview.alpha = 1
                            })
                        }
                    }
                }) { _ in self.loadingIndicator.removeAllAnimations() }
            }
        }
    }
}
