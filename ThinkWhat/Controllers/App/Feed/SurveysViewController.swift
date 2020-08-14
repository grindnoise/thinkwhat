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
        case New, Hot, Category, Top, Unknown
        
        static func getCurrentIconByTag(tag: Int) -> CurrentIcon {
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
    fileprivate var currentIcon: CurrentIcon = .Hot {
        didSet {
            if currentIcon != oldValue {
                presentSubview()
                switch currentIcon {
                case .Category:
                    setTitle("Разделы")
                    newTableVC.needsAnimation = false
                    newTableVC.refreshControl?.removeFromSuperview()
                    newTableVC.tableView.bounces = false
                case .Hot:
                    setTitle("Горячие")
                case .New:
                    setTitle("Новые")
                case .Top:
                    setTitle("Популярные")
                case .Unknown:
                    setTitle("Сделать")
                }
                newTableVC.tableView.reloadData()
                tabBarController?.tabBar.items?[0].title = "Лента"
            }
        }
    }
    fileprivate var isViewSetupCompleted = false
    fileprivate let newTableVC: SurveysTableViewController = {
        let vc = Storyboards.controllers.instantiateViewController(withIdentifier: "SurveysTableViewController") as! SurveysTableViewController
        vc.type = .New
        return vc
    } ()
//    fileprivate let topTableVC: SurveysTableViewController = {
//        let vc = Storyboards.controllers.instantiateViewController(withIdentifier: "SurveysTableViewController") as! SurveysTableViewController
//        vc.type = .Top
//        return vc
//    } ()
    fileprivate let surveyStackVC: SurveyStackViewController = {
        return Storyboards.controllers.instantiateViewController(withIdentifier: "SurveyStackViewController") as! SurveyStackViewController
    } ()
    var isDataLoaded = false {
        didSet {
            if isInitialLoad, isDataLoaded {
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
                                icon.alpha = 1
                                icon.transform = .identity
                            }
                        }
                    }
                    self.loadingIndicator.removeFromSuperview()
                    self.currentIcon = .Hot
                    self.hotIcon.state = .enabled
                    self.setTitle("Горячие")
                    self.presentSubview()
                    self.lostConnectionView = nil
                    if let btn = self.navigationItem.rightBarButtonItem as? UIBarButtonItem {
                        let v = Megaphone(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))//PlusIcon(frame: CGRect(origin: .zero, size: CGSize(width: 27, height: 27)))
                        v.isOpaque = false
                        let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleAddTap))
                        v.addGestureRecognizer(tap)
                        btn.customView = v
                        btn.customView?.alpha = 0
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
        }
    }
    private var loadingIndicator: LoadingIndicator!
//    @IBOutlet weak var topIcon: TopIcon! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleIconTap(gesture:)))
//            topIcon.addGestureRecognizer(tap)
//        }
//    }
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
//    @IBOutlet weak var unknownIcon: CategoryIcon! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveysViewController.handleIconTap(gesture:)))
//            unknownIcon.addGestureRecognizer(tap)
//        }
//    }

    fileprivate var icons: [Icon] = []
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
//        startTimer()
        
        loadData()
        tabBarController?.tabBar.isUserInteractionEnabled = false
        tabBarController?.tabBar.tintColor = .lightGray
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: K_COLOR_RED], for: .selected)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        UIView.animate(withDuration: 0.2) {
//            self.navigationItem.titleView?.alpha = 0
//        }
//    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if startingPoint == .zero, let rbtn = navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
                startingPoint = rbtn.convert(rbtn.center, to: tabBarController?.view)
        }
        (navigationController as? NavigationControllerPreloaded)?.startingPoint = .zero
        UIView.animate(withDuration: 0.2, animations: {
            self.navigationItem.titleView?.alpha = 1
        }) {
            _ in
//            if self.isDataLoaded {
//                if let rbtn = self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
//                    rbtn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//                    UIView.animate(withDuration: 0.3) {
//                        rbtn.transform = .identity
//                        rbtn.alpha = 1w
//                    }
//                }
//            }
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
            tabBarController?.setTabBarVisible(visible: true, animated: true)
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
            icons = [newIcon, hotIcon, categoryIcon]
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
        
        addChild(self.newTableVC)
        newTableVC.delegate = self
        newTableVC.didMove(toParent: self)
//        addChild(self.topTableVC)
//        topTableVC.delegate = self
//        topTableVC.didMove(toParent: self)
        addChild(self.surveyStackVC)
        surveyStackVC.delegate = self
        surveyStackVC.didMove(toParent: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (navigationController as? NavigationControllerPreloaded)?.delegate = nil
        if segue.identifier == Segues.App.FeedToCategory, let destinationVC = segue.destination as? CategoryTableViewController {
            if let cell = newTableVC.tableView.cellForRow(at: newTableVC.tableView.indexPathForSelectedRow!) as? SubcategoryTableViewCell {
                destinationVC.category = cell.category
                destinationVC.title = cell.category.title
            }
        } else if segue.identifier == Segues.App.FeedToSurvey, let destinationVC = segue.destination as? SurveyViewController {
//            var cell: SurveyTableViewCell!
            switch currentIcon {
            case .New:
                if let cell = newTableVC.tableView.cellForRow(at: newTableVC.tableView.indexPathForSelectedRow!) as? SurveyTableViewCell {
                    destinationVC.surveyLink = cell.survey
                    destinationVC.apiManager = apiManager
                }
//            case.Top:
//                if let cell = topTableVC.tableView.cellForRow(at: topTableVC.tableView.indexPathForSelectedRow!) as? SurveyTableViewCell {
//                    destinationVC.surveyLink = cell.survey
//                    destinationVC.apiManager = apiManager
//                }
            default: //Hot
                print("s")
//                if let sender = sender as? SurveyStackViewController {
//                    destinationVC.apiManager = apiManager
//                    destinationVC.survey = sender.surveyPreview.survey
//                    destinationVC.delegate = sender
//                }
            }
            tabBarController?.setTabBarVisible(visible: false, animated: true)
            
        } else if segue.identifier == Segues.App.FeedToSurveyFromTop, let destinationVC = segue.destination as? SurveyViewController, let sender = sender as? SurveyStackViewController {
            destinationVC.apiManager = apiManager
            destinationVC.needsImageLoading = false
            destinationVC.survey = sender.surveyPreview.survey
            destinationVC.delegate = sender
            tabBarController?.setTabBarVisible(visible: false, animated: true)
        } else if segue.identifier == Segues.App.FeedToNewSurvey { //New survey
            navigationController?.setNavigationBarHidden(true, animated: false)
            tabBarController?.setTabBarVisible(visible: false, animated: false)
            if let _sender = sender as? EmptySurvey {
                (navigationController as? NavigationControllerPreloaded)?.startingPoint = _sender.startingPoint//.createButton.center//.convert(_sender.createButton.frame.origin, to: tabBarController?.view)
            } else {
                (navigationController as? NavigationControllerPreloaded)?.startingPoint = startingPoint
            }
        } else if segue.identifier == Segues.App.FeedToUser, let userProfile = sender as? UserProfile, let destinationVC = segue.destination as? UserViewController {
            destinationVC.userProfile = userProfile
            tabBarController?.setTabBarVisible(visible: false, animated: true)
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
            for i in icons {
                if i === icon {
                    i.state = .enabled
                } else {
                    i.state = .disabled
                }
            }
            navigationController?.setNavigationBarHidden(false, animated: true)
            currentIcon = CurrentIcon.getCurrentIconByTag(tag: icon.tag)
        }
    }
    
    @objc private func handleAddTap() {
        performSegue(withIdentifier: Segues.App.FeedToNewSurvey, sender: self)
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
    
    fileprivate func presentSubview() {
        let oldView = container.subviews.first
        var newView: UIView!
        switch currentIcon {
        case .New:
            newTableVC.view.frame = container.frame
            newView = newTableVC.view
//        case .Top:
//            topTableVC.view.frame = container.frame
//            newView = topTableVC.view
        case .Hot:
            surveyStackVC.view.frame = container.frame
            newView = surveyStackVC.view
        case .Category:
            print("")
//        case .Unknown:
//            print("")
        default:
            print("default")
        }
        newView.alpha = 0
        newView.addEquallyTo(to: container)
        newView.layer.zPosition = 2
        newView.transform = newView.transform.scaledBy(x: 0.93, y: 0.93)
        if oldView != nil {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                    oldView!.alpha = 0
                    oldView!.transform = oldView!.transform.scaledBy(x: 0.93, y: 0.93)
            }) {
                _ in
                oldView!.removeFromSuperview()
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            newView.alpha = 1
            newView.transform = .identity
        })
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
                if json != nil, !self.interruptRequests {
                    AppData.shared.system.APIVersion = json!["api_version"].stringValue
                    SurveyCategories.shared.importJson(json!["categories"])
                    SurveyCategories.shared.updateCount(json!["total_count"])
                    ClaimCategories.shared.importJson(json!["claim_categories"])
                    Surveys.shared.importSurveys(json!["surveys"])
                    self.newTableVC.refreshControl?.endRefreshing()
                    self.newTableVC.needsAnimation = true
                    if self.isInitialLoad {
                        self.newTableVC.tableView.isUserInteractionEnabled = true
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
                    self.newTableVC.refreshControl?.attributedTitle = NSAttributedString(string: "Ошибка, повторите позже", attributes: semiboldAttrs_red_12)
                    self.newTableVC.refreshControl?.endRefreshing()
                    delay(seconds: 0.5) {
                        self.newTableVC.refreshControl?.attributedTitle = NSAttributedString(string: "")
                    }
                }
            }
            if json != nil {
                Surveys.shared.importSurveys(json!)
                self.newTableVC.refreshControl?.endRefreshing()
                self.newTableVC.needsAnimation = true
                if self.isInitialLoad {
                    self.newTableVC.tableView.isUserInteractionEnabled = true
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

