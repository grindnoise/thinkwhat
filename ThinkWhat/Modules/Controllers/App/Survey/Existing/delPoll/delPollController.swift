//
//  PollController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON

class delPollController: UIViewController {

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
    private var shouldDownloadImages  = true
    private var requestAttempt = 0
    private let tableViewSections   = ["main", "answers", "vote"]
    private var isRequesting        = false
    private var loadingIndicator:   ClockIndicator?
    private let likeButton          = HeartView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    private var isInitialLoading    = true {
        didSet {
            if tableView != nil {
                tableView.isUserInteractionEnabled = !isInitialLoading
            }
        }
    }
    weak var delegate: CallbackObservable?
    private var isDownloadingImages  = true
    private var answersCells: [ChoiceSelectionCell] = []
    private var needsAnimation                      = true
    private var scrollArrow: ScrollArrow!
    private var isAutoScrolling = false   //is on when scrollArrow is tapped
    private var vote: Answer! {
        didSet {
            if oldValue != vote {
                //UI update
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SurveyVoteCell {
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.btn.backgroundColor = K_COLOR_RED
                    }) {
                        _ in
                        cell.btn.isUserInteractionEnabled = true
                    }
                }
                if oldValue == nil {
                    delay(seconds: 0.5) {
                        self.isAutoScrolling = false
                    }
                    isAutoScrolling = true
//                    navigationController?.setNavigationBarHidden(true, animated: true)
                    tableView.scrollToBottom()//scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
                }
                answersCells.filter { $0.answer != vote }.forEach { $0.isChecked = false }
            }
        }
    }
    private var resultIndicators: [ResultIndicator] = []
    
    var surveyRef: SurveyReference! {
        didSet {
            if let instance = surveyRef.survey {
                isInitialLoading = false
                survey = surveyRef.survey
            }
            likeButton.removeAllAnimations()
            likeButton.state = Array(Surveys.shared.favoriteReferences.keys).filter( {$0.id == surveyRef.id }).isEmpty ? .disabled : .enabled
        }
    }
    //Nil if object isn't downloaded, checked in performChecks()
    var survey: Survey? {
        didSet {
            guard survey != nil else {
                return
            }
            if survey!.isComplete {
                updateResults()
            }
            if isInitialLoading {
                presentSurvey()
//                if surveyRef == nil {
//                    surveyRef = SurveyRef(id: survey!.id!, title: survey!.title, startDate: survey!.startDate, category: survey!.category, type: survey!.type, isOwn: survey!.isOwn, isComplete: survey!.isComplete, isFavorite: survey!.isFavorite)
//                }
                if survey!.owner.image != nil {
                    NotificationCenter.default.post(name: Notifications.UI.ImageReceived, object: nil)
                } else if survey!.owner.image == nil, let url = survey!.owner.imageURL {
                    API.shared.downloadImage(url: url) { progress in
                        print(progress)
                    } completion: { result in
                        switch result {
                        case .success(let image):
                            self.survey!.owner.image = image
                            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AuthorCell {
                                UIView.transition(with: cell.avatar,
                                                  duration: 0.5,
                                                  options: .transitionCrossDissolve,
                                                  animations: { cell.avatar.imageView.image = image.circularImage(size: cell.avatar.frame.size, frameColor: self.survey!.topic.tagColor) }
                                )
                            }
                        case .failure(let error):
                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
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
        setupUI()
        performChecks()
        
        //Temporary
        UserDefaults.App.youtubePlay = nil
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = true
            nc.duration = 0.25
        }
    }
    
    private func setupUI() {
        //Set icon category in title
        let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        icon.backgroundColor = .clear
        icon.iconColor = surveyRef.topic.tagColor
        icon.isRounded = false
        icon.scaleMultiplicator = 1.4
        icon.category = Icon.Category(rawValue: surveyRef.topic.id) ?? .Null
        navigationItem.titleView = icon
        navigationItem.titleView?.clipsToBounds = false
//        navigationItem.backBarButtonItem?.title = ""
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(delPollController.handleTap))
        likeButton.addGestureRecognizer(gesture)
        
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.setNavigationBarHidden(false, animated: false)
//            nc.isShadowed = true
            nc.navigationBar.isTranslucent = false
        }
        if !surveyRef.isOwn {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: likeButton)]
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(delPollController.updateViewsCount(notification:)),
                                               name: Notifications.UI.SuveyViewsCountReceived,
                                               object: nil)
        tableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.06)
    }
    
    private func updateResults() {
        guard survey != nil else { return }
        for answer in survey!.answers {
            var resultIndicator: ResultIndicator!
            if let found = resultIndicators.filter({ $0.answer === answer }).first {
                resultIndicator = found
            } else {
                resultIndicator = ResultIndicator(delegate: self, answer: answer, color: survey!.topic.tagColor, isSelected: answer.id == survey!.result!.keys.first)
                resultIndicators.append(resultIndicator)
            }
            resultIndicator.needsUIUpdate = true
//            resultIndicator.isSelected = answer.ID == survey!.result!.keys.first
            if survey!.isAnonymous {
                resultIndicator.mode = .Anon
            } else if answer.voters.isEmpty {
                resultIndicator.mode = .None
            }
            resultIndicator.value = survey!.getPercentForAnswer(answer)
        }
    }
    
    private func performChecks() {
        switch survey {
        case .none:
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
            downloadPoll()
        default:
            switch survey?.isComplete {
            case true:
                API.shared.getSurveyStats(surveyReference: surveyRef) { result in
                    switch result {
                    case .success(let json):
                        guard let views = json["views"].int, let results = json["result_total"].array else { return }
                            NotificationCenter.default.post(name: Notifications.UI.SuveyViewsCountReceived, object: views)
                        self.surveyRef.views = views
                        
                        var totalVotes = 0
                        do {
                            for entity in results {
                                guard let dict = entity.dictionary else { continue }
                                guard let data = try dict["userprofiles"]?.rawData() else { continue }
                                guard let _answerID = dict["answer"]?.int else { continue }
                                guard let answer = self.survey?.answers.filter({ $0.id == _answerID }).first, let _total = dict["total"]?.int else { continue }
                                answer.totalVotes = _total
                                totalVotes += _total
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                                           DateFormatter.dateTimeFormatter,
                                                                           DateFormatter.dateFormatter ]
                                let instances = try decoder.decode([Userprofile].self, from: data)
                                for instance in instances {
                                    if let existing = Userprofiles.shared.all.filter({ $0.hashValue == instance.hashValue }).first {
                                        answer.addVoter(existing)
                                        continue
                                    }
                                    answer.addVoter(instance)
                                }
                                
                                self.survey?.totalVotes = totalVotes
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                        //TODO: - Update UI
                        self.updateResults()
                            self.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
                    case .failure(let error):
                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                    }
                }
            case false:
                API.shared.incrementViewCounter(surveyReference: surveyRef) { result in
                    switch result {
                    case .success(let json):
                        guard let views = json["views"].int else { return }
                        NotificationCenter.default.post(name: Notifications.UI.SuveyViewsCountReceived, object: views)
                        self.surveyRef.views = views
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            default:
                fatalError("Shouldn't get here")
            }

        }
    }
    
    private func downloadPoll() {
        requestAttempt += 1
        API.shared.downloadSurvey(surveyReference: surveyRef, incrementCounter: true) { result in
            switch result {
            case .success(let json):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                do {
                    let instance = try decoder.decode(Survey.self, from: json.rawData())
                    self.survey = Surveys.shared.all.filter({ $0.id == instance.id }).first
                    self.requestAttempt = 0
                } catch {
                    fatalError(error.localizedDescription)
                }
            case .failure(let error):
                if self.requestAttempt > MAX_REQUEST_ATTEMPTS {
                    showAlert(type: .Ok, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { UIView.animate(withDuration: 0.3, animations: {
                        self.loadingIndicator?.alpha = 0
                    }) { _ in self.loadingIndicator?.removeAllAnimations() } }]]], text: error.localizedDescription)
                } else {
                    //Retry
                    self.downloadPoll()
                }
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
            if segue.identifier == Segues.App.User, let destinationVC = segue.destination as? UserViewController, let userprofile = survey?.owner {
                nc.duration = 0.25
                nc.transitionStyle = .Icon
                destinationVC.color = survey!.topic.tagColor
                destinationVC.userprofile = userprofile
            } else if segue.identifier == Segues.App.Image, let image = sender as? UIImage, let destinationVC = segue.destination as? delImageViewController, survey != nil {
                nc.duration = 0.25
                nc.transitionStyle = .Icon
                destinationVC.image = image
                destinationVC.mode = .ReadOnly
                destinationVC.titleString = survey?.media.filter({ $0.image == image }).first?.title ?? ""
//                for dict in survey!.images! {
//                    if let text = dict.value.filter({$0.key == image}).values.first {
//                        destinationVC.titleString = text
//                        break
//                    }
//                }
            } else if segue.identifier == Segues.App.UsersList, let destinationVC = segue.destination as? delVotersViewController, let array = sender as? [AnyObject],
                let answer = array.filter({ $0 is Answer}).first as? Answer,
//                let imageViews = array.filter({ $0 is [UIImageView]}).first as? [UIImageView],
                let indexPath = array.filter({ $0 is IndexPath}).first as? IndexPath {
                nc.duration = 0.35
                destinationVC.answer = answer
                destinationVC.initialIndex = indexPath
                destinationVC.frameColor = survey!.topic.tagColor
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
            if survey == nil {
                delBanner.shared.contentType = .Warning
                if let content = delBanner.shared.content as? Warning {
                    content.level = .Error
                    content.text = "Пожалуйста, дождитесь загрузки опроса"
                }
                delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
            } else if survey!.isComplete {
                isRequesting = true
                var mark = true
                if likeButton.state == .disabled {
                    likeButton.state = .enabled
                    mark = true
                    if Array(Surveys.shared.favoriteReferences.keys).filter( {$0.id == surveyRef.id }).isEmpty { Surveys.shared.favoriteReferences[self.surveyRef] = Date() }
                } else {
                    likeButton.state = .disabled
                    mark = false
                    if let key = Surveys.shared.favoriteReferences.keys.filter({ $0.id == surveyRef.id }).first {
                        Surveys.shared.favoriteReferences.removeValue(forKey: key)
                    }
                }
                NotificationCenter.default.post(name: Notifications.Surveys.FavoriteSurveysUpdated, object: nil)
                API.shared.markFavorite(mark: mark, surveyReference: surveyRef) { result in
                    switch result {
                    case .success:
                        print("Added to favorites")
                    case .failure(let error):
                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                    }
                    self.isRequesting = false
                }
            } else {
                delBanner.shared.contentType = .Warning
                if let content = delBanner.shared.content as? Warning {
                    content.level = .Info
                    content.text = "Пройдите опрос для отслеживания результатов"
                }
                delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
            }
        }
    }
}

extension delPollController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let cell = tableView.cellForRow(at: indexPath) as? ChoiceResultCell, let resultIndicator = cell.getResultIndicator() {
                resultIndicator.needsUIUpdate = false
                resultIndicator.setPercentage(value: nil)
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard survey != nil else {
            return UITableViewCell()
        }
        if indexPath.section == 0 { //Params
            if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "author", for: indexPath) as? AuthorCell {
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
//                cell.delegate = self
                if let image = survey!.owner.image {
                    cell.avatar.imageView.image = image.circularImage(size: cell.avatar.frame.size, frameColor: survey!.topic.tagColor)
                }
                let categoryString = NSMutableAttributedString()
                categoryString.append(NSAttributedString(string: "\(survey!.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: survey!.topic.tagColor, backgroundColor: .clear)))
                categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: survey!.topic.tagColor, backgroundColor: .clear)))
                categoryString.append(NSAttributedString(string: "\(survey!.topic.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: survey!.topic.tagColor, backgroundColor: .clear)))
                cell.topic.attributedText = categoryString
                cell.viewsLabel.text = "\(survey!.views), \(survey!.startDate.toDateStringLiteral_dMMM())"
                cell.user.text = survey!.owner.name.replacingOccurrences(of: " ", with: "\n")//.components(separatedBy: CharacterSet.whitespaces)
                return cell
            } else if indexPath.row == 1, let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? LabelCell {
                cell.label.text = survey!.title
                return cell
            } else if indexPath.row == 2, let cell = tableView.dequeueReusableCell(withIdentifier: "description", for: indexPath) as? TextViewCell {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                let text = survey!.description//"\t\(survey!.description)"
                let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 17), foregroundColor: .black, backgroundColor: .clear), range: text.fullRange())
                cell.textView.attributedText = attributedString
                return cell
            } else if indexPath.row == 3 {
                if survey!.imagesCount > 0, let cell = tableView.dequeueReusableCell(withIdentifier: "images", for: indexPath) as? ImagesCell  {
//                    if !cell.isSetupCompleted {
//                        cell.setNeedsLayout()
//                        cell.layoutIfNeeded()
//                        cell.pageControl.cornerRadius = cell.pageControl.frame.height/4
//                        cell.createSlides(count: survey!.imagesCount)
//                        for (index, slide) in cell.slides.enumerated() {
//                            if let media = survey!.mediaWithImageURLs.filter({ $0.order == index}).first {
//                                if let image = media.image {
//                                    slide.imageView.image = image//survey!.images![index]?.keys.first
//                                    slide.imageView.progressIndicatorView.alpha = 0
//                                } else if let url = media.imageURL {
//                                    API.shared.downloadImage(url: url) { progress in
//                                        cell.slides[index].imageView.progressIndicatorView.progress = progress
//                                    } completion: { result in
//                                        switch result {
//                                        case .success(let image):
//                                            media.image = image
//                                            cell.slides[index].imageView.image = image
//                                            cell.slides[index].imageView.progressIndicatorView.reveal()
//                                            if index == 0 {
//                                                cell.showPageControl()
//                                            }
//                                        case .failure(let error):
//                                            Banner.shared.contentType = .Warning
//                                            if let content = Banner.shared.content as? Warning {
//                                                content.level = .Error
//                                                content.text = "Произошла ошибка, изображение не было загружено"
//                                            }
//                                            Banner.shared.present(shouldDismissAfter: 2, delegate: nil)
//                                            print(error.localizedDescription)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        cell.delegate = self
//                        cell.pageControl.alpha = cell.slides.count > 1 ? 1 : 0
//                        cell.showPageControl(animated: false)
//                        cell.isSetupCompleted = true
//                    }
                    return cell
                }
            } else if indexPath.row == 4 {
                if let link = survey!.url{
                    //1) YT link
                    if link.absoluteString.isYoutubeLink, let cell = tableView.dequeueReusableCell(withIdentifier: "youtube") as? YoutubeCell, let videoID = link.absoluteString.youtubeID {
//                        cell.delegate = self
//                        cell.videoID = videoID
//                        cell.loadVideo(url: link)
                        return cell
                    } else if link.absoluteString.isTikTokLink, let cell = tableView.dequeueReusableCell(withIdentifier: "embedded") as? EmbeddedURLCell {
                        cell.app = .TikTok
                        guard !cell.isContentLoading else {
                            return cell
                        }
                        cell.isContentLoading = true
                        if link.absoluteString.isTikTokEmbedLink {
                            var webContent = "<meta name='viewport' content='initial-scale=0.8, maximum-scale=0.8, user-scalable=no'/>"
                            webContent += link.absoluteString
                            cell.webView.loadHTMLString(webContent, baseURL: URL(string: "http://www.tiktok.com")!)
                        } else {
                            cell.url = link
                            guard let url = URL(string: "https://www.tiktok.com/oembed?url=\(link)") else {
                                delBanner.shared.contentType = .Warning
                                if let content = delBanner.shared.content as? Warning {
                                    content.level = .Error
                                    content.text = "Произошла ошибка, TikTok не загрузился"
                                }
                                delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
                                return cell
                            }
                            API.shared.getTikTokEmbedHTML(url: url) { result in
                                switch result {
                                case .success(let json):
                                    guard let html = json["html"].string else {
                                        delBanner.shared.contentType = .Warning
                                        if let content = delBanner.shared.content as? Warning {
                                            content.level = .Error
                                            content.text = "Произошла ошибка, TikTok не загрузился"
                                        }
                                        delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
                                        return
                                    }
                                    var webContent = "<meta name='viewport' content='initial-scale=0.8, maximum-scale=0.8, user-scalable=no'/>"
                                    webContent += html
                                    cell.webView.loadHTMLString(webContent, baseURL: URL(string: "http://www.tiktok.com")!)
                                case .failure(let error):
                                    delBanner.shared.contentType = .Warning
                                    if let content = delBanner.shared.content as? Warning {
                                        content.level = .Error
                                        content.text = "Произошла ошибка, TikTok не загрузился"
                                    }
                                    delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
                                    print(error.localizedDescription)
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
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 15), foregroundColor: .lightGray, backgroundColor: .clear), range: text.fullRange())
                cell.textView.attributedText = attributedString
                cell.textView.textContainerInset = UIEdgeInsets(top: 25, left: cell.textView.textContainerInset.left, bottom: 30, right: cell.textView.textContainerInset.right)
                return cell
            }
        } else if indexPath.section == 1 {
            switch mode {
            case .Write:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "choice", for: indexPath) as? ChoiceSelectionCell, let answer = survey?.answers[indexPath.row] {
                    cell.answer = answer
                    cell.delegate = self
                    if answersCells.filter({ $0 == cell }).isEmpty { answersCells.append(cell) }
                    return cell
                }
            case .ReadOnly:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as? ChoiceResultCell, let answer = survey?.answersSortedByVotes[indexPath.row], let resultIndicator = resultIndicators.filter({ $0.answer === answer }).first {
                    if !cell.isViewSetupComplete {
                        cell.layer.masksToBounds = false
                        cell.frame.size = CGSize(width: view.frame.width, height: cell.frame.height)
                        cell.setNeedsLayout()
                        cell.layoutIfNeeded()
                        cell.isViewSetupComplete = true
                        cell.container.backgroundColor = .clear
                    }
                    resultIndicator.indexPath = indexPath
                    cell.setResultIndicator(resultIndicator)
                    cell.answer = answer
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
                    cell.btn.backgroundColor = vote == nil  ? K_COLOR_GRAY : K_COLOR_RED
                    cell.btn.isUserInteractionEnabled = vote == nil ? false : true
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
                if survey!.imagesCount > 0 {
                    return UIScreen.main.bounds.width/(16/9)
                }
//                } else if survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty {
//                    return UIScreen.main.bounds.width/(16/9)
//                }
                return 0
            } else if indexPath.row == 4 {//Web resource
                if survey!.url == nil {
                    return 0
                } else if survey!.url!.absoluteString.isYoutubeLink {
                    return UIScreen.main.bounds.width/(16/9)
                } else if survey!.url!.absoluteString.isTikTokLink {
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
            vote = cell.answer
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

extension delPollController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.map{ $0() }
        }
    }
}

import SafariServices
extension delPollController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if sender is WebResourceCell, let url = survey!.url {
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
                                AlertController.shared.show(delegate: self, height: UIScreen.main.bounds.height * 0.76, contentType: .Claim, survey: survey)
//                Alert.shared.icon.category = .Caution
//                Alert.shared.present(delegate: self, height: UIScreen.main.bounds.height * 0.7, contentType: .Claim, survey: survey)
//                performSegue(withIdentifier: Segues.App.Claim, sender: nil)
            } else if string == "vote" {
                AlertController.shared.icon.category = .Info
                AlertController.shared.show(delegate: self, height: UIScreen.main.bounds.height * 0.5)
                API.shared.postVote(answer: vote) { result in
                    switch result {
                    case .success(let json):
                        for i in json {
                            if i.0 == "survey_result" {
                                for entity in i.1 {
                                    guard let answerId = entity.1["answer"].int,
                                          let timeString = entity.1["timestamp"].string,
                                          let timestamp = Date(dateTimeString: timeString) as? Date else { break }
                                    self.survey!.result = [answerId: timestamp]
                                    Surveys.shared.hot.remove(object: self.survey!)
                                    Userprofiles.shared.current!.balance += 1
                                }
                                self.surveyRef.isComplete = true
                                self.mode = .ReadOnly
                            } else if i.0 == "hot" && !i.1.isEmpty {
                                Surveys.shared.load(i.1)
                            } else if i.0 == "result_total" {
                                do {
                                    var totalVotes = 0
                                    for entity in i.1 {
                                        guard let dict = entity.1.dictionary,
                                              let data = try dict["userprofiles"]?.rawData(),
                                              let _answerID = dict["answer"]?.int,
                                              let answer = self.survey?.answers.filter({ $0.id == _answerID }).first,
                                              let _total = dict["total"]?.int else { break }
                                        answer.totalVotes = _total
                                        totalVotes += _total
                                        let instances = try JSONDecoder().decode([Userprofile].self, from: data)
                                        instances.forEach { instance in
                                            answer.addVoter(Userprofiles.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
                                        }
                                    }
                                    self.survey?.totalVotes = totalVotes
                                } catch let error {
                                    print(error)
                                }
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        delBanner.shared.contentType = .Warning
                        if let content = delBanner.shared.content as? Warning {
                            content.level = .Error
                            content.text = "Произошла ошибка по техническим причинам, повторите позже"
                        }
                        delBanner.shared.present(isModal: true, shouldDismissAfter: 3, delegate: self)
                    }
                }
                AlertController.shared.show(delegate: self, survey: nil)
//            } else if string == "post_claim" {
//                navigationController?.popViewController(animated: true)
            } else if string == AlertController.popController {
                navigationController?.popViewController(animated: true)
            }
        } else if let image = sender as? UIImage {
            performSegue(withIdentifier: Segues.App.Image, sender: image)
        } else if let array = sender as? [AnyObject], let _ = array.filter({ $0 is Answer}).first as? Answer,
//            let _ = array.filter({ $0 is [UIImageView]}).first as? [UIImageView],
            let _ = array.filter({ $0 is IndexPath}).first as? IndexPath {
            performSegue(withIdentifier: Segues.App.UsersList, sender: array)
        }
//        } else if let dict = sender as? [String: AnyObject], let _ = dict["users"] as? [UserProfile], let _ = dict["total"] as? Int, let _ = dict["answerID"] as? Int {
//            performSegue(withIdentifier: Segues.App.UsersList, sender: dict)
//        }
    }
}

















//class AuthorCell: UITableViewCell {
//    weak var delegate: CallbackDelegate?
//    @IBOutlet weak var avatar: UIImageView! {
//        didSet {
//            let touch = UITapGestureRecognizer(target:self, action:#selector(self.handleTap(recognizer:)))
//            touch.cancelsTouchesInView = false
//            avatar.addGestureRecognizer(touch)
//        }
//    }
//    @IBOutlet weak var userCredentials: UILabel! {
//        didSet {
//            userCredentials.backgroundColor = .clear
//            userCredentials.textColor = .black
//        }
//    }
//    @IBOutlet weak var categoryLabel: UILabel!
//    @IBOutlet weak var viewsIcon: Icon! {
//        didSet {
//            viewsIcon.scaleMultiplicator = 1.3
//            viewsIcon.backgroundColor = .clear
//            viewsIcon.iconColor = .darkGray
//            viewsIcon.category = .Eye
//        }
//    }
//    @IBOutlet weak var viewsLabel: UILabel! {
//        didSet {
//            viewsLabel.textColor = .darkGray
//        }
//    }
////    @IBOutlet weak var commentsIcon: SurveyCategoryIcon! {
////        didSet {
////            commentsIcon.scaleMultiplicator = 1
////            commentsIcon.backgroundColor = .clear
////            commentsIcon.iconColor = .lightGray
////            commentsIcon.category = .Opinion
////        }
////    }
////    @IBOutlet weak var commentsLabel: UILabel! {
////        didSet {
////            commentsLabel.textColor = .lightGray
////        }
////    }
//
//
//    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
//        delegate?.callbackReceived("user" as AnyObject)
//    }
//}

class LabelCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

class TextViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
}

class WebResourceCell: UITableViewCell {
    weak var delegate: CallbackObservable?
    @IBOutlet weak var button: ButtonWithImage!
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.callbackReceived(self)
    }
}

//class ImagesCell: UITableViewCell, UIScrollViewDelegate {
//    deinit {
//        print("***ImagesCell deinit()***")
//    }
//    var slides: [Slide] = []
//    var isSetupCompleted = false {
//        didSet {
//            if isSetupCompleted {
//                scrollView.isUserInteractionEnabled = true
//            }
//        }
//    }
//    @IBOutlet weak var scrollView: UIScrollView! {
//        didSet {
//            scrollView.isUserInteractionEnabled = isSetupCompleted ? true : false
//            scrollView.delegate = self
//        }
//    }
//    @IBOutlet weak var pageControl: UIView! {
//        didSet {
//            pageControl.alpha = 0
//            pageControl.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        }
//    }
//    @IBOutlet weak var page: UILabel! {
//        didSet {
//            if page != nil, !slides.isEmpty {
//                page.text = "\(pageIndex+1)/\(slides.count)"
//            }
//        }
//    }
//    //    @IBOutlet weak var pageControl: UIPageControl! {
////        didSet {
////            pageControl.alpha = 0
////        }
////    }
//
//    @objc fileprivate func callback() {
//        delegate?.callbackReceived(self)
//    }
//    private var pageIndex: Int = 0
//    weak var delegate: CallbackDelegate?
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//    func createSlides(count: Int) {
////        if !isSetupCompleted {
//            scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(count), height: scrollView.frame.height)
//            scrollView.isScrollEnabled = true
//            scrollView.isPagingEnabled = true
//
//            for i in 0..<count {
//                let slide  = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
//                slide.frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
//                slide.imageView.backgroundColor = .lightGray
//                let recognizer = UITapGestureRecognizer(target: self, action: #selector(ImagesCell.imageTapped(recognizer:)))
//                slide.imageView.addGestureRecognizer(recognizer)
////                scrollView.addSubview(slide)
//                scrollView.insertSubview(slide, at: 0)
//                slides.append(slide)
//            }
////            isSetupCompleted = true
////        }
//    }
//
//    func showPageControl(animated: Bool = true) {
//        if slides.count > 1, pageControl != nil, page != nil {
//            page.text = "\(pageIndex+1)/\(slides.count)"
//            if animated {
//                pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut, animations: {
//                    self.pageControl.alpha = 1
//                    self.pageControl.transform = .identity
//                })
//            } else {
//                pageControl.alpha = 1
//            }
//        }
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        pageIndex = Int(round(scrollView.contentOffset.x/contentView.frame.width))
//        page.text = "\(pageIndex+1)/\(slides.count)"
//    }
//
//    @objc private func imageTapped(recognizer: UITapGestureRecognizer) {
//        if let imageView = recognizer.view as? UIImageView, let image = imageView.image {
//            delegate?.callbackReceived(image as AnyObject)
//        }
//    }
//}

import YoutubePlayer_in_WKWebView
//class YoutubeCell: UITableViewCell, WKYTPlayerViewDelegate, CallbackDelegate {
////    private var bannerHasBeenShown = false
//    private var tempAppPreference: SideAppPreference?
//    private var sideAppPreference: SideAppPreference? {
//        if UserDefaults.App.youtubePlay == nil {
//            return nil
//        } else {
//            return UserDefaults.App.youtubePlay
//        }
//    }
//    private var isYoutubeInstalled: Bool {
//        let appName = "youtube"
//        let appScheme = "\(appName)://app"
//        let appUrl = URL(string: appScheme)
//        return UIApplication.shared.canOpenURL(appUrl! as URL)
//    }
//    var videoID = ""
//    private var loadingIndicator: ClockIndicator!
//    private var isVideoLoaded = false
////    @IBOutlet weak var subv: UIView! {
////        didSet {
////            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: subv.frame.height, height: subv.frame.height)))
////            loadingIndicator.layoutCentered(in: subv, multiplier: 0.6)//addEquallyTo(to: tableView)
////            loadingIndicator.addEnableAnimation()
////        }
////    }
//    @IBOutlet weak var playerView: WKYTPlayerView! {
//        didSet {
//            playerView.alpha = 0
//            playerView.delegate = self
//            loadingIndicator = ClockIndicator(frame: CGRect(origin: .zero, size: CGSize(width: contentView.frame.height, height: contentView.frame.height)))
//            loadingIndicator.layer.masksToBounds = false
//            loadingIndicator.layoutCentered(in: contentView, multiplier: 0.2)//addEquallyTo(to: tableView)
//            loadingIndicator.addEnableAnimation()
////            let recognizer = UITapGestureRecognizer(target: self, action: #selector(YoutubeCell.viewTapped(recognizer:)))
////            playerView.addGestureRecognizer(recognizer)
//        }
//    }
//    
//    @objc fileprivate func callback() {
//        delegate?.callbackReceived(self)
//    }
//    weak var delegate: CallbackDelegate?
//    
//    func loadVideo(url: URL) {
//        if !isVideoLoaded {
//            isVideoLoaded = true
//            if let id = url.absoluteString.youtubeID {
//                playerView.load(withVideoId: id)
//            }
//        }
//    }
//    
//    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
//        print("ready")
//        UIView.animate(withDuration: 0.3, animations: {
//            self.loadingIndicator.alpha = 0
//        }) {
//            _ in
//            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
//                self.playerView.alpha = 1
//            })
//        }
//    }
//    
//    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
//        if state == .buffering {
//            if sideAppPreference != nil {
//                if sideAppPreference! == .Embedded {
//                    playerView.playVideo()
//                } else {
//                    if isYoutubeInstalled {
//                        playInYotubeApp()
//                        playerView.stopVideo()
//                    }
//                }
//            } else if isYoutubeInstalled, tempAppPreference == nil {
//                    playerView.pauseVideo()
//                    Banner.shared.contentType = .SideApp
//                    if let content = Banner.shared.content as? SideApp {
//                        content.app = .Youtube
//                        content.delegate = self
//                    }
//                    Banner.shared.present(isModal: true, delegate: nil)
//            } else {
//                if tempAppPreference == .Embedded {
//                    playerView.playVideo()
//                } else {
//                    if isYoutubeInstalled {
//                        playInYotubeApp()
//                        playerView.stopVideo()
//                    }
//                }
//            }
//        }
//    }
//    
//    private func playInYotubeApp() {
//        let appScheme = "youtube://watch?v=\(videoID)"
//        if let appUrl = URL(string: appScheme) {
//            UIApplication.shared.open(appUrl)
//        }
//    }
//
//    func callbackReceived(_ sender: Any) {
//        if let option = sender as? SideAppPreference {
//            switch option {
//            case .App:
//                tempAppPreference = .App
//                playInYotubeApp()
//                playerView.stopVideo()
//            case .Embedded:
//                playerView.playVideo()
//                tempAppPreference = .Embedded
//            }
//        }
//    }
//}

class EmbeddedURLCell: UITableViewCell, WKNavigationDelegate, WKUIDelegate, CallbackObservable {
    private var tempAppPreference: SideAppPreference?
    private var sideAppPreference: SideAppPreference? {
        if app == .TikTok {
            if UserDefaults.App.tiktokPlay == nil {
                return nil
            } else {
                return UserDefaults.App.tiktokPlay
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
    weak var delegate: CallbackObservable?
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
                    delBanner.shared.contentType = .SideApp
                    if let content = delBanner.shared.content as? SideApp {
                        content.app = .TikTok
                        content.delegate = self
                    }
                    delBanner.shared.present(isModal: true, delegate: nil)
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
    
    func callbackReceived(_ sender: Any) {
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
    weak var delegate: CallbackObservable?
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
    @IBOutlet weak var container: UIView! {
        didSet {
            container.layer.masksToBounds = false
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
        }
    }
    private var resultIndicator: ResultIndicator? {
        didSet {
            if resultIndicator != nil {
                resultIndicator!.addEquallyTo(to: container)
//                resultIndicator!.updateUI()
            } else if oldValue != nil {
                oldValue?.removeFromSuperview()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        container.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func setResultIndicator(_ _resultIndicator: ResultIndicator) {
        resultIndicator = _resultIndicator
    }
    
    func getResultIndicator() -> ResultIndicator? {
        return resultIndicator
    }
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
    weak var delegate: CallbackObservable?
}
