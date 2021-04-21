//
//  PrivacySelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.11.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class PrivacySelectionViewController: UIViewController {

    var delegate: CallbackDelegate?
    private let privacyEnabledDescription = "Опроса не в общем доступе, просмотр и голосование только по приглашению"
    private let privacyDisabledDescription = "Опрос публичный, голосовать могут все"
    private var isSelected = false
    var color: UIColor!
    var isPrivate: Bool?
    var lineWidth: CGFloat = 5 {
        didSet {
            if oldValue != lineWidth, actionButton != nil {
                actionButton.lineWidth = lineWidth
            }
        }
    }
    private var isFirstSelection = true

    @IBOutlet weak var actionButton: CircleButton! {
        didSet {
            actionButton.lineWidth = lineWidth
            actionButton.state = .On
            actionButton.text = "?"
            actionButton.color = K_COLOR_GRAY
            actionButton.category = .Ready_RU
            let tap = UITapGestureRecognizer(target: self, action: #selector(PrivacySelectionViewController.okButtonTapped))
            actionButton.addGestureRecognizer(tap)
            actionButton.isUserInteractionEnabled = false
            actionButton.oval.strokeStart = 1
        }
    }
    @IBOutlet weak var enabledIcon: SurveyCategoryIcon! {
        didSet {
            enabledIcon.backgroundColor = UIColor.lightGray
            enabledIcon.category    = .Anon
        }
    }
    @IBOutlet weak var disabledIcon: SurveyCategoryIcon! {
        didSet {
            disabledIcon.backgroundColor = UIColor.lightGray
            disabledIcon.category        = .AnonDisabled
        }
    }
    @IBOutlet weak var enabledBg: UIView!
    @IBOutlet weak var enabledFg: UIView! {
        didSet {
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = color.withAlphaComponent(0.2).cgColor
            shapeLayer.setValue(true, forKey: "isCircle")
            enabledFg.layer.insertSublayer(shapeLayer, at: 0)
            let tap = UITapGestureRecognizer(target: self, action: #selector(PrivacySelectionViewController.iconTapped(gesture:)))
            enabledFg.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var disabledBg: UIView!
    @IBOutlet weak var disabledFg: UIView! {
        didSet {
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = color.withAlphaComponent(0.2).cgColor
            shapeLayer.setValue(true, forKey: "isCircle")
            disabledFg.layer.insertSublayer(shapeLayer, at: 0)
            let tap = UITapGestureRecognizer(target: self, action: #selector(PrivacySelectionViewController.iconTapped(gesture:)))
            disabledFg.addGestureRecognizer(tap)
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
        }
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        leftConstraint.constant -= (disabledBg.frame.width + disabledBg.frame.origin.x)
        rightConstraint.constant += (enabledBg.frame.width) + (self.view.frame.width - enabledBg.frame.origin.x)
        
        enabledFg.cornerRadius = enabledFg.frame.width * 0.2
        disabledFg.cornerRadius = disabledFg.frame.width * 0.2
        
        lineWidth = actionButton.bounds.height / 10
//        DispatchQueue.main.async {
//            self.enabledBg.setNeedsLayout()
//            self.enabledBg.layoutIfNeeded()
//            self.enabledBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
//            self.enabledBg.layer.shadowPath = UIBezierPath(roundedRect: self.enabledBg.bounds, cornerRadius: 10).cgPath
//            self.enabledBg.layer.shadowRadius = 15
//            self.enabledBg.layer.shadowOffset = .zero
//            self.enabledBg.layer.shadowOpacity = 0
//            self.enabledBg.layer.masksToBounds = false
////            self.enabledBg.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        }
//
//        disabledBg.setNeedsLayout()
//        disabledBg.layoutIfNeeded()
//        disabledBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
//        disabledBg.layer.shadowPath = UIBezierPath(roundedRect: disabledBg.bounds, cornerRadius: 10).cgPath
//        disabledBg.layer.shadowRadius = 15
//        disabledBg.layer.shadowOffset = .zero
//        disabledBg.layer.shadowOpacity = 0
//        disabledBg.layer.masksToBounds = false
////        disabledBg.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
  
    @objc fileprivate func okButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func iconTapped(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let v = gesture.view {
            actionButton.isUserInteractionEnabled = true
            let selectedView: UIView! = v == enabledFg ? enabledFg : disabledFg
            let deselectedView: UIView! = v != enabledFg ? enabledFg : disabledFg
            
            if isPrivate != nil, (isPrivate! && v == enabledFg) || (!isPrivate! && v == disabledFg) {
                return
            }
            
            if let enabled = selectedView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let disabled = deselectedView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
                    disabled.backgroundColor = UIColor.lightGray
                    enabled.backgroundColor = self.color
                })
            }
            
            if !isSelected {
                isSelected = true
                actionButton.addEnableAnimation()
                UIView.animate(withDuration: 0.5) {
                    self.actionButton.color = K_COLOR_RED
                }
            }
            
            UIView.transition(with: descriptionLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.descriptionLabel.text = v == self.enabledFg ? self.privacyEnabledDescription : self.privacyDisabledDescription
            })
            
            if let revealLayer = selectedView.layer.sublayers?.filter({ $0.value(forKey: "isCircle") as? Bool == true }).first as? CAShapeLayer, let hideLayer = deselectedView.layer.sublayers?.filter({ $0.value(forKey: "isCircle") as? Bool == true }).first as? CAShapeLayer {
                selectedView.animateCircleLayer(shapeLayer: revealLayer, reveal: true, duration: 0.3, completionBlocks: [], completionDelegate: nil)
                if !isFirstSelection { deselectedView.animateCircleLayer(shapeLayer: hideLayer, reveal: false, duration: 0.3, completionBlocks: [], completionDelegate: nil) }
            }
            
            isFirstSelection = false
            isPrivate = v == enabledFg ? true : false
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
