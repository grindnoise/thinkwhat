////
////  UserSurveysViewController.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 18.11.2019.
////  Copyright © 2019 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class UserSurveysViewController: UIViewController {
//
//    enum UserFeedIcon {
//        case Own, Favorite, Statistics, None
//
//        static func getCurrentIconByTag(tag: Int) -> UserFeedIcon {
//            switch tag {
//            case 0:
//                return .Own
//            case 1:
//                return .Favorite
//            case 2:
//                return .Statistics
//            default:
//                return .None
//            }
//        }
//    }
//
//    fileprivate var currentIcon: UserFeedIcon = .Own {
//        didSet {
//            if currentIcon != oldValue {
//                presentSubview(oldIcon: oldValue, newIcon: currentIcon)
//                switch currentIcon {
//                case .Own:
//                    setTitle("Мои")
//                case .Favorite:
//                    setTitle("Избранные")
//                case .Statistics:
//                    setTitle("Статистика")
//                default:
//                    print("Def")
//                }
//                tabBarController?.tabBar.items?[1].title = "Мои опросы"
//            }
//        }
//    }
//    fileprivate let tableVC: SurveysTableViewController = {
//        let storyboard = UIStoryboard(name: "Controllers", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "SurveysTableViewController") as! SurveysTableViewController
//        return vc
//    } ()
//
//    fileprivate let statisticsVC: StatisticsViewController = {
//        return StatisticsViewController(nibName :"StatisticsViewController",bundle : nil)
//    } ()
//    fileprivate var icons: [AnimatedIcon] = []
//    fileprivate var isViewSetupCompleted = false
//
//    @IBOutlet weak var container: UIView!
//    @IBOutlet weak var buttonsContainer: UIView!
//    @IBOutlet weak var ownIcon: MegaphoneIcon! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(UserSurveysViewController.handleIconTap(gesture:)))
//            ownIcon.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var favoriteIcon: HeartIcon! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(UserSurveysViewController.handleIconTap(gesture:)))
//            favoriteIcon.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var statsIcon: PieIcon! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(UserSurveysViewController.handleIconTap(gesture:)))
//            statsIcon.addGestureRecognizer(tap)
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//    }
//
//    override func viewDidLayoutSubviews() {
//        if !isViewSetupCompleted {
//            icons = [ownIcon, favoriteIcon, statsIcon]
//            isViewSetupCompleted = true
//        }
//    }
//
//    private func setupViews() {
//        let titleView = UIAnimatedTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40), title: "")
//        self.navigationItem.titleView = titleView
////        self.navigationItem.titleView?.alpha = 0
//        DispatchQueue.main.async {
//            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//            self.navigationController?.navigationBar.shadowImage     = UIImage()
//            self.navigationController?.navigationBar.isTranslucent   = false
//            self.navigationController?.isNavigationBarHidden         = false
//            self.navigationController?.navigationBar.barTintColor    = .white
//            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
//        }
//
//        DispatchQueue.main.async {
//            NotificationCenter.default.addObserver(self, selector: #selector(UserSurveysViewController.ownSurveysReceived), name: Notifications.Surveys.OwnSurveysReceived, object: nil)
//        }
//
//        if let btn = self.navigationItem.rightBarButtonItem as? UIBarButtonItem {
//            let v = Megaphone(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
//            v.isOpaque = false
//            v.clipsToBounds = false
//            let tap = UITapGestureRecognizer(target: self, action: #selector(UserSurveysViewController.handleAddTap))
//            v.addGestureRecognizer(tap)
//            btn.customView = v
//            btn.customView?.alpha = 0
//            btn.customView?.clipsToBounds = false
//            btn.customView?.layer.masksToBounds = false
//            btn.customView?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//            UIView.animate(
//                withDuration: 0.4,
//                delay: 0,
//                usingSpringWithDamping: 0.6,
//                initialSpringVelocity: 2.5,
//                options: [.curveEaseInOut],
//                animations: {
//                    btn.customView?.transform = .identity
//                    btn.customView?.alpha = 1
//            })
//            self.navigationController?.navigationBar.setNeedsLayout()
//        }
//
//        addChild(self.tableVC)
//        tableVC.delegate = self
//        tableVC.view.backgroundColor = .white
//        tableVC.didMove(toParent: self)
//
//    }
//
//    @objc private func handleIconTap(gesture: UITapGestureRecognizer) {
//        if gesture.state == .ended, let icon = gesture.view {
//            for i in icons {
//                if i === icon {
//                    i.state = .enabled
//                } else {
//                    i.state = .disabled
//                }
//            }
//            tableVC.tableView.setContentOffset(tableVC.tableView.contentOffset, animated: false)
//            navigationController?.setNavigationBarHidden(false, animated: true)
//            currentIcon = UserFeedIcon.getCurrentIconByTag(tag: icon.tag)
//        }
//    }
//
//    @objc private func handleAddTap() {
//        performSegue(withIdentifier: Segues.App.UserSurveysToNewSurvey, sender: self)
//    }
//
//    @objc fileprivate func ownSurveysReceived() {
//        ownIcon.state = .enabled
//        tableVC.type = .Own
//        self.setTitle("Мои")
//        self.presentSubview(oldIcon: nil, newIcon: .Own)
//        self.buttonsContainer.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
//        let shadowSize: CGFloat = 5
//        let contactRect = CGRect(x: -shadowSize, y: self.buttonsContainer.frame.height - (shadowSize * 0.4), width: self.buttonsContainer.frame.width + shadowSize * 2, height: shadowSize)
//        self.buttonsContainer.layer.shadowPath = UIBezierPath(rect: contactRect).cgPath
//        self.buttonsContainer.layer.shadowRadius = 5
//        self.buttonsContainer.layer.shadowOffset = .zero
//        self.buttonsContainer.layer.zPosition = 100
//        self.buttonsContainer.layer.shadowOpacity = 1
//    }
//
//    fileprivate func setTitle(_ _title: String) {
//        guard let titleView = navigationItem.titleView as? UIAnimatedTitleView else { return }
//
//        let fadeTextAnimation = CATransition()
//        fadeTextAnimation.duration = 0.1
//        fadeTextAnimation.type = .fade
//
//        titleView.layer.add(fadeTextAnimation, forKey: "pushText")
//        titleView.text = _title
//    }
//
//    fileprivate func presentSubview(oldIcon: UserFeedIcon?, newIcon: UserFeedIcon) {
//        func toggleTableType(own: Bool) {
//            setTitle(own ? "Мои" : "Избранное")
//            tableVC.type = own ? .Own : .Favorite
//        }
//
//        var oldView = container.subviews.first
//        //        var newView: UIView!
//        switch newIcon {
//        case .Own, .Favorite:
//            if oldIcon == .Statistics || oldIcon == nil {
//                tableVC.view.frame = container.frame
//                tableVC.view.alpha = 0
//                tableVC.view.addEquallyTo(to: container)
//                tableVC.view.layer.zPosition = 2
//                tableVC.view.transform = tableVC.view.transform.scaledBy(x: 1.05, y: 1.05)
//                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
//                    self.tableVC.view.transform = .identity
//                    self.tableVC.view.alpha = 1
//                })
//            } else {
//                oldView = nil
//                toggleTableType(own: newIcon == .Own ? true : false)
//            }
//
//        case .Statistics:
//            print("default")
////            surveyStackVC.view.frame = container.frame
////            surveyStackVC.view.alpha = 0
////            surveyStackVC.view.addEquallyTo(to: container)
////            surveyStackVC.view.layer.zPosition = 2
////            surveyStackVC.view.transform = surveyStackVC.view.transform.scaledBy(x: 0.85, y: 0.85)
////            UIView.animate(withDuration: 0.17, delay: 0, options: [.curveEaseOut], animations: {
////                self.surveyStackVC.view.transform = .identity
////                self.surveyStackVC.view.alpha = 1
////            })
//        default:
//            print("default")
//        }
//        if oldView != nil {
//            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveLinear], animations: {
//                oldView!.alpha = 0
//                oldView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//            }) {
//                _ in
//                oldView!.transform = .identity
//                oldView!.removeFromSuperview()
//            }
//        }
//    }
//
//
//
//
//    //MARK: - Navigation
////    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////        if segue.identifier == Segues.App.UserSurveysToSurvey, let destinationVC = segue.destination as? SurveyViewController, let cell = tableVC.tableView.cellForRow(at: tableVC.tableView.indexPathForSelectedRow!) as? SurveyTableViewCell {
////            destinationVC.surveyLink = cell.survey
////        } else {
////            showAlert(type: .Ok, buttons: [["Хорошо": [CustomAlertView.ButtonType.Ok: nil]]], text: "Ошибка вызова сервера, пожалуйста, обновите список")
////        }
////    }
//
//}
