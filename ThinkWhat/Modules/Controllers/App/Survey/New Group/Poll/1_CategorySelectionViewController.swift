//
//  CategorySelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.02.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CategorySelectionViewController: UIViewController {

    deinit {
        print("***CategorySelectionViewController deinit***")
    }
    
    let categoryVC: CategoryCollectionViewController = {
        return Storyboards.controllers.instantiateViewController(withIdentifier: "CategoryCollectionViewController") as! CategoryCollectionViewController
    } ()
    private var parentCategory: Topic? {
        didSet {
            category = nil
//            backButton.color = parentCategory?.tagColor
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                self.view.setNeedsLayout()
                self.backButtonConstraint.constant = self.parentCategory == nil ? self.hiddenConstraintConstant : self.initialConstraintConstant
                self.view.layoutIfNeeded()
                self.backButton.alpha = self.parentCategory == nil ? 0 : 1
            })
            dataSource = Topics.shared.all.filter { $0.parent == parentCategory }
        }
    }
    
//    var lineWidth: CGFloat = 5 {
//        didSet {
//            if oldValue != lineWidth, actionButton != nil {
//                actionButton.lineWidth = lineWidth
//            }
//        }
//    }
    var isAnimationStopped = false
    var category: Topic? {
        didSet {
            if actionButton != nil {
                if category != nil, oldValue == nil {
                    
                    isAnimationStopped = false
                    
                    actionButton.animateIconChange(toCategory: Icon.Category.Next_RU)
                    
                    UIView.animate(withDuration: 0.15, animations: {
                        self.actionButton.icon.backgroundColor = K_COLOR_RED
                    }) {
                        _ in
                        self.actionButton.bounce(animationDelegate: self)
                    }
                    self.actionButton.isUserInteractionEnabled = true
                    
                } else if category == nil, oldValue != nil {
                    actionButton.animateIconChange(toCategory: Icon.Category.Choose_RU)
                    isAnimationStopped = true
                    self.actionButton.isUserInteractionEnabled = false
                }
            }
        }
    }
    var actionButtonHeight: CGFloat = 0
    private var dataSource: [Topic]! {
        didSet {
            if oldValue != dataSource {
                categoryVC.categories = dataSource
                categoryVC.childColor = parentCategory?.tagColor
                categoryVC.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
            }
        }
    }
    private var isViewSetupCompleted = false
    private var initialConstraintConstant: CGFloat = 0//When backButton is on the screen
    private var hiddenConstraintConstant: CGFloat = 0//When backButton is out of the screen
    @IBOutlet weak var actionButton: CircleButton! {
        didSet {
            actionButton.oval.opacity = 0
            actionButton.contentView.backgroundColor = .clear
//            actionButton.lineWidth = lineWidth
            actionButton.isUserInteractionEnabled = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(CategorySelectionViewController.okButtonTapped))
            actionButton.addGestureRecognizer(tap)
            actionButton.state = .On
            actionButton.color = K_COLOR_GRAY
            actionButton.category = .Category_RU
            actionButton.oval.strokeStart = 1
        }
    }
    @IBOutlet weak var containerBg: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var backButtonBg: UIView!
    @IBOutlet weak var backButtonFg: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CategorySelectionViewController.backButtonTapped))
            backButton.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var backButton: BackRoundedButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CategorySelectionViewController.backButtonTapped))
            backButton.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var backButtonConstraint: NSLayoutConstraint!
//    @IBOutlet weak var actionButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryVC.delegate = self
        categoryVC.selectionMode = true
        categoryVC.categories = Topics.shared.all.filter { $0.parent == parentCategory }
        categoryVC.view.addEquallyTo(to: container)
        addChild(self.categoryVC)
        categoryVC.didMove(toParent: self)
        categoryVC.needsAnimation = false
//        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if let nc = navigationController as? NavigationControllerPreloaded {
//            nc.isShadowed = false
//            nc.duration = 0.3
//            nc.transitionStyle = .Icon
//        }
        
        if !isViewSetupCompleted {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            containerTopConstraint.constant += containerBg.frame.height
            navigationItem.setHidesBackButton(true, animated: false)
            containerBg.setNeedsLayout()
            containerBg.layoutIfNeeded()
            containerBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor//UIColor.lightGray.withAlphaComponent(0.6).cgColor
            containerBg.layer.shadowPath = UIBezierPath(roundedRect: containerBg.bounds, cornerRadius: 20).cgPath
            containerBg.layer.shadowRadius = 7
            containerBg.layer.shadowOffset = .zero
            containerBg.layer.shadowOpacity = 1
            containerBg.layer.masksToBounds = false
            backButtonBg.setNeedsLayout()
            backButtonBg.layoutIfNeeded()
            backButtonFg.layer.cornerRadius = backButtonFg.frame.height / 2
            backButtonBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor//UIColor.lightGray.withAlphaComponent(0.6).cgColor
            backButtonBg.layer.shadowPath = UIBezierPath(roundedRect: backButtonBg.bounds, cornerRadius: 20).cgPath
            backButtonBg.layer.shadowRadius = 7
            backButtonBg.layer.shadowOffset = .zero
            backButtonBg.layer.shadowOpacity = 1
            backButtonBg.layer.masksToBounds = false
            initialConstraintConstant   = backButtonConstraint.constant
            hiddenConstraintConstant    = -(initialConstraintConstant + backButtonBg.frame.width)//backButtonConstraint.constant + (initialConstraintConstant * 1.5 + backButtonBg.frame.width * 2)
            backButtonBg.setNeedsLayout()
            backButtonConstraint.constant = hiddenConstraintConstant
            backButtonBg.layoutIfNeeded()
            actionButton.setNeedsLayout()
//            actionButtonConstraint.constant = actionButtonHeight
            actionButton.layoutIfNeeded()
            
            isViewSetupCompleted = true
//            lineWidth = actionButton.bounds.height / 10
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        navigationController?.popViewController(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.4,
            options: [.curveEaseInOut],
            animations: {
                self.view.setNeedsLayout()
                self.backButtonConstraint.constant = self.hiddenConstraintConstant
                self.view.layoutIfNeeded()
                self.backButton.alpha = 0
        })
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        actionButton.removeFromSuperview()
//    }
    
    @objc fileprivate func backButtonTapped() {
        parentCategory = nil
    }
    
    @objc fileprivate func okButtonTapped() {
        isAnimationStopped = true
//        actionButton.layer.removeAllAnimations()
        navigationController?.popViewController(animated: true)
    }
}

extension CategorySelectionViewController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let _category = sender as? Topic {
            if _category.isParentNode {
                category = _category
            } else if parentCategory == nil {
                parentCategory = _category
            } else {
                category = _category
            }
        }
    }
}

extension CategorySelectionViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        actionButton.layer.removeAllAnimations()
        if !isAnimationStopped {
            actionButton.layer.removeAllAnimations()
            actionButton.bounce(animationDelegate: self)
        } else {
            actionButton.scaleColorAnim = nil
            UIView.animate(withDuration: 0.25) {
                self.actionButton.icon.backgroundColor = K_COLOR_GRAY
            }
        }
    }
}
