//
//  SurveySelectionController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.05.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class NewSurveySelectionTypeController: UIViewController {

    deinit {
        print("DEINIT NewSurveySelectionTypeController")
    }
    private var isFirstSelection = true {
        didSet {
            if oldValue != isFirstSelection {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    self.view.setNeedsLayout()
                    self.actionButtonTopConstraint.constant -= self.actionButton.frame.height*2
                    self.actionButton.backgroundColor = K_COLOR_RED
                    self.view.layoutIfNeeded()
//                    self.ratingLabel.alpha = 1
//                    self.pollLabel.alpha = 1
                })
            }
        }
    }
    var isRatingSelected: Bool?
    private var pollDescription     = "Классический опрос.\nИзучайте мнения окружающих."
    private var ratingDescription   = "Выбирайте лучших!\nБыстро. Легко. Просто."
    
    
    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            actionButton.backgroundColor = K_COLOR_GRAY
        }
    }
    @IBAction func actionButtonTapped(_ sender: Any) {
        if isRatingSelected! {
            performSegue(withIdentifier: Segues.NewSurvey.Rating, sender: nil)
        } else {
            performSegue(withIdentifier: Segues.NewSurvey.Poll, sender: nil)
        }
    }
    @IBOutlet weak var actionButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingIcon: SurveyCategoryIcon! {
        didSet {
            ratingIcon.backgroundColor = UIColor.clear
            ratingIcon.iconColor       = UIColor.lightGray.withAlphaComponent(0.75)
//            ratingIcon.scaleMultiplicator     = 0.7
            ratingIcon.category        = .Rating
            ratingIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewSurveySelectionTypeController.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel! {
        didSet {
            ratingLabel.alpha = 0
        }
    }
    @IBOutlet weak var pollIcon: SurveyCategoryIcon! {
        didSet {
            pollIcon.backgroundColor = UIColor.clear
            pollIcon.iconColor       = UIColor.lightGray.withAlphaComponent(0.75)
            pollIcon.scaleMultiplicator     = 0.65
            pollIcon.category        = .Poll
            pollIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewSurveySelectionTypeController.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var pollLabel: UILabel! {
        didSet {
            pollLabel.alpha = 0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.transitionStyle = .Icon
            nc.duration = 0.3
            nc.isShadowed = false
        }
        if isRatingSelected == nil {
            actionButton.setNeedsLayout()
            actionButton.layoutIfNeeded()
            actionButton.cornerRadius            = actionButton.frame.height/2
            actionButtonTopConstraint.constant  += actionButton.frame.height*2
            actionButton.layer.cornerRadius = actionButton.frame.height/2
            actionButton.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            actionButton.layer.shadowPath = UIBezierPath(roundedRect: actionButton.bounds, cornerRadius: actionButton.frame.height / 2).cgPath
            actionButton.layer.shadowRadius = 4
            actionButton.layer.shadowOffset = .zero
            actionButton.layer.shadowOpacity = 1
        } else {
            actionButton.setNeedsLayout()
            actionButton.layoutIfNeeded()
            actionButtonTopConstraint.constant = 0
        }
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended, let icon = recognizer.view as? SurveyCategoryIcon {
            let selectedIcon: SurveyCategoryIcon! = icon == ratingIcon ? ratingIcon : pollIcon
            let deselectedIcon: SurveyCategoryIcon! = icon != ratingIcon ? ratingIcon : pollIcon
            
            if isRatingSelected != nil, (isRatingSelected! && icon == ratingIcon) || (!isRatingSelected! && icon == pollIcon) {
                return
            }
            
            let enableAnim  = Animations.get(property: .FillColor, fromValue: selectedIcon.iconColor.cgColor, toValue: K_COLOR_RED.cgColor, duration: 0.3, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
            let disableAnim = Animations.get(property: .FillColor, fromValue: K_COLOR_RED.cgColor, toValue: deselectedIcon.iconColor.cgColor, duration: 0.3, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
//            enableAnim.setValue({ selectedIcon.iconColor = K_COLOR_RED }, forKey: "completionBlock")
//            selectedIcon.iconColor = K_COLOR_RED
            
            selectedIcon.icon.add(enableAnim, forKey: nil)
            (selectedIcon.icon as! CAShapeLayer).fillColor = K_COLOR_RED.cgColor
            if !isFirstSelection {
//                disableAnim.setValue({ deselectedIcon.iconColor = UIColor.lightGray.withAlphaComponent(0.75) }, forKey: "completionBlock")
                deselectedIcon.icon.add(disableAnim, forKey: nil)
                (deselectedIcon.icon as! CAShapeLayer).fillColor = UIColor.lightGray.withAlphaComponent(0.75).cgColor
//                deselectedIcon.iconColor = UIColor.lightGray.withAlphaComponent(0.75)
            }
            
            UIView.transition(with: descriptionLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.descriptionLabel.text = icon == self.ratingIcon ? self.ratingDescription : self.pollDescription
            })
            isFirstSelection = false
            isRatingSelected = icon == ratingIcon ? true : false
        }
    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let nc = navigationController as? NavigationControllerPreloaded {
//            nc.transitionStyle  = .Default
//        }
//    }
}
