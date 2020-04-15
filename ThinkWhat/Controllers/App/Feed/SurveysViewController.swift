//
//  TopSurveysViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveysViewController: UIViewController/*, CircleTransitionable*/ {
    
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
    fileprivate var lostConnectionView: LostConnectionView?
    private var _currentIcon: CurrentIcon = .New {
        didSet {
            if _currentIcon != oldValue {
                if _currentIcon == .Category {
                    setTitle("Разделы")
                    tableVC.needsAnimation = false
                    tableVC.refreshControl?.removeFromSuperview()
                    tableVC.tableView.bounces = false
                } else {
                    if _currentIcon == .New {
                        setTitle("Новые")
                    } else {
                        setTitle("Популярные")
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
    private var isViewSetupCompleted = false
    private let tableVC: TopSurveysTableViewController = {
        let storyboard = UIStoryboard(name: "App", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TopSurveysTableViewController") as! TopSurveysTableViewController
        return vc
    } ()
    var isDataLoaded = false {
        didSet {
            if oldValue != isDataLoaded {
                tabBarController?.setTabBarVisible(visible: true, animated: true)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.loadingIndicator.alpha = 0
                }) {
                    _ in
                    for (index, icon) in self.icons.enumerated() {
                        delay(seconds: Double(index) * 0.1) {
                            UIView.animate(withDuration: 0.6) {
                                icon.alpha = 1
                            }
                        }
                    }
                    self.loadingIndicator.removeFromSuperview()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.tableVC.view.alpha = 1
                        self.newIcon.state = .enabled
                        self.setTitle("Новые")
                    }) {
                        _ in
                        self.lostConnectionView = nil
                        if let btn = self.navigationItem.rightBarButtonItem as? UIBarButtonItem {
                            let v = PlusIcon(frame: CGRect(origin: .zero, size: CGSize(width: 27, height: 27)))
                            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleAddTap))
                            v.addGestureRecognizer(tap)
                            btn.customView = v
                            let scaleAnim       = CASpringAnimation(keyPath: "transform.scale")//CABasicAnimation(keyPath: "transform.scale")
                            let fadeAnim        = CABasicAnimation(keyPath: "opacity")
                            let groupAnim       = CAAnimationGroup()
                            
                            scaleAnim.fromValue = 0.7
                            scaleAnim.toValue   = 1.0
                            scaleAnim.damping   = 10
                            scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                            fadeAnim.fromValue  = 0
                            fadeAnim.toValue    = 1
                            
                            groupAnim.animations        = [scaleAnim, fadeAnim]
                            groupAnim.duration          = 0.3
                            groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                            btn.customView?.layer.add(groupAnim, forKey: nil)

                            self.navigationController?.navigationBar.setNeedsLayout()

                        }
                    }
                }
            }
        }
    }
    private var loadingIndicator: LoadingIndicator!
    @IBOutlet weak var newIcon: NewIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleTap(gesture:)))
            newIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var hotIcon: FlameIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleTap(gesture:)))
            hotIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var categoryIcon: CategoryIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleTap(gesture:)))
            categoryIcon.addGestureRecognizer(tap)
        }
    }
    fileprivate var icons: [Icon] = []
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        tabBarController?.setTabBarVisible(visible: false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if startingPoint == .zero, let rbtn = navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
                startingPoint = rbtn.convert(rbtn.center, to: tabBarController?.view)
        }
        if isDataLoaded {
            tabBarController?.setTabBarVisible(visible: true, animated: true)
        }
        UIView.animate(withDuration: 0.2) {
            self.navigationItem.titleView?.alpha = 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !isViewSetupCompleted {
            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: container.frame.width, height: container.frame.height)))
            loadingIndicator.alpha = 0
            loadingIndicator.layoutCentered(in: container, multiplier: 0.6)//addEquallyTo(to: tableView)
            isViewSetupCompleted = true
            delay(seconds: 0.5) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.loadingIndicator.alpha = 1
                }) {
                    _ in
                    self.loadingIndicator.addEnableAnimation()
                }
            }
        }
    }
    
    private func setupViews() {
        let titleView = UIAnimatedTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40), title: "Соединение")
        self.navigationItem.titleView = titleView
        self.navigationItem.titleView?.alpha = 0
        setTitle("Соединение")
        self.tabBarController?.tabBar.items?[0].title = "Лента"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage     = UIImage()
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.icons = [self.newIcon, self.hotIcon, self.categoryIcon]
            self.addButton.isEnabled = true
        }
        DispatchQueue.main.async {
            self.addChild(self.tableVC)
            self.tableVC.view.alpha = 0
            self.tableVC.view.frame = CGRect(x: 0, y: 0, width: self.container.frame.width, height: self.container.frame.height)
            self.tableVC.view.addEquallyTo(to: self.container)
            self.tableVC.didMove(toParent: self)
        }
    }
    
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
    
    @objc private func handleAddTap() {
        performSegue(withIdentifier: kSegueAppFeedToNewSurvey, sender: self)
    }
    
    fileprivate func setTitle(_ _title: String) {
        guard let titleView = navigationItem.titleView as? UIAnimatedTitleView else { return }

        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 0.1
        fadeTextAnimation.type = .fade

        titleView.layer.add(fadeTextAnimation, forKey: "pushText")
        titleView.text = _title
//                let fadeTextAnimation = CATransition()
//        fadeTextAnimation.duration = 0.1
//        fadeTextAnimation.type = .fade
//
//        navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: nil)
//        navigationItem.title = _title
    }
    
    func presentLostConnectionView() {
        if lostConnectionView == nil {
            self.lostConnectionView = LostConnectionView(frame: CGRect(origin: .zero, size: CGSize(width: self.container.frame.width, height: self.container.frame.height)))
            self.lostConnectionView!.delegate = self
            self.lostConnectionView!.alpha = 0
            self.lostConnectionView!.layoutCentered(in: self.container, multiplier: 0.65)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingIndicator.alpha = 0
        }) {
            _ in
            self.setTitle("Ошибка соединения")
            self.lostConnectionView!.retryButton.layer.cornerRadius = self.lostConnectionView!.retryButton.frame.height / 2
            self.lostConnectionView?.animationView.addEnableAnimation()
            UIView.animate(withDuration: 0.3) {
                self.lostConnectionView?.alpha = 1
            }
        }
    }
}

extension SurveysViewController: CellButtonDelegate {
    func cellSubviewTapped(_ sender: AnyObject) {
        if sender is LostConnectionView {
            tableVC.loadData()
            UIView.animate(withDuration: 0.3, animations: {
                self.lostConnectionView?.alpha = 0
            }) {
                _ in
                UIView.animate(withDuration: 0.3) {
                self.setTitle("Соединение")
                self.loadingIndicator.alpha = 1
                }
            }
        }
    }
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

class UIAnimatedTitleView: UIView {
    private var label = UILabel()
    
    var text: String = "" {
        didSet {
            label.text = text
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.font = UIFont(name: "OpenSans-Bold", size: 19)
            setNeedsLayout()
        }
    }
    
    // MARK: Initializers
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        
        label.frame = self.frame
        text = title
        addSubview(label)
        clipsToBounds = true
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
