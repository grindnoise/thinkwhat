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
            isAnimationStopped = true
            category = nil
            backButton.color = parentCategory?.tagColor
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                self.view.setNeedsLayout()
                self.backButtonConstraint.constant = self.parentCategory == nil ? self.hiddenConstraintConstant : self.initialConstraintConstant
                self.view.layoutIfNeeded()
                self.backButton.transform = self.parentCategory == nil ? CGAffineTransform(scaleX: 0.7, y: 0.7) : CGAffineTransform.identity
                self.backButton.alpha = self.parentCategory == nil ? 0 : 1
            })
            dataSource = SurveyCategories.shared.categories.filter { $0.parent == parentCategory }
        }
    }
    
//    var delegate: CallbackDelegate?
    var isModified = false
    var category: SurveyCategory? {
        didSet {
            if actionButton != nil {
                if category != nil {
                    if actionButton.tagColor != K_COLOR_RED {
                        actionButton.tagColor = K_COLOR_RED
                    }
                    actionButton.isUserInteractionEnabled = true
                    if !isAnimating {
                        isAnimationStopped = false
                        actionButton.text = "OK"
//                        let anim = animateTransformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, delegate: self as CAAnimationDelegate)
//                        anim.setValue(actionButton, forKey: "btn")
//                        actionButton.layer.add(anim, forKey: nil)
                        groupAnim.setValue(actionButton, forKey: "btn")
                        actionButton.layer.add(groupAnim, forKey: nil)
                        isAnimating = true
                    }
                } else {
                    actionButton.isUserInteractionEnabled = false
                    actionButton.tagColor = K_COLOR_GRAY
                    isAnimationStopped = true
                    actionButton.text = "?"
                    actionButton.categoryID = .Text
                }
            }
        }
    }
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
    private var isAnimationStopped = false
    private var isAnimating = false
    private var initialConstraintConstant: CGFloat = 0//When backButton is on the screen
    private var hiddenConstraintConstant: CGFloat = 0//When backButton is out of the screen
    private var finalShadowPath: CGPath!
    private var initialShadowPath: CGPath!
    private var scaleAnim: CABasicAnimation!
    private var shadowPathAnim: CABasicAnimation!
    private var groupAnim: CAAnimationGroup!
    @IBOutlet weak var upperContainer: UIView!
    @IBOutlet weak var actionButton: SurveyCategoryIcon! {
        didSet {
            actionButton.isUserInteractionEnabled = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(CategorySelectionViewController.okButtonTapped))
            actionButton.addGestureRecognizer(tap)
            actionButton.tagColor = K_COLOR_GRAY
            actionButton.text = "?"
            actionButton.categoryID = .Text
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
            nc.duration = 0.25
            nc.transitionStyle = .Icon
        }
        
        if !isViewSetupCompleted {
            DispatchQueue.main.async {
                self.actionButton.setNeedsLayout()
                self.actionButton.layoutIfNeeded()
                self.actionButton.layer.shadowColor = K_COLOR_GRAY.withAlphaComponent(0.3).cgColor
                let delta = self.actionButton.bounds.width - self.actionButton.bounds.width / 1.15
                self.initialShadowPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: self.actionButton.bounds.origin.x + delta/2, y: self.actionButton.bounds.origin.y + delta/2), size: CGSize(width: self.actionButton.bounds.width - delta, height: self.actionButton.bounds.height - delta))).cgPath
                self.finalShadowPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: self.actionButton.bounds.origin.x - delta/2, y: self.actionButton.bounds.origin.y - delta/2), size: CGSize(width: self.actionButton.bounds.width + delta, height: self.actionButton.bounds.height + delta))).cgPath//UIBezierPath(ovalIn: self.actionButton.bounds).cgPath
                self.actionButton.layer.shadowPath = self.initialShadowPath
                self.actionButton.layer.shadowRadius = 5
                self.actionButton.layer.shadowOffset = .zero
                self.actionButton.layer.shadowOpacity = 1
                self.actionButton.layer.masksToBounds = false
            }
            navigationItem.setHidesBackButton(true, animated: false)
            containerBg.setNeedsLayout()
            containerBg.layoutIfNeeded()
            containerBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            containerBg.layer.shadowPath = UIBezierPath(roundedRect: containerBg.bounds, cornerRadius: 15).cgPath
            containerBg.layer.shadowRadius = 7
            containerBg.layer.shadowOffset = .zero
            containerBg.layer.shadowOpacity = 1
            containerBg.layer.masksToBounds = false
            backButtonBg.setNeedsLayout()
            backButtonBg.layoutIfNeeded()
//            backButtonFg.setNeedsLayout()
//            backButtonFg.layoutIfNeeded()
            backButtonFg.layer.cornerRadius = backButtonFg.frame.height / 2
            backButtonBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            backButtonBg.layer.shadowPath = UIBezierPath(roundedRect: backButtonBg.bounds, cornerRadius: 15).cgPath
            backButtonBg.layer.shadowRadius = 7
            backButtonBg.layer.shadowOffset = .zero
            backButtonBg.layer.shadowOpacity = 1
            backButtonBg.layer.masksToBounds = false
            initialConstraintConstant = backButtonConstraint.constant
            hiddenConstraintConstant = backButtonConstraint.constant - (initialConstraintConstant * 1.2 + backButtonBg.frame.width)
            backButtonBg.setNeedsLayout()
            backButtonConstraint.constant = hiddenConstraintConstant
            backButtonBg.layoutIfNeeded()
            
            isViewSetupCompleted = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if scaleAnim == nil {
            scaleAnim = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.6, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.linear.rawValue, delegate: nil)
        }
        if shadowPathAnim == nil {
            shadowPathAnim = animateShadowPath(fromValue: initialShadowPath, toValue: finalShadowPath, duration: 0.6, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.linear.rawValue, delegate: nil)
        }
        if groupAnim == nil {
            groupAnim = joinAnimations(animations: [scaleAnim, shadowPathAnim], repeatCount: 0, autoreverses: true, duration: 0.6, timingFunction: CAMediaTimingFunctionName.linear.rawValue, delegate: self)
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        isAnimationStopped = true
    }
    
//    fileprivate func animateShadow(_ isShadowed: Bool) {
//        if NSNumber(value: upperContainer.layer.shadowOpacity).boolValue != isShadowed {
//            print("anim")
//            let anim = CABasicAnimation(keyPath: "shadowOpacity")
//            anim.fromValue = isShadowed ? 0 : 1
//            anim.toValue = isShadowed ? 1 : 0
//            anim.duration = 0.2
//            anim.isRemovedOnCompletion = false
//            upperContainer.layer.add(anim, forKey: anim.keyPath)
//            upperContainer.layer.shadowOpacity = isShadowed ? 1 : 0
//        }
//    }
    
    @objc fileprivate func backButtonTapped() {
        parentCategory = nil
    }
    
    @objc fileprivate func okButtonTapped() {
        isModified = true
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
        isAnimating = false
        if !isAnimationStopped, let btn = anim.value(forKey: "btn") as? SurveyCategoryIcon {
//            let _anim = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.5, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeInEaseOut.rawValue, delegate: self as CAAnimationDelegate)
//            _anim.setValue(btn, forKey: "btn")
//            btn.layer.add(_anim, forKey: nil)
            groupAnim.setValue(btn, forKey: "btn")
            btn.layer.add(groupAnim, forKey: nil)
            isAnimating = true
        }
    }
}





//
//class CategorySelectionViewController: UIViewController {
//
//    class var subcategoryNib: UINib {
//        return UINib(nibName: "SubcategorySelectionTableViewCell", bundle: nil)
//    }
//    class var categoryNib: UINib {
//        return UINib(nibName: "CategoryTableViewCell", bundle: nil)
//    }
//
//    @IBOutlet weak var selectButton: UIButton!
//    @IBOutlet weak var tableView: UITableView!
//    @IBAction func selectTapped(_ sender: Any) {
//        if delegate != nil {
//            delegate!.category = category
//            if let cell = delegate?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CategorySelectionCell {
//                cell.categoryTitle.text = category?.title
//            }
//            //delegate?.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .none)//reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
//            navigationController?.popViewController(animated: true)
//        }
//    }
//
//    fileprivate var isViewSetupCompleted = false
//    var delegate: NewSurveyViewController?
//    var category: SurveyCategory? {
//        didSet {
//            if category != nil, selectButton != nil {
//                UIView.animate(withDuration: 0.2) {
//                    self.selectButton.backgroundColor = K_COLOR_RED
//                }
//            }
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self as UITableViewDelegate
//        tableView.dataSource = self
//        tableView.register(CategorySelectionViewController.subcategoryNib, forCellReuseIdentifier: "subcategoryCell")
//        tableView.register(CategorySelectionViewController.categoryNib, forCellReuseIdentifier: "categoryCell")
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        if !isViewSetupCompleted {
//            self.view.setNeedsLayout()
//            self.view.layoutIfNeeded()
//            isViewSetupCompleted = true
//            self.selectButton.layer.cornerRadius = self.selectButton.frame.height / 2
//        }
//        if category == nil {
//            selectButton.backgroundColor = K_COLOR_GRAY
//        }
//    }
//}
//
//extension CategorySelectionViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return SurveyCategories.shared.tree[section].first!.value.count
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return SurveyCategories.shared.tree[section].first?.key
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "subcategoryCell", for: indexPath) as? SubcategorySelectionTableViewCell {
//            cell.title.text = SurveyCategories.shared.tree[indexPath.section].first?.value[indexPath.row].title.lowercased()//
//            cell.category = SurveyCategories.shared.tree[indexPath.section].first?.value[indexPath.row]
//            cell.isMarked = cell.category == category
//            if (indexPath.row % 2 == 0) {
//                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
//            } else {
//                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
//            }
//            return cell
//        }
//        return UITableViewCell()
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return SurveyCategories.shared.tree.count
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as? CategoryTableViewCell {
//            cell.title.text = SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.title.uppercased()
//            cell.backgroundColor = SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.tagColor ?? UIColor.gray
//            cell.total.text = "всего " + (SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.total.stringValue!)!
//            cell.active.text = "активных " + (SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.active.stringValue!)!
//            return cell
//        }
//        return nil
//    }
//
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as? CategoryTableViewCell {
//            return cell.contentView.frame.height
//        }
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 35
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) as? SubcategorySelectionTableViewCell {
//            if !cell.isMarked {
//                cell.isMarked = true
//                category = cell.category
//                for c in tableView.visibleCells {
//                    if let _cell = c as? SubcategorySelectionTableViewCell, _cell.isMarked, _cell != cell {
//                        _cell.isMarked = false
//                    }
//                }
//            }
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
