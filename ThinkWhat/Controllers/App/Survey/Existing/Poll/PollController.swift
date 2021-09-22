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

    deinit {
        print("DEINIT PollController")
        NotificationCenter.default.removeObserver(self)
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
    private var isSurveyJustCompleted = false
    private var isReadOnly = false
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
    private let tableViewSections            = ["main", "answers", "vote"]
    private var isRequesting        = false
    private let requestAttempts     = 3
    private var loadingIndicator:   LoadingIndicator?
    private let likeButton          = HeartView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
    private var isInitialLoading    = true {
        didSet {
            if tableView != nil {
                tableView.isUserInteractionEnabled = !isInitialLoading
            }
        }
    }
    weak var delegate: CallbackDelegate?
    private var isDownloadingImages  = true
    private var selectedAnswerID = 0 {
        didSet {
            if oldValue != selectedAnswerID {
                //UI update
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SurveyVoteCell {
                    UIView.animate(withDuration: 0.3) {
                        cell.btn.backgroundColor = K_COLOR_RED
                    }
                }
                isAutoScrolling = true
                navigationController?.setNavigationBarHidden(true, animated: true)
                delay(seconds: 0.3) {
                    self.isAutoScrolling = false
                }
                tableView.scrollToBottom()//scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
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
    private var answersCells: [SurveyAnswerCell]    = []
    private var needsAnimation                      = true
    private var scrollArrow: ScrollArrow!
    private var isAutoScrolling = false   //is on when scrollArrow is tapped
    
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
//                self.presentSurvey()
                if surveyRef == nil {
                    surveyRef = SurveyRef(id: survey!.ID!, title: survey!.title, startDate: survey!.startDate, category: survey!.category, type: survey!.type)
                }
                if let owner = strongSurvey.userProfile, owner.image == nil, let url = owner.imageURL as? String {
                    apiManager.downloadImage(url: url) {
                        image, error in
                        if error != nil {
                            print(error!.localizedDescription)
                        }
                        if image != nil {
                            self.survey!.userProfile!.image = image!
                            NotificationCenter.default.post(name: Notifications.UI.ProfileImageReceived, object: nil)
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
    
    private func setupViews() {
        //Set icon category in title
        let icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        icon.backgroundColor = .clear
        icon.iconColor = surveyRef.category.tagColor
        icon.scaleMultiplicator = 0.25
        icon.category = SurveyCategoryIcon.Category(rawValue: surveyRef.category.ID) ?? .Null
        navigationItem.titleView = icon
        
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.setNavigationBarHidden(false, animated: false)
            nc.isShadowed = true
            nc.navigationBar.isTranslucent = false
            //            nc.transitionStyle = .Default
        }
        navigationItem.rightBarButtonItems                  = [UIBarButtonItem(customView: likeButton)]
//        let gesture     = UITapGestureRecognizer(target: self, action: #selector(SurveyViewController.barButtonTapped(gesture:)))
//        likeButton.addGestureRecognizer(gesture)
        
    }
    
    private func performChecks() {
        //Check if Survey is already downloaded
        if survey == nil, let found = Surveys.shared.downloadedObjects.filter({ $0.ID == self.surveyRef.ID }).first {
            survey = found
        } else {
            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.width)))
            loadingIndicator!.layoutCentered(in: self.view, multiplier: 0.8)
            loadingIndicator!.layer.zPosition = 1
            loadingIndicator?.alpha = 1
            loadingIndicator?.addEnableAnimation()
            loadData()
        }
    }
    
    //Load data into app
    private func loadData() {
        requestAttempt += 1
        apiManager.loadSurvey(survey: surveyRef) {
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
    
}

extension PollController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard survey != nil else {
            return UITableViewCell()
        }
        if indexPath.section == 0 { //Params
            if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "author", for: indexPath) as? AuthorCell {
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                if let image = survey!.userProfile!.image {
                    cell.avatar.image = image.circularImage(size: cell.avatar.frame.size, frameColor: K_COLOR_RED)
                }
                let attrString = NSMutableAttributedString()
                attrString.append(NSAttributedString(string: "  \(survey!.category.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 10), foregroundColor: survey!.category.tagColor, backgroundColor: .clear)))
                attrString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 10), foregroundColor: survey!.category.tagColor, backgroundColor: .clear)))
                attrString.append(NSAttributedString(string: "\(survey!.category.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 10), foregroundColor: survey!.category.tagColor, backgroundColor: .clear)))
                cell.categoryLabel.attributedText = attrString
                cell.userCredentials.text = survey!.userProfile?.name.replacingOccurrences(of: " ", with: "\n")//.components(separatedBy: CharacterSet.whitespaces)
                return cell
            } else if indexPath.row == 1, let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? TitleCell {
                cell.title.text = survey!.title
                return cell
            } else if indexPath.row == 2, let cell = tableView.dequeueReusableCell(withIdentifier: "description", for: indexPath) as? DescriptionCell {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                let text = "     \(survey!.description)"
                let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Light, size: 17), foregroundColor: .black, backgroundColor: .clear), range: text.fullRange())
                cell.textView.attributedText = attributedString
                return cell
            } else if indexPath.row == 3 {
                if survey!.images != nil, !survey!.images!.isEmpty, let cell = tableView.dequeueReusableCell(withIdentifier: "images", for: indexPath) as? ImagesCell  {
                    cell.createSlides(count: survey!.images!.count)
                    for (i, dict) in survey!.images!.enumerated() {
                        if let image = dict.keys.first {
                            cell.slides[i].imageView.image = image
                            cell.slides[i].imageView.progressIndicatorView.alpha = 0
                        }
                    }
                    cell.delegate = self
                    return cell
                } else if survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty, let cell = tableView.dequeueReusableCell(withIdentifier: "images", for: indexPath) as? ImagesCell {
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
                                    if self.survey!.images!.count > 1 {
                                        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseInOut, animations: {
                                            cell.pageControl.alpha = 1
                                        })
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
            }
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return survey == nil ? 0 : tableViewSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {//ОСНОВНОЕ
            return 5
        } else if section == 1, survey != nil {//ОТВЕТЫ
            return survey!.answers.count
        } else if section == 2 {//ПОСЛЕДНЯЯ СЕКЦИЯ
            return 1//2
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
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 86
        }
        return CGFloat.leastNonzeroMagnitude
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
        }
    }
    @IBOutlet weak var categoryLabel: UILabel!
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        
    }
}

class TitleCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class DescriptionCell: UITableViewCell {
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
    @IBOutlet weak var pageControl: UIPageControl! {
        didSet {
            pageControl.alpha = 0
        }
    }
    
    @objc fileprivate func callback() {
        delegate?.callbackReceived(self)
    }
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
                scrollView.addSubview(slide)
                slides.append(slide)
            }
            pageControl.numberOfPages = count
            isSetupCompleted = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/contentView.frame.width)
        pageControl.currentPage = Int(pageIndex)
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
    private var loadingIndicator: LoadingIndicator!
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
            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: contentView.frame.height, height: contentView.frame.height)))
            loadingIndicator.layoutCentered(in: contentView, multiplier: 0.6)//addEquallyTo(to: tableView)
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
