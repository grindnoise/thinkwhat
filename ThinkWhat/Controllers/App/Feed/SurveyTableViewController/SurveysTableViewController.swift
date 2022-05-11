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
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        if #available(iOS 13.0, *) {
//            return .darkContent
//        } else {
//            return .lightContent
//        }
//    }
    
    override var childForStatusBarStyle: UIViewController? {
        return children.first
    }
    
    enum SurveyTableType {
        case New, Top, User, UserFavorite, Own, Favorite, Category
    }
    
    var category: Topic? {
        didSet {
            type = .Category
        }
    }
    var type: SurveyTableType = .New {
        didSet {
            if oldValue != type {
//                NotificationCenter.default.removeObserver(self)
                if type == .New || type == .Top {
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(SurveysTableViewController.updateTableView),
                                                           name: Notifications.Surveys.UpdateNewSurveys,
                                                           object: nil)
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(SurveysTableViewController.updateTableView),
                                                           name: Notifications.Surveys.UpdateTopSurveys,
                                                           object: nil)
                    
                    //            refreshControl?.attributedTitle = NSAttributedString(string: "")
                    //            refreshControl?.addTarget(self, action: #selector(SurveysTableViewController.refreshTableView), for: .valueChanged)
                    //            refreshControl?.tintColor = K_COLOR_RED
                } else if type == .Own || type == .Favorite {
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(SurveysTableViewController.updateTableView),
                                                           name: Notifications.Surveys.OwnSurveysUpdated,
                                                           object: nil)
                    //            refreshControl?.attributedTitle = NSAttributedString(string: "")
                    //            refreshControl?.addTarget(self, action: #selector(SurveysTableViewController.refreshTableView), for: .valueChanged)
                    //            refreshControl?.tintColor = K_COLOR_RED
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(SurveysTableViewController.updateTableView),
                                                           name: Notifications.Surveys.UpdateFavorite,
                                                           object: nil)
                    //            refreshControl?.attributedTitle = NSAttributedString(string: "")
                    //            refreshControl?.addTarget(self, action: #selector(SurveysTableViewController.refreshTableView), for: .valueChanged)
                    //            refreshControl?.tintColor = K_COLOR_RED
                } else if type == .User || type == .UserFavorite {
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(SurveysTableViewController.profileImageReceived(_:)),
                                                           name: Notifications.UI.ImageReceived,
                                                           object: nil)
                    if needsAwaitForNotification {
                        NotificationCenter.default.addObserver(self,
                                                               selector: #selector(SurveysTableViewController.updateTableView(_:)),
                                                               name: Notifications.Surveys.UserSurveysUpdated,
                                                               object: nil)
                        NotificationCenter.default.addObserver(self,
                                                               selector: #selector(SurveysTableViewController.updateTableView),
                                                               name: Notifications.Surveys.UserFavoriteSurveysUpdated,
                                                               object: nil)
                        
                    }
                    //            tableView.refreshControl = nil
                } else if type == .Category {
                    //            NotificationCenter.default.addObserver(self,
                    //                                                   selector: #selector(SurveysTableViewController.profileImageReceived(_:)),
                    //                                                   name: Notifications.UI.ProfileImageReceived,
                    //                                                   object: nil)
                    //            if needsAwaitForNotification {
                    //                NotificationCenter.default.addObserver(self,
                    //                                                       selector: #selector(SurveysTableViewController.updateTableView),
                    //                                                       name: Notifications.Surveys.UserFavoriteSurveysUpdated,
                    //                                                       object: nil)
                    //            }
                }
                tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
            }
        }
    }
    var delegate: UIViewController?
//    public var needsAnimation = true
    fileprivate var isViewSetupCompleted = false
    fileprivate var loadingIndicator: LoadingIndicator!
    var needsAwaitForNotification = false
//    fileprivate var isInitialLoad = true {
//        didSet {
//            if !isInitialLoad {
//                vc.addButton.isEnabled = true
//            }
//        }
//    }
    fileprivate var navTitle: UIView?
    var navTitleImage: UIImage?
    fileprivate var navTitleImageSize: CGSize = .zero
    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate var userSurveysReceived = false {
        didSet {
            if userSurveysReceived {
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.alpha = 0
                }) {
                    _ in
                    self.loadingIndicator.removeAllAnimations()
                    self.tableView.reloadData()
                    UIView.animate(withDuration: 0.3) {
                        self.tableView.alpha = 1
                    }
                }
            }
        }
    }
    weak var userprofile: Userprofile?
    
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
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.addTarget(self, action: #selector(SurveysTableViewController.refreshTableView), for: .valueChanged)
        refreshControl?.tintColor = K_COLOR_RED
        
    navigationItem.backBarButtonItem?.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        needsAnimation = true
//        if userSurveysReceived {
        
//        }
        if !isViewSetupCompleted {
            if type == .User || type == .UserFavorite, needsAwaitForNotification {
                tabBarController?.setTabBarVisible(visible: false, animated: false)
                loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height)))
                loadingIndicator.layoutCentered(in: view, multiplier: 0.6)//addEquallyTo(to: tableView)
                loadingIndicator.addEnableAnimation()
                isViewSetupCompleted = true
                if let nav = navigationController as? NavigationControllerPreloaded {
                    nav.isShadowed = true
                }
            } else if type == .Category {
                if let nav = navigationController as? NavigationControllerPreloaded {
                    nav.isShadowed = true
                }
            }
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
////        tableView.reloadData()
//        let seconds = Double(tableView.visibleCells.count) * 0.04 + 0.2
//        delay(seconds: seconds) {
//            self.needsAnimation = false
//        }
//    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        navigationItem.backBarButtonItem?.title = ""//               = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
//    }
    override func viewDidDisappear(_ animated: Bool) {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: false)
        }
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
        navTitleImageSize = CGSize(width: 45, height: 45)
        if type == .User || type == .UserFavorite {
            navTitleImageSize = CGSize(width: 45, height: 45)
            navTitle = UIImageView(frame: CGRect(origin: .zero, size: navTitleImageSize))
            if let _image = navTitleImage {
                (navTitle! as! UIImageView).image = _image.circularImage(size: navTitleImageSize, frameColor: K_COLOR_RED)
            } else if let _image = UIImage(named: "user") {
                (navTitle! as! UIImageView).image = _image.circularImage(size: navTitleImageSize, frameColor: K_COLOR_RED)
            }
            navTitle!.isUserInteractionEnabled = false
            navTitle!.clipsToBounds = false
            navigationItem.titleView = navTitle
        } else if type == .Category {
            navTitleImageSize = CGSize(width: 45, height: 45)
            let icon = Icon(frame: CGRect(origin: .zero, size: navTitleImageSize))
            icon.category = Icon.Category(rawValue: category!.id) ?? .Null
            icon.isOpaque = false
            icon.backgroundColor = category?.parent?.tagColor ?? category?.tagColor
            navTitle = icon
            navTitle!.isUserInteractionEnabled = false
            navTitle!.clipsToBounds = false
            navigationItem.titleView = navTitle
        } else if type == .Own || type == .Favorite {
            navTitleImageSize = CGSize(width: 45, height: 45)
            navTitle = UIImageView(frame: CGRect(origin: .zero, size: navTitleImageSize))
            if let imagePath = UserDefaults.Profile.imagePath, let image = UIImage(contentsOfFile: imagePath) {
                (navTitle! as! UIImageView).image = image.circularImage(size: navTitleImageSize, frameColor: K_COLOR_RED)
            } else if let _image = UIImage(named: "user") {
                (navTitle! as! UIImageView).image = _image.circularImage(size: navTitleImageSize, frameColor: K_COLOR_RED)
            }
            navTitle!.isUserInteractionEnabled = false
            navTitle!.clipsToBounds = false
            navigationItem.titleView = navTitle
        }
    }

    @objc func profileImageReceived(_ notification: Notification) {
        if type == .User || type == .User, navTitle != nil, let image = notification.object as? UIImage {
            UIView.transition(with: navTitle!,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { (self.navTitle! as! UIImageView).image = image.circularImage(size: self.navTitleImageSize, frameColor: K_COLOR_RED) },
                              completion: nil)
        }
    }
    
    
    @objc private func updateTableView(_ notification: Notification?) {
        if let name = notification?.name, name == Notifications.Surveys.UserSurveysUpdated || name == Notifications.Surveys.UserFavoriteSurveysUpdated {
            userSurveysReceived = true
        }
//        if type == .New || type == .Top {
            //TODO User, UserFavorite, Own, Favorite?
            tableView.reloadData()
//        }
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
            return Surveys.shared.newReferences.count
        case .Top:
            return Surveys.shared.topReferences.count
        case .User:
            if !needsAwaitForNotification || userSurveysReceived {
                return Userprofiles.shared.current?.surveys.count ?? 0
            } else {
                return 0
            }
        case .UserFavorite:
            if !needsAwaitForNotification ||  userSurveysReceived {
                return Userprofiles.shared.current?.favoritesTotal ?? 0
            } else {
                return 0
            }
        case .Category:
            return SurveyReferences.shared.all.filter({ $0.topic == self.category }).count
//        default:
//            print("default")
            //return Surveys.shared.topLinks.count
        case .Own:
            return Surveys.shared.ownReferences.count
        case .Favorite:
            return Surveys.shared.favoriteReferences.count
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

                var dataSource: [SurveyReference]
//                if vc.currentIcon == .New {
//                    dataSource = Surveys.shared.newSurveys
//                } else {
//                    dataSource = Surveys.shared.topSurveys
//                }
                switch type {
                case .New:
                    dataSource = Surveys.shared.newReferences
                case .Top:
                    dataSource = Surveys.shared.topReferences
                case .User:
                    dataSource = Userprofiles.shared.current!.surveys//userProfile!.surveysCreated
                case .UserFavorite:
                    dataSource = Userprofiles.shared.current!.favorites.values.first ?? []//userProfile!.surveysFavorite
//                case .Category:
//                    dataSource = Surveys.shared.allLinks.filter { $0.category == self.category }
                case .Own:
                    dataSource = Surveys.shared.ownReferences
                case .Favorite:
                    dataSource = Surveys.shared.favoriteReferences.keys.compactMap({ $0 })
                default:
                    dataSource = Surveys.shared.topReferences
                }
                let survey = dataSource[indexPath.row]

                cell.survey = survey
                let attrString = NSMutableAttributedString()
                attrString.append(NSAttributedString(string: "  \(survey.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 9), foregroundColor: .white, backgroundColor: .clear)))
                attrString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 9), foregroundColor: .white, backgroundColor: .clear)))
                attrString.append(NSAttributedString(string: "\(survey.topic.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 9), foregroundColor: .white, backgroundColor: .clear)))
//                attrString.append(NSAttributedString(string: " \(survey.category!.title.uppercased())", attributes: StringAttributes.Bold.red_11))
//                attrString.append(NSAttributedString(string: " / ", attributes: StringAttributes.Regular.red_11))
//                attrString.append(NSAttributedString(string: "\(survey.category!.parent!.title.uppercased()) ", attributes: StringAttributes.SemiBold.red_11))
                cell.category.attributedText = attrString
                cell.category.backgroundColor = .clear
                cell.duration.backgroundColor = .clear
                let color = survey.topic.tagColor 
                    cell.category.backgroundColor = color//.withAlphaComponent(0.5)
                    cell.duration.backgroundColor = color
                    cell.join.backgroundColor = color
                    cell.join_2.backgroundColor = color
                    cell.category.cornerRadius = cell.category.frame.height / 2.5
                    cell.duration.cornerRadius = cell.duration.frame.height / 2.5
                cell.title.text = survey.title
                cell.duration.attributedText = NSAttributedString(string: " \(dataSource[indexPath.row].startDate.toDateStringLiteral_dMMM())   ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 9), foregroundColor: .white, backgroundColor: .clear))
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
        if type == .New || type == .Top {
            if delegate != nil, delegate is SurveysViewController {
                (delegate as! SurveysViewController).updateSurveys(type: type == .New ? .New : .Top)
            }
        } else if type == .UserFavorite || type == .User {
            loadSurveys()
        } else if type == .Category {
            fatalError("TODO: refresh")
        }
//        updateSurveys(type: vc.currentIcon == .New ? .New : .Top)
    }
    
    private func loadSurveys() {
        func stopRefreshing(error: Error) {
            refreshControl?.attributedTitle = NSAttributedString(string: "Ошибка, повторите позже", attributes: StringAttributes.SemiBold.red_12)//semiboldAttrs_red_12)
            refreshControl?.endRefreshing()
            delay(seconds: 0.5) {
                self.refreshControl?.attributedTitle = NSAttributedString(string: "")
            }
            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
        }
        
        var _type: API.SurveyType!
        if type == .User {
            _type = API.SurveyType.User
        } else if type == .UserFavorite {
            _type = API.SurveyType.UserFavorite
        }
//        API.shared.loadSurveysByOwner(user: Userprofiles.shared.current!, type: _type) { result in
//            switch result {
//            case .success(let json):
//                //TODO: - поместить в json с ключом
//                var _type: Userprofile.UserSurveyType!
//                if self.type == .User {
//                    _type = Userprofile.UserSurveyType.Own
//                } else if self.type == .UserFavorite {
//                    _type = Userprofile.UserSurveyType.Favorite
//                }
//                do {
//                    AppData.shared.userprofile.loadSurveys(data: try json.rawData())//importSurveys(_type, json: json!)
//                    self.refreshControl?.endRefreshing()
//                    self.tableView.reloadData()
//                } catch (let error) {
//                    stopRefreshing(error: error)
//                }
//            case .failure(let error):
//                stopRefreshing(error: error)
//            }
//        }
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
//        if needsAnimation {
//            let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.2, delayFactor: 0.03)////makeFadeAnimation(duration: 0.15, delayFactor: 0.04)//.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.25, delayFactor: 0.03)//makeFadeAnimation(duration: 0.25, delayFactor: 0.03)AnimationFactory.makeSlideInWithFade(duration: 0.1, delayFactor: 0.05)//
//            let animator = Animator(animation: animation)
//            animator.animate(cell: cell, at: indexPath, in: tableView)
////            needsAnimation = (tableView.visibleCells.count < (indexPath.row + 1))
//        }
//    }
    
//    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if needsAnimation {
//            needsAnimation = (tableView.visibleCells.count < (indexPath.row + 1))
//        }
//    }
    
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        view.alpha = 0
//        UIView.animate(withDuration: 0.15) { view.alpha = 1 }
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if vc.currentIcon == .Category {
//            vc.performSegue(withIdentifier: kSegueAppTopSurveysToCategory, sender: nil)
//        } else {
//            vc.performSegue(withIdentifier: kSegueAppFeedToSurvey, sender: nil)
//        }
        if delegate != nil, delegate is SurveysViewController, let surveyRef = (tableView.cellForRow(at: indexPath) as? SurveyTableViewCell)?.survey as? SurveyReference {
            (delegate as! SurveysViewController).performSegue(withIdentifier: Segues.App.FeedToSurvey, sender: surveyRef)
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if type == .New || type == .Top {
            lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if type == .New || type == .Top {
            if self.lastContentOffset < scrollView.contentOffset.y {
                navigationController?.setNavigationBarHidden(true, animated: true)
            } else if (lastContentOffset - scrollView.contentOffset.y) > 160 {
                navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }
}

//extension SurveysTableViewController: ServerInitializationProtocol {
//    func initializeServerAPI() -> APIManagerProtocol {
//        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).apiManager
//    }
//
//    fileprivate func loadSurveys() {
//        apim
//    }
//}

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

//extension SurveysTableViewController: ServerProtocol {
//    file
//}
