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

    
    var color: UIColor!
    var votesCount = 100 {
        didSet {
            if votesCount != oldValue {
                if votesCount == 0 {
                    actionButton.color = K_COLOR_GRAY
                    actionButton.text = "\(votesCount)"
                    actionButton.isUserInteractionEnabled = false
                } else {
                    if actionButton != nil {
                        actionButton.text = "\(votesCount)"
                        actionButton.color = color//Colors.UpperButtons.Avocado
                        actionButton.isUserInteractionEnabled = true
                    }
                }
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
            actionButton.category = .Text
            actionButton.color   = color//Colors.UpperButtons.Avocado
            actionButton.text = "\(votesCount)"
            let tap = UITapGestureRecognizer(target: self, action: #selector(VotesCountViewController.actionButtonTapped))
            actionButton.addGestureRecognizer(tap)
        }
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if let text = sender.text, let intValue = Int(text) {
            votesCount = intValue
        } else {
            votesCount = 0
        }
    }
    @IBOutlet weak var votesCountTF: UITextField! {
        didSet {
            votesCountTF.text = "\(votesCount)"
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
            nc.duration = 0.55
            nc.transitionStyle = .Icon
            navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        delay(seconds: 0.1) {
            self.votesCountTF.becomeFirstResponder()
        }
        
        DispatchQueue.main.async {
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.lineWidth = self.actionButton.bounds.height / 10
            
        }
        
    }
    
    @objc fileprivate func actionButtonTapped() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
            self.actionButton.transform = .identity
        }) {
            _ in
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}
