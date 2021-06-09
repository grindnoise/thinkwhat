//
//  AnonimitySelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class BinarySelectionViewController: UIViewController {
    
    deinit {
        print("***BinarySelectionViewController deinit***")
    }

    enum SelectionType {
        case Anonimity, Privacy
    }
    var selectionType: SelectionType = .Anonimity {
        didSet {
            enabledString   = selectionType == .Anonimity ? "Вы будете скрыты от пользователей на протяжении всего времени существования опроса" : "Доступ к опросу осуществляется только по ссылке"
            disabledString  = selectionType == .Anonimity ? "Вы будете видны пользователям" : "Опрос доступен всем пользователям"
        }
    }
    var delegate: CallbackDelegate?
    private var enabledString = ""
    private var disabledString = ""
    private var isSelected = false
    private var isFirstSelection = true
    var isAnimationStopped = false
    var isEnabled: Bool?
    var color: UIColor!
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
            actionButton.text = "?"
            actionButton.color = K_COLOR_GRAY
            actionButton.category = .Ready_RU
            let tap = UITapGestureRecognizer(target: self, action: #selector(BinarySelectionViewController.okButtonTapped))
            actionButton.addGestureRecognizer(tap)
            actionButton.isUserInteractionEnabled = false
            actionButton.oval.strokeStart = 1
        }
    }
    @IBOutlet weak var enabledIcon: SurveyCategoryIcon! {
        didSet {
            enabledIcon.backgroundColor = UIColor.clear
            enabledIcon.iconColor       = UIColor.lightGray.withAlphaComponent(0.75)
            switch selectionType {
            case .Anonimity:
                enabledIcon.category = .Anon
            case .Privacy:
                enabledIcon.category = .Locked
            }
        }
    }
    @IBOutlet weak var enabledLabel: UILabel! {
        didSet {
            enabledLabel.text = selectionType == .Anonimity ? "Скрыт" : "Приватный"
        }
    }
    @IBOutlet weak var disabledIcon: SurveyCategoryIcon! {
        didSet {
            disabledIcon.backgroundColor = UIColor.clear
            disabledIcon.iconColor       = UIColor.lightGray.withAlphaComponent(0.75)
            switch selectionType {
            case .Anonimity:
                disabledIcon.category        = .AnonDisabled
            case .Privacy:
                disabledIcon.category        = .Unlocked
            }
        }
    }
    @IBOutlet weak var enabledBg: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(BinarySelectionViewController.iconTapped(gesture:)))
            enabledBg.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var disabledLabel: UILabel! {
        didSet {
            disabledLabel.text = selectionType == .Anonimity ? "Виден" : "Публичный"
        }
    }
    @IBOutlet weak var disabledBg: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(BinarySelectionViewController.iconTapped(gesture:)))
            disabledBg.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
            nc.duration = 0.5
            nc.transitionStyle = .Icon
            navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.leftConstraint.constant -= (self.enabledBg.frame.width) + self.enabledBg.frame.origin.x
            self.rightConstraint.constant += (self.disabledBg.frame.width) + (self.view.frame.width - self.disabledBg.frame.origin.x)
            self.lineWidth = self.actionButton.bounds.height / 10
        }
        
        title = selectionType == .Anonimity ? "Анонимность" : "Доступность"
    }
    
    @objc fileprivate func okButtonTapped() {
        isAnimationStopped = true
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func iconTapped(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let v = gesture.view {
         
            actionButton.isUserInteractionEnabled = true
            let selectedView: UIView! = v == enabledBg ? enabledBg : disabledBg
            let deselectedView: UIView! = v != enabledBg ? enabledBg : disabledBg
            
            if isEnabled != nil, (isEnabled! && v == enabledBg) || (!isEnabled! && v == disabledBg) { return }
            
            if let selectedIcon = selectedView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let deselectedIcon = deselectedView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon {
                let enableAnim = Animations.get(property: .FillColor,
                                                fromValue: selectedIcon.iconColor.cgColor,
                                                toValue: UIColor.black.cgColor,
                                                duration: 0.3,
                                                timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                delegate: nil,
                                                isRemovedOnCompletion: false)
                let disableAnim = Animations.get(property: .FillColor,
                                                 fromValue: UIColor.black.cgColor,
                                                 toValue: deselectedIcon.iconColor.cgColor,
                                                 duration: 0.3,
                                                 timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                 delegate: nil,
                                                 isRemovedOnCompletion: false)
                selectedIcon.icon.add(enableAnim, forKey: nil)
                
                if !isFirstSelection { deselectedIcon.icon.add(disableAnim, forKey: nil) }
            }

            if !isSelected {
                isSelected = true
                actionButton.animateIconChange(toCategory: SurveyCategoryIcon.Category.Next_RU)
                UIView.animate(withDuration: 0.15, animations: {
                    self.actionButton.color = K_COLOR_RED
                }) {
                    _ in
                    self.actionButton.bounce(animationDelegate: self)
                }
            }
            
            UIView.transition(with: descriptionLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.descriptionLabel.text = v == self.enabledBg ? self.enabledString : self.disabledString
            })

            isEnabled = v == enabledBg ? true : false
            isFirstSelection = false
        }
    }
    
    private func setShadow(subview: UIView, on: Bool) {
        CATransaction.begin()
        let anim = CABasicAnimation(keyPath: "shadowOpacity")
        anim.fromValue = on ? 0 : 1
        anim.toValue = on ? 1 :0
        anim.duration = 0.2
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        anim.isRemovedOnCompletion = false
        subview.layer.add(anim, forKey: "shadowOpacity")
        CATransaction.commit()
        subview.layer.shadowOpacity = on ? 1 : 0
    }
}

extension BinarySelectionViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !isAnimationStopped {
            actionButton.layer.removeAllAnimations()
            actionButton.bounce(animationDelegate: self)
        } else {
            actionButton.scaleColorAnim = nil
        }
    }
}
