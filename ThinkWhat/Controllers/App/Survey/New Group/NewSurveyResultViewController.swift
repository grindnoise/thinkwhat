//
//  NewSurveyResultViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewSurveyResultViewController: UIViewController, ServerProtocol {

    deinit {
        print("DEINIT NewSurveyResultViewController")
    }
    @IBOutlet weak var iconView: Icon! {
        didSet {
            iconView.iconColor = K_COLOR_RED
            iconView.category = iconCategory
            iconView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            actionButton.backgroundColor = K_COLOR_RED
//            actionButton.alpha = 0
        }
    }
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.NewSurvey.BackToSurveys, sender: nil)
    }
    @IBOutlet weak var actionButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicator: UIActivityIndicatorView! {
        didSet {
            indicator.startAnimating()
        }
    }
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dots: UILabel!
    @IBOutlet weak var stack: UIStackView!
    
    private var timer:  Timer?
    var iconCategory: Icon.Category = .Poll
    weak var survey: Survey?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
//        NotificationCenter.default.addObserver(self, selector: #selector(NewSurveyResultViewController.handleSuccessResponse), name: Notifications.Surveys.OwnSurveysUpdated, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(NewSurveyResultViewController.handleErrorResponse(notification:)), name: Notifications.Surveys.NewSurveyPostError, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
            nc.navigationBar.isTranslucent = false
            nc.transitionStyle = .Icon
            nc.duration = 0.4
        }
        actionButton.setNeedsLayout()
        actionButton.layoutIfNeeded()
        actionButton.cornerRadius       = actionButton.frame.height/2
        actionButtonConstraint.constant += actionButton.frame.height*2
        postSurvey()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        actionButton.cornerRadius = actionButton.frame.height/2
        startTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        timer = nil
        survey = nil
    }
    
    @objc private func handleSuccessResponse() {
        delay(seconds: 0.5) {
            self.stopTimer()
            self.dots.text = ""
            UIView.transition(with: self.label, duration: 0.1, options:
                [.transitionCrossDissolve], animations: {
                    self.indicator.alpha = 0
                    self.label.text = "Успех!"
            }) {
                _ in
                self.indicator.stopAnimating()
                self.animateIconView()
                UIView.animate(withDuration: 0.4, delay: 1.5, options: [.curveEaseInOut], animations: {
                    self.stack.alpha = 0
                }) {
                    _ in
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                        self.view.setNeedsLayout()
                        self.actionButtonConstraint.constant -= self.actionButton.frame.height*2
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    @objc private func handleErrorResponse(error: Error) {
//        delay(seconds: 0.5) {
//        if let dict = notification.object as? Dictionary<String, Any>, let error = dict["error"] as? String {
//            NotificationCenter.default.removeObserver(self)
            self.stopTimer()
            self.dots.text = ""
            UIView.transition(with: self.label, duration: 0.1, options:
                [.transitionCrossDissolve], animations: {
                    self.indicator.alpha = 0
                    self.label.text = "Ошибка!"
            }) {
                _ in
                self.indicator.stopAnimating()
                
                
                }
                delay(seconds: 0.5) {
                    [weak self] in
        showAlert(type: .Warning,
                  buttons: [["К опросу": [CustomAlertView.ButtonType.Cancel: { self?.navigationController?.popViewController(animated: true)/*self.navigationController?.popViewController(animated: false)*/ }]], ["Повторить": [CustomAlertView.ButtonType.Ok: { self?.postSurvey() } ]]],
                  title: "Ошибка",
                  body: error.localizedDescription)
            }
//        }
    }
    
    private func postSurvey() {
        UIView.transition(with: self.label, duration: 0.1, options:
            [.transitionCrossDissolve], animations: {
                self.indicator.alpha = 0
                self.label.text = "Публикация опроса"
        }) {
            _ in
            self.startTimer()
        }

        if let strongSurvey = survey {
            apiManager.postSurvey(survey: strongSurvey) {
                json, error in
                if error != nil {
                    self.handleErrorResponse(error: error!)
//                    NotificationCenter.default.post(name: Notifications.Surveys.NewSurveyPostError, object: ["error": error!.localizedDescription])
                } else if json != nil {
                    if let _ID = json!["id"].intValue as? Int, let _answers = json!["answers"].arrayValue as? [JSON] {
                        self.survey!.ID = _ID
                        for _answer in _answers {
                            if let answer = Answer(json: _answer) {
                                self.survey!.answers.append(answer)
                            }
                        }
                        Surveys.shared.append(object: self.survey!, type: .Downloaded)
                        //Create SurveyLink & append to own & new arrays
                        if let surveyLink = self.survey!.getSurveyRef() {
                            Surveys.shared.categorizedLinks[strongSurvey.category]?.append(surveyLink)
                            Surveys.shared.append(object: surveyLink, type: .OwnLinks)
                            Surveys.shared.append(object: surveyLink, type: .NewLinks)
                            //                        NotificationCenter.default.removeObserver(self)
                            NotificationCenter.default.post(name: Notifications.Surveys.UpdateNewSurveys, object: nil)
                            NotificationCenter.default.post(name: Notifications.Surveys.SurveysByCategoryUpdated, object: nil)
                            NotificationCenter.default.post(name: Notifications.Surveys.OwnSurveysUpdated, object: nil)
                            self.handleSuccessResponse()
                        }
                    } else {
                        showAlert(type: .Warning,
                                  buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { self.navigationController?.popViewController(animated: false) }]], ["Повторить": [CustomAlertView.ButtonType.Ok: { self.postSurvey() } ]]],
                                  text: "Не удалось прочитать данные")
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(NewSurveyResultViewController.updateTimer), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func updateTimer() {
        if let text = dots.text, text.filter({ $0 == "."}).count < 3 {
            let _text = text + "."
            dots.text = _text
        } else {
            dots.text = ""
        }
    }
    
    private func animateIconView() {
        if let initialLayer = iconView.icon as? CAShapeLayer, let initialPath = initialLayer.path, let destinationLayer = iconView.getLayer(.Success) as? CAShapeLayer, let destinationPath = destinationLayer.path {
            let pathAnim      = Animations.get(property: .Path,
                                               fromValue: initialPath as Any,
                                               toValue: destinationPath as Any,
                                               duration: 0.5,
                                               delay: 0,
                                               repeatCount: 0,
                                               autoreverses: false,
                                               timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                               delegate: nil,
                                               isRemovedOnCompletion: false)
            let fillColorAnim   = Animations.get(property: .FillColor,
                                                 fromValue: iconView.iconColor.cgColor as Any,
                                                 toValue: Colors.UpperButtons.Avocado.cgColor as Any,
                                                 duration: 0.5,
                                                 delay: 0,
                                                 repeatCount: 0,
                                                 autoreverses: false,
                                                 timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                 delegate: nil,
                                                 isRemovedOnCompletion: false)
            iconView.icon.add(fillColorAnim, forKey: nil)
            iconView.icon.add(pathAnim, forKey: nil)
        }
    }
}
