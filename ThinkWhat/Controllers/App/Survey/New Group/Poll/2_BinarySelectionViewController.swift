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
        case Anonimity, Privacy, Comments, Hot
    }
    var selectionType: SelectionType = .Anonimity {
        didSet {
            switch selectionType {
            case .Anonimity:
                enabledString  = "Автор и респонденты будут скрыты"
                disabledString = "Автор и респонденты видны"
            case .Privacy:
                enabledString  = "Доступ к опросу осуществляется только по приглашению"
                disabledString = "Опрос доступен всем респондентам"
            case .Comments:
                enabledString  = "Респонденты могут оставлять комментарии"
                disabledString = "Комментарии запрещены"
            case .Hot:
                enabledString  = "Опрос попадет в хот-лист, набирайте ответы быстро"
                disabledString = "Опрос не попадет в хот-лист"
            }
        }
    }
    var cost: [String: Int]?
    var delegate: CallbackDelegate?
    private var enabledString = ""
    private var disabledString = ""
    private var isSelected = false
    private var isFirstSelection = true
    private var isBannerShown = false
    var isAnimationStopped = false
    var isEnabled: Bool? {
        didSet {
            if AppData.shared.system.newPollTutorialRequired, selectionType == .Hot, isEnabled == true, !isBannerShown {
                Banner.shared.contentType = .Warning
                if let content = Banner.shared.content as? Warning {
                    content.level = .Warning
                    content.text = "Платная опция, будет списано дополнительно \(PriceList.shared.hotPost) баллов"
                }
                Banner.shared.present(shouldDismissAfter: 3, delegate: nil)
                isBannerShown = true
            }
        }
    }
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
//            actionButton.lineWidth = lineWidth
            actionButton.state = .Off
//            actionButton.text = "?"
            actionButton.color = K_COLOR_GRAY
            switch selectionType {
            case .Anonimity:
                actionButton.category = .Anon
            case .Comments:
                actionButton.category = .Comment
            case .Hot:
                actionButton.category = .Rocket
            case .Privacy:
                actionButton.category = .Locked
            }
//            actionButton.category = .Ready_RU
            let tap = UITapGestureRecognizer(target: self, action: #selector(BinarySelectionViewController.okButtonTapped))
            actionButton.addGestureRecognizer(tap)
//            actionButton.isUserInteractionEnabled = false
            actionButton.oval.strokeStart = 1
        }
    }
    @IBOutlet weak var enabledIcon: SurveyCategoryIcon! {
        didSet {
//            enabledIcon.scaleMultiplicator = 0.55
            enabledIcon.backgroundColor = UIColor.clear
            enabledIcon.iconColor       = UIColor.lightGray.withAlphaComponent(0.75)
            switch selectionType {
            case .Anonimity:
                enabledIcon.category = AppData.shared.userProfile.gender == Gender.Female ? .GirlFaceHidden : .ManFaceHidden
//                enabledIcon.category = .Anon
            case .Privacy:
                enabledIcon.category = .Locked
            case .Comments:
                enabledIcon.category = .Comment
            case .Hot:
                enabledIcon.category = .Rocket
            }
        }
    }
    @IBOutlet weak var enabledLabel: UILabel! {
        didSet {
            switch selectionType {
            case .Anonimity:
                enabledLabel.text = "Включена"
            case .Privacy:
                enabledLabel.text = "Включена"
            case .Comments:
                enabledLabel.text = "Разрешены"
            case .Hot:
                enabledLabel.text = "Включен"
            }
        }
    }
    @IBOutlet weak var disabledIcon: SurveyCategoryIcon! {
        didSet {
//            disabledIcon.scaleMultiplicator = 0.55
            disabledIcon.backgroundColor = UIColor.clear
            disabledIcon.iconColor       = UIColor.lightGray.withAlphaComponent(0.75)
            switch selectionType {
            case .Anonimity:
                disabledIcon.category = AppData.shared.userProfile.gender == Gender.Female ? .GirlFace : .ManFace
//                disabledIcon.category = .AnonDisabled
            case .Privacy:
                disabledIcon.category = .Unlocked
            case .Comments:
                disabledIcon.category  = .CommentDisabled
            case .Hot:
                disabledIcon.category  = .RocketOff
            }
        }
    }
    @IBOutlet weak var enabledBg: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(BinarySelectionViewController.viewTapped(gesture:)))
            enabledBg.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var disabledLabel: UILabel! {
        didSet {
            switch selectionType {
            case .Anonimity:
                disabledLabel.text = "Выключена"
            case .Privacy:
                disabledLabel.text = "Выключена"
            case .Comments:
                disabledLabel.text = "Запрещены"
            case .Hot:
                disabledLabel.text = "Выключен"
            }
        }
    }
    @IBOutlet weak var disabledBg: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(BinarySelectionViewController.viewTapped(gesture:)))
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
            nc.duration = 0.4
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
        
        switch selectionType {
        case .Anonimity:
            title = "Анонимность"
        case .Privacy:
            title = "Приватность"
        case .Comments:
            title = "Комментарии"
        case .Hot:
            title = "Быстрый старт"
            if let btn = self.navigationItem.rightBarButtonItem as? UIBarButtonItem {
                let v = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: CGSize(width: 27, height: 27)))
                v.accessibilityIdentifier = "info"
                v.backgroundColor = .clear
                v.iconColor = .black//Colors.UpperButtons.VioletBlueCrayola
                v.category = .Info
                let tap = UITapGestureRecognizer(target: self, action: #selector(BinarySelectionViewController.viewTapped(gesture:)))
                v.addGestureRecognizer(tap)
                btn.customView = v
                v.scaleMultiplicator = 0.15
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
    }
    
    @objc fileprivate func okButtonTapped() {
        isAnimationStopped = true
        if !isSelected {
            Banner.shared.contentType = .Warning
            if let content = Banner.shared.content as? Warning {
                content.level = .Error
                content.text = "Необходимо выбрать опцию"
            }
            Banner.shared.present(shouldDismissAfter: 2, delegate: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc fileprivate func viewTapped(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let v = gesture.view {
            if v.accessibilityIdentifier == "info" {
                Banner.shared.contentType = .Warning
                if let content = Banner.shared.content as? Warning {
                    content.level = .Info
                    content.text = "Стоимость публикации в ленте горячих составляет \(PriceList.shared.hotPost) баллов"
                }
                Banner.shared.present(shouldDismissAfter: 2, delegate: nil)
                return
            }
         
            actionButton.isUserInteractionEnabled = true
            let selectedView: UIView! = v == enabledBg ? enabledBg : disabledBg
            let deselectedView: UIView! = v != enabledBg ? enabledBg : disabledBg
            
            if isEnabled != nil, (isEnabled! && v == enabledBg) || (!isEnabled! && v == disabledBg) { return }
            
            if let selectedIcon = selectedView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let deselectedIcon = deselectedView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let selectedLabel = selectedView.subviews.filter({ $0 is UILabel }).first as? UILabel, let deselectedLabel = deselectedView.subviews.filter({ $0 is UILabel }).first as? UILabel {
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
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 2.5,
                    options: [.curveEaseInOut],
                    animations: {
                        selectedIcon.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                        selectedLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                        selectedLabel.textColor = .black
                }) { _ in }
                if !isFirstSelection {
                    deselectedIcon.icon.add(disableAnim, forKey: nil)
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                        deselectedIcon.transform = .identity
                        deselectedLabel.transform = .identity
                        deselectedLabel.textColor = UIColor.lightGray.withAlphaComponent(0.75)
                    })
                }
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
