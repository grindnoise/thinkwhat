//
//  CategorySelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.02.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CategorySelectionViewController: UIViewController {

    let categoryVC: CategoryCollectionViewController = {
        return Storyboards.controllers.instantiateViewController(withIdentifier: "CategoryCollectionViewController") as! CategoryCollectionViewController
    } ()
    private var parentCategory: SurveyCategory? {
        didSet {
            category = nil
//            backButton.color = parentCategory?.tagColor
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                self.view.setNeedsLayout()
                self.backButtonConstraint.constant = self.parentCategory == nil ? self.hiddenConstraintConstant : self.initialConstraintConstant
                self.view.layoutIfNeeded()
                self.backButton.alpha = self.parentCategory == nil ? 0 : 1
            })
            dataSource = SurveyCategories.shared.categories.filter { $0.parent == parentCategory }
        }
    }
    
    var lineWidth: CGFloat = 5 {
        didSet {
            if oldValue != lineWidth, actionButton != nil {
                actionButton.lineWidth = lineWidth
            }
        }
    }
    var isAnimationStopped = false
    var category: SurveyCategory? {
        didSet {
            if actionButton != nil {
                if category != nil, oldValue == nil {
                    
                    isAnimationStopped = false
                    
                    actionButton.animateIconChange(toCategory: SurveyCategoryIcon.Category.Next_RU)
                    
                    UIView.animate(withDuration: 0.15, animations: {
                        self.actionButton.icon.backgroundColor = K_COLOR_RED
                    }) {
                        _ in
                        self.actionButton.setNext(animationDelegate: self)
                    }
                    self.actionButton.isUserInteractionEnabled = true
                    
                } else if category == nil, oldValue != nil {
                    
                    actionButton.animateIconChange(toCategory: SurveyCategoryIcon.Category.Choose_RU)
                    
                    isAnimationStopped = true
                    self.actionButton.isUserInteractionEnabled = false
                }
            }
        }
    }
    var actionButtonHeight: CGFloat = 0
    private var dataSource: [SurveyCategory]! {
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
            actionButton.lineWidth = lineWidth
            actionButton.isUserInteractionEnabled = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(CategorySelectionViewController.okButtonTapped))
            actionButton.addGestureRecognizer(tap)
            actionButton.state = .On
            actionButton.color = K_COLOR_GRAY
            actionButton.text = "РАЗДЕЛ"
            actionButton.category = .Ready_RU
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
        categoryVC.categories = SurveyCategories.shared.categories.filter { $0.parent == parentCategory }
        categoryVC.view.addEquallyTo(to: container)
        addChild(self.categoryVC)
        categoryVC.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
            nc.duration = 0.4
            nc.transitionStyle = .Icon
        }
        
        if !isViewSetupCompleted {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            containerTopConstraint.constant += containerBg.frame.height
            navigationItem.setHidesBackButton(true, animated: false)
            containerBg.setNeedsLayout()
            containerBg.layoutIfNeeded()
            containerBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            containerBg.layer.shadowPath = UIBezierPath(roundedRect: containerBg.bounds, cornerRadius: 20).cgPath
            containerBg.layer.shadowRadius = 7
            containerBg.layer.shadowOffset = .zero
            containerBg.layer.shadowOpacity = 1
            containerBg.layer.masksToBounds = false
            backButtonBg.setNeedsLayout()
            backButtonBg.layoutIfNeeded()
            backButtonFg.layer.cornerRadius = backButtonFg.frame.height / 2
            backButtonBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
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
            lineWidth = actionButton.bounds.height / 10
        }
    }
    
    @objc fileprivate func backButtonTapped() {
        parentCategory = nil
    }
    
    @objc fileprivate func okButtonTapped() {
        isAnimationStopped = true
        navigationController?.popViewController(animated: true)
    }
}

extension CategorySelectionViewController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if let _category = sender as? SurveyCategory {
            if _category.hasNoChildren {
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
        if !isAnimationStopped {
            actionButton.setNext(animationDelegate: self)
        } else {
            UIView.animate(withDuration: 0.25) {
                self.actionButton.icon.backgroundColor = K_COLOR_GRAY
            }
        }
    }
}
