//
//  VotesCountViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.12.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class VotesCountViewController: UIViewController {

    deinit {
        print("***CreateNewSurveyViewController deinit***")
    }
    
    private var isMinVotesBannerShown = false
    private var isMaxVotesBannerShown = false
    
    //Если повторно окно откроется, при это установлены доп опции ценовые, то надо прочитать их стоимость
    var cost: [String: Int]!
    private var totalCost: Int = 0
    var color: UIColor!
    var votesCapacity = 0 {
        didSet {
            totalCost = 0
            if actionButton != nil {
//                actionButton.text = "\(votesCapacity)"
                if votesCapacity > MAX_VOTES_COUNT {//, UserDefaults.App.hasSeenPollCreationIntroduction {
                    if !isMaxVotesBannerShown {
                        Banner.shared.contentType = .Warning
                        if let content = Banner.shared.content as? Warning {
                            content.level = .Warning
                            content.text = "Максимальное число участников должно быть не более \(MAX_VOTES_COUNT)"
                        }
                        Banner.shared.present(shouldDismissAfter: 2, delegate: self)
                        isMaxVotesBannerShown = true
                        actionButton.animateIconChange(toCategory: Icon.Category.Error)
                    }
                    UIView.animate(withDuration: 0.3) {
                        self.actionButton.color = K_COLOR_GRAY
                    }
                } else if votesCapacity < MIN_VOTES_COUNT {//}, UserDefaults.App.hasSeenPollCreationIntroduction {
                    if !isMinVotesBannerShown {
                        Banner.shared.contentType = .Warning
                        if let content = Banner.shared.content as? Warning {
                            content.level = .Warning
                            content.text = "Минимальное число участников должно быть не менее \(MIN_VOTES_COUNT)"
                        }
                        Banner.shared.present(shouldDismissAfter: 2, delegate: self)
                        isMinVotesBannerShown = true
                        actionButton.animateIconChange(toCategory: Icon.Category.Error)
                    }
                    UIView.animate(withDuration: 0.3) {
                        self.actionButton.color = K_COLOR_GRAY
                    }
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.actionButton.color = self.color
                    }
                    actionButton.animateIconChange(toCategory: Icon.Category.Next_RU)
                }
//                if cost != nil, !cost.isEmpty {
//                    self.cost.map {
//                        (_, value) in
//                        self.totalCost += value
//                    }
//                }
//                totalCost += votesCapacity
//                if AppData.shared.userProfile.balance < totalCost {//(self.votesCount + self.totalCost) {
////                    Banner.shared.contentType = .InsufficientBalance
////                    if let content = Banner.shared.content as? InsufficientBalance {
////                        content.balance = AppData.shared.userProfile.balance
////                    }
////                    Banner.shared.present()
//
//                    UIView.animate(withDuration: 0.3) {
//                        self.actionButton.color = K_COLOR_GRAY
//                    }
//                } else if totalCost == 0  {
//                    UIView.animate(withDuration: 0.3) {
//                        self.actionButton.color = K_COLOR_GRAY
//                    }
//                } else {
//                    Banner.shared.dismiss()
//                    UIView.animate(withDuration: 0.3) {
//                        self.actionButton.color = self.color
//                    }
//                }
            }
        }
    }
    var actionButtonWidthConstant: CGFloat = 100
    var lineWidth: CGFloat = 5 {
        didSet {
            if oldValue != lineWidth, actionButton != nil {
                actionButton.lineWidth = lineWidth
            }
        }
    }
    @IBOutlet weak var actionButton: CircleButton! {
        didSet {
            actionButton.lineWidth = lineWidth
            actionButton.state = .Off
            actionButton.category = .Crowd//.Text
            actionButton.color   = color//Colors.UpperButtons.Avocado
//            actionButton.text = "\(votesCapacity)"
            let tap = UITapGestureRecognizer(target: self, action: #selector(VotesCountViewController.actionButtonTapped))
            actionButton.addGestureRecognizer(tap)
        }
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if let text = sender.text, let intValue = Int(text) {
            votesCapacity = intValue
        } else {
            votesCapacity = 0
        }
    }
    @IBOutlet weak var votesCountTF: UITextField! {
        didSet {
            votesCountTF.text = "\(votesCapacity)"
        }
    }
    @IBOutlet weak var actionButtonWidth: NSLayoutConstraint! {
        didSet {
            actionButtonWidth.constant = actionButtonWidthConstant
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
            nc.duration = 0.3
            nc.transitionStyle = .Icon
            navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delay(seconds: 0.1) {
            self.votesCountTF.becomeFirstResponder()
        }
        actionButton.text = "\(votesCapacity)"
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.lineWidth = self.actionButton.bounds.height / 10
        }
        if let btn = self.navigationItem.rightBarButtonItem as? UIBarButtonItem {
            let v = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 27, height: 27)))
            v.accessibilityIdentifier = "sum"
            v.backgroundColor = .clear
            v.iconColor = .black//Colors.UpperButtons.VioletBlueCrayola
            v.category = .Info
            let tap = UITapGestureRecognizer(target: self, action: #selector(VotesCountViewController.viewTapped(recognizer:)))
            v.addGestureRecognizer(tap)
            btn.customView = v
            v.scaleMultiplicator = 1.5
            btn.customView?.alpha = 0
            btn.customView?.clipsToBounds = false
            btn.customView?.layer.masksToBounds = false
            btn.customView?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 2.5,
                options: [.curveEaseInOut],
                animations: {
                    btn.customView?.transform = .identity
                    btn.customView?.alpha = 1
            })
            self.navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    @objc private func actionButtonTapped() {
        if votesCapacity < MIN_VOTES_COUNT {
            Banner.shared.contentType = .Warning
            if let content = Banner.shared.content as? Warning {
                content.level = .Warning
                content.text = "Минимальное число участников не менее \(MIN_VOTES_COUNT)"
            }
            Banner.shared.present(shouldDismissAfter: 2, delegate: self)
//            showAlert(type: .Warning, buttons: [["Хорошо": [.Ok: {self.votesCountTF.becomeFirstResponder()}]]], text: "Минимальное число участников - \(MIN_VOTES_COUNT)")
        } else if votesCapacity > MAX_VOTES_COUNT {
            Banner.shared.contentType = .Warning
            if let content = Banner.shared.content as? Warning {
                content.level = .Warning
                content.text = "Максимальное число участников не более \(MAX_VOTES_COUNT)"
            }
            Banner.shared.present(shouldDismissAfter: 2, delegate: self)
//            showAlert(type: .Warning, buttons: [["Хорошо": [.Ok: {self.votesCountTF.becomeFirstResponder()}]]], text: "Максимально возможное количество голосов - \(MAX_VOTES_COUNT)")
        } else {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                self.actionButton.transform = .identity
            }) {
                _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func viewTapped(recognizer: UITapGestureRecognizer) {
        if let v = recognizer.view, v.accessibilityIdentifier == "sum" {
            Banner.shared.contentType = .Sum
            if let content = Banner.shared.content as? VotesFormula {
//                content.backgroundColor = Colors.UpperButtons.Avocado
                content.icon.backgroundColor = Colors.Banner.Info
                content.icon.category = .Info
                
                content.votes = votesCapacity
//                content.price = PriceList.shared.vote
            }
            Banner.shared.present(shouldDismissAfter: 5, delegate: self)
        }
    }
}

extension VotesCountViewController: CallbackDelegate {
    func callbackReceived(_ sender: Any) {
        if let identifier = sender as? String {
            if identifier == Banner.bannerWillAppearSignal {
                self.view.endEditing(true)
            } else if identifier == Banner.bannerDidDisappearSignal {
                self.votesCountTF.becomeFirstResponder()
            }
        }
    }
}
