//
//  TopSurveysTableViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//



import UIKit



class SurveysTableViewController: UITableViewController {

    deinit {
        "SurveysTableViewController deinit"
        NotificationCenter.default.removeObserver(self)
    }
//    fileprivate var requestAttempt = 0 {
//        didSet {
//            if oldValue != requestAttempt {
//                if requestAttempt > MAX_REQUEST_ATTEMPTS {
//                    requestAttempt = 0
//                }
//            }
//        }
//    }
    enum SurveyTableType {
        case New, Top, User
    }
    
    var type: SurveyTableType = .New
    var delegate: UIViewController?
    public var needsAnimation = true
//    private var isViewSetupCompleted = false
//    private var loadingIndicator: LoadingIndicator!
//    fileprivate var isInitialLoad = true {
//        didSet {
//            if !isInitialLoad {
//                vc.addButton.isEnabled = true
//            }
//        }
//    }
    fileprivate var navTitle: UIImageView?
    var navTitleImage: UIImage?
    fileprivate var navTitleImageSize: CGSize = .zero
    fileprivate var lastContentOffset: CGFloat = 0
    
    class var surveyNib: UINib {
        return UINib(nibName: "SurveyTableViewCell", bundle: nil)
    }
//    class var categoryNib: UINib {
//        return UINib(nibName: "CategoryTableViewCell", bundle: nil)
//    }
//    class var subcategoryNib: UINib {
//        return UINib(nibName: "SubcategoryTableViewCell", bundle: nil)
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
//        NotificationCenter.default.addObserver(self,
//                                       selector: #selector(SurveysTableViewController.updateTableView),
//                                       name: kNotificationTopSurveysUpdated,
//                                       object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SurveysTableViewController.updateTableView),
                                               name: kNotificationNewSurveysUpdated,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SurveysTableViewController.profileImageReceived(_:)),
                                               name: kNotificationProfileImageReceived,
                                               object: nil)
        
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.addTarget(self, action: #selector(SurveysTableViewController.refreshTableView), for: .valueChanged)
        refreshControl?.tintColor = K_COLOR_RED
    }
    
    
    
    private func setupViews() {
        tableView.register(SurveysTableViewController.surveyNib, forCellReuseIdentifier: "topSurveyCell")
//        tableView.register(FeedSurveysTableViewController.categoryNib, forCellReuseIdentifier: "categoryCell")
//        tableView.register(FeedSurveysTableViewController.subcategoryNib, forCellReuseIdentifier: "subcategoryCell")
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
        
        if type == .User {
            navTitleImageSize = CGSize(width: 45, height: 45)
            navTitle = UIImageView(frame: CGRect(origin: .zero, size: navTitleImageSize))
            if let _image = navTitleImage {
                navTitle!.image = _image.circularImage(size: navTitleImageSize, frameColor: K_COLOR_RED)
            } else if let _image = UIImage(named: "user") {
                navTitle!.image = _image.circularImage(size: navTitleImageSize, frameColor: K_COLOR_RED)
            }
            navTitle!.isUserInteractionEnabled = false
            navTitle!.clipsToBounds = false
            navigationItem.titleView = navTitle
        }
    }

    @objc func profileImageReceived(_ notification: Notification) {
        if type == .User, navTitle != nil, let image = notification.object as? UIImage {
            UIView.transition(with: navTitle!,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.navTitle!.image = image.circularImage(size: self.navTitleImageSize, frameColor: K_COLOR_RED) },
                              completion: nil)
        }
    }
    
    
    @objc private func updateTableView() {
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
//        if vc.currentIcon == .Category {
//            return SurveyCategories.shared.tree.count
//        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if vc.currentIcon == .New {
        switch type {
        case .New:
            return Surveys.shared.newLinks.count
        case .Top:
            return Surveys.shared.topLinks.count
        default:
            return Surveys.shared.topLinks.count
        }
        
//        } else if vc.currentIcon == .Hot{
//            return Surveys.shared.topSurveys.count
//        } else {
//            return SurveyCategories.shared.tree[section].first!.value.count
//        }
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if vc.currentIcon == .Category {
//            return SurveyCategories.shared.tree[section].first?.key
//        }
//        return nil
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if vc.currentIcon != .Category {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "topSurveyCell", for: indexPath) as? SurveyTableViewCell {

                var dataSource: [ShortSurvey]
//                if vc.currentIcon == .New {
//                    dataSource = Surveys.shared.newSurveys
//                } else {
//                    dataSource = Surveys.shared.topSurveys
//                }
                switch type {
                case .New:
                    dataSource = Surveys.shared.newLinks
                default:
                    dataSource = Surveys.shared.topLinks
                }
                cell.survey = dataSource[indexPath.row]
                cell.title.text = dataSource[indexPath.row].title
                for view in cell.tags.subviews {
                    view.removeFromSuperview()
                }
                //        if cell.tags.subviews.isEmpty {
                if let subcategory = dataSource[indexPath.row].category, let category: SurveyCategory? = dataSource[indexPath.row].category?.parent {
                    let categoryTag = TagLabel(frame: cell.tags.frame, surveyCategory: category!)
                    cell.completionPercentage.color = category!.tagColor
                    cell.tags.addSubview(categoryTag)
                    cell.tags.addSubview(TagLabel(frame: CGRect(origin: CGPoint(x: categoryTag.frame.maxX + 2, y: 0), size: categoryTag.frame.size), surveyCategory: subcategory))
                    cell.duration.text = "\(daysBetweenDate(startDate: dataSource[indexPath.row].startDate, endDate: Date())) дн."
                }
                //        }

                cell.completionPercentage.progress = CGFloat(dataSource[indexPath.row].completionPercentage)

                if (indexPath.row % 2 == 0) {
                    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
                } else {
                    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                }
                return cell
            }
//        }
//        } else {
//            if let cell = tableView.dequeueReusableCell(withIdentifier: "subcategoryCell", for: indexPath) as? SubcategoryTableViewCell {
//                cell.title.text = SurveyCategories.shared.tree[indexPath.section].first?.value[indexPath.row].title.lowercased()//
//                cell.category = SurveyCategories.shared.tree[indexPath.section].first?.value[indexPath.row]
//                if (indexPath.row % 2 == 0) {
//                    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
//                } else {
//                    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
//                }
//                return cell
//            }
//        }
        return UITableViewCell()
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if vc.currentIcon == .Category, let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as? CategoryTableViewCell {
//            cell.title.text = SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.title.uppercased()
//            cell.backgroundColor = SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.tagColor ?? UIColor.gray
//            cell.total.text = "всего " + (SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.total.stringValue!)!
//            cell.active.text = "активных " + (SurveyCategories.shared.categories.filter { $0.title == SurveyCategories.shared.tree[section].first?.key}.first?.active.stringValue!)!
//            return cell
//        }
//        return nil
//    }
    
    @objc private func refreshTableView() {
        if delegate != nil, delegate is SurveysViewController {
            (delegate as! SurveysViewController).updateSurveys(type: .New)
        }
//        updateSurveys(type: vc.currentIcon == .New ? .New : .Top)
    }

//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if vc.currentIcon == .Category, let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as? CategoryTableViewCell {
//            return cell.contentView.frame.height
//        }
//        return 0
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if vc.currentIcon == .Category {
//            return 35
//        } else {
//            return 80
//        }
        return 80
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if vc.currentIcon == .Category {
//            cell.alpha = 0
//            UIView.animate(withDuration: 0.1, delay: 0.05, options: [], animations: { cell.alpha = 1 })
//        } else {
//            if needsAnimation {
//                let animation = AnimationFactory.makeSlideInWithFade(duration: 0.1, delayFactor: 0.05)//AnimationFactory.makeFadeAnimation(duration: 0.25, delayFactor: 0.015)//.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.25, delayFactor: 0.03)//makeFadeAnimation(duration: 0.25, delayFactor: 0.03)//makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.2, delayFactor: 0.05)//
//                let animator = Animator(animation: animation)
//                animator.animate(cell: cell, at: indexPath, in: tableView)
//                needsAnimation = (tableView.visibleCells.count < (indexPath.row + 1))
//            }
//        }
//    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.alpha = 0
        UIView.animate(withDuration: 0.15) { view.alpha = 1 }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if vc.currentIcon == .Category {
//            vc.performSegue(withIdentifier: kSegueAppTopSurveysToCategory, sender: nil)
//        } else {
//            vc.performSegue(withIdentifier: kSegueAppFeedToSurvey, sender: nil)
//        }
        if delegate != nil, delegate is SurveysViewController {
            (delegate as! SurveysViewController).performSegue(withIdentifier: Segues.App.FeedToSurvey, sender: nil)
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffset < scrollView.contentOffset.y {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else if (lastContentOffset - scrollView.contentOffset.y) > 160 {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}

extension SurveysTableViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol {
        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).apiManager
    }
}

typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void

final class Animator {
    private var hasAnimatedAllCells = false
    private let animation: Animation
    
    init(animation: @escaping Animation) {
        self.animation = animation
    }
    
    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        guard !hasAnimatedAllCells else {
            return
        }
        
        animation(cell, indexPath, tableView)
        
        hasAnimatedAllCells = (tableView.visibleCells.last != nil)//tableView.isLastVisibleCell(at: indexPath)
    }
}

enum AnimationFactory {
    
    static func makeFadeAnimation(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in
            cell.alpha = 0
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                animations: {
                    cell.alpha = 1
            })
        }
    }
    
    static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.1,
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
    
    static func makeMoveUpWithFade(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight / 2)
            cell.alpha = 0
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
                    cell.alpha = 1
            })
        }
    }
    
    static func makeSlideIn(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                options: [.curveEaseIn],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
    
    static func makeSlideInWithFade(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: tableView.bounds.width/3, y: 0)
            cell.alpha = 0
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                options: [.curveEaseOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
                    cell.alpha = 1
            })
        }
    }
}
