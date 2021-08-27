//
//  TopSurveysViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveysViewController: UIViewController/*, CircleTransitionable*/ {
    
    enum FeedIcon {
        case New, Hot, Category, Top, Unknown
        
        static func getCurrentIconByTag(tag: Int) -> FeedIcon {
            switch tag {
            case 0:
                return .Top
            case 1:
                return .New
            case 2:
                return .Hot
            case 3:
                return .Category
            default:
                return .Unknown
            }
        }
    }
    
//    fileprivate var timer:  Timer?//Network inactivity timeout
//    fileprivate var loadingTitleTimer:  Timer?
    fileprivate var interruptRequests = false
    fileprivate var requestAttempt = 0 {
        didSet {
            if oldValue != requestAttempt {
                if requestAttempt > MAX_REQUEST_ATTEMPTS {
                    requestAttempt = 0
                }
            }
        }
    }
    public var startingPoint: CGPoint = CGPoint.zero
    fileprivate var lostConnectionView: LostConnectionView?
    fileprivate var isInitialLoad = true
    fileprivate var currentIcon: FeedIcon = .Hot {
        didSet {
            if currentIcon != oldValue {
                presentSubview(oldIcon: oldValue, newIcon: currentIcon)
                switch currentIcon {
                case .Category:
                    setTitle("Разделы")
                    toggleSwitch(isOn: false)
                case .Hot:
                    setTitle("Горячие")
                    toggleSwitch(isOn: false)
                case .New:
                    setTitle("Новые")
                    if oldValue != .Top {
                    toggleSwitch(isOn: true)
                    }
                case .Top:
                    setTitle("Популярные")
                    if oldValue != .New {
                    toggleSwitch(isOn: true)
                    }
                case .Unknown:
                    setTitle("Сделать")
                }
//                newTableVC.tableView.reloadData()
                tabBarController?.tabBar.items?[0].title = "Лента"
            }
        }
    }
    fileprivate var isViewSetupCompleted = false
    fileprivate let tableVC: SurveysTableViewController = {
        let vc = Storyboards.controllers.instantiateViewController(withIdentifier: "SurveysTableViewController") as! SurveysTableViewController
        vc.type = .New
        return vc
    } ()
    
    public let categoryVC: CategoryCollectionViewController = {
        return Storyboards.controllers.instantiateViewController(withIdentifier: "CategoryCollectionViewController") as! CategoryCollectionViewController
    } ()
//    fileprivate let topTableVC: SurveysTableViewController = {
//        let vc = Storyboards.controllers.instantiateViewController(withIdentifier: "SurveysTableViewController") as! SurveysTableViewController
//        vc.type = .Top
//        return vc
//    } ()
    public let surveyStackVC: SurveyStackViewController = {
        return Storyboards.controllers.instantiateViewController(withIdentifier: "SurveyStackViewController") as! SurveyStackViewController
    } ()
    var isDataLoaded = false {
        didSet {
            if isInitialLoad, isDataLoaded {
//                delay(seconds: 1) { Banner.shared.present() }
//                delay(seconds: 2) { Banner.shared.dismiss()}
                isInitialLoad = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.setNeedsLayout()
                    self.iconsHeightConstraint.constant = 45
                    self.view.layoutIfNeeded()
                    self.loadingIndicator.alpha = 0
                    self.navigationItem.titleView?.alpha = 1
                    self.tabBarController?.tabBar.tintColor = K_COLOR_TABBAR
                }) {
                    _ in
                    self.tabBarController?.tabBar.isUserInteractionEnabled = true
                    self.tabBarController?.setTabBarVisible(visible: true, animated: true)
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    
                    for (index, icon) in self.icons.enumerated() {
                        icon.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        delay(seconds: Double(index) * 0.09) {
                            UIView.animate(withDuration: 0.3) {
                                if !(icon is ThumbUp) {
                                    icon.alpha = 1
                                }
                                icon.transform = .identity
                            }
                        }
                    }
                    
                    self.loadingIndicator.removeFromSuperview()
                    self.currentIcon = .Hot
                    self.hotIcon.state = .enabled
                    self.setTitle("Горячие")
                    self.presentSubview(oldIcon: nil, newIcon: .Hot)
                    self.lostConnectionView = nil
                    if let btn = self.navigationItem.rightBarButtonItem as? UIBarButtonItem {
//                        let v = Megaphone(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
//                        v.isOpaque = false
//                        v.clipsToBounds = false
                        let v = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: CGSize(width: 37, height: 37)))
                        v.backgroundColor = .clear
                        v.iconColor = K_COLOR_RED
//                        v.scaleFactor = 0.2
                        v.category = .AddStar
                        let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleAddTap))
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
                    if let btn = self.navigationItem.leftBarButtonItem as? UIBarButtonItem {
                        let switchV = CustomSwitch(frame: CGRect(origin: .zero, size: CGSize(width: 43, height: 15)))//UISwitch(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
                        switchV.isOn = false
//                        switchV.addTarget(self, action: #selector(SurveysViewController.toggleTopNewIcon), for: .valueChanged)
                        switchV.addTarget(self, action: #selector(SurveysViewController.toggleTableType), for: .touchUpInside)
//                        let v = Filter(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
//                        v.isOpaque = false
//                        let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleFilterTap))
//                        v.addGestureRecognizer(tap)
                        btn.customView = switchV
                        btn.customView?.alpha = 0
                    }

                        self.buttonsContainer.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
                        let shadowSize: CGFloat = 5
                        let contactRect = CGRect(x: -shadowSize, y: self.buttonsContainer.frame.height - (shadowSize * 0.4), width: self.buttonsContainer.frame.width + shadowSize * 2, height: shadowSize)
                        self.buttonsContainer.layer.shadowPath = UIBezierPath(rect: contactRect).cgPath
                        self.buttonsContainer.layer.shadowRadius = 5
                        self.buttonsContainer.layer.shadowOffset = .zero
                        self.buttonsContainer.layer.zPosition = 100
                        let anim = CABasicAnimation(keyPath: "shadowOpacity")
                        anim.fromValue = 0
                        anim.toValue = 1
                        anim.duration = 0.5
                        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                        anim.isRemovedOnCompletion = false
                    
                    if let tbView = self.tabBarController?.tabBar {
                        tbView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
                        let shadowSize: CGFloat = 5
                        let contactRectTB = CGRect(x: -shadowSize, y: -shadowSize, width: tbView.frame.width + shadowSize * 2, height: shadowSize)
                        tbView.layer.shadowPath = UIBezierPath(rect: tbView.bounds).cgPath//contactRect).cgPath
                        tbView.layer.shadowRadius = 5
                        tbView.layer.shadowOffset = .zero
                        tbView.layer.zPosition = 100
                        CATransaction.begin()
                        self.buttonsContainer.layer.add(anim, forKey: "shadowOpacity")
                        tbView.layer.add(anim, forKey: "shadowOpacity")
                        CATransaction.commit()
                        tbView.layer.shadowOpacity = 1
                        self.buttonsContainer.layer.shadowOpacity = 1
                    }
                }
            }
        }
    }
    private var loadingIndicator: LoadingIndicator!
    @IBAction func unwindToSurveysVC(unwindSegue: UIStoryboardSegue) {}
    @IBOutlet weak var topIcon: ThumbUp! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleIconTap(gesture:)))
            topIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var iconsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var newIcon: NewIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleIconTap(gesture:)))
            newIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var hotIcon: FlameIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleIconTap(gesture:)))
            hotIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var categoryIcon: CategoryIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleIconTap(gesture:)))
            categoryIcon.addGestureRecognizer(tap)
        }
    }


    fileprivate var icons: [Icon] = []
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
//        startTimer()
        
        loadData()
        tabBarController?.tabBar.isUserInteractionEnabled = false
        tabBarController?.tabBar.tintColor = .lightGray
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if startingPoint == .zero, let rbtn = navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
                startingPoint = rbtn.convert(rbtn.center, to: tabBarController?.view)
        }
        (navigationController as? NavigationControllerPreloaded)?.startingPoint = .zero
        UIView.animate(withDuration: 0.2) {
            self.navigationItem.titleView?.alpha = 1
        }
        if !isDataLoaded {
            loadingIndicator.alpha = 0
            loadingIndicator.addEnableAnimation()
            UIView.animate(withDuration: 0.5) {
                self.loadingIndicator.alpha = 1
            }
        }
        delay(seconds: TimeIntervals.NetworkInactivity) {
            self.checkDataIsLoaded()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isDataLoaded {
            if let rbtn = self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
                rbtn.alpha = 0
                UIView.animate(withDuration: 0.15, delay: 0.1, options: .curveEaseOut, animations: {
                    rbtn.alpha = 1
                })
            }
            tabBarController?.tabBar.isUserInteractionEnabled = true
            delay(seconds: 0.1) {
                self.tabBarController?.setTabBarVisible(visible: true, animated: true)
            }
        }
        
        if let nav = navigationController as? NavigationControllerPreloaded {
            nav.isShadowed = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !isViewSetupCompleted {
//            view.setNeedsLayout()
            iconsHeightConstraint.constant = 0
//            view.layoutIfNeeded()
            navigationController?.setNavigationBarHidden(true, animated: false)
            tabBarController?.setTabBarVisible(visible: false, animated: false)
            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: container.frame.width, height: container.frame.height)))
            loadingIndicator.alpha = 0
            loadingIndicator.layoutCentered(in: view, multiplier: 0.6)//addEquallyTo(to: tableView)
            isViewSetupCompleted = true
//            delay(seconds: 0.8) {
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.loadingIndicator.alpha = 1
//                }) {
//                    _ in
//                    self.loadingIndicator.addEnableAnimation()
//                    print("addEnableAnimation")
//                }
//            }
//            container.setNeedsLayout()
//            container.layoutIfNeeded()
//            icons = [self.topIcon, self.newIcon, self.hotIcon, self.categoryIcon, self.unknownIcon]
            icons = [newIcon, topIcon, hotIcon, categoryIcon]
//            buttonsContainer.layer.shadowColor = UIColor.lightGray.cgColor
//            let shadowSize: CGFloat = 20
//            let contactRect = CGRect(x: -shadowSize, y: buttonsContainer.frame.height - (shadowSize * 0.4), width: buttonsContainer.frame.width + shadowSize * 2, height: shadowSize)
//            buttonsContainer.layer.shadowPath = UIBezierPath(rect: contactRect).cgPath
//            buttonsContainer.layer.shadowRadius = 5
//            buttonsContainer.layer.shadowOffset = .zero
//            buttonsContainer.layer.shadowOpacity = 0.5
//            buttonsContainer.layer.zPosition = 100
        }
    }
    
    private func setupViews() {
        let titleView = UIAnimatedTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40), title: "")
        self.navigationItem.titleView = titleView
        self.navigationItem.titleView?.alpha = 0
        setTitle("")
        self.tabBarController?.tabBar.items?[0].title = "Лента"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage     = UIImage()
        
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            
            self.addButton.isEnabled = true
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(SurveysViewController.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(SurveysViewController.applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
        
        addChild(self.tableVC)
        tableVC.delegate = self
        tableVC.view.backgroundColor = .white
        tableVC.didMove(toParent: self)
//        addChild(self.topTableVC)
//        topTableVC.delegate = self
//        topTableVC.didMove(toParent: self)
        addChild(self.surveyStackVC)
        surveyStackVC.delegate = self
        surveyStackVC.didMove(toParent: self)
        
        addChild(self.categoryVC)
        categoryVC.delegate = self
        categoryVC.didMove(toParent: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nc = navigationController as! NavigationControllerPreloaded
        nc.transitionStyle = .Default
        tabBarController?.setTabBarVisible(visible: false, animated: true)
        if segue.identifier == Segues.App.FeedToCategory, let destinationVC = segue.destination as? SubcategoryViewController, let category = sender as? SurveyCategory {
            destinationVC.parentCategory = category
            destinationVC.title = category.title
            nc.category = category
            nc.duration = 0.3
            nc.transitionStyle = .Icon
            destinationVC.delegate = self
        } else if segue.identifier == Segues.App.FeedToSurvey, let destinationVC = segue.destination as? PollController, let cell = tableVC.tableView.cellForRow(at: tableVC.tableView.indexPathForSelectedRow!) as? SurveyTableViewCell {
            destinationVC.surveyRef = cell.survey
            destinationVC.apiManager = apiManager
            tabBarController?.setTabBarVisible(visible: false, animated: true)
        
        
        
        /*else if segue.identifier == Segues.App.FeedToSurvey, let destinationVC = segue.destination as? SurveyViewController {
            switch currentIcon {
            case .New:
                if let cell = tableVC.tableView.cellForRow(at: tableVC.tableView.indexPathForSelectedRow!) as? SurveyTableViewCell {
                    destinationVC.surveyLink = cell.survey
                    destinationVC.apiManager = apiManager
                }
//            case.Top:
//                if let cell = topTableVC.tableView.cellForRow(at: topTableVC.tableView.indexPathForSelectedRow!) as? SurveyTableViewCell {
//                    destinationVC.surveyLink = cell.survey
//                    destinationVC.apiManager = apiManager
//                }
            default:
                print("s")
            }
            tabBarController?.setTabBarVisible(visible: false, animated: true)*/
        } else if segue.identifier == Segues.App.FeedToSurveyFromTop, let destinationVC = segue.destination as? SurveyViewController, let sender = sender as? SurveyStackViewController {
            destinationVC.apiManager = apiManager
            destinationVC.shouldDownloadImages = false
            destinationVC.survey = sender.surveyPreview.survey
            destinationVC.delegate = sender
            destinationVC.isNavTitleEnabled = false
            nc.transitionStyle = .Icon
            nc.duration = 0.25//5.4//
        } else if segue.identifier == Segues.App.FeedToNewSurvey {
            nc.transitionStyle = .Icon
            nc.duration = 0.4
        } else if segue.identifier == Segues.App.FeedToUser, let userProfile = sender as? UserProfile, let destinationVC = segue.destination as? UserViewController {
            destinationVC.userProfile = userProfile
            nc.duration = 0.2
            nc.transitionStyle = .Icon
        }
    }
    
    @objc fileprivate func applicationDidBecomeActive() {
//        if Surveys.shared.topLinks.isEmpty {
//            loadData()
//        }
    }
    
    @objc fileprivate func applicationDidEnterBackground() {
        //TODD: Cancel requests?
        apiManager.cancelAllRequests()
    }
    
    @objc private func handleIconTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let icon = gesture.view {
            var pairIcon = Icon(frame: .zero)
            if icon is NewIcon {
                if currentIcon == FeedIcon.Top || currentIcon == FeedIcon.New {
                    return
                }
                pairIcon = topIcon
            } else if icon is ThumbUp {
                if currentIcon == FeedIcon.Top || currentIcon == FeedIcon.New {
                    return
                }
                pairIcon = newIcon
            }
            for i in icons {
                if i === icon || i === pairIcon {
                    i.state = .enabled
//                    if i is NewIcon {
//                        topIcon.state = .enabled
//                    } else if i is ThumbUp {
//                        newIcon.state = .enabled
//                    }
                } else {
                    i.state = .disabled
//                    if i is NewIcon {
//                        topIcon.state = .disabled
//                    } else if i is ThumbUp {
//                        newIcon.state = .disabled
//                    }
                }
            }
            tableVC.tableView.setContentOffset(tableVC.tableView.contentOffset, animated: false)
            navigationController?.setNavigationBarHidden(false, animated: true)
            currentIcon = FeedIcon.getCurrentIconByTag(tag: icon.tag)
        }
    }
    
    @objc private func handleAddTap() {
        performSegue(withIdentifier: Segues.App.FeedToNewSurvey, sender: self)
//        navigationItem.setRightBarButton(nil, animated: false)
    }
    
    @objc private func handleFilterTap() {
        
    }
    
    fileprivate func toggleSwitch(isOn: Bool) {
//        if let filter = navigationItem.leftBarButtonItem?.customView as? Filter {
        if let sw = navigationItem.leftBarButtonItem?.customView as? CustomSwitch {
            if isOn { sw.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) }
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 3,
                options: [.curveEaseInOut],
                animations: {
                    if isOn { sw.transform =  .identity }
                    sw.alpha = isOn ? 1 : 0
            })
            self.navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    fileprivate func setTitle(_ _title: String) {
        guard let titleView = navigationItem.titleView as? UIAnimatedTitleView else { return }

        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 0.1
        fadeTextAnimation.type = .fade

        titleView.layer.add(fadeTextAnimation, forKey: "pushText")
        titleView.text = _title
//        if _title == "Загрузка" {
//            startTimer()
//        } else {
//            stopTimer()
//        }
    }
    
//    fileprivate func startTimer() {
//        guard loadingTitleTimer == nil else { return }
//        loadingTitleTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SurveysViewController.updateTimer), userInfo: nil, repeats: true)
//        loadingTitleTimer?.fire()
//    }
//
//    fileprivate func stopTimer() {
//        loadingTitleTimer?.invalidate()
//        loadingTitleTimer = nil
//    }
//
//    @objc private func updateTimer() {
//        guard let titleView = navigationItem.titleView as? UIAnimatedTitleView else { return }
//
//        if titleView.text.filter({ $0 == "."}).count < 4 {
//            titleView.text += "."
//        } else {
//            titleView.text = "Загрузка"
//        }
//    }
    @objc fileprivate func toggleTableType() {
        if let v = navigationItem.leftBarButtonItem?.customView as? CustomSwitch {
            let animationDuration: Double = 0.3
            let revealView: UIView! = v.isOn ? topIcon : newIcon
            let hideView: UIView! = v.isOn ? newIcon : topIcon
            revealView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: animationDuration/2, delay: 0, options: [.curveEaseInOut], animations: {
                hideView.alpha = 0
                hideView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in hideView.transform = .identity }
            UIView.animate(withDuration: animationDuration/2, delay: 0, options: [.curveEaseInOut], animations: {
                revealView.alpha = 1
                revealView.transform = .identity
            })
            setTitle(v.isOn ? "Популярные" : "Новые")
            tableVC.type = v.isOn ? .Top : .New
//            currentIcon = v.isOn ? .Top : .New
        }
        
    }
    
    fileprivate func presentSubview(oldIcon: FeedIcon?, newIcon: FeedIcon) {
//
////        if oldIcon != nil, let newView = surveyStackVC.view {
////            surveyStackVC.view.frame = container.frame
////            newView.alpha = 0
////            newView.addEquallyTo(to: container)
////            newView.layer.zPosition = 2
////            newView.transform = newView.transform.scaledBy(x: 0.93, y: 0.93)
////            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
////                newView.alpha = 1
////                newView.transform = .identity
////            })
////        } else if let _oldIcon = oldIcon {
////            switch newIcon {
////            case .New:
////                newTableVC.view.frame = container.frame
////                let newView = newTableVC.view
////                switch _oldIcon {
////                case .Hot:
////
////                case .Category:
////
////                default:
////                    print("def")
////                }
////                //        case .Top:
////                //            topTableVC.view.frame = container.frame
////            //            newView = topTableVC.view
////            case .Hot:
////                surveyStackVC.view.frame = container.frame
////                newView = surveyStackVC.view
////            case .Category:
////                categoryVC.view.frame = container.frame
////                newView = categoryVC.view
////            default:
////                print("default")
////            }
////        }
//        let oldView = container.subviews.first
//        var newView: UIView!
//        switch newIcon {
//        case .New:
//            newTableVC.view.frame = container.frame
//            newView = newTableVC.view
////        case .Top:
////            topTableVC.view.frame = container.frame
////            newView = topTableVC.view
//            newView.alpha = 0
//            newView.addEquallyTo(to: container)
//            newView.layer.zPosition = 2
////            newView.transform = newView.transform.scaledBy(x: 0.93, y: 0.93)
//            if let _oldIcon = oldIcon {
//                switch _oldIcon {
//                case .Hot:
//                    delay(seconds: 0.07) {
//                        self.newTableVC.tableView.reloadData()
//                        newView.alpha = 1
//                    }
//                    UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
//                        oldView!.alpha = 0
//                        self.surveyStackVC.surveyPreview.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//                        //oldView!.transform = oldView!.transform.scaledBy(x: 1.2, y: 1.2)
//                    }) {
//                        _ in
////                        oldView!.transform = .identity
//                        self.surveyStackVC.surveyPreview.transform = .identity
//                        oldView!.removeFromSuperview()
//                    }
//                case .Category:
////                    delay(seconds: 0.07) {
////                        self.newTableVC.tableView.reloadData()
////                        newView.alpha = 1
////                    }
//                    UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
//                        oldView!.alpha = 0
//                        self.surveyStackVC.surveyPreview.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//
//                    }) {
//                        _ in
//                        self.categoryVC.collectionView.reloadData()
//                        newView.alpha = 1
//                        self.surveyStackVC.surveyPreview.transform = .identity
//                        oldView!.removeFromSuperview()
//                    }
//                default:
//                    print("def")
//                }
//            }
//        case .Hot:
//            surveyStackVC.view.frame = container.frame
//            newView = surveyStackVC.view
//            newView.alpha = 0
//            newView.addEquallyTo(to: container)
//            newView.layer.zPosition = 2
//            newView.transform = newView.transform.scaledBy(x: 0.93, y: 0.93)
//            if oldView != nil {
//                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
//                    oldView!.alpha = 0
//                    oldView!.transform = oldView!.transform.scaledBy(x: 0.93, y: 0.93)
//                }) {
//                    _ in
//                    oldView!.removeFromSuperview()
//                    oldView!.transform = .identity
//                }
//            }
//            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
//                newView.alpha = 1
//                newView.transform = .identity
//            })
//        case .Category:
//            categoryVC.view.frame = container.frame
//            newView = categoryVC.view
//            newView.alpha = 0
//            newView.addEquallyTo(to: container)
//            newView.layer.zPosition = 2
//            newView.transform = newView.transform.scaledBy(x: 0.93, y: 0.93)
//            if oldView != nil {
//                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
//                    oldView!.alpha = 0
//                    oldView!.transform = oldView!.transform.scaledBy(x: 0.93, y: 0.93)
//                }) {
//                    _ in
//                    oldView!.removeFromSuperview()
//                    oldView!.transform = .identity
//                }
//            }
//            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
//                newView.alpha = 1
//                newView.transform = .identity
//            })
//        default:
//            print("default")
//        }

        let oldView = container.subviews.first
//        var newView: UIView!
        switch newIcon {
        case .New, .Top:
            tableVC.view.frame = container.frame
            tableVC.view.alpha = 0
            tableVC.view.addEquallyTo(to: container)
            tableVC.view.layer.zPosition = 2
            tableVC.view.transform = tableVC.view.transform.scaledBy(x: 1.05, y: 1.05)
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.tableVC.view.transform = .identity
                self.tableVC.view.alpha = 1
            })

//            delay(seconds: 0.07) {
//                self.newTableVC.tableView.reloadData()
//            UIView.animate(withDuration: 0.2, delay: 0.07, options: [], animations: {
//                self.newTableVC.view.alpha = 1
//                if let indexArray = self.newTableVC.tableView.indexPathsForVisibleRows {
//                    self.newTableVC.tableView.reloadRows(at: indexArray, with: .none)
//                }
//            })
            
//                self.newTableVC.tableView.endUpdates()
            
//            }
            //        case .Top:
            //            topTableVC.view.frame = container.frame
        //            newView = topTableVC.view
        case .Hot:
            surveyStackVC.view.frame = container.frame
            surveyStackVC.view.alpha = 0
            surveyStackVC.view.addEquallyTo(to: container)
            surveyStackVC.view.layer.zPosition = 2
            surveyStackVC.view.transform = surveyStackVC.view.transform.scaledBy(x: 0.85, y: 0.85)
            UIView.animate(withDuration: 0.17, delay: 0, options: [.curveEaseOut], animations: {
                self.surveyStackVC.view.transform = .identity
                self.surveyStackVC.view.alpha = 1
            })
        case .Category:
            categoryVC.view.frame = container.frame
            categoryVC.view.alpha = 0
            categoryVC.view.addEquallyTo(to: container)
            categoryVC.view.layer.zPosition = 2
            delay(seconds: 0.07) {
                self.categoryVC.collectionView.reloadData()
                self.categoryVC.view.alpha = 1
            }
        default:
            print("default")
        }
        if oldView != nil {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveLinear], animations: {
                oldView!.alpha = 0
                oldView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) {
                _ in
                oldView!.transform = .identity
                oldView!.removeFromSuperview()
            }
        }
    }
    
    func presentLostConnectionView() {
        if lostConnectionView == nil {
            self.lostConnectionView = LostConnectionView(frame: CGRect(origin: .zero, size: CGSize(width: self.container.frame.width, height: self.container.frame.height)))
            self.lostConnectionView!.delegate = self
            self.lostConnectionView!.alpha = 0
            self.lostConnectionView!.layoutCentered(in: self.view, multiplier: 0.65)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingIndicator.alpha = 0
        }) {
            _ in
            self.setTitle("Нет соединения")
            self.lostConnectionView!.retryButton.layer.cornerRadius = self.lostConnectionView!.retryButton.frame.height / 2
            self.lostConnectionView?.animationView.addEnableAnimation()
            UIView.animate(withDuration: 0.3) {
                self.lostConnectionView?.alpha = 1
            }
        }
    }
}

extension SurveysViewController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if sender is LostConnectionView {
            delay(seconds: TimeIntervals.NetworkInactivity) {
                self.checkDataIsLoaded()
            }
            interruptRequests = false
            loadData()
            UIView.animate(withDuration: 0.3, animations: {
                self.lostConnectionView?.alpha = 0
            }) {
                _ in
                UIView.animate(withDuration: 0.3) {
                self.setTitle("")
                self.loadingIndicator.alpha = 1
                }
            }
        } else if let category = sender as? SurveyCategory {//let dict = sender as? [String: Any], let startingPoint = dict["startingPoint"] as? CGPoint, let category = dict["category"] as? SurveyCategory, let size = dict["size"] as? CGSize {//if sender is SurveyCategory {
            performSegue(withIdentifier: Segues.App.FeedToCategory, sender: sender)
        }
    }
}


extension SurveysViewController: ServerProtocol {
    func loadData() {
        if !interruptRequests {
            
            //                delay(seconds: 3) {
            //                    self.presentLostConnectionView()
            //                }
            apiManager.initialLoad() {
                json, error in
                if error != nil {
                    if self.requestAttempt > MAX_REQUEST_ATTEMPTS {
                        self.presentLostConnectionView()
                    } else {
                        //Retry unless successfull
                        self.requestAttempt += 1
                        if self.isInitialLoad {
                            self.loadData()
                        }
                    }
                }
                if let strongJSON = json, !self.interruptRequests {
                    AppData.shared.system.APIVersion = strongJSON["api_version"].stringValue
                    SurveyCategories.shared.importJson(strongJSON["categories"])
                    SurveyCategories.shared.updateCount(strongJSON["total_count"])
                    ClaimCategories.shared.importJson(strongJSON["claim_categories"])
                    Surveys.shared.importSurveys(strongJSON["surveys"])
                    ModelProperties.shared.importJson(strongJSON["field_properties"])
                    PriceList.shared.importJson(strongJSON["pricelist"])
                    if let balance = strongJSON[DjangoVariables.UserProfile.balance].intValue as? Int {
                        AppData.shared.userProfile.balance = balance
                    }
                    self.tableVC.refreshControl?.endRefreshing()
//                    self.newTableVC.needsAnimation = true
                    if self.isInitialLoad {
                        self.tableVC.tableView.isUserInteractionEnabled = true
                        self.isDataLoaded = true
                    }
                    self.requestAttempt = 0
                }
            }
        }
    
//        apiManager.loadSurveyCategories() {
//            json, error in
//            if error != nil {
//                if self.requestAttempt > MAX_REQUEST_ATTEMPTS {
//                    self.presentLostConnectionView()
//                } else {
//                    //Retry unless successfull
//                    self.requestAttempt += 1
//                    if self.isInitialLoad {
//                        self.loadData()
//                    }
//                }
//            }
//            if json != nil {
//                SurveyCategories.shared.importJson(json!)
//                self.updateSurveysTotalCount()
//                self.updateSurveys(type: .All)
//                self.requestAttempt = 0
//            }
//        }
    }
    
    func updateSurveysTotalCount() {
        self.apiManager.loadTotalSurveysCount() {
            json, error in
            if error != nil {
                print(error!.localizedDescription)
                //Retry unless successfull
                if self.isInitialLoad {
                    self.updateSurveysTotalCount()
                }
            } else if json != nil {
                SurveyCategories.shared.updateCount(json!)
            }
        }
    }
    
    func updateSurveys(type: APIManager.SurveyType) {
        self.apiManager.loadSurveys(type: type) {
            json, error in
            if error != nil {
                //Retry unless successfull
                if self.isInitialLoad {
                    self.updateSurveys(type: .All)
                } else {
                    self.tableVC.refreshControl?.attributedTitle = NSAttributedString(string: "Ошибка, повторите позже", attributes: StringAttributes.SemiBold.red_12)//semiboldAttrs_red_12)
                    self.tableVC.refreshControl?.endRefreshing()
                    delay(seconds: 0.5) {
                        self.tableVC.refreshControl?.attributedTitle = NSAttributedString(string: "")
                    }
                }
            }
            if json != nil {
                Surveys.shared.importSurveys(json!)
                self.tableVC.refreshControl?.endRefreshing()
//                self.newTableVC.needsAnimation = true
                if self.isInitialLoad {
                    self.tableVC.tableView.isUserInteractionEnabled = true
                    self.isDataLoaded = true
//                    self.isInitialLoad = false
                }
            }
        }
    }
    
//    fileprivate func startTimer() {
//        guard timer == nil else { return }
//        timer = Timer.scheduledTimer(timeInterval: TimeIntervals.NetworkInactivity, target: self, selector: #selector(SurveysViewController.interruptNetworkActivity), userInfo: nil, repeats: false)
//        timer?.fire()
//    }
    
    fileprivate func checkDataIsLoaded() {
        if !isDataLoaded {
            interruptRequests = true
            requestAttempt = 0
            Surveys.shared.eraseData()
            apiManager.cancelAllRequests()
            presentLostConnectionView()
            tabBarController?.setTabBarVisible(visible: false, animated: true)
        }
    }
}

    
    
    
    
    
    

class UIAnimatedTitleView: UIView {
    private var label = UILabel()
    var font = UIFont(name: "OpenSans-Bold", size: 19)
    
    var text: String = "" {
        didSet {
            label.text = text
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.font = font
        }
    }
    
    func animateTextChange(newString: String, completion: @escaping(Bool)->()) {
        UIView.transition(with: label, duration: 0.4, options: [.transitionCrossDissolve], animations: {
            self.label.text = newString
        }) {
            _ in
            self.text = newString
            completion(true)
        }
    }
    
    // MARK: Initializers
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        label.addEquallyTo(to: self)
        addSubview(label)
        clipsToBounds = true
        isUserInteractionEnabled = false
    }
}

