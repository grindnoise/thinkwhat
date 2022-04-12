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
    private var loadingIndicator: LoadingIndicator? {
        didSet {
            loadingIndicator?.color = surveyReference.topic.tagColor
        }
    }
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
    private var isAwaitingVoteResponse = false
    ///Enable/disable checkboxes
    private var isChoiceEnabled = true {
        didSet {
            guard !tableView.isNil else { return }
            tableView.visibleCells.forEach { cell in
                guard cell.isKind(of: ChoiceCell.self)
                        || cell.isKind(of: AuthorCell.self)
                        || cell.isKind(of: HyperlinkCell.self)
                        || cell.isKind(of: VoteCell.self)
                        || cell.isKind(of: ImagesCell.self) else { return }
                cell.isUserInteractionEnabled = self.isChoiceEnabled
            }
        }
    }
    
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
    func onClaim(_: Result<Bool, Error>) {
//        fatalError()
    }
    
    func onVote(_ result: Result<Bool, Error>) {
        isAwaitingVoteResponse = false
        tableView.visibleCells.forEach {
            guard let cell = $0 as? VoteCell else { return }
            cell.isLoading = false
        }
        switch result {
        case .success:
            let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self, heightMultiplictator: 1.25)
            banner.present(subview: VoteMessage(imageContent: UIView(), color: survey?.topic.tagColor ?? K_COLOR_RED, callbackDelegate: banner))
//            mode = .ReadOnly
        case .failure:
            self.isChoiceEnabled = true
            let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
            banner.present(subview: PlainBannerContent(text: "backend_error".localized, imageContent: ImageSigns.exclamationMark, color: .systemRed), isModal: false, shouldDismissAfter: 3)
        }
    }
    
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
        tableView.visibleCells.forEach {
            guard let cell = $0 as? AuthorCell else { return }
            UIView.transition(with: cell.viewsLabel, duration: 0.2, options: .transitionCrossDissolve) {
                cell.viewsLabel.text = "\(self.survey!.views)"
            } completion: { _ in}
        }
    }
    
    var survey: Survey? {
        return viewInput?.survey
    }
    
    var surveyReference: SurveyReference {
        return viewInput!.surveyReference
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
//        if indexPath.section == 1 {
//            if let cell = tableView.cellForRow(at: indexPath) as? ChoiceResultCell, let resultIndicator = cell.getResultIndicator() {
//                resultIndicator.needsUIUpdate = false
//                resultIndicator.setPercentage(value: nil)
//            }
//        }
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
            return UITableViewCell()
        }
        if indexPath.section == 0 {
            if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "author", for: indexPath) as? AuthorCell {
                cell.setupUI(delegate: self, survey: survey!)
                cell.viewsLabel.text = "\(self.survey!.views)"
                cell.isUserInteractionEnabled = isChoiceEnabled
                return cell
            } else if indexPath.row == 1, let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? TitleCell {
                cell.setupUI(delegate: self, survey: survey!)
                return cell
            } else if indexPath.row == 2, let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as? TextCell {
                cell.setupUI(delegate: self, survey: survey!)
                return cell
            } else if indexPath.row == 3, let cell = tableView.dequeueReusableCell(withIdentifier: "images", for: indexPath) as? ImagesCell {
                cell.setupUI(delegate: self, survey: survey!)
                cell.isUserInteractionEnabled = isChoiceEnabled
                return cell
            } else if indexPath.row == 4, let url = survey!.url {
                if url.absoluteString.isYoutubeLink, let videoID = url.absoluteString.youtubeID, let cell = tableView.dequeueReusableCell(withIdentifier: "youtube") as? YoutubeCell {
                    cell.setupUI(delegate: self, videoID: videoID, color: surveyReference.topic.tagColor)
                    return cell
                } else if url.absoluteString.isTikTokLink, let cell = tableView.dequeueReusableCell(withIdentifier: "web") as? WebCell {
                    cell.setupUI(delegate: self, url: url)
                    return cell
                } else if let cell = tableView.dequeueReusableCell(withIdentifier: "hyperlink", for: indexPath) as? HyperlinkCell {
                    cell.setupUI(delegate: self)
                    cell.isUserInteractionEnabled = isChoiceEnabled
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
                    cell.isChecked = answer == choice
                    cell.isUserInteractionEnabled = isChoiceEnabled
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
                    cell.setupUI(delegate: self, color: survey!.topic.tagColor)
                    cell.isLoading = isAwaitingVoteResponse
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
        } else if let claim = sender as? Claim {
            viewInput?.onClaim(claim)
        } else if let button = sender as? UIButton {
            if button.accessibilityIdentifier == "vote" {
                guard !choice.isNil else {
                    let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
                    banner.present(subview: PlainBannerContent(text: "make_choice".localized, imageContent: ImageSigns.exclamationMark, color: .systemRed), isModal: false, shouldDismissAfter: 1)
                    return
                }
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? VoteCell {
                    cell.isLoading = true
                }
                isChoiceEnabled = false
                isAwaitingVoteResponse = true
                viewInput?.onVote(choice)
                return
            } else if button.accessibilityIdentifier == "claim" {
                let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, heightMultiplictator: 1.5)
                banner.accessibilityIdentifier = "claim"
                banner.present(subview: ClaimSelection(callbackDelegate: banner))
            }
        } else if let image = sender as? UIImage {
            viewInput?.onImageTapped(image: image, title: "")
        } else if let array = sender as? [AnyObject], let _ = array.filter({ $0 is Answer}).first as? Answer,
//            let _ = array.filter({ $0 is [UIImageView]}).first as? [UIImageView],
            let _ = array.filter({ $0 is IndexPath}).first as? IndexPath {
//            performSegue(withIdentifier: Segues.App.UsersList, sender: array)
        } else if sender is HyperlinkCell {
            guard let url = survey?.url else {
                let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
                banner.present(subview: PlainBannerContent(text: "bad_url".localized, imageContent: ImageSigns.exclamationMark, color: .systemRed), isModal: false, shouldDismissAfter: 1)
                return
            }
            viewInput?.onURLTapped(url)
        }
    }
}

extension PollView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
            if popup.accessibilityIdentifier == "claim" {
                viewInput?.onExitWithClaim()
            }
        }
    }
}
