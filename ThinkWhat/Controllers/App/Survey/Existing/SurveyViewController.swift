//
//  SurveyViewController_.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView
import SafariServices
import SwiftyJSON

class SurveyViewController: UITableViewController, UINavigationControllerDelegate {
    
    deinit {
        print("deinit")
    }
    
    class var answerHeaderCell: UINib {
        return UINib(nibName: "AnswerHeaderCell", bundle: nil)
    }
    
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
    
    fileprivate var isReadOnly = false {//false - user hasn't answered this survey
        didSet {
            if isReadOnly {
                //View mode
                print("View mode")
            }
        }
    }
    fileprivate var requestAttempt = 0 {
        didSet {
            if oldValue != requestAttempt {
                if requestAttempt > MAX_REQUEST_ATTEMPTS {
                    requestAttempt = 0
                }
            }
        }
    }
    fileprivate lazy var voteCompletionView: VoteCompletionView? = {
        return VoteCompletionView(frame: (UIApplication.shared.keyWindow?.frame)!, delegate: self)
    } ()
    fileprivate let sections = ["ОСНОВНОЕ", "ОТВЕТЫ", "КНОПКА ГОЛОСОВАНИЯ"]
    fileprivate var isRequesting = false
//    fileprivate lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
    var apiManager: APIManagerProtocol!
    fileprivate let requestAttempts = 3
    fileprivate var loadingIndicator: LoadingIndicator?
    fileprivate let likeButton = HeartView(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
    fileprivate var isInitialLoading = true {
        didSet {
            if tableView != nil {
                tableView.isUserInteractionEnabled = !isInitialLoading
            }
        }
    }
    fileprivate var isLoadingImages  = true
    fileprivate var selectedAnswerID = 0 {
        didSet {
            if oldValue != selectedAnswerID {
                //UI update
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SurveyVoteCell {
                    UIView.animate(withDuration: 0.3) {
                        cell.btn.backgroundColor = K_COLOR_RED
                    }
                }
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
                for cell in answersCells {
                    if cell.answer!.ID != selectedAnswerID {
                        cell.isChecked = false
                        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
                        scaleAnim.fromValue = 1.002
                        scaleAnim.toValue   = 1
                        scaleAnim.duration  = 0.15
                        cell.label.layer.add(scaleAnim, forKey: nil)
                        cell.label.transform = CGAffineTransform.identity
                        UIView.transition(with: cell.label, duration: 0.15, options: .transitionCrossDissolve, animations: {
                            cell.label.textColor = UIColor.gray
                        })
                    }
                }
            }
        }
    }
    fileprivate var answersCells: [SurveyAnswerCell]    = []
    fileprivate var needsAnimation                      = true
    fileprivate var headerNeedsAnimation                = true
    
    var surveyLink: ShortSurvey! {
        didSet {
            likeButton.removeAllAnimations()
            title = surveyLink.category!.title//"Опрос №\(surveyLink.ID)"
            likeButton.state = Array(Surveys.shared.favoriteLinks.keys).filter( {$0.ID == surveyLink.ID }).isEmpty ? .disabled : .enabled
        }
    }
    
    var survey: FullSurvey? {
        didSet {
            if survey != nil, isInitialLoading {
//                delay(seconds: 0.01) {
                    self.presentSurvey()
//                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        tableView.register(SurveyViewController.answerHeaderCell, forHeaderFooterViewReuseIdentifier: "answerHeader")
        //Check if user has already answered
        if survey == nil {
            isReadOnly = Surveys.shared.completedSurveyIDs.contains(surveyLink.ID)
        }
    }
    
    private func setupViews() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage     = UIImage()
        self.navigationController?.navigationBar.isTranslucent   = false
        self.navigationController?.isNavigationBarHidden         = false
        self.navigationController?.navigationBar.barTintColor    = .white
        self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.backBarButtonItem?.tintColor         = .black
        self.navigationItem.rightBarButtonItem                   = UIBarButtonItem(customView: likeButton)
        self.loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.width)))
        self.loadingIndicator!.layoutCentered(in: self.view, multiplier: 0.8)
        self.loadingIndicator!.layer.zPosition = 1
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SurveyViewController.likeTapped(gesture:)))
        likeButton.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        //surveyTitle.text = surveyLink.title
        if survey != nil {
            isInitialLoading = false
            loadingIndicator?.alpha = 0
            if survey!.images != nil {
                isLoadingImages = false
            }
        } else if let _survey = Surveys.shared[surveyLink.ID] {
            isInitialLoading = false
            survey = _survey
            loadingIndicator?.alpha = 0
            if survey!.images != nil {
                isLoadingImages = false
            }
        } else {
            isInitialLoading = true
            loadingIndicator?.alpha = 1
            loadingIndicator?.addEnableAnimation()
            loadData()
        }
        if let likeBtn = navigationItem.rightBarButtonItem?.customView {
            likeBtn.alpha = 0
            likeBtn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                likeBtn.transform = .identity
                likeBtn.alpha = 1
                
//                self.navigationController?.navigationBar.layoutIfNeeded()
            })
        }
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        voteCompletionView = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return survey == nil ? 0 : sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {//ОСНОВНОЕ
            return 5
        } else if section == 1, survey != nil {//ОТВЕТЫ
            return survey!.answers.count
        } else if section == 2 {//ПОСЛЕДНЯЯ СЕКЦИЯ
//            if isReadOnly {
//                return 1
//            } else if selectedAnswerID != 0 {
//                return 1
//            }
            return 2
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 { //Params
            if indexPath.row == 0, let _cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? SurveyTitleCell {
                if survey != nil {
                    _cell.label.text = survey!.title
                } else {
                    _cell.label.text = surveyLink.title
                }
                cell = _cell
            } else if indexPath.row == 1, let _cell = tableView.dequeueReusableCell(withIdentifier: "question", for: indexPath) as? SurveyQuestionCell {
                _cell.textView.text = survey!.description
                cell = _cell
            } else if indexPath.row == 2, survey!.link != nil, !survey!.link!.isEmpty, let _cell = tableView.dequeueReusableCell(withIdentifier: "link", for: indexPath) as? SurveyLinkCell {
                _cell.delegate = self
                _cell.delegate = self
                cell = _cell
            } else if indexPath.row == 3, survey!.link != nil, !survey!.link!.isEmpty, let _cell = tableView.dequeueReusableCell(withIdentifier: "youtube", for: indexPath) as? SurveyYoutubeCell {
                let isYoutube = isYoutubeLink(checkString: survey!.link!)
                _cell.playerView.delegate = self
                _cell.delegate = self
                if isYoutube {
                    _cell.loadVideo(url: survey!.link!)
                }
                if isInitialLoading {
                    _cell.contentView.alpha = 1
                    let isYoutube = self.isYoutubeLink(checkString: self.survey!.link!)
                    if isYoutube {
                        _cell.loadVideo(url: self.survey!.link!)
                    }
                }
                cell = _cell
            } else if indexPath.row == 4, survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty, let _cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? SurveyImageCell {
                //?????
                _cell.createSlides(count: survey!.imagesURLs!.count)
                //?????
//                if isInitialLoading {
                if survey != nil, survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty, (survey!.images == nil), isLoadingImages {
                    self.isLoadingImages = false
                    for (i, imageURL) in survey!.imagesURLs!.enumerated() {
                        apiManager.downloadImage(url: imageURL.keys.first!, percentageClosure: {
                            percent in
                            _cell.slides[i].imageView.progressIndicatorView.progress = percent
                        }) {
                            image, error in
                            if error != nil {
                                showAlert(type: CustomAlertView.AlertType.Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], title: "Ошибка", body: "Изображение не было загружено. \(error!.localizedDescription)")
                            }
                            
                            if image != nil {
                                if self.survey!.images == nil {
                                    self.survey!.images = []
                                }
                                
                                if !self.survey!.images!.isEmpty {
                                    self.survey!.images!.map() {
                                        if let _image = $0.keys.first, !_image.isEqualToImage(image: image!) {
                                            self.survey!.images!.append([image!: imageURL.values.first!])
                                            _cell.slides[i].imageView.image = image
                                            _cell.slides[i].imageView.progressIndicatorView.reveal()
                                        }
                                    }
                                    } else {
                                        self.survey!.images!.append([image!: imageURL.values.first!])
                                        _cell.slides[i].imageView.image = image
                                        _cell.slides[i].imageView.progressIndicatorView.reveal()
                                    }
                                }
                            }
                        }
                } else if survey!.images != nil, !survey!.images!.isEmpty {
                    for (i, dict) in survey!.images!.enumerated() {
                        if let image = dict.keys.first as? UIImage {
                            _cell.slides[i].imageView.image = image
                            _cell.slides[i].imageView.progressIndicatorView.alpha = 0
                        }
                    }
                }
                _cell.delegate = self
                cell = _cell
            }
        } else if indexPath.section == 1 {
            if isReadOnly {
                if let _cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as? SurveyResultCell, let answer = survey!.answers[indexPath.row] as? SurveyAnswer {
                    //Highlight user's answer
                    if let answerID = survey?.result?.keys.first, answerID == answer.ID {
                        _cell.label.isSelected = true
                    } else {
                        _cell.label.isSelected = false
                    }
                    _cell.label.text = answer.text
                    _cell.percent = survey!.getAnswerVotePercentage(answer.totalVotes)
                    cell = _cell
                }
            } else {
                if let _cell = tableView.dequeueReusableCell(withIdentifier: "answer", for: indexPath) as? SurveyAnswerCell {
                    _cell.answer = survey!.answers[indexPath.row]
                    cell = _cell
                    if !answersCells.contains(_cell) {
                        answersCells.append(_cell)
                    }
                }
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if isReadOnly {
                    if let _cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath) as? SurveyTotalCell {
                        _cell.label.text = "Голосов: \(survey!.totalVotes)"
                        cell = _cell
                    }
                } else if let _cell = tableView.dequeueReusableCell(withIdentifier: "vote", for: indexPath) as? SurveyVoteCell {
                    _cell.delegate = self
                    if selectedAnswerID != 0 {
                        _cell.btn.backgroundColor = K_COLOR_RED
                        //cell.contentView.alpha = 1
                    } else {
                        _cell.btn.backgroundColor = K_COLOR_GRAY
                        //                    cell.contentView.alpha = 0
                    }
                    cell = _cell
                }
            } else if let _cell = tableView.dequeueReusableCell(withIdentifier: "info", for: indexPath) as? SurveyInfoCell {
                _cell.dateLabel.text = survey?.modified.toDateTimeStringWithoutSeconds()
                if let userProfile = survey?.userProfile {
                    _cell.userLabel.text = userProfile.name
                    if userProfile.image != nil {
                        _cell.userImage.image = userProfile.image!.circularImage(size: _cell.userImage.frame.size, frameColor: K_COLOR_RED)
                    } else {
                        apiManager.downloadImage(url: userProfile.imageURL) {
                            image, error in
                            if error != nil {
                                showAlert(type: CustomAlertView.AlertType.Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], title: "Ошибка", body: "Изображение не было загружено. \(error!.localizedDescription)")
                            }
                            if image != nil {
                                userProfile.image = image!
                                _cell.userImage.alpha = 0
                                _cell.userImage.image = userProfile.image!.circularImage(size: _cell.userImage.frame.size, frameColor: K_COLOR_RED)
                                _cell.userImage.transform = _cell.userImage.transform.scaledBy(x: 0.75, y: 0.75)
                                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                                    _cell.userImage.alpha = 1
                                    _cell.userImage.transform = .identity
                                })
                            }
                        }
                    }
                }
                cell = _cell
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {//Title
                return 140
            } else if indexPath.row == 2 {
                if survey!.link != nil, !survey!.link!.isEmpty, !isYoutubeLink(checkString: survey!.link!), let _ = URL(string: survey!.link!) {
                    return UITableView.automaticDimension
                }
                return 0
            } else if indexPath.row == 3 {
                if survey!.link != nil, !survey!.link!.isEmpty, isYoutubeLink(checkString: survey!.link!) {
                    return 270
                }
                return 0
            } else if indexPath.row == 4 {
                if survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty {
                    return 270
                }
                return 0
            }
        } else if indexPath.section == 1 {
            return max(100, UITableView.automaticDimension)
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if isReadOnly {
                    return 50
                } else {
                    return 100
                }
            } else {
                return 50
            }
//            } else if selectedAnswerID != 0 {
//                return 100
//            } else if selectedAnswerID == 0 {
//                return 0
//            }
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 100
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "answerHeader") as? AnswerHeaderCell {
                header.delegate = self
                return header
            }
        }
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let cell = tableView.cellForRow(at: indexPath) as? SurveyAnswerCell {
                cell.isChecked = true
                let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
                scaleAnim.fromValue = 1
                scaleAnim.toValue   = 1.002
                scaleAnim.duration  = 0.15
                cell.label.layer.add(scaleAnim, forKey: nil)
                cell.label.layer.transform = CATransform3DMakeScale(1.002, 1.002, 1.002)
                UIView.transition(with: cell.label, duration: 0.15, options: .transitionCrossDissolve, animations: {
                    cell.label.textColor = UIColor.black
                })
                //Uncheck others
                selectedAnswerID = cell.answer!.ID
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let animation = AnimationFactory.makeFadeAnimation(duration: 0.18, delayFactor: 0.015)//AnimationFactory.makeSlideInWithFade(duration: 0.1, delayFactor: 0.05)//.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.25, delayFactor: 0.03)//makeFadeAnimation(duration: 0.25, delayFactor: 0.03)//makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.2, delayFactor: 0.05)//
            let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            view.alpha = 0
            UIView.animate(withDuration: 0.18) {
                view.alpha = 1
            }
    }
}


extension SurveyViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol {
        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).apiManager
    }
}

//API calling
extension SurveyViewController {
    //GET request SurveySerializer
    public func loadData() {
        
        requestAttempt += 1
        apiManager.loadSurvey(survey: surveyLink) {
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
                print(json!)
                if let _survey = FullSurvey(json!) {
                    Surveys.shared.append(object: _survey, type: .Downloaded)
                    self.survey = _survey
                    self.requestAttempt = 0
                }
//                self.presentSurvey()
            }
        }
    }
    
    //POST request FavoriteSurvey model
    @objc fileprivate func likeTapped(gesture: UITapGestureRecognizer) {
        if !isRequesting {
            isRequesting = true
            if gesture.state == .ended {
                var mark = true
                if likeButton.state == .disabled {
                    likeButton.state = .enabled
                    mark = true
                    if Array(Surveys.shared.favoriteLinks.keys).filter( {$0.ID == surveyLink.ID }).isEmpty { Surveys.shared.favoriteLinks[self.surveyLink] = Date() }
                } else {
                    likeButton.state = .disabled
                    mark = false
                    if let key = Surveys.shared.favoriteLinks.keys.filter({ $0.ID == surveyLink.ID }).first {
                        Surveys.shared.favoriteLinks.removeValue(forKey: key)
                    }
                    //                Surveys.shared.favoriteSurveys.removeValue(forKey: self.surveyLink)
                    NotificationCenter.default.post(name: kNotificationFavoriteSurveysUpdated, object: nil)
                }
                apiManager.markFavorite(mark: mark, survey: surveyLink!) {
                    _, error in
                    self.isRequesting = false
                    if error != nil {
                        showAlert(type: CustomAlertView.AlertType.Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], title: "Ошибка", body: "Опрос не добавлен в любимые. \(error!.localizedDescription)")
                    }
                }
            }
        }
    }
    
    //POST request post result
    fileprivate func postResult() {
        let result = ["survey": survey!.ID!, "answer": selectedAnswerID]
        apiManager.postResult(result: result) {
            json, error in
            if error != nil {
                showAlert(type: .Ok, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { UIView.animate(withDuration: 0.3, animations: {
                    self.loadingIndicator?.alpha = 0
                }) { _ in self.loadingIndicator?.removeAllAnimations() } }]]], text: "Ошибка: \(error!.localizedDescription)")
            }
            if json != nil {
                self.voteCompletionView?.present()
                print(json!)
                //Update answer votes count, survey total votes, user's survey result & add to completed
                if let response = json!.arrayValue as? [JSON] {
                    for entity in response {
                        if let _answer = entity["answer"].intValue as? Int, let _timestamp = Date(dateTimeString: entity["timestamp"].stringValue as! String) as? Date {
                            self.survey!.result = [_answer: _timestamp]
                            self.survey!.totalVotes += 1
                            for answer in self.survey!.answers {
                                if answer.ID == _answer {
                                    answer.totalVotes += 1
                                    break
                                }
                            }
                            if !Surveys.shared.completedSurveyIDs.contains(self.survey!.ID!) {
                                Surveys.shared.completedSurveyIDs.append(self.survey!.ID!)
                            }
                            //Increase user's balance
                            //TODO Detect, whether it's an ordinary survey
                            AppData.shared.userProfile.balance += SurveyPoints.Vote.rawValue
                        }
                    }
                }
                self.isReadOnly = true
                self.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
                self.tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .fade)
            }
        }
    }
}

//UI, animations
extension SurveyViewController {
    fileprivate func presentSurvey() {
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingIndicator?.alpha = 0
        }) {
            _ in
            self.tableView.reloadData()
            self.loadingIndicator?.removeAllAnimations()
            self.isInitialLoading = false
        }
    }
}

//Helpers
extension SurveyViewController {
    func isYoutubeLink(checkString: String) -> Bool {
        
        let youtubeRegex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?youtu(be\\.com|\\.be)(\\/watch\\?([&=a-z]{0,})(v=[\\d\\w]{1,}).+|\\/[\\d\\w]{1,})"
        
        let youtubeCheckResult = NSPredicate(format: "SELF MATCHES %@", youtubeRegex)
        return youtubeCheckResult.evaluate(with: checkString)
    }
}

extension SurveyViewController: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        print("ready")
        //playerView.load(withVideoId: "LSebnSTh3Ks")
    }
}

extension SurveyViewController: ButtonDelegate {
    func signalReceived(_ sender: AnyObject) {
        if sender is UIButton {
            if let url = URL(string: survey!.link!) {
                var vc: SFSafariViewController!
                if #available(iOS 11.0, *) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true
                    vc = SFSafariViewController(url: url, configuration: config)
                } else {
                    vc = SFSafariViewController(url: url)
                }
                present(vc, animated: true)
            }
        } else if sender is SurveyVoteCell {
            if selectedAnswerID != 0 {
                postResult()
            } else {
                showAlert(type: CustomAlertView.AlertType.Warning, buttons: [["Хорошо": [CustomAlertView.ButtonType.Ok: nil]]], text: "Выберите вариант ответа")
            }
        } else if sender is SurveyImageCell {
            tableView.scrollToRow(at: IndexPath(row: 4, section: 0), at: .top, animated: true)
        } else if sender is SurveyYoutubeCell {
            tableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
        } else if sender is AnswerHeaderCell {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        }
    }
}
