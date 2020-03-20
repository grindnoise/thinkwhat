//
//  TopSurveysViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopSurveysViewController: UIViewController/*, CircleTransitionable*/ {
    
//    var triggerView: UIView = UIView()
//    var mainView: UIView {
//        return view
//    }
    
    
    enum CurrentIcon {
        case New, Hot, Category
        
        static func getCurrentIconByTag(tag: Int) -> CurrentIcon {
            switch tag {
            case 1:
                return .New
            case 2:
                return .Hot
            default:
                return .Category
            }
        }
    }
    
    public var currentIcon: CurrentIcon {
        return _currentIcon
    }
    public var startingPoint: CGPoint = CGPoint.zero
//    private let transition = CircularTransition()
    private var _currentIcon: CurrentIcon = .New {
        didSet {
            if _currentIcon != oldValue {
                if _currentIcon == .Category {
                    title = "Разделы"
                    tableVC.needsAnimation = false
                    tableVC.refreshControl?.removeFromSuperview()
                    tableVC.tableView.bounces = false
                } else {
                    if _currentIcon == .New {
                        title = "Новые"
                    } else {
                        title = "Популярные"
                    }
                    tableVC.needsAnimation = true
                    tableVC.view.addSubview(tableVC.refreshControl!)
                    tableVC.tableView.bounces = true
                }
                tableVC.tableView.reloadData()
                tabBarController?.tabBar.items?[0].title = "Лента"
            }
        }
    }
    private let attrs     = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 13)]//,
//                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
//                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    private var isViewSetupCompleted = false
    private let tableVC: TopSurveysTableViewController = {
        let storyboard = UIStoryboard(name: "App", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TopSurveysTableViewController") as! TopSurveysTableViewController
        return vc
    } ()
//    lazy private var newSurveyVC: NewSurveyViewController = initializeNewSurveyVC()
    
    @IBOutlet weak var newIcon: NewIcon!
    @IBOutlet weak var hotIcon: FlameIcon!
    @IBOutlet weak var categoryIcon: CategoryIcon!
    fileprivate var icons: [Icon] = []
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
        super.viewDidAppear(animated)
        if startingPoint == .zero {
            if let rbtn = navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
                startingPoint = rbtn.convert(rbtn.center, to: tabBarController?.view)
            }
        }
//        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
//        tabBarController!.setTabBarVisible(visible: true, duration: 0, animated: false)
//        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.setTabBarVisible(visible: true, animated: true)
    }
//
    private func setupViews() {
        title = "Новые"
        tabBarController?.tabBar.items?[0].title = "Лента"
//        let btn = AddButton(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
//        btn.layer.isOpaque = true
//        btn.backgroundColor = .clear
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.icons = [self.newIcon, self.hotIcon, self.categoryIcon]
            for icon in self.icons {
                let tap = UITapGestureRecognizer(target: self, action: #selector(TopSurveysViewController.handleTap(gesture:)))
                icon.addGestureRecognizer(tap)
            }
            self.addButton.isEnabled = false
        }
        DispatchQueue.main.async {
            self.addChild(self.tableVC)
            self.tableVC.view.frame = CGRect(x: 0, y: 0, width: self.container.frame.width, height: self.container.frame.height)
            self.tableVC.view.addEquallyTo(to: self.container)
            self.tableVC.didMove(toParent: self)
        }
        DispatchQueue.main.async {
//            if let rbtn = self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
//                self.triggerView = rbtn
//            }
        }
//        DispatchQueue.main.async {
//            self.newSurveyVC
//        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if let rbtn = self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
//            self.triggerView = rbtn
//        }
//    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (navigationController as? NavigationControllerPreloaded)?.delegate = nil
        if segue.identifier == kSegueAppTopSurveysToCategory, let destinationVC = segue.destination as? CategoryTableViewController {
            if let cell = tableVC.tableView.cellForRow(at: tableVC.tableView.indexPathForSelectedRow!) as? SubcategoryTableViewCell {
                destinationVC.category = cell.category
                destinationVC.title = cell.category.title
            }
        } else if segue.identifier == kSegueAppFeedToSurvey, let destinationVC = segue.destination as? SurveyViewController, let cell = tableVC.tableView.cellForRow(at: tableVC.tableView.indexPathForSelectedRow!) as? SurveyTableViewCell {
            tabBarController?.setTabBarVisible(visible: false, animated: true)
            destinationVC.surveyLink = cell.survey
        } else if segue.identifier == kSegueAppFeedToNewSurvey { //New survey
            navigationController?.setNavigationBarHidden(true, animated: false)
            tabBarController?.setTabBarVisible(visible: false, animated: false)
            (navigationController as? NavigationControllerPreloaded)?.startingPoint = startingPoint
//            (navigationController as? NavigationControllerPreloaded)?.snapshotParent = tabBarController!.view.snapshotView(afterScreenUpdates: false)
        }
    }
    
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let icon = gesture.view {
            for i in icons {
                if i === icon {
                    i.state = .enabled
                } else {
                    i.state = .disabled
                }
            }
            _currentIcon = CurrentIcon.getCurrentIconByTag(tag: icon.tag)
        }
    }
    
    func animateNew() {
        newIcon.state = .enabled
    }
    
//    private func initializeNewSurveyVC() -> NewSurveyViewController {
//            let vc = NewSurveyViewController()
//            vc.transitioningDelegate     = self
//            vc.modalPresentationStyle    = .custom
//            vc.view.frame                = tabBarController!.view.frame
//            vc.view.backgroundColor      = .white
//            vc.parentVC                  = self
//            return vc
//    }
}

//extension TopSurveysViewController: UIViewControllerTransitioningDelegate {
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.transitionMode = .present
//        transition.startingPoint = startingPoint
//        transition.circleColor = K_COLOR_RED
//
//        return transition
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.transitionMode = .dismiss
//        transition.startingPoint = startingPoint
//        transition.circleColor = K_COLOR_RED
//
//        return transition
//    }
//
//
//}

//extension TopSurveysViewController: UINavigationControllerDelegate {
//        func navigationController(_ navigationController: UINavigationController,
//                                  animationControllerFor operation: UINavigationController.Operation,
//                                  from fromVC: UIViewController,
//                                  to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//            return CircularTransition(operation)
//
//        }
//}
