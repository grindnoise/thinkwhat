//
//  SubcategoryCollectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubcategoryViewController: UIViewController {

    weak var delegate: CallbackDelegate?
    var parentCategory: SurveyCategory!
    @IBOutlet weak var icon: Icon!
    @IBOutlet weak var upperContainer: UIView!
    @IBOutlet weak var container: UIView!
    fileprivate var categories: [SurveyCategory]!
    fileprivate let categoryVC: CategoryCollectionViewController = {
        return Storyboards.controllers.instantiateViewController(withIdentifier: "CategoryCollectionViewController") as! CategoryCollectionViewController
    } ()
    fileprivate var isViewSetupCompleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        container.alpha = 0
        categories = SurveyCategories.shared.categories.filter { $0.parent == parentCategory }.sorted { $0.total > $1.total }
        categoryVC.delegate = self
        categoryVC.categories = categories
        categoryVC.childColor = parentCategory.tagColor
        categoryVC.view.addEquallyTo(to: container)
        addChild(self.categoryVC)
        categoryVC.didMove(toParent: self)
        icon.backgroundColor = parentCategory.tagColor
        icon.category = Icon.Category(rawValue: parentCategory.ID) ?? .Null
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = true
            nc.duration = 0.3
            nc.transitionStyle = .Icon
        }
        let navTitle = UILabel()
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: parentCategory.title, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
        attrString.append(NSAttributedString(string: "\n(\(parentCategory.total))", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 9), foregroundColor: .gray, backgroundColor: .clear)))
        navTitle.attributedText = attrString
        navigationItem.titleView = navTitle
        
        if !isViewSetupCompleted {
            upperContainer.layer.shadowOpacity = 0
            upperContainer.layer.shadowColor = parentCategory.tagColor.withAlphaComponent(0.3).cgColor
            upperContainer.layer.shadowPath = UIBezierPath(rect: upperContainer.bounds).cgPath
            upperContainer.layer.masksToBounds = false
            upperContainer.layer.shadowRadius = 10
            upperContainer.layer.shadowOffset = .zero
            isViewSetupCompleted = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addChild(self.categoryVC)
        categoryVC.didMove(toParent: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.App.CategoryToSurveys, let destinationVC = segue.destination as? SurveysTableViewController, let category = sender as? SurveyCategory {
            destinationVC.category = category
        }
    }
    
    fileprivate func animateShadow(_ isShadowed: Bool) {
        if NSNumber(value: upperContainer.layer.shadowOpacity).boolValue != isShadowed {
            print("anim")
            let anim = CABasicAnimation(keyPath: "shadowOpacity")
            anim.fromValue = isShadowed ? 0 : 1
            anim.toValue = isShadowed ? 1 : 0
            anim.duration = 0.2
            anim.isRemovedOnCompletion = false
            upperContainer.layer.add(anim, forKey: anim.keyPath)
            upperContainer.layer.shadowOpacity = isShadowed ? 1 : 0
        }
    }
}

extension SubcategoryViewController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if sender is SurveyCategory {
            if let nc = navigationController as? NavigationControllerPreloaded {
                nc.transitionStyle = .Default
            }
            performSegue(withIdentifier: Segues.App.CategoryToSurveys, sender: sender)
        } else if let dict = sender as? Dictionary<String, Any>, let isShadowed = dict["isShadowed"] as? Bool {
            animateShadow(isShadowed)
        }
    }
}
