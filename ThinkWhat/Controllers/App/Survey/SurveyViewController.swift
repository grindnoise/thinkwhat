//
//  SurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController {
    
    private lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
    private let requestAttempts = 3
    private var loadingIndicator: LoadingIndicator!
    private let likeButton = HeartView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
    var surveyLink: SurveyLink! {
        didSet {
            title = "Опрос №\(surveyLink.ID)"
        }
    }
    var survey: Survey? {
        didSet {
            if survey != nil {
                print("Survey loaded")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        if let _survey = Surveys.shared[surveyLink.ID] {
            survey = _survey
        } else {
            loadData()
        }
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
        
//        DispatchQueue.main.async {
            self.loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.width)))
            self.loadingIndicator.layoutCentered(in: self.view, multiplier: 0.7)
//        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SurveyViewController.likeTapped(gesture:)))
        likeButton.addGestureRecognizer(gesture)
        
        
    }

    @objc fileprivate func likeTapped(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            if likeButton.state == .disabled {
                likeButton.state = .enabled
            } else {
                likeButton.state = .disabled
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
        loadingIndicator.alpha = 1
        loadingIndicator.addUntitled1Animation()
        apiManager.loadSurvey(survey: surveyLink) {
            json, error in
            if error != nil {
                showAlert(type: .Ok, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: { UIView.animate(withDuration: 0.3, animations: {
                    self.loadingIndicator.alpha = 0
                }) { _ in self.loadingIndicator.removeAllAnimations() } }]], text: "Ошибка: \(error!.localizedDescription)")
            }
            if json != nil {
                if let _survey = Survey(json!) {
                    Surveys.shared.downloadedSurveys.append(_survey)
                    self.survey = _survey
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.loadingIndicator.alpha = 0
                }) { _ in self.loadingIndicator.removeAllAnimations() }
            }
        }
    }
}
