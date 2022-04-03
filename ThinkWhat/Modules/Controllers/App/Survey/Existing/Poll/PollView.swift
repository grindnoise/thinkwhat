//
//  PollView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollView: UIView {
    
    deinit {
        print("PollView deinit")
    }
    
    enum Mode {
        case ReadOnly, Write
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupTableView()
        setupUI()
    }
    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: PollViewInput?
    var mode: Mode = .Write {
        didSet {
            if tableView != nil {
                tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
                tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .fade)
            }
        }
    }
    private var loadingIndicator: LoadingIndicator?
    private var answersCells: [ChoiceCell] = []
    private var resultIndicators: [ResultIndicator] = []
    private var choice: Answer! {
        didSet {
            if oldValue != choice {
                //UI update
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? VoteCell {
                    cell.enable()
                }
                if oldValue == nil {
                    delay(seconds: 0.5) {
                        self.isAutoScrolling = false
                    }
                    isAutoScrolling = true
                    tableView.scrollToBottom()
                }
                answersCells.filter { $0.answer != choice }.forEach { $0.isChecked = false }
            }
        }
    }
    private var isAutoScrolling = false   //is on when scrollArrow is tapped
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            ///Set bottom inset for safe area
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIApplication.shared.windows[0].safeAreaInsets.bottom, right: 0.0)
        }
    }
}

// MARK: - Controller Output
extension PollView: PollControllerOutput {
    func onLoad(_: Result<Bool, Error>) {
        tableView.reloadData()
        
//        let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        effectViewOutgoing.frame = view.frame
//        effectViewOutgoing.addEquallyTo(to: view)
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
//            effectViewOutgoing.effect = nil
//        })
//
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
//            self.loadingIndicator?.alpha = 0
//            self.loadingIndicator?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            effectViewOutgoing.effect = UIBlurEffect(style: .light)
//        }) {
//            _ in
//            self.loadingIndicator?.transform = .identity
//            self.loadingIndicator?.removeAllAnimations()
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0/*delay*/, options: [.curveEaseIn], animations: {
//                effectViewOutgoing.effect = nil
//            })
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0/*delay*/, options: [.curveEaseOut], animations: {
//                self.tableView.transform = .identity
//                self.tableView.alpha = 1
//            }) {
//                _ in
//                effectViewOutgoing.removeFromSuperview()
//                self.isInitialLoading = false
//            }
//        }
    }
    
    func onCountUpdated() {
        guard !survey.isNil,
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AuthorCell,
              let label = cell.viewsLabel else {
            return
        }
        UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve) {
            label.text = "\(self.survey!.views)"
        } completion: { _ in}
    }
    
    var survey: Survey? {
        return viewInput?.survey
    }
    
}

// MARK: - UI Setup
extension PollView {
    private func setupUI() {
        
    }
}

// MARK: - TableView delegate
extension PollView: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AuthorCell", bundle: nil), forCellReuseIdentifier: "author")
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "title")
        tableView.register(UINib(nibName: "TextCell", bundle: nil), forCellReuseIdentifier: "text")
        tableView.register(UINib(nibName: "ImagesCell", bundle: nil), forCellReuseIdentifier: "images")
        tableView.register(UINib(nibName: "HyperlinkCell", bundle: nil), forCellReuseIdentifier: "hyperlink")
        tableView.register(UINib(nibName: "YoutubeCell", bundle: nil), forCellReuseIdentifier: "youtube")
        tableView.register(UINib(nibName: "WebCell", bundle: nil), forCellReuseIdentifier: "web")
        tableView.register(UINib(nibName: "ChoiceCell", bundle: nil), forCellReuseIdentifier: "choice")
        tableView.register(UINib(nibName: "VoteCell", bundle: nil), forCellReuseIdentifier: "vote")
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let cell = tableView.cellForRow(at: indexPath) as? ChoiceResultCell, let resultIndicator = cell.getResultIndicator() {
                resultIndicator.needsUIUpdate = false
                resultIndicator.setPercentage(value: nil)
            }
        }
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard survey != nil else {
            fatalError()
            return UITableViewCell()
        }
        if indexPath.section == 0 {
            if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "author", for: indexPath) as? AuthorCell {
                cell.setupUI(delegate: self, survey: survey!)
                return cell
            } else if indexPath.row == 1, let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? TitleCell {
                cell.setupUI(delegate: self, survey: survey!)
                return cell
            } else if indexPath.row == 2, let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as? TextCell {
                cell.setupUI(delegate: self, survey: survey!)
                return cell
            } else if indexPath.row == 3, let cell = tableView.dequeueReusableCell(withIdentifier: "images", for: indexPath) as? ImagesCell {
                cell.setupUI(delegate: self, survey: survey!)
                return cell
            } else if indexPath.row == 4, let url = survey!.url {
                if url.absoluteString.isYoutubeLink, let videoID = url.absoluteString.youtubeID, let cell = tableView.dequeueReusableCell(withIdentifier: "youtube") as? YoutubeCell {
                    cell.setupUI(delegate: self, videoID: videoID)
                    return cell
                } else if url.absoluteString.isTikTokLink, let cell = tableView.dequeueReusableCell(withIdentifier: "web") as? WebCell {
                    cell.setupUI(delegate: self, url: url)
                    return cell
                } else if let cell = tableView.dequeueReusableCell(withIdentifier: "hyperlink", for: indexPath) as? HyperlinkCell {
                    cell.setupUI(delegate: self)
                    return cell
                }
            } else if indexPath.row == 5, let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as? TextCell {
                cell.setupUI(delegate: self, survey: survey!, isQuestion: true)
                return cell
            }
        } else if indexPath.section == 1 {
            switch mode {
            case .Write:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "choice", for: indexPath) as? ChoiceCell, let answer = survey?.answers[indexPath.row] {
                    cell.setupUI(delegate: self, answer: answer)
                    if answersCells.filter({ $0 == cell }).isEmpty { answersCells.append(cell) }
                    return cell
                }
            case .ReadOnly:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as? ChoiceResultCell, let answer = survey?.answersSortedByVotes[indexPath.row], let resultIndicator = resultIndicators.filter({ $0.answer === answer }).first {
                    if !cell.isViewSetupComplete {
                        cell.layer.masksToBounds = false
                        cell.frame.size = CGSize(width: frame.width, height: cell.frame.height)
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
                return UITableViewCell()
            }
        } else if indexPath.section == 2 {
            switch mode {
            case .Write:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "vote", for: indexPath) as? VoteCell {
                    cell.setupUI(delegate: self)
                    return cell
                }
            case .ReadOnly:
                print("ReadOnly")
                return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard survey != nil else {
            return 0
        }
        if indexPath.section == 0 {
            if indexPath.row == 0 {//Author & category
                return 80
            } else if indexPath.row == 1 {
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
//                    if indexPath.row == 0 {
                        return 140
//                    } else {
//                        return 0
//                    }
                case .ReadOnly:
                    //TODO: - Set row height
                    return 140
                }
            
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChoiceCell {
            cell.isChecked = true
            choice = cell.answer
        }
    }
}

extension PollView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if sender is Avatar {
            fatalError()
        } else if let string = sender as? String {
            if string == "claim" {
                fatalError()
            } else if string == "vote" {
                let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self)
                banner.present(subview: PlainBannerContent(text: "check_fields".localized, imageContent: UIImageView(image: UIImage(systemName: "exclamationmark.circle.fill"))))
//                delBanner.shared.contentType = .Warning
//                if let content = delBanner.shared.content as? Warning {
//                    content.level = .Error
//                    content.text = "Произошла ошибка по техническим причинам, повторите позже"
//                }
//                delBanner.shared.present(isModal: true, shouldDismissAfter: 3, delegate: self)
                
//                API.shared.postVote(answer: vote) { result in
//                    switch result {
//                    case .success(let json):
//                        for i in json {
//                            if i.0 == "survey_result" {
//                                for entity in i.1 {
//                                    guard let answerId = entity.1["answer"].int,
//                                          let timeString = entity.1["timestamp"].string,
//                                          let timestamp = Date(dateTimeString: timeString) as? Date else { break }
//                                    self.survey!.result = [answerId: timestamp]
//                                    Surveys.shared.hot.remove(object: self.survey!)
//                                    Userprofiles.shared.current!.balance += 1
//                                }
//                                self.surveyReference.isComplete = true
//                                self.mode = .ReadOnly
//                            } else if i.0 == "hot" && !i.1.isEmpty {
//                                Surveys.shared.load(i.1)
//                            } else if i.0 == "result_total" {
//                                do {
//                                    var totalVotes = 0
//                                    for entity in i.1 {
//                                        guard let dict = entity.1.dictionary,
//                                              let data = try dict["userprofiles"]?.rawData(),
//                                              let _answerID = dict["answer"]?.int,
//                                              let answer = self.survey?.answers.filter({ $0.id == _answerID }).first,
//                                              let _total = dict["total"]?.int else { break }
//                                        answer.totalVotes = _total
//                                        totalVotes += _total
//                                        let instances = try JSONDecoder().decode([Userprofile].self, from: data)
//                                        instances.forEach { instance in
//                                            answer.addVoter(Userprofiles.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
//                                        }
//                                    }
//                                    self.survey?.totalVotes = totalVotes
//                                } catch let error {
//                                    print(error)
//                                }
//                            }
//                        }
//                    case .failure(let error):
//                        print(error.localizedDescription)
//                        Banner.shared.contentType = .Warning
//                        if let content = Banner.shared.content as? Warning {
//                            content.level = .Error
//                            content.text = "Произошла ошибка по техническим причинам, повторите позже"
//                        }
//                        Banner.shared.present(isModal: true, shouldDismissAfter: 3, delegate: self)
//                    }
//                }
            } else if string == AlertController.popController {
//                navigationController?.popViewController(animated: true)
            }
        } else if let image = sender as? UIImage {
//            performSegue(withIdentifier: Segues.App.Image, sender: image)
        } else if let array = sender as? [AnyObject], let _ = array.filter({ $0 is Answer}).first as? Answer,
//            let _ = array.filter({ $0 is [UIImageView]}).first as? [UIImageView],
            let _ = array.filter({ $0 is IndexPath}).first as? IndexPath {
//            performSegue(withIdentifier: Segues.App.UsersList, sender: array)
        }
    }
}

extension PollView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {
            
    }
    
    func onBannerWillDisappear(_ sender: Any) {
            
    }
    
    func onBannerDidAppear(_ sender: Any) {
            
    }
    
    func onBannerDidDisappear(_ sender: Any) {
        guard let banner = sender as? Banner else { return }
        banner.removeFromSuperview()
    }
    
    
}
