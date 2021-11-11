//
//  PollController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON

class PollController: UIViewController {

    enum Mode {
        case ReadOnly, Write
    }
    
    deinit {
        print("DEINIT PollController")
        NotificationCenter.default.removeObserver(self)
    }
    
    var tagColors = Colors.tags()
    var mode: Mode = .Write {
        didSet {
            if tableView != nil {
                tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
                tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .fade)
            }
        }
    }
    var apiManager: APIManagerProtocol!
    var statusBarHidden = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    private var lastContentOffset: CGFloat = 0//Nav bar reveal depend on scroll view offset's limit
//    private var isSurveyJustCompleted = false
//    private var isReadOnly = false {
//        didSet {
//            if oldValue == false, oldValue != isReadOnly {
//                self.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
//                self.tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .fade)
//            }
//        }
//    }
    private var isLoadingImages  = true
    private var requestAttempt = 0 {
        didSet {
            if oldValue != requestAttempt {
                if requestAttempt > MAX_REQUEST_ATTEMPTS {
                    requestAttempt = 0
                }
            }
        }
    }
    private let tableViewSections   = ["main", "answers", "vote"]
    private var isRequesting        = false
    private let requestAttempts     = 3
    private var loadingIndicator:   ClockIndicator?
    private let likeButton          = HeartView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    private var isInitialLoading    = true {
        didSet {
            if tableView != nil {
                tableView.isUserInteractionEnabled = !isInitialLoading
            }
        }
    }
    weak var delegate: CallbackDelegate?
    private var isDownloadingImages  = true
    private var answersCells: [ChoiceSelectionCell] = []
//    private var resultCells: [ChoiceResultCell] = []
    private var needsAnimation                      = true
    private var scrollArrow: ScrollArrow!
    private var isAutoScrolling = false   //is on when scrollArrow is tapped
    private var selectedAnswerID = 0 {
        didSet {
            if oldValue != selectedAnswerID {
                //UI update
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SurveyVoteCell {
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.btn.backgroundColor = K_COLOR_RED
                    }) {
                        _ in
                        cell.btn.isUserInteractionEnabled = true
                    }
                }
                if oldValue == 0 {
                    delay(seconds: 0.5) {
                        self.isAutoScrolling = false
                    }
                    isAutoScrolling = true
//                    navigationController?.setNavigationBarHidden(true, animated: true)
                    tableView.scrollToBottom()//scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
                }
                for cell in answersCells {
                    if cell.answer!.ID != selectedAnswerID {
                        cell.isChecked = false
//                        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
//                        scaleAnim.fromValue = 1.002
//                        scaleAnim.toValue   = 1
//                        scaleAnim.duration  = 0.15
//                        cell.label.layer.add(scaleAnim, forKey: nil)
//                        cell.label.transform = CGAffineTransform.identity
                    }
                }
            }
        }
    }
    
    var surveyRef: SurveyRef! {
        didSet {
            likeButton.removeAllAnimations()
            likeButton.state = Array(Surveys.shared.favoriteLinks.keys).filter( {$0.ID == surveyRef.ID }).isEmpty ? .disabled : .enabled
        }
    }
    //Nil if object isn't downloaded, checked in performChecks()
    var survey: Survey? {
        didSet {
            if let strongSurvey = survey, isInitialLoading {
//            if let strongSurvey = survey {
                presentSurvey()
                if surveyRef == nil {
                    surveyRef = SurveyRef(id: survey!.ID!, title: survey!.title, startDate: survey!.startDate, category: survey!.category, type: survey!.type, isOwn: survey!.isOwn, isComplete: survey!.isComplete, isFavorite: survey!.isFavorite)
                }
                if let owner = strongSurvey.userProfile {
                    if owner.image != nil {
                        NotificationCenter.default.post(name: Notifications.UI.ImageReceived, object: nil)
                    } else if owner.image == nil, let url = owner.imageURL as? String {
                        apiManager.downloadImage(url: url) {
                            image, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                            if image != nil {
                                self.survey!.userProfile!.image = image!
                                NotificationCenter.default.post(name: Notifications.UI.ImageReceived, object: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //    var shouldDownloadImages = true//True - segue from list, false - from stack
    
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        performChecks()
        AppData.shared.system.youtubePlayOption = nil
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = true
            nc.duration = 0.25
        }
    }
    
    private func setupViews() {
//        tableView.register(ChoiceResultCell.self, forCellReuseIdentifier: "result")
        //Set icon category in title
        let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        icon.backgroundColor = .clear
        icon.iconColor = surveyRef.category.tagColor
        icon.isRounded = false
        icon.scaleMultiplicator = 1.4
        icon.category = Icon.Category(rawValue: surveyRef.category.ID) ?? .Null
        navigationItem.titleView = icon
        navigationItem.titleView?.clipsToBounds = false
//        navigationItem.backBarButtonItem?.title = ""
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PollController.handleTap))
        likeButton.addGestureRecognizer(gesture)
        
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.setNavigationBarHidden(false, animated: false)
//            nc.isShadowed = true
            nc.navigationBar.isTranslucent = false
            //            nc.transitionStyle = .Default
        }
        if !surveyRef.isOwn {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: likeButton)]
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PollController.updateViewsCount(notification:)),
                                               name: Notifications.UI.SuveyViewsCountReceived,
                                               object: nil)
        tableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.06)
    }
    
    private func performChecks() {
        //Check if Survey is already downloaded
        if survey == nil, let found = Surveys.shared.downloadedObjects.filter({ $0.ID == self.surveyRef.ID }).first {
            isInitialLoading = false
            survey = found
            apiManager.addViewCount(survey: surveyRef) {
                json, error in
                if error != nil {
                    print(error.debugDescription)
                }
                if let strongJson = json, let value = strongJson["views"].intValue as? Int {
                    NotificationCenter.default.post(name: Notifications.UI.SuveyViewsCountReceived, object: value)
                    self.surveyRef.views = value
                    self.survey!.views = value
                }
            }
        } else {
            tableView.alpha = 0
            tableView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            DispatchQueue.main.async {
                self.loadingIndicator = ClockIndicator(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.width)))
                self.loadingIndicator!.layer.masksToBounds = false
                self.loadingIndicator!.layoutCentered(in: self.view, multiplier: 0.2)
                self.loadingIndicator!.layer.zPosition = 1
                self.loadingIndicator?.alpha = 1
                self.loadingIndicator?.addEnableAnimation()
            }
            loadData()
        }
    }
    
    //Load data into app
    private func loadData() {
        requestAttempt += 1
        apiManager.loadSurvey(survey: surveyRef, addViewCount: true) {
            json, error in
            if error != nil {
                if self.requestAttempt > MAX_REQUEST_ATTEMPTS {
                    showAlert(type: .Ok, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { UIView.animate(withDuration: 0.3, animations: {
                        self.loadingIndicator?.alpha = 0
                    }) { _ in self.loadingIndicator?.removeAllAnimations() } }]]], text: "Ошибка: \(error!.localizedDescription)")
                } else {
                    //Retry
                    self.loadData()
                }
            }
            if json != nil {
                print(json)
                if let _survey = Survey(json!) {
                    Surveys.shared.append(object: _survey, type: .Downloaded)
                    self.survey = _survey
                    self.requestAttempt = 0
                }
                //                self.presentSurvey()
            }
        }
    }
    
    @objc private func openUserProfile() {
        performSegue(withIdentifier: Segues.App.SurveyToUser, sender: nil)
    }
    @objc private func updateViewsCount(notification: Notification) {
        if let value = notification.object as? Int, let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AuthorCell, survey != nil {
            cell.viewsLabel.text = "\(value), \(survey!.startDate.toDateStringLiteral_dMMM())"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.transitionStyle = .Icon
            nc.duration = 0.4
            if segue.identifier == Segues.App.User, let destinationVC = segue.destination as? UserViewController, let userProfile = survey?.userProfile {
                nc.transitionStyle = .Default
                destinationVC.userProfile = userProfile
            } else if segue.identifier == Segues.App.Image, let image = sender as? UIImage, let destinationVC = segue.destination as? ImageViewController, survey != nil {
                nc.duration = 0.25
                nc.transitionStyle = .Icon
                destinationVC.image = image
                destinationVC.mode = .ReadOnly
                for dict in survey!.images! {
                    if let text = dict.filter({$0.key == image}).values.first {
                        destinationVC.titleString = text
                        break
                    }
                }
            } else if segue.identifier == Segues.App.UsersList, let destinationVC = segue.destination as? UsersCollectionViewController, let users = sender as? [UserProfile] {
                destinationVC.users = users
                destinationVC.title = "Проголосовали"
            }
        }
    }
    
    private func presentSurvey() {
        tableView.reloadData()
        
        let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        effectViewOutgoing.frame = view.frame
        effectViewOutgoing.addEquallyTo(to: view)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
            effectViewOutgoing.effect = nil
        })
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
            self.loadingIndicator?.alpha = 0
            self.loadingIndicator?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            effectViewOutgoing.effect = UIBlurEffect(style: .light)
        }) {
            _ in
            self.loadingIndicator?.transform = .identity
            self.loadingIndicator?.removeAllAnimations()
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0/*delay*/, options: [.curveEaseIn], animations: {
                effectViewOutgoing.effect = nil
            })
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0/*delay*/, options: [.curveEaseOut], animations: {
                self.tableView.transform = .identity
                self.tableView.alpha = 1
            }) {
                _ in
                effectViewOutgoing.removeFromSuperview()
                self.isInitialLoading = false
            }
        }
    }
    
    @objc private func handleTap() {
        if !isRequesting {
            isRequesting = true
            var mark = true
            if likeButton.state == .disabled {
                likeButton.state = .enabled
                mark = true
                if Array(Surveys.shared.favoriteLinks.keys).filter( {$0.ID == surveyRef.ID }).isEmpty { Surveys.shared.favoriteLinks[self.surveyRef] = Date() }
            } else {
                likeButton.state = .disabled
                mark = false
                if let key = Surveys.shared.favoriteLinks.keys.filter({ $0.ID == surveyRef.ID }).first {
                    Surveys.shared.favoriteLinks.removeValue(forKey: key)
                }
            }
            NotificationCenter.default.post(name: Notifications.Surveys.FavoriteSurveysUpdated, object: nil)
            apiManager.addFavorite(mark: mark, survey: surveyRef!) {
                _, error in
                self.isRequesting = false
                if error != nil {
                    print(error!.localizedDescription)
                }
            }
        }
    }
}

extension PollController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard survey != nil else {
            return UITableViewCell()
        }
        if indexPath.section == 0 { //Params
            if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "author", for: indexPath) as? AuthorCell {
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                cell.delegate = self
                if let image = survey!.userProfile!.image {
                    cell.avatar.image = image.circularImage(size: cell.avatar.frame.size, frameColor: K_COLOR_RED)
                }
                let categoryString = NSMutableAttributedString()
                categoryString.append(NSAttributedString(string: "\(survey!.category.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: survey!.category.tagColor, backgroundColor: .clear)))
                categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: survey!.category.tagColor, backgroundColor: .clear)))
                categoryString.append(NSAttributedString(string: "\(survey!.category.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: survey!.category.tagColor, backgroundColor: .clear)))
                cell.categoryLabel.attributedText = categoryString
                cell.viewsLabel.text = "\(survey!.views), \(survey!.startDate.toDateStringLiteral_dMMM())"
                cell.userCredentials.text = survey!.userProfile?.name.replacingOccurrences(of: " ", with: "\n")//.components(separatedBy: CharacterSet.whitespaces)
                return cell
            } else if indexPath.row == 1, let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? LabelCell {
                cell.label.text = survey!.title
                return cell
            } else if indexPath.row == 2, let cell = tableView.dequeueReusableCell(withIdentifier: "description", for: indexPath) as? TextViewCell {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                let text = "\t\(survey!.description)"
                let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 16), foregroundColor: .darkGray, backgroundColor: .clear), range: text.fullRange())
                cell.textView.attributedText = attributedString
                return cell
            } else if indexPath.row == 3 {
                if survey!.images != nil, !survey!.images!.isEmpty, let cell = tableView.dequeueReusableCell(withIdentifier: "images", for: indexPath) as? ImagesCell  {
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                    cell.pageControl.cornerRadius = cell.pageControl.frame.height/4
                    cell.createSlides(count: survey!.images!.count)
                    for (i, dict) in survey!.images!.enumerated() {
                        if let image = dict.keys.first {
                            cell.slides[i].imageView.image = image
                            cell.slides[i].imageView.progressIndicatorView.alpha = 0
                        }
                    }
                    cell.delegate = self
                    cell.pageControl.alpha = cell.slides.count > 1 ? 1 : 0
                    return cell
                } else if survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty, let cell = tableView.dequeueReusableCell(withIdentifier: "images", for: indexPath) as? ImagesCell {
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                    cell.pageControl.cornerRadius = cell.pageControl.frame.height/4
                    cell.createSlides(count: survey!.imagesURLs!.count)
                    if survey != nil, survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty, (survey!.images == nil), isLoadingImages {
                        self.isLoadingImages = false
                        for (i, imageURL) in survey!.imagesURLs!.enumerated() {
                            apiManager.downloadImage(url: imageURL.keys.first!, percentageClosure: {
                                percent in
                                cell.slides[i].imageView.progressIndicatorView.progress = percent
                            }) {
                                image, error in
                                if error != nil {
                                    Banner.shared.contentType = .Warning
                                    if let content = Banner.shared.content as? Warning {
                                        content.level = .Error
                                        content.text = "Произошла ошибка, изображение не было загружено"
                                    }
                                    Banner.shared.present(shouldDismissAfter: 2, delegate: nil)
                                    print(error!.localizedDescription)
                                }
                                
                                if image != nil {
                                    if self.survey!.images == nil {
                                        self.survey!.images = []
                                    }
                                    
                                    if !self.survey!.images!.isEmpty {
                                        self.survey!.images!.map() {
                                            if let _image = $0.keys.first, !_image.isEqualToImage(image: image!) {
                                                self.survey!.images!.append([image!: imageURL.values.first!])
                                                cell.slides[i].imageView.image = image
                                                cell.slides[i].imageView.progressIndicatorView.reveal()
                                            }
                                        }
                                    } else {
                                        self.survey!.images!.append([image!: imageURL.values.first!])
                                        cell.slides[i].imageView.image = image
                                        cell.slides[i].imageView.progressIndicatorView.reveal()
                                    }
                                    if i == 0 {
                                        cell.showPageControl()
                                    }
                                }
                            }
                        }
                    } else if survey!.images != nil, !survey!.images!.isEmpty {
                        for (i, dict) in survey!.images!.enumerated() {
                            if let image = dict.keys.first {
                                cell.slides[i].imageView.image = image
                                cell.slides[i].imageView.progressIndicatorView.alpha = 0
                            }
                        }
                    }
                    cell.delegate = self
                    return cell
                }
            } else if indexPath.row == 4 {
                if let link = survey!.link, !link.isEmpty {
                    //1) YT link
                    if link.isYoutubeLink, let cell = tableView.dequeueReusableCell(withIdentifier: "youtube") as? YoutubeCell, let videoID = link.youtubeID {
                        cell.delegate = self
                        cell.videoID = videoID
                        cell.loadVideo(url: survey!.link!)
                        return cell
                    } else if link.isTikTokLink, let cell = tableView.dequeueReusableCell(withIdentifier: "embedded") as? EmbeddedURLCell {
                        cell.app = .TikTok
                        guard !cell.isContentLoading else {
                            return cell
                        }
                        cell.isContentLoading = true
                        if link.isTikTokEmbedLink {
                            var webContent = "<meta name='viewport' content='initial-scale=0.8, maximum-scale=0.8, user-scalable=no'/>"
                            webContent += link
                            cell.webView.loadHTMLString(webContent, baseURL: URL(string: "http://www.tiktok.com")!)
                        } else {
                            cell.url = URL(string: link)
                            apiManager.getTikTokEmbedHTML(url: URL(string: "https://www.tiktok.com/oembed?url=\(link)")!) {
                                json, error in
                                if error != nil {
                                    Banner.shared.contentType = .Warning
                                    if let content = Banner.shared.content as? Warning {
                                        content.level = .Error
                                        content.text = "Произошла ошибка, изображение не было загружено"
                                    }
                                    Banner.shared.present(shouldDismissAfter: 2, delegate: nil)
                                    print(error!.localizedDescription)
                                }
                                if let strongJSON = json {
                                    if let html = strongJSON["html"].stringValue as? String {
                                        var webContent = "<meta name='viewport' content='initial-scale=0.8, maximum-scale=0.8, user-scalable=no'/>"
                                        webContent += html
                                        cell.webView.loadHTMLString(webContent, baseURL: URL(string: "http://www.tiktok.com")!)
                                    }
                                }
                            }
                        }
                        return cell
                    } else {
                        //Plain link
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "web") as? WebResourceCell {
                            cell.delegate = self
                            cell.button.setImage(UIImage(named: "external link")?.withRenderingMode(.alwaysTemplate), for: .normal)
                            cell.button.imageView?.contentMode = .scaleAspectFit
                            cell.button.setTitleColor(.blue, for: .normal)
                            cell.button.tintColor = .blue
                            return cell
                        }
                    }
                }
            } else if indexPath.row == 5, let cell = tableView.dequeueReusableCell(withIdentifier: "question", for: indexPath) as? TextViewCell {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                let text = survey!.question//"\t\(survey!.question)"
                let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 17), foregroundColor: .black, backgroundColor: .clear), range: text.fullRange())
                cell.textView.attributedText = attributedString
                cell.textView.textContainerInset = UIEdgeInsets(top: 20, left: cell.textView.textContainerInset.left, bottom: 20, right: cell.textView.textContainerInset.right)
                return cell
            }
        } else if indexPath.section == 1 {
            switch mode {
            case .Write:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "choice", for: indexPath) as? ChoiceSelectionCell, let answer = survey?.answers[indexPath.row] {
                    cell.answer = answer
                    cell.delegate = self
                    return cell
                }
            case .ReadOnly:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as? ChoiceResultCell, let answer = survey?.answersSortedByVotes[indexPath.row] {
                    if !cell.isViewSetupComplete {
                        cell.layer.masksToBounds = false
                        cell.frame.size = CGSize(width: view.frame.width, height: cell.frame.height)
                        cell.setNeedsLayout()
                        cell.layoutIfNeeded()
                        cell.resultIndicator.apiManager = (tabBarController as! TabBarController).apiManager
                        cell.resultIndicator.backgroundFrame.cornerRadius = cell.resultIndicator.backgroundFrame.frame.height/2
                        cell.resultIndicator.foregroundFrame.cornerRadius = cell.resultIndicator.backgroundFrame.frame.height/2
                        cell.resultIndicator.color = tagColors[indexPath.row]
                        cell.resultIndicator.layer.masksToBounds = false
                        if let id = survey!.result!.keys.first, id == answer.ID {
                            cell.selectedResult = true
                        }
                        cell.answer = answer
                        cell.resultIndicator.delegate = self
//                        cell.resultIndicator.imageViews.forEach({ $0.keys.first!.cornerRadius = $0.keys.first!.frame.height/2})
                        if survey!.isAnonymous {
                            cell.mode = .Anon
                        } else if answer.userprofiles.isEmpty {
                            cell.mode = .None
                        }
                        cell.percent = survey!.getPercentForAnswer(answer)
                        cell.isViewSetupComplete = true
                    }
                    return cell
                }
                print("ReadOnly")
                return UITableViewCell()
            }
        } else if indexPath.section == 2 {
            switch mode {
            case .Write:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "vote", for: indexPath) as? SurveyVoteCell {
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                    cell.delegate = self
                    cell.btn.layer.cornerRadius = cell.btn.frame.height / 2
                    cell.btn.backgroundColor = selectedAnswerID != 0 ? K_COLOR_RED : K_COLOR_GRAY
                    cell.btn.isUserInteractionEnabled = selectedAnswerID != 0 ? true : false
                    return cell
                }
            case .ReadOnly:
                print("ReadOnly")
                return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if survey == nil {
            return 0
        } else {
            switch mode {
            case .ReadOnly:
                return 3//2//Body & answers
            case .Write:
                return 3//Body & answers & vote button
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {//ОСНОВНОЕ
            return 6
        } else if section == 1, survey != nil {//Варианты ответов
            return survey!.answers.count
        } else if section == 2 {//ПОСЛЕДНЯЯ СЕКЦИЯ
            if mode == .Write {
                return 1
            } else {
                return 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard survey != nil else {
            return 0
        }
        if indexPath.section == 0 {
            if indexPath.row == 0 {//Author & category
                return 60
            } else if indexPath.row == 1 {//Title
                return 140
            } else if indexPath.row == 3 {//Images
                if survey!.images != nil, !survey!.images!.isEmpty {
                    return UIScreen.main.bounds.width/(16/9)
                } else if survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty {
                    return UIScreen.main.bounds.width/(16/9)
                }
                return 0
            } else if indexPath.row == 4 {//Web resource
                if survey!.link == nil || survey!.link!.isEmpty {
                    return 0
                } else if survey!.link!.isYoutubeLink {
                    return UIScreen.main.bounds.width/(16/9)
                } else if survey!.link!.isTikTokLink {
                    return 650
                } else {
                    return 60
                }
            }
        } else if indexPath.section == 2 {
            switch mode {
            case .Write:
                return 120
            case .ReadOnly:
                //TODO: - Set row height
                print("")
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 1 {
//            return 0
//        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //        if section == 1 {
        //            return 0
        //        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChoiceSelectionCell {
            cell.isChecked = true
            //Uncheck others
            selectedAnswerID = cell.answer!.ID
        }
        //        if indexPath.section == 1, let cell = tableView.cellForRow(at: indexPath) as? ChoiceSelectionCell, let region = cell.frameView as? UIView, region.layer.sublayers!.filter({ $0.name == "selectionLayer" }).isEmpty {
        //            let sublayer = CAShapeLayer()
        //            sublayer.path = UIBezierPath(ovalIn: cell.tagView.frame).cgPath
        //            sublayer.name = "selectionLayer"
        //            sublayer.fillColor = cell.tagView.backgroundColor?.cgColor
        //            region.layer.insertSublayer(sublayer, at: 0)
        //            cell.tagView.backgroundColor = .clear
        //
        //            let destinationPath = UIBezierPath(roundedRect: region.bounds, cornerRadius: cell.tagView.cornerRadius)
        //            let pathAnim        = Animations.get(property: .Path, fromValue: sublayer.path as Any, toValue: destinationPath as Any, duration: 0.25, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
        //            sublayer.add(pathAnim, forKey: nil)
        //            sublayer.path = destinationPath.cgPath
        //        }
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if indexPath.section == 1, let cell = tableView.cellForRow(at: indexPath) as? ChoiceSelectionCell, let region = cell.frameView as? UIView, let sublayer = region.layer.sublayers?.filter({ $0.name == "selectionLayer" }).first as? CAShapeLayer {//sublayers {
//
//            let destinationPath = UIBezierPath(ovalIn: cell.tagView.frame).cgPath
//            let pathAnim        = Animations.get(property: .Path, fromValue: sublayer.path as Any, toValue: destinationPath as Any, duration: 0.25, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, isRemovedOnCompletion: false, completionBlocks: [{
//                sublayer.removeFromSuperlayer()
//                cell.tagView.backgroundColor = self.tagColors[indexPath.row]
//            }])
//            sublayer.add(pathAnim, forKey: nil)
//            sublayer.path = destinationPath
//        }
//    }
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        lastContentOffset = scrollView.contentOffset.y
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard !isAutoScrolling else { return }
//
//        if lastContentOffset < scrollView.contentOffset.y {
//            navigationController?.setNavigationBarHidden(true, animated: true)
//        } else if scrollView.contentOffset.y <= 0 {
//            navigationController?.setNavigationBarHidden(false, animated: true)
//        }
//    }
}

extension PollController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.map{ $0() }
        }
    }
}

import SafariServices
extension PollController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if sender is WebResourceCell, let url = URL(string: survey!.link!) {
            var vc: SFSafariViewController!
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        } else if sender is YoutubeCell {
//            let appName = "youtube"
//            let appScheme = "\(appName)://app"
//            let appUrl = URL(string: appScheme)
//
//            if UIApplication.shared.canOpenURL(appUrl! as URL) {
//                UIApplication.shared.open(appUrl!)
//            } else {
//                print("App not installed")
//            }
        } else if let string = sender as? String {
            if string == "user" {
                performSegue(withIdentifier: Segues.App.User, sender: nil)
            } else if string == "claim" {
                                AlertController.shared.icon.category = .Caution
                                AlertController.shared.present(delegate: self, height: UIScreen.main.bounds.height * 0.76, contentType: .Claim, survey: survey)
//                Alert.shared.icon.category = .Caution
//                Alert.shared.present(delegate: self, height: UIScreen.main.bounds.height * 0.7, contentType: .Claim, survey: survey)
//                performSegue(withIdentifier: Segues.App.Claim, sender: nil)
            } else if string == "vote" {
                AlertController.shared.icon.category = .Info
                AlertController.shared.present(delegate: self, height: UIScreen.main.bounds.height * 0.5, contentType: .Info, survey: nil)
                apiManager.postVote(result: ["survey": survey!.ID!, "answer": selectedAnswerID]) {
                    json, error in
                    if error != nil {
                        print(error.debugDescription)
                        Banner.shared.contentType = .Warning
                        if let content = Banner.shared.content as? Warning {
                            content.level = .Error
                            content.text = "Произошла ошибка по техническим причинам, повторите позже"
                        }
                        Banner.shared.present(isModal: true, shouldDismissAfter: 3, delegate: self)
                    }
                    
                    if json != nil {
                        print(json)
                        //Update answer votes count, survey total votes, user's survey result & add to completed
                        
                        for i in json! {
                            if i.0 == "survey_result" {
                                for entity in i.1 {
                                    if let _answer = entity.1["answer"].intValue as? Int, let _timestamp = Date(dateTimeString: entity.1["timestamp"].stringValue as! String) as? Date {
                                        self.survey!.result = [_answer: _timestamp]
//                                        self.survey!.totalVotes += 1
//                                        for answer in self.survey!.answers {
//                                            if answer.ID == _answer {
//                                                answer.totalVotes += 1
//                                                break
//                                            }
//                                        }
                                        
                                        Surveys.shared.stackObjects.remove(object: self.survey!)
                                        //Increase user's balance
                                        AppData.shared.userProfile.balance += SurveyPoints.Vote.rawValue
                                    }
                                }
                                self.surveyRef.isComplete = true
                                self.mode = .ReadOnly
                            } else if i.0 == "hot" && !i.1.isEmpty {
                                Surveys.shared.importSurveys(i.1)
                            } else if i.0 == "result_total" {
                                var totalVotes = 0
                                for entity in i.1 {
                                    if let dict = entity.1.dictionaryValue as? [String: JSON] {
                                        if let _userprofiles = dict["userprofiles"]?.arrayValue as? [JSON], let _answerID = dict["answer"]?.intValue as? Int, let answer = self.survey?.answers.filter({ $0.ID == _answerID }).first, let _total = dict["total"]?.intValue as? Int {
                                            answer.totalVotes = _total
                                            totalVotes += _total
                                            for _userprofile in _userprofiles {
                                                var userprofile: UserProfile!
                                                if let ID = _userprofile["id"].intValue as? Int, let foundValue = UserProfiles.shared.container.filter({ $0.ID == ID }).first {
                                                    userprofile = foundValue
                                                } else if let newUserprofile = UserProfile(_userprofile) {
                                                    UserProfiles.shared.container.append(newUserprofile)
                                                    userprofile = newUserprofile
                                                }
                                                answer.appendUserprofile(userprofile)
                                            }
                                        }
                                    }
                                }
                                self.survey?.totalVotes = totalVotes
                            }
                        }
                    }
                }
                AlertController.shared.present(delegate: self, survey: nil)
//            } else if string == "post_claim" {
//                navigationController?.popViewController(animated: true)
            } else if string == AlertController.popController {
                navigationController?.popViewController(animated: true)
            }
        } else if let image = sender as? UIImage {
            performSegue(withIdentifier: Segues.App.Image, sender: image)
        } else if let users = sender as? [UserProfile] {
            performSegue(withIdentifier: Segues.App.UsersList, sender: users)
        }
    }
}

















class AuthorCell: UITableViewCell {
    weak var delegate: CallbackDelegate?
    @IBOutlet weak var avatar: UIImageView! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(self.handleTap(recognizer:)))
            touch.cancelsTouchesInView = false
            avatar.addGestureRecognizer(touch)
        }
    }
    @IBOutlet weak var userCredentials: UILabel! {
        didSet {
            userCredentials.backgroundColor = .clear
            userCredentials.textColor = .black
        }
    }
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var viewsIcon: Icon! {
        didSet {
            viewsIcon.scaleMultiplicator = 1.3
            viewsIcon.backgroundColor = .clear
            viewsIcon.iconColor = .darkGray
            viewsIcon.category = .Eye
        }
    }
    @IBOutlet weak var viewsLabel: UILabel! {
        didSet {
            viewsLabel.textColor = .darkGray
        }
    }
//    @IBOutlet weak var commentsIcon: SurveyCategoryIcon! {
//        didSet {
//            commentsIcon.scaleMultiplicator = 1
//            commentsIcon.backgroundColor = .clear
//            commentsIcon.iconColor = .lightGray
//            commentsIcon.category = .Opinion
//        }
//    }
//    @IBOutlet weak var commentsLabel: UILabel! {
//        didSet {
//            commentsLabel.textColor = .lightGray
//        }
//    }
    
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.callbackReceived("user" as AnyObject)
    }
}

class LabelCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

class TextViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
}

class WebResourceCell: UITableViewCell {
    weak var delegate: CallbackDelegate?
    @IBOutlet weak var button: ButtonWithImage!
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.callbackReceived(self)
    }
}

class ImagesCell: UITableViewCell, UIScrollViewDelegate {
    var slides: [Slide] = []
    var isSetupCompleted = false {
        didSet {
            if isSetupCompleted {
                scrollView.isUserInteractionEnabled = true
            }
        }
    }
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.isUserInteractionEnabled = isSetupCompleted ? true : false
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var pageControl: UIView! {
        didSet {
            pageControl.alpha = 0
            pageControl.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        }
    }
    @IBOutlet weak var page: UILabel! {
        didSet {
            if page != nil, !slides.isEmpty {
                page.text = "\(pageIndex+1)/\(slides.count)"
            }
        }
    }
    //    @IBOutlet weak var pageControl: UIPageControl! {
//        didSet {
//            pageControl.alpha = 0
//        }
//    }
    
    @objc fileprivate func callback() {
        delegate?.callbackReceived(self)
    }
    private var pageIndex: Int = 0
    weak var delegate: CallbackDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func createSlides(count: Int) {
        if !isSetupCompleted {
            scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(count), height: scrollView.frame.height)
            scrollView.isScrollEnabled = true
            scrollView.isPagingEnabled = true
            
            for i in 0..<count {
                let slide  = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                slide.frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
                slide.imageView.backgroundColor = .lightGray
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(ImagesCell.imageTapped(recognizer:)))
                slide.imageView.addGestureRecognizer(recognizer)
//                scrollView.addSubview(slide)
                scrollView.insertSubview(slide, at: 0)
                slides.append(slide)
            }
            isSetupCompleted = true
        }
    }
    
    func showPageControl() {
        if slides.count > 1, pageControl != nil, page != nil, pageControl.alpha == 0 {
            page.text = "\(pageIndex+1)/\(slides.count)"
            pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut, animations: {
                self.pageControl.alpha = 1
                self.pageControl.transform = .identity
            })
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageIndex = Int(round(scrollView.contentOffset.x/contentView.frame.width))
        page.text = "\(pageIndex+1)/\(slides.count)"
    }
    
    @objc private func imageTapped(recognizer: UITapGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView, let image = imageView.image {
            delegate?.callbackReceived(image as AnyObject)
        }
    }
    
}

import YoutubePlayer_in_WKWebView
class YoutubeCell: UITableViewCell, WKYTPlayerViewDelegate, CallbackDelegate {
//    private var bannerHasBeenShown = false
    private var tempAppPreference: SideAppPreference?
    private var sideAppPreference: SideAppPreference? {
        if AppData.shared.system.youtubePlayOption == nil {
            return nil
        } else {
            return AppData.shared.system.youtubePlayOption
        }
    }
    private var isYoutubeInstalled: Bool {
        let appName = "youtube"
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)
        return UIApplication.shared.canOpenURL(appUrl! as URL)
    }
    var videoID = ""
    private var loadingIndicator: ClockIndicator!
    private var isVideoLoaded = false
//    @IBOutlet weak var subv: UIView! {
//        didSet {
//            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: subv.frame.height, height: subv.frame.height)))
//            loadingIndicator.layoutCentered(in: subv, multiplier: 0.6)//addEquallyTo(to: tableView)
//            loadingIndicator.addEnableAnimation()
//        }
//    }
    @IBOutlet weak var playerView: WKYTPlayerView! {
        didSet {
            playerView.alpha = 0
            playerView.delegate = self
            loadingIndicator = ClockIndicator(frame: CGRect(origin: .zero, size: CGSize(width: contentView.frame.height, height: contentView.frame.height)))
            loadingIndicator.layer.masksToBounds = false
            loadingIndicator.layoutCentered(in: contentView, multiplier: 0.2)//addEquallyTo(to: tableView)
            loadingIndicator.addEnableAnimation()
//            let recognizer = UITapGestureRecognizer(target: self, action: #selector(YoutubeCell.viewTapped(recognizer:)))
//            playerView.addGestureRecognizer(recognizer)
        }
    }
    
    @objc fileprivate func callback() {
        delegate?.callbackReceived(self)
    }
    weak var delegate: CallbackDelegate?
    
    func loadVideo(url: String) {
        if !isVideoLoaded {
            isVideoLoaded = true
            if let id = url.youtubeID {
                playerView.load(withVideoId: id)
            }
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        print("ready")
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingIndicator.alpha = 0
        }) {
            _ in
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                self.playerView.alpha = 1
            })
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        if state == .buffering {
            if sideAppPreference != nil {
                if sideAppPreference! == .Embedded {
                    playerView.playVideo()
                } else {
                    if isYoutubeInstalled {
                        playInYotubeApp()
                        playerView.stopVideo()
                    }
                }
            } else if isYoutubeInstalled, tempAppPreference == nil {
                    playerView.pauseVideo()
                    Banner.shared.contentType = .SideApp
                    if let content = Banner.shared.content as? SideApp {
                        content.app = .Youtube
                        content.delegate = self
                    }
                    Banner.shared.present(isModal: true, delegate: nil)
            } else {
                if tempAppPreference == .Embedded {
                    playerView.playVideo()
                } else {
                    if isYoutubeInstalled {
                        playInYotubeApp()
                        playerView.stopVideo()
                    }
                }
            }
        }
    }
    
    private func playInYotubeApp() {
        let appScheme = "youtube://watch?v=\(videoID)"
        if let appUrl = URL(string: appScheme) {
            UIApplication.shared.open(appUrl)
        }
    }

    func callbackReceived(_ sender: AnyObject) {
        if let option = sender as? SideAppPreference {
            switch option {
            case .App:
                tempAppPreference = .App
                playInYotubeApp()
                playerView.stopVideo()
            case .Embedded:
                playerView.playVideo()
                tempAppPreference = .Embedded
            }
        }
    }
}

class EmbeddedURLCell: UITableViewCell, WKNavigationDelegate, WKUIDelegate, CallbackDelegate {
    private var tempAppPreference: SideAppPreference?
    private var sideAppPreference: SideAppPreference? {
        if app == .TikTok {
            if AppData.shared.system.tiktokPlayOption == nil {
                return nil
            } else {
                return AppData.shared.system.tiktokPlayOption
            }
        }
        return nil
    }
    private var isTiTokInstalled: Bool {
        let appName = "tiktok"
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)
        return UIApplication.shared.canOpenURL(appUrl! as URL)
    }
    private var opaqueView: UIView?
    var url: URL!
    var isContentLoading = false
    var app: ThirdPartyApp  = .Null
    weak var delegate: CallbackDelegate?
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            opaqueView = UIView(frame: .zero)
            opaqueView!.backgroundColor = .clear
            opaqueView!.addEquallyTo(to: contentView)
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(EmbeddedURLCell.viewTapped(recognizer: )))
            opaqueView!.addGestureRecognizer(recognizer)
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.alpha = 0
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.3, delay: 1, options: [.curveEaseInOut], animations: {
            self.webView.alpha = 1
        })
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    print(html)
        })
    }
    
    @objc private func viewTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            switch app {
            case .TikTok:
                if sideAppPreference == .App || tempAppPreference == .App {
                    if isTiTokInstalled {
                        UIApplication.shared.open(url, options: [:], completionHandler: {_ in})
                    }
                } else if sideAppPreference == nil, tempAppPreference == nil, isTiTokInstalled {
                    Banner.shared.contentType = .SideApp
                    if let content = Banner.shared.content as? SideApp {
                        content.app = .TikTok
                        content.delegate = self
                    }
                    Banner.shared.present(isModal: true, delegate: nil)
                }
            default:
                print("")
            }
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if sideAppPreference != nil {
            return sideAppPreference == .App ? false : true
        } else if tempAppPreference != nil {
            return tempAppPreference == .App ? false : true
        }
        return true
    }
    
    func callbackReceived(_ sender: AnyObject) {
        if let option = sender as? SideAppPreference {
            switch option {
            case .App:
                tempAppPreference = .App
                UIApplication.shared.open(url, options: [:], completionHandler: {_ in})
            case .Embedded:
                tempAppPreference = .Embedded
                opaqueView?.removeFromSuperview()
            }
        }
    }
}

class ChoiceSelectionCell: UITableViewCell {
    deinit {
        print("***ChoiceSelectionCell deinit***")
    }
    
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var textView: UITextView! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(ChoiceSelectionCell.handleTap(recognizer:)))
            textView.addGestureRecognizer(recognizer)
            if answer != nil {
                let textContent = answer.description.contains("\t") ? answer.description : "\t" + answer.description
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                paragraphStyle.lineSpacing = 5
                let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 16), foregroundColor: isChecked ? .black : .gray, backgroundColor: .clear), range: textContent.fullRange())
                textView.attributedText = attributedString
                textView.textContainerInset = UIEdgeInsets(top: 3, left: textView.textContainerInset.left, bottom: 3, right: textView.textContainerInset.right)
            }
        }
    }
    
    var answer: Answer! {
        didSet {
            if textView != nil {
                let textContent = answer.description.contains("\t") ? answer.description : "\t" + answer.description
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                paragraphStyle.lineSpacing = 5
                let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 16), foregroundColor: isChecked ? .black : .gray, backgroundColor: .clear), range: textContent.fullRange())
                textView.attributedText = attributedString
                textView.textContainerInset = UIEdgeInsets(top: 3, left: textView.textContainerInset.left, bottom: 3, right: textView.textContainerInset.right)
            }
        }
    }
    weak var delegate: CallbackDelegate?
//    var index: IndexPath!
    var isChecked = false {
        didSet {
            if oldValue != isChecked, checkBox != nil {
                checkBox.isOn = isChecked
                UIView.transition(with: textView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.textView.textColor = self.isChecked ? .black : .gray
                })
            }
        }
    }
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            delegate?.callbackReceived(index as AnyObject)
        }
    }
}

class ChoiceResultCell: UITableViewCell {
    enum Mode {
        case None, Anon, Stock
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            if answer != nil {
                let textContent = answer.description
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                paragraphStyle.lineSpacing = 5
                let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .black, backgroundColor: .clear), range: textContent.fullRange())
                textView.attributedText = attributedString
                textView.textContainerInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            }
        }
    }
    @IBOutlet weak var resultIndicator: ResultIndicator! {
        didSet {
            resultIndicator.layer.masksToBounds = false
        }
    }
    var selectedResult = false {
        didSet {
            if resultIndicator != nil, selectedResult {
                resultIndicator.isSelected = selectedResult
            }
        }
    }
    var percent: Int = 0 {
        didSet {
            if resultIndicator != nil {
                resultIndicator.value = percent
            }
        }
    }
    var mode: Mode = .Stock {
        didSet {
            if resultIndicator != nil {
                resultIndicator.mode = mode
            }
        }
    }
    var isViewSetupComplete = false
    var answer: Answer! {
        didSet {
            if textView != nil {
                let textContent = answer.description
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                paragraphStyle.lineSpacing = 5
                let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .black, backgroundColor: .clear), range: textContent.fullRange())
                textView.attributedText = attributedString
                textView.textContainerInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            }
            if resultIndicator != nil {
                resultIndicator.totalCount = answer.totalVotes
                resultIndicator.userprofiles = answer.userprofiles
//                resultIndicator.apiManager = apiMa
            }
        }
    }
    
//    override func layoutSubviews() {
//        if resultIndicator != nil {
//            resultIndicator.imageViews.forEach({ $0.keys.first!.cornerRadius = $0.keys.first!.frame.height/2})
//        }
//    }
}

class SurveyVoteCell: UITableViewCell {
    @IBOutlet weak var claimIcon: Icon! {
        didSet {
            claimIcon.backgroundColor = .clear
            claimIcon.isRounded = false
            claimIcon.iconColor = Colors.Tags.OrangeSoda
            claimIcon.scaleMultiplicator = 1.35
            claimIcon.category = .Caution
        }
    }
    @IBOutlet weak var claimButton: UIButton! {
        didSet {
//            claimButton.setTitleColor(Colors.Tags.OrangeSoda, for: .normal)
        }
    }
    @IBAction func claimTapped(_ sender: Any) {
        delegate?.callbackReceived("claim" as AnyObject)
    }
    @IBOutlet weak var btn: UIButton!
    @IBAction func btnTapped(_ sender: Any) {
        delegate?.callbackReceived("vote" as AnyObject)
    }
    weak var delegate: CallbackDelegate?
}
