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

class SurveyViewController: UITableViewController {
    
    fileprivate var requestAttempt = 0 {
        didSet {
            if oldValue != requestAttempt {
                if requestAttempt > MAX_REQUEST_ATTEMPTS {
                    requestAttempt = 0
                }
            }
        }
    }
    fileprivate let sections = ["ОСНОВНОЕ", "ОТВЕТЫ"]
    fileprivate var isRequesting = false
    fileprivate lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
    fileprivate let requestAttempts = 3
    fileprivate var loadingIndicator: LoadingIndicator!
    fileprivate let likeButton = HeartView(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
    fileprivate var isInitialLoading = true
    var surveyLink: SurveyLink! {
        didSet {
            likeButton.removeAllAnimations()
            title = surveyLink.category!.title//"Опрос №\(surveyLink.ID)"
            likeButton.state = Array(Surveys.shared.favoriteSurveys.keys).filter( {$0.ID == surveyLink.ID }).isEmpty ? .disabled : .enabled
        }
    }
    
    var survey: Survey? {
        didSet {
            if survey != nil, isInitialLoading {
                tableView.reloadData()
                delay(seconds: 0.01) {
                    self.presentSurvey()
                }
                //                surveyQuestion.text = "     \(survey!.description)"
                //                let sizeThatFitsTextView = surveyQuestion.sizeThatFits(CGSize(width: surveyQuestion.frame.size.width, height: CGFloat(MAXFLOAT)))
                //                print(sizeThatFitsTextView)
                //                view.setNeedsLayout()
                //                surveyQuestionHeight.constant = sizeThatFitsTextView.height
                //                view.layoutIfNeeded()
                //TODO: answers
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage     = UIImage()
        self.navigationController?.navigationBar.isTranslucent   = false
        self.navigationController?.isNavigationBarHidden         = false
        self.navigationController?.navigationBar.barTintColor    = .white
        self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.rightBarButtonItem                   = UIBarButtonItem(customView: likeButton)
        self.loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.width)))
        self.loadingIndicator.layoutCentered(in: self.view, multiplier: 0.8)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SurveyViewController.likeTapped(gesture:)))
        likeButton.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //surveyTitle.text = surveyLink.title
        if let _survey = Surveys.shared[surveyLink.ID] {
            isInitialLoading = false
            survey = _survey
            loadingIndicator.alpha = 0
//            for subview in view.subviews {
//                if !(subview is LoadingTextIndicator) {
//                    subview.alpha = 1
//                }
//            }
        } else {
//            self.view.alpha = 0
//            tableView.alpha = 0
//            for subview in view.subviews {
//                if !(subview is LoadingTextIndicator) {
//                    subview.alpha = 0
//                }
//                if subview is UILabel {
//                    subview.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1)
//                }
//            }
            isInitialLoading = true
            loadingIndicator.alpha = 1
            loadingIndicator.addUntitled1Animation()
            loadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return survey == nil ? 0 : sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {//ОСНОВНОЕ
            return 5
        } else if section == 1, survey != nil {
            return survey!.answers.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 { //Params
            if indexPath.row == 0, let _cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? SurveyTitleCell {
                _cell.label.text = surveyLink.title
                if isInitialLoading {
                    _cell.label.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
                    _cell.label.layer.opacity = 0
                }
                cell = _cell
            } else if indexPath.row == 1, let _cell = tableView.dequeueReusableCell(withIdentifier: "question", for: indexPath) as? SurveyQuestionCell {
                _cell.textView.text = survey!.description
                if isInitialLoading {
//                    _cell.label.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1)
                    _cell.textView.alpha = 0
                }
                cell = _cell
            } else if indexPath.row == 2, survey!.link != nil, !survey!.link!.isEmpty, let _cell = tableView.dequeueReusableCell(withIdentifier: "link", for: indexPath) as? SurveyLinkCell {
                _cell.delegate = self
                if isInitialLoading {
                    _cell.linkButton.alpha = 0
                }
                cell = _cell
            } else if indexPath.row == 3, survey!.link != nil, !survey!.link!.isEmpty, let _cell = tableView.dequeueReusableCell(withIdentifier: "youtube", for: indexPath) as? SurveyYoutubeCell {
                let isYoutube = isYoutubeLink(checkString: survey!.link!)
//                _cell.isVisible = isYoutube ? true : false
                _cell.playerView.delegate = self
                if isYoutube {
                    _cell.loadVideo(url: survey!.link!)
                }
                if isInitialLoading {
//                    _cell.contentView.alpha = 0
//                    _cell.playerView.layer.add(animateFadeInOut(layer: _cell.playerView.layer, fromValue: 0, toValue: 1, duration: 0.75, timingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)), forKey: nil)
                    _cell.contentView.alpha = 1
                    for v in _cell.contentView.subviews {
                        if v is FilmIcon {
                            v.alpha = 0
                        }
                    }
                    let isYoutube = self.isYoutubeLink(checkString: self.survey!.link!)
                    //                _cell.isVisible = isYoutube ? true : false
                    if isYoutube {
                        _cell.loadVideo(url: self.survey!.link!)
                    }
                }
                cell = _cell
            } else if indexPath.row == 4, survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty, let _cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? SurveyImageCell {
                _cell.createSlides(count: survey!.imagesURLs!.count)
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
                            _cell.slides[i].imageView.image = image
                            _cell.slides[i].imageView.progressIndicatorView.reveal()
                        }
                    }
                }
                if isInitialLoading {
                    _cell.contentView.alpha = 0
                }
                cell = _cell
            }
        } else if indexPath.section == 1 {
            if let _cell = tableView.dequeueReusableCell(withIdentifier: "answer", for: indexPath) as? SurveyAnswerCell {
//                _cell.label.text = surveyLink.title
                if isInitialLoading {
                                    }
                cell = _cell
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {//Title
                return 120
            } else if indexPath.row == 2 {
                if survey!.link != nil, !survey!.link!.isEmpty, !isYoutubeLink(checkString: survey!.link!), let _ = URL(string: survey!.link!) {
                    return UITableView.automaticDimension
                }
                return 0
            } else if indexPath.row == 3 {
                if survey!.link != nil, !survey!.link!.isEmpty, isYoutubeLink(checkString: survey!.link!) {
                    return 220
                }
                return 0
            } else if indexPath.row == 4 {
                if survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty {
                    return 220
                }
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
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
                        self.loadingIndicator.alpha = 0
                    }) { _ in self.loadingIndicator.removeAllAnimations() } }]]], text: "Ошибка: \(error!.localizedDescription)")
                } else {
                    //Retry
                    self.loadData()
                }
            }
            if json != nil {
                print(json!)
                if let _survey = Survey(json!) {
                    Surveys.shared.downloadedSurveys.append(_survey)
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
                    if Array(Surveys.shared.favoriteSurveys.keys).filter( {$0.ID == surveyLink.ID }).isEmpty { Surveys.shared.favoriteSurveys[self.surveyLink] = Date() }
                } else {
                    likeButton.state = .disabled
                    mark = false
                    if let key = Surveys.shared.favoriteSurveys.keys.filter({ $0.ID == surveyLink.ID }).first {
                        Surveys.shared.favoriteSurveys.removeValue(forKey: key)
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
    
    //POST request post answer
    fileprivate func postAnswer() {
        //TODO
    }
}

//UI, animations
extension SurveyViewController {
    fileprivate func presentSurvey() {
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingIndicator.alpha = 0
            self.isInitialLoading = false
            delay(seconds: 0.1) {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SurveyTitleCell {
                    self.animateScaleFade(scaleFactor: 0.7, duration: 0.5, view: cell.label)
                }
            }
            delay(seconds: 0.2) {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SurveyQuestionCell {
                    cell.textView.layer.add(animateFadeInOut(layer: cell.textView.layer, fromValue: 0, toValue: 1, duration: 0.45, timingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)), forKey: nil)
                    cell.textView.alpha = 1
                }
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SurveyLinkCell {
                    cell.linkButton.layer.add(animateFadeInOut(layer: cell.linkButton.layer, fromValue: 0, toValue: 1, duration: 0.45, timingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)), forKey: nil)
                    cell.linkButton.alpha = 1
                }
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? SurveyYoutubeCell {
//                    cell.playerView.layer.add(animateFadeInOut(layer: cell.playerView.layer, fromValue: 0, toValue: 1, duration: 0.45, timingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)), forKey: nil)
//                    cell.contentView.alpha = 1
//                    let isYoutube = self.isYoutubeLink(checkString: self.survey!.link!)
//                    //                _cell.isVisible = isYoutube ? true : false
//                    if isYoutube {
//                        cell.loadVideo(url: self.survey!.link!)
//                    }
                    for v in cell.contentView.subviews {
                        if v is FilmIcon {
                            UIView.animate(withDuration: 0.45, animations: {
                                v.alpha = 1
                            })
                        }
                    }
                }
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? SurveyImageCell {
                    UIView.animate(withDuration: 0.45, animations: {
                        cell.contentView.alpha = 1
                    })
                }
            }
        }) {
            _ in
            self.loadingIndicator.removeAllAnimations()
            self.isInitialLoading = false
        }
        
        
    
        
//        UIView.animate(withDuration: 0.3, animations: {
//            for subview in self.view.subviews {
//                if subview is LoadingTextIndicator {
//                    subview.alpha = 0
//                }/* else if subview is UITextView {
//                     self.animateScaleFade(scaleFactor: 0.3, duration: 1, view: subview)
//                 } */else if subview is UILabel {
//                    self.animateScaleFade(scaleFactor: 0.3, duration: 1, view: subview)
//                    //                    let label = subview as! UILabel
//                    //                    label.alpha = 1
//                    //                    label.setTextWithTypeAnimation(typedText: label.text!, characterDelay: 6.6)
//                } else {
//                    UIView.animate(withDuration: 0.9, delay: 0.3, options: [.curveEaseIn], animations: {
//                        subview.alpha = 1
//                    })
//                }
//            }
//        }) { _ in self.loadingIndicator.removeAllAnimations() }
    }
    
    fileprivate func animateScaleFade(scaleFactor: CGFloat, duration: CFTimeInterval, view _view: UIView) {
        //Light scale/fade animation
        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
        let groupAnim       = CAAnimationGroup()
        
        scaleAnim.fromValue = scaleFactor
        scaleAnim.toValue   = 1.0
//        scaleAnim.duration  = duration
        fadeAnim.fromValue  = 0
        fadeAnim.toValue    = 1
//        fadeAnim.duration   = duration
        
        groupAnim.animations        = [scaleAnim, fadeAnim]
        groupAnim.duration          = duration
        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        _view.layer.add(groupAnim, forKey: nil)
        _view.layer.opacity = Float(1)
        _view.layer.transform = CATransform3DMakeScale(1, 1, 1)
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

extension SurveyViewController: CellButtonDelegate {
    func cellSubviewTapped(_ sender: AnyObject) {
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
        }
    }
}



















////
////  _SurveyViewController.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 04.11.2019.
////  Copyright © 2019 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class _SurveyViewController: UIViewController {
//
//    @IBOutlet weak var surveyTitle: UILabel!
//    @IBOutlet weak var surveyQuestion: UITextView!
//    @IBOutlet weak var surveyQuestionHeight: NSLayoutConstraint!
//    fileprivate var requestAttempt = 0 {
//        didSet {
//            if oldValue != requestAttempt {
//                if requestAttempt > MAX_REQUEST_ATTEMPTS {
//                    requestAttempt = 0
//                }
//            }
//        }
//    }
//    private var isRequesting = false
//    private lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
//    private let requestAttempts = 3
//    private var loadingIndicator: LoadingTextIndicator!
//    private let likeButton = HeartView(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
//    var surveyLink: SurveyLink! {
//        didSet {
//            likeButton.removeAllAnimations()
//            title = surveyLink.category!.title//"Опрос №\(surveyLink.ID)"
//            likeButton.state = Array(Surveys.shared.favoriteSurveys.keys).filter( {$0.ID == surveyLink.ID }).isEmpty ? .disabled : .enabled
//        }
//    }
//    var survey: Survey? {
//        didSet {
//            if survey != nil {
//                surveyQuestion.text = "     \(survey!.description)"
//                let sizeThatFitsTextView = surveyQuestion.sizeThatFits(CGSize(width: surveyQuestion.frame.size.width, height: CGFloat(MAXFLOAT)))
//                print(sizeThatFitsTextView)
//                view.setNeedsLayout()
//                surveyQuestionHeight.constant = sizeThatFitsTextView.height
//                view.layoutIfNeeded()
//                //TODO: answers
//            }
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//    }
//
//    private func setupViews() {
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage     = UIImage()
//        self.navigationController?.navigationBar.isTranslucent   = false
//        self.navigationController?.isNavigationBarHidden         = false
//        self.navigationController?.navigationBar.barTintColor    = .white
//        self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
//
//        //        DispatchQueue.main.async {
//        self.loadingIndicator = LoadingTextIndicator(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.width)))
//        self.loadingIndicator.layoutCentered(in: self.view, multiplier: 0.8)
//        //        }
//
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(_SurveyViewController.likeTapped(gesture:)))
//        likeButton.addGestureRecognizer(gesture)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        surveyTitle.text = surveyLink.title
//        if let _survey = Surveys.shared[surveyLink.ID] {
//            survey = _survey
//            loadingIndicator.alpha = 0
//            for subview in view.subviews {
//                if !(subview is LoadingTextIndicator) {
//                    subview.alpha = 1
//                }
//            }
//        } else {
//            for subview in view.subviews {
//                if !(subview is LoadingTextIndicator) {
//                    subview.alpha = 0
//                }
//                if subview is UILabel {
//                    subview.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1)
//                }
//            }
//            loadingIndicator.alpha = 1
//            loadingIndicator.addEnableAnimation()
//            loadData()
//        }
//    }
//
//
//    /*
//     // MARK: - Navigation
//
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destination.
//     // Pass the selected object to the new view controller.
//     }
//     */
//
//}
//
//extension _SurveyViewController: ServerInitializationProtocol {
//    func initializeServerAPI() -> APIManagerProtocol {
//        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).apiManager
//    }
//}
//
////API calling
//extension _SurveyViewController {
//    //GET request SurveySerializer
//    public func loadData() {
//
//        requestAttempt += 1
//        apiManager.loadSurvey(survey: surveyLink) {
//            json, error in
//            if error != nil {
//                if self.requestAttempt > MAX_REQUEST_ATTEMPTS {
//                    showAlert(type: .Ok, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { UIView.animate(withDuration: 0.3, animations: {
//                        self.loadingIndicator.alpha = 0
//                    }) { _ in self.loadingIndicator.removeAllAnimations() } }]]], text: "Ошибка: \(error!.localizedDescription)")
//                } else {
//                    //Retry
//                    self.loadData()
//                }
//            }
//            if json != nil {
//                print(json!)
//                if let _survey = Survey(json!) {
//                    Surveys.shared.downloadedSurveys.append(_survey)
//                    self.survey = _survey
//                    self.requestAttempt = 0
//                }
//                self.presentSurvey()
//            }
//        }
//    }
//
//    //POST request FavoriteSurvey model
//    @objc fileprivate func likeTapped(gesture: UITapGestureRecognizer) {
//        if !isRequesting {
//            isRequesting = true
//            if gesture.state == .ended {
//                var mark = true
//                if likeButton.state == .disabled {
//                    likeButton.state = .enabled
//                    mark = true
//                    if Array(Surveys.shared.favoriteSurveys.keys).filter( {$0.ID == surveyLink.ID }).isEmpty { Surveys.shared.favoriteSurveys[self.surveyLink] = Date() }
//                } else {
//                    likeButton.state = .disabled
//                    mark = false
//                    if let key = Surveys.shared.favoriteSurveys.keys.filter({ $0.ID == surveyLink.ID }).first {
//                        Surveys.shared.favoriteSurveys.removeValue(forKey: key)
//                    }
//                    //                Surveys.shared.favoriteSurveys.removeValue(forKey: self.surveyLink)
//                    NotificationCenter.default.post(name: kNotificationFavoriteSurveysUpdated, object: nil)
//                }
//                apiManager.markFavorite(mark: mark, survey: surveyLink!) {
//                    _, error in
//                    self.isRequesting = false
//                    if error != nil {
//                        showAlert(type: CustomAlertView.AlertType.Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], title: "Ошибка", body: "Опрос не добавлен в любимые. \(error!.localizedDescription)")
//                    }
//                }
//            }
//        }
//    }
//
//    //POST request post answer
//    fileprivate func postAnswer() {
//        //TODO
//    }
//}
//
////UI, animations
//extension _SurveyViewController {
//    fileprivate func presentSurvey() {
//        UIView.animate(withDuration: 0.3, animations: {
//            for subview in self.view.subviews {
//                if subview is LoadingTextIndicator {
//                    subview.alpha = 0
//                }/* else if subview is UITextView {
//                     self.animateScaleFade(scaleFactor: 0.3, duration: 1, view: subview)
//                 } */else if subview is UILabel {
//                    self.animateScaleFade(scaleFactor: 0.3, duration: 1, view: subview)
//                    //                    let label = subview as! UILabel
//                    //                    label.alpha = 1
//                    //                    label.setTextWithTypeAnimation(typedText: label.text!, characterDelay: 6.6)
//                } else {
//                    UIView.animate(withDuration: 0.9, delay: 0.3, options: [.curveEaseIn], animations: {
//                        subview.alpha = 1
//                    })
//                }
//            }
//        }) { _ in self.loadingIndicator.removeAllAnimations() }
//    }
//
//    fileprivate func animateScaleFade(scaleFactor: CGFloat, duration: CFTimeInterval, view _view: UIView) {
//        //Light scale/fade animation
//        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
//        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
//        let groupAnim       = CAAnimationGroup()
//
//        scaleAnim.fromValue = scaleFactor
//        scaleAnim.toValue   = 1.0
//        fadeAnim.fromValue  = 0
//        fadeAnim.toValue    = 1
//
//        groupAnim.animations        = [scaleAnim, fadeAnim]
//        groupAnim.duration          = duration
//        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//
//        _view.layer.add(scaleAnim, forKey: nil)
//        _view.layer.opacity = Float(1)
//        _view.layer.transform = CATransform3DMakeScale(1, 1, 1)
//    }
//}
