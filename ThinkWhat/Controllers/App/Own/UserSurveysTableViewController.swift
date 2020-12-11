//
//  OwnSurveysTableViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class UserSurveysTableViewController: UITableViewController {

//    class var surveyNib: UINib {
//        return UINib(nibName: "SurveyTableViewCell", bundle: nil)
//    }
//    
//    public var needsAnimation = true
//    private var vc: UserSurveysViewController!
//    private var semiboldAttrs       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 12),
//                                       NSAttributedString.Key.foregroundColor: K_COLOR_RED,
//                                       NSAttributedString.Key.backgroundColor: UIColor.clear]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        vc = parent! as! UserSurveysViewController
//        setupViews()
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(UserSurveysTableViewController.updateTableView),
//                                               name: Notifications.Surveys.OwnSurveysUpdated,
//                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(UserSurveysTableViewController.updateTableView),
//                                               name: Notifications.Surveys.FavoriteSurveysUpdated,
//                                               object: nil)
//        refreshControl?.attributedTitle = NSAttributedString(string: "")
//        refreshControl?.addTarget(self, action: #selector(UserSurveysTableViewController.refreshTableView), for: .valueChanged)
//        refreshControl?.tintColor = K_COLOR_RED
//    }
//    
//    private func setupViews() {
//        tableView.register(SurveysTableViewController.surveyNib, forCellReuseIdentifier: "topSurveyCell")
//        DispatchQueue.main.async {
//            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//            self.navigationController?.navigationBar.shadowImage     = UIImage()
//            self.navigationController?.navigationBar.isTranslucent   = false
//            self.navigationController?.isNavigationBarHidden         = false
//            self.navigationController?.navigationBar.barTintColor    = .white
//            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
//        }
//    }
//    
//    @objc private func updateTableView() {
//        tableView.reloadData()
//    }
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if vc.control.selectedSegmentIndex == 0 {
//            return Surveys.shared.ownLinks.count
//        } else if vc.control.selectedSegmentIndex == 1 {
//            return Surveys.shared.favoriteLinks.count
//        }
//        return 0
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "topSurveyCell", for: indexPath) as? SurveyTableViewCell {
//            
//            var dataSource: [ShortSurvey]
//            if vc.control.selectedSegmentIndex == 0 {
//                dataSource = Surveys.shared.ownLinks
//            } else {
//                dataSource = Array(Surveys.shared.favoriteLinks.keys)
//            }
//            cell.survey = dataSource[indexPath.row]
//            cell.title.text = dataSource[indexPath.row].title
////            for view in cell.tags.subviews {
////                view.removeFromSuperview()
////            }
////            if let subcategory = dataSource[indexPath.row].category, let category: SurveyCategory? = dataSource[indexPath.row].category?.parent {
////                let categoryTag = TagLabel(frame: cell.tags.frame, surveyCategory: category!)
////                cell.completionPercentage.color = category!.tagColor
////                cell.tags.addSubview(categoryTag)
////                cell.tags.addSubview(TagLabel(frame: CGRect(origin: CGPoint(x: categoryTag.frame.maxX + 2, y: 0), size: categoryTag.frame.size), surveyCategory: subcategory))
//                cell.duration.text = "\(daysBetweenDate(startDate: dataSource[indexPath.row].startDate, endDate: Date())) дн."
////            }
////
////            cell.completionPercentage.progress = CGFloat(dataSource[indexPath.row].completionPercentage)
////
////            if (indexPath.row % 2 == 0) {
////                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
////            } else {
////                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
////            }
//            return cell
//        }
//        return UITableViewCell()
//    }
//    
//    @objc private func refreshTableView() {
//        updateSurveys(type: vc.control.selectedSegmentIndex == 0 ? .Own : .Favorite)
//    }
//    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if needsAnimation {
//            let animation = AnimationFactory.makeSlideInWithFade(duration: 0.1, delayFactor: 0.05)
//            let animator = Animator(animation: animation)
//            animator.animate(cell: cell, at: indexPath, in: tableView)
//            needsAnimation = (tableView.visibleCells.count < (indexPath.row + 1))
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        vc.performSegue(withIdentifier: Segues.App.UserSurveysToSurvey, sender: nil)
//    }
//}
//
//extension UserSurveysTableViewController: ServerInitializationProtocol {
//    func initializeServerAPI() -> APIManagerProtocol {
//        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).apiManager
//    }
//}
//
//extension UserSurveysTableViewController: ServerProtocol {
//    private func updateSurveys(type: APIManager.SurveyType) {
//        apiManager.loadSurveys(type: type) {
//            json, error in
//            if error != nil {
//                self.refreshControl?.attributedTitle = NSAttributedString(string: "Ошибка, повторите позже", attributes: self.semiboldAttrs)
//                self.refreshControl?.endRefreshing()
//                delay(seconds: 0.5) {
//                    self.refreshControl?.attributedTitle = NSAttributedString(string: "")
//                }
//            }
//            if json != nil {
//                Surveys.shared.importSurveys(json!)
//                self.refreshControl?.endRefreshing()
//                self.needsAnimation = true
//            }
//        }
//    }
}
