//
//  UserViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.05.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, ServerProtocol {

    deinit {
        print("UserViewController deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    var userProfile: UserProfile!
    fileprivate var isViewSetupCompleted = false
    fileprivate var circularImage: UIImage!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var header: UserLogoHeader!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self as! UITableViewDelegate
        }
    }
    @IBOutlet weak var proportionalHeightConstraint: NSLayoutConstraint!
    fileprivate var headerHeightConstraint:NSLayoutConstraint!
    fileprivate var headerMaxHeight: CGFloat = 0
    fileprivate var leftEdgeInset: CGFloat = 0
    fileprivate var setNeedsAwaitForNotification = false
    var apiManager: APIManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UserViewController.profileImageReceived(_:)),
                                               name: Notifications.UI.ProfileImageReceived,
                                               object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        container.setNeedsLayout()
        container.layoutIfNeeded()
        if !isViewSetupCompleted {
            var image = UIImage()
            if let _image = userProfile.image  {
                image = _image
            } else {
                image = UIImage(named: "user")!
            }
            circularImage     = image.circularImage(size: header.imageView.frame.size, frameColor: K_COLOR_RED)
            header.nameTF.text   = userProfile.name
            header.ageGenderTF.text = "\(userProfile.age), \(userProfile.gender.rawValue)"
            header.imageView.image = circularImage
            isViewSetupCompleted = true
            headerHeightConstraint = header.heightAnchor.constraint(equalToConstant: header.frame.height)
            NSLayoutConstraint.deactivate([proportionalHeightConstraint])
            headerHeightConstraint.isActive = true
            headerMaxHeight = headerHeightConstraint.constant
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if esteemMinutes(date: userProfile.updatedAt) {
            apiManager.getUserStats(userProfile: userProfile) {
                json, error in
                if error != nil {
                    print(error?.localizedDescription)
                } else if json != nil {
                    self.userProfile.updateStats(json!)
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UserSurveysCell {
                        cell.count.text = "\(self.userProfile.surveysCreatedTotal)"
                    }
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? UserVotesCell {
                        cell.count.text = "\(self.userProfile.surveysAnsweredTotal)"
                    }
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? UserFavoriteCell {
                        cell.count.text = "\(self.userProfile.surveysFavoriteTotal)"
                    }
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? UserActivityCell {
                        cell.label.text = self.userProfile.gender == .Male ? "Был \(self.userProfile.lastVisit.toDateTimeStringLiteral())" : "Была \(self.userProfile.lastVisit.toDateTimeStringLiteral())"
                    }
                }
            }
        }
        if let nav = navigationController as? NavigationControllerPreloaded {
            delay(seconds: 0.3){
                nav.isShadowed = true
            }
        }
    }
    
    fileprivate func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
        

//            var image = UIImage()
//            if let _image = userProfile.image  {
//                image = _image
//            } else {
//                image = UIImage(named: "user")!
//            }
//            self.circularImage     = image.circularImage(size: self.userImage.frame.size, frameColor: K_COLOR_RED)
//            self.usernameTF.text   = self.userProfile.name
//                        self.genderTF.text = "\(self.userProfile.age), \(self.userProfile.gender.rawValue)"

    }
    
    @objc func profileImageReceived(_ notification: Notification) {
        if let image = notification.object as? UIImage {
            UIView.transition(with: header.imageView,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.header.imageView.image = image.circularImage(size: self.header.imageView.frame.size, frameColor: K_COLOR_RED) },
                              completion: nil)
        }
    }
    
    fileprivate func animateHeader(isFolding: Bool) {
        if isFolding {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: {
                self.view.setNeedsLayout()
                self.headerHeightConstraint.constant = 100
                self.header.stackView.alpha = 0
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
                self.view.setNeedsLayout()
                self.headerHeightConstraint.constant = self.headerMaxHeight
                self.header.stackView.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.App.UserToUserSurveys || segue.identifier == Segues.App.UserToUserFavoriteSurveys, let destinationVC = segue.destination as? SurveysTableViewController, let nav = navigationController as? NavigationControllerPreloaded {
            nav.transitionStyle = .Default
            if segue.identifier == Segues.App.UserToUserSurveys {
                destinationVC.type = .User
            } else if segue.identifier == Segues.App.UserToUserFavoriteSurveys {
                destinationVC.type = .UserFavorite
            }
            if let image = userProfile.image {
                destinationVC.navTitleImage = image
                destinationVC.userProfile = userProfile
                destinationVC.needsAwaitForNotification = setNeedsAwaitForNotification
            }
        }
//        } else if segue.identifier == Segues.App.UserToUserFavoriteSurveys, let destinationVC = segue.destination as? SurveysTableViewController {
//            destinationVC.type = .UserFavorite
//            if let image = userProfile.image {
//                destinationVC.navTitleImage = image
//                destinationVC.userProfile = userProfile
//                destinationVC.needsAwaitForNotification = setNeedsAwaitForNotification
//            }
//        }
    }
    
    fileprivate func esteemMinutes(date: Date) -> Bool {
        let calendar = Calendar.current
        let endComponents = calendar.dateComponents([.hour, .minute], from: date)
        let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())
        return calendar.dateComponents([.minute], from: endComponents, to: nowComponents).minute! >= Int(TimeIntervals.UserStatsTimeOutdated)
    }
}


extension UserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            animateHeader(isFolding: false)
//            headerHeightConstraint.constant += abs(scrollView.contentOffset.y)
//            header.incrementAlpha(offset: headerHeightConstraint.constant, denominator: headerMaxHeight / 2)
        } else if scrollView.contentOffset.y > 0 && headerHeightConstraint.constant >= 100 {
            animateHeader(isFolding: true)
//            headerHeightConstraint.constant -= scrollView.contentOffset.y/15
//            header.decrementAlpha(offset: headerHeightConstraint.constant, denominator: headerMaxHeight / 2)
//            if headerHeightConstraint.constant < 100 {
//                UIView.animate(withDuration: 0.1) {
//                    self.view.setNeedsLayout()
//                    self.headerHeightConstraint.constant = 100
//                    self.view.layoutIfNeeded()
//                }
//            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if headerHeightConstraint.constant > headerMaxHeight {
            animateHeader(isFolding: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if headerHeightConstraint.constant > headerMaxHeight {
            animateHeader(isFolding: false)
        }
    }
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "surveys") as? UserSurveysCell {
            if leftEdgeInset == 0 {
                for v in cell.contentView.subviews {
                    if v.isKind(of: UILabel.self) {
                        leftEdgeInset = v.frame.origin.x
                        break
                    }
                }
            }
            cell.label.text = userProfile.gender == .Male ? "Создал опросов" : "Создала опросов"
            cell.count.text = "\(userProfile.surveysCreatedTotal)"
            cell.separatorInset = UIEdgeInsets(top: 0, left: leftEdgeInset, bottom: 0, right: 0)
            return cell
        } else if indexPath.row == 2, let cell = tableView.dequeueReusableCell(withIdentifier: "votes") as? UserVotesCell {
            cell.label.text = userProfile.gender == .Male ? "Прошел опросов" : "Прошла опросов"
            cell.count.text = "\(userProfile.surveysAnsweredTotal)"
            cell.separatorInset = UIEdgeInsets(top: 0, left: leftEdgeInset, bottom: 0, right: 0)
            return cell
        } else if indexPath.row == 1, let cell = tableView.dequeueReusableCell(withIdentifier: "favorite") as? UserFavoriteCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: leftEdgeInset, bottom: 0, right: 0)
            cell.label.text = userProfile.gender == .Male ? "Добавил в избранное" : "Добавила в избранное"
            cell.count.text = "\(userProfile.surveysFavoriteTotal)"
            return cell
        } else if indexPath.row == 3, let cell = tableView.dequeueReusableCell(withIdentifier: "subscription") as? UserSubscriptionCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: .greatestFiniteMagnitude)
            cell.delegate = self
            return cell
        } else if indexPath.row == 4, let cell = tableView.dequeueReusableCell(withIdentifier: "claim") as? UserClaimCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        } else if indexPath.row == 5, let cell = tableView.dequeueReusableCell(withIdentifier: "activity") as? UserActivityCell {
            cell.label.text = userProfile.gender == .Male ? "Был \(userProfile.lastVisit.toDateTimeStringLiteral())" : "Была \(userProfile.lastVisit.toDateTimeStringLiteral())"
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        }
        let cell = UITableViewCell()
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: .greatestFiniteMagnitude)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 || indexPath.row == 5 {
            return 50
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setNeedsAwaitForNotification = false
        if indexPath.row == 0 {
            if userProfile.surveysCreated.values.first!.isEmpty || esteemMinutes(date: userProfile.surveysCreated.keys.first!) {
                setNeedsAwaitForNotification = true
                apiManager.loadSurveysByOwner(userProfile: userProfile, type: .User) {
                    json, error in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else if json != nil {
                        self.userProfile.importSurveys(UserProfile.UserSurveyType.Own, json: json!)
                    }
                }
            }
            performSegue(withIdentifier: Segues.App.UserToUserSurveys, sender: nil)
        } else if indexPath.row == 1 {
            if userProfile.surveysFavorite.values.first!.isEmpty || esteemMinutes(date: userProfile.surveysFavorite.keys.first!) {
                setNeedsAwaitForNotification = true
                apiManager.loadSurveysByOwner(userProfile: userProfile, type: .UserFavorite) {
                    json, error in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else if json != nil {
                        self.userProfile.importSurveys(UserProfile.UserSurveyType.Favorite, json: json!)
                    }
                }
            }
            performSegue(withIdentifier: Segues.App.UserToUserFavoriteSurveys, sender: nil)
        }
    }
}

extension UserViewController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if let _sender = sender as? UISwitch {
            apiManager.subsribeToUserProfile(subscribe: _sender.isOn, userprofile: userProfile) {
                json, error in
                
            }
        }
    }
}
