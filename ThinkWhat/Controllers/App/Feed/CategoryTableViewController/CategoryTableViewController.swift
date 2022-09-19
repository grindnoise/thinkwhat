////
////  CategoryTableViewController.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 04.11.2019.
////  Copyright © 2019 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//
//class CategoryTableViewController: UITableViewController {
//
//    var topic: Topic!// {
////        didSet {
////            if category != nil && oldValue != category {
////                self.updateSurveys()
////            }
////        }
////    }
//    public var needsAnimation = true
//    private var surveyReferences: [SurveyReference] = []
//    private var isViewSetupCompleted = false
//    private var loadingIndicator: LoadingIndicator!
//    private var isInitialLoad = true
//    private var semiboldAttrs       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 12),
//                                       NSAttributedString.Key.foregroundColor: K_COLOR_RED,
//                                       NSAttributedString.Key.backgroundColor: UIColor.clear]
//    class var surveyNib: UINib {
//        return UINib(nibName: "SurveyTableViewCell", bundle: nil)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        surveyReferences = SurveyReferences.shared.all.filter { $0.topic == topic }
//        self.tableView.register(CategoryTableViewController.surveyNib, forCellReuseIdentifier: "topSurveyCell")
//        setupViews()
//        if tableView.numberOfRows(inSection: 0) == 0 {
//            updateSurveys()
//        }
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(CategoryTableViewController.updateTableView),
//                                               name: Notifications.Surveys.SurveysByCategoryUpdated,
//                                               object: nil)
//        refreshControl?.attributedTitle = NSAttributedString(string: "")
//        refreshControl?.addTarget(self, action: #selector(CategoryTableViewController.refreshTableView), for: .valueChanged)
//        refreshControl?.tintColor = K_COLOR_RED
//    }
//    
//    private func setupViews() {
//        DispatchQueue.main.async {
//            
//            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//            self.navigationController?.navigationBar.shadowImage     = UIImage()
//            self.navigationController?.navigationBar.isTranslucent   = false
//            self.navigationController?.isNavigationBarHidden         = false
//            self.navigationController?.navigationBar.barTintColor    = .white
//            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
//        }
//    }
//
//    override func viewDidLayoutSubviews() {
//        tableView.layoutIfNeeded()
//        if !isViewSetupCompleted {
//            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: tableView.frame.width)))
//            loadingIndicator.layoutCentered(in: tableView,multiplier: 0.7)
//            isViewSetupCompleted = true
//            if tableView.numberOfRows(inSection: 0) == 0 {
//                loadingIndicator.addEnableAnimation()
//                tableView.isUserInteractionEnabled = false
//            }
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    
//    @objc private func updateTableView() {
//        tableView.reloadData()
//    }
//
//    @objc private func refreshTableView() {
//        updateSurveys()
//    }
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return surveyReferences.count//Surveys.shared.categorizedLinks[category]?.count ?? 0
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "topSurveyCell", for: indexPath) as? SurveyTableViewCell {//}, let dataSource = Surveys.shared.categorizedLinks[category] {
////                cell.title.text = dataSource[indexPath.row].title
////                for view in cell.tags.subviews {
////                    view.removeFromSuperview()
////                }
////                if let subcategory = dataSource[indexPath.row].category, let category: SurveyCategory? = dataSource[indexPath.row].category?.parent {
////                    let categoryTag = TagLabel(frame: cell.tags.frame, surveyCategory: category!)
////                    cell.completionPercentage.color = category!.tagColor
////                    cell.tags.addSubview(categoryTag)
////                    cell.tags.addSubview(TagLabel(frame: CGRect(origin: CGPoint(x: categoryTag.frame.maxX + 2, y: 0), size: categoryTag.frame.size), surveyCategory: subcategory))
////                    cell.duration.text = "\(daysBetweenDate(startDate: dataSource[indexPath.row].startDate, endDate: Date())) дн."
////                }
////
////                cell.completionPercentage.progress = CGFloat(dataSource[indexPath.row].completionPercentage)
////
////                if (indexPath.row % 2 == 0) {
////                    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
////                } else {
////                    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
////                }
//                return cell
//            }
//        return UITableViewCell()
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//            return 80
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
//    private func updateSurveys() {
//        API.shared.downloadSurveys(topic: topic) { result in
//            switch result {
//            case .success(let json):
//                Surveys.shared.load(JSON(["by_category": json]))
//                self.refreshControl?.endRefreshing()
//                self.needsAnimation = true
//                if self.isInitialLoad {
//                    self.tableView.isUserInteractionEnabled = true
//                    UIView.animate(withDuration: 0.3, animations: {
//                        self.loadingIndicator.alpha = 0
//                    }) {
//                        comleted in
//                        self.loadingIndicator.removeAllAnimations()
//                        self.isInitialLoad = false
//                    }
//                }
//            case .failure(let error):
//                print(error)
//                if self.isInitialLoad {
//                    self.updateSurveys()
//                } else {
//                    self.refreshControl?.attributedTitle = NSAttributedString(string: "Ошибка, повторите позже", attributes: self.semiboldAttrs)
//                    self.refreshControl?.endRefreshing()
//                    delay(seconds: 0.5) {
//                        self.refreshControl?.attributedTitle = NSAttributedString(string: "")
//                    }
//                }
//            }
//        }
//    }
//}
//
////extension CategoryTableViewController: ServerInitializationProtocol {
////    func initializeServerAPI() -> APIManagerProtocol {
////        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).apiManager
////    }
////}
////
////extension CategoryTableViewController: ServerProtocol {
//    
////}
