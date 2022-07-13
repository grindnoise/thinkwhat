//
//  PollView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Agrume

class PollView: UIView {
    
    deinit {
        print("PollView deinit")
        NotificationCenter.default.removeObserver(self)
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
        guard !survey.isNil else { return }
        setupUI()
    }
    
    // MARK: - Properties
    weak var viewInput: (PollViewInput & UIViewController)?
    
    private lazy var collectionView: PollCollectionView = {
        let instance = PollCollectionView(host: self, poll: survey!, callbackDelegate: self)
        instance.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: deviceType == .iPhoneSE ? 0 : 60, right: 0.0)
        //////            UIApplication.shared.windows[0].safeAreaInsets.bottom, right: 0.0)
        instance.layer.masksToBounds = false
        return instance
    }()
    private var isLoadingData = false
    private var loadingIndicator: LoadingIndicator? {
        didSet {
            loadingIndicator?.color = surveyReference.topic.tagColor
        }
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet var container: UIView!
}

// MARK: - Controller Output
extension PollView: PollControllerOutput {
    
    func onAddFavoriteCallback() {
        
    }
    
    var mode: PollController.Mode {
        return viewInput!.mode
    }
    
    func startLoading() {
        container.alpha = 0
        loadingIndicator = LoadingIndicator()
        loadingIndicator!.alpha = 1
        loadingIndicator!.layoutCentered(in: self, multiplier: 0.6)
        loadingIndicator!.addEnableAnimation()
    }
    
    var showNext: Bool {
        return viewInput?.showNext ?? false
    }
    
    func onClaimCallback(_: Result<Bool, Error>) {
 
    }
    
    func onVoteCallback(_ result: Result<Bool, Error>) {
        isUserInteractionEnabled = true
        //Hide vote button & show comments section
        collectionView.onVoteCallback(result)
    }
    
    func onLoadCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            collectionView.addEquallyTo(to: container)
            guard !loadingIndicator.isNil else { return }
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                        self.loadingIndicator?.alpha = 0
                        self.loadingIndicator?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    }) {
                        _ in
                        self.loadingIndicator?.removeFromSuperview()
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                            self.container.alpha = 1
                        }) {_ in }
                    }
        case .failure:
            showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: ImageSigns.exclamationMark)
        }
    }
    
    func onCountUpdatedCallback() {
//        collectionView.updateViewsCount()
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
    
    private func updateResults() {
        
    }
    
//    private func showBanner(callbackDelegate: CallbackObservable? = nil, bannerDelegate: BannerObservable, text: String, imageContent: UIView, color: UIColor = .systemRed, isModal: Bool = false, shouldDismissAfter: TimeInterval = 1, accessibilityIdentifier: String = "") {
//        let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: callbackDelegate, bannerDelegate: bannerDelegate)
//        banner.accessibilityIdentifier = accessibilityIdentifier
//        banner.present(subview: PlainBannerContent(text: text, imageContent: imageContent, color: color), isModal: isModal, shouldDismissAfter: shouldDismissAfter)
    //    }
}

extension PollView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let mediafile = sender as? Mediafile {
            let images = survey!.media.sorted { $0.order < $1.order }.compactMap {$0.image}
            let agrume = Agrume(images: images, startIndex: mediafile.order, background: .colored(.black))
            let helper = makeHelper()
            agrume.onLongPress = helper.makeSaveToLibraryLongPressGesture
            agrume.show(from: viewInput!)
            guard images.count > 1 else { return }
            agrume.didScroll = { [weak self] index in
                guard let self = self else { return }
                self.collectionView.onImageScroll(index)
            }
        } else if let url = sender as? URL {
            viewInput?.onURLTapped(url)
        } else if let answer = sender as? Answer {
            viewInput?.onVote(answer)
            isUserInteractionEnabled = true
//            delayAsync(delay: 3) {
//                self.collectionView.onVoteCallback()
//                self.isUserInteractionEnabled = true
//            }
        } else if let string = sender as? String {
//            if string == "vote_to_view_comments" {
//                showBanner(callbackDelegate: self, bannerDelegate: self, text: string.localized, content: ImageSigns.exclamationMark, dismissAfter: 1)
//            }
        } else if let instance = sender as? ChoiceCell {
            viewInput?.onVotersTapped(answer: instance.item, color: instance.color)
        }
    }
    
    private func makeHelper() -> AgrumePhotoLibraryHelper {
        let saveButtonTitle = "save_image".localized
        let cancelButtonTitle = "cancel".localized
       let helper = AgrumePhotoLibraryHelper(saveButtonTitle: saveButtonTitle, cancelButtonTitle: cancelButtonTitle) { error in
         guard error == nil else {
           print("Could not save your photo")
           return
         }
         print("Photo has been saved to your library")
       }
       return helper
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
            if popup.accessibilityIdentifier == "exit" {
                viewInput?.onExitWithSkip()
            }
        }
    }
}






// MARK: - Backup
//
//////
//////  PollView.swift
//////  ThinkWhat
//////
//////  Created by Pavel Bukharov on 25.03.2022.
//////  Copyright © 2022 Pavel Bukharov. All rights reserved.
//////
////
////import UIKit
////
////class PollView: UIView {
////
////    deinit {
////        print("PollView deinit")
////        NotificationCenter.default.removeObserver(self)
////    }
////
////    // MARK: - Initialization
////    override init(frame: CGRect) {
////        super.init(frame: frame)
////        commonInit()
////    }
////
////    required init?(coder: NSCoder) {
////        super.init(coder: coder)
////        commonInit()
////    }
////
////    private func commonInit() {
////        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
////        addSubview(contentView)
////        contentView.frame = self.bounds
////        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
////        self.addSubview(contentView)
////        setupTableView()
////        setupUI()
//////        mode = surveyReference.isComplete ? .ReadOnly : .Write
////    }
////
////    override func layoutSubviews() {
////
////    }
////
////    // MARK: - Properties
////    weak var viewInput: PollViewInput?
//////    var mode: PollController.Mode = .Write
//////    var mode: PollController.Mode = .Write {
//////        didSet {
//////            guard !isLoadingData else { return }
//////            if tableView != nil {
//////                updateResults()
////////                tableView.insertSections(IndexSet(, with: <#T##UITableView.RowAnimation#>)
//////                tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
//////                tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .automatic)
//////                tableView.reloadSections(IndexSet(arrayLiteral: 3), with: .automatic)
//////            }
//////            guard oldValue == .Write, mode == .ReadOnly else { return }
//////            _hasVoted = true
//////        }
//////    }
////    private var isLoadingData = false
////    private var loadingIndicator: LoadingIndicator? {
////        didSet {
////            loadingIndicator?.color = surveyReference.topic.tagColor
////        }
////    }
////    private var answersCells: [ChoiceCell] = []
////    private var resultIndicators: [ResultIndicator] = []
////    private var choice: Answer! {
////        didSet {
////            if oldValue != choice {
////                //UI update
////                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? VoteCell {
////                    cell.enable()
////                }
////                if oldValue == nil {
////                    delay(seconds: 0.5) {
////                        self.isAutoScrolling = false
////                    }
////                    isAutoScrolling = true
////                    tableView.scrollToBottom()
////                }
////                answersCells.filter { $0.answer != choice }.forEach { $0.isChecked = false }
////            }
////        }
////    }
////    private var isAutoScrolling = false   //is on when scrollArrow is tapped
////    private var isAwaitingVoteResponse = false
////    ///Enable/disable checkboxes
////    private var isChoiceEnabled = true {
////        didSet {
////            guard !tableView.isNil else { return }
////            tableView.visibleCells.forEach { cell in
////                guard cell.isKind(of: ChoiceCell.self)
////                        || cell.isKind(of: AuthorCell.self)
////                        || cell.isKind(of: HyperlinkCell.self)
////                        || cell.isKind(of: VoteCell.self)
////                        || cell.isKind(of: ImagesCell.self) else { return }
////                cell.isUserInteractionEnabled = self.isChoiceEnabled
////            }
////        }
////    }
////    private var _hasVoted = false
////    private var foldWebCell = false {
////        didSet {
////            tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
////        }
////    }
////
////    // MARK: - IB outlets
////    @IBOutlet var contentView: UIView!
////    @IBOutlet weak var tableView: UITableView! {
////        didSet {
////            ///Set bottom inset for safe area
////            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: deviceType == .iPhoneSE ? 0 : 60, right: 0.0)
//////            UIApplication.shared.windows[0].safeAreaInsets.bottom, right: 0.0)
////        }
////    }
////}
////
////// MARK: - Controller Output
////extension PollView: PollControllerOutput {
////    func onAddFavorite() {
////        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
////        imageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
////        imageView.alpha = 0
////        imageView.contentMode = .scaleAspectFill
////        imageView.image = ImageSigns.binocularsFilled.image
////        imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : survey!.topic.tagColor
////        insertSubview(imageView, at: 10)
////        imageView.translatesAutoresizingMaskIntoConstraints = false
////        NSLayoutConstraint.activate([
////            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
////            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
////            imageView.widthAnchor.constraint(equalToConstant: frame.width/2.5),
////            imageView.heightAnchor.constraint(equalToConstant: frame.width/2.5)
////        ])
////        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear) {
////            imageView.transform = .identity
////        } completion: { _ in
////            imageView.removeFromSuperview()
////
////        }
////
////        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveLinear) {
////            imageView.alpha = 0.7
////        } completion: { _ in
////            UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveLinear) {
////                imageView.alpha = 0
////            } completion: { _ in }
////        }
////    }
////
////    var mode: PollController.Mode {
////        return viewInput!.mode
////    }
////
////    func startLoading() {
////        tableView.alpha = 0
////        loadingIndicator = LoadingIndicator()//CGSize(width: view.frame.width, height: container.frame.height)))
////        loadingIndicator!.alpha = 1
////        loadingIndicator!.layoutCentered(in: self, multiplier: 0.6)
////        loadingIndicator!.addEnableAnimation()
////    }
////
////    var showNext: Bool {
////        return viewInput?.showNext ?? false
////    }
////
////    var hasVoted: Bool {
////        return _hasVoted
////    }
////
////    func onClaim(_: Result<Bool, Error>) {
//////        fatalError()
////    }
////
////    func onVote(_ result: Result<Bool, Error>) {
////        func animate() {
////            let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
////            label.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
////            label.alpha = 0
////            label.textAlignment = .center
////            insertSubview(label, at: 10)
////            label.translatesAutoresizingMaskIntoConstraints = false
////            NSLayoutConstraint.activate([
////                label.centerXAnchor.constraint(equalTo: centerXAnchor),
////                label.centerYAnchor.constraint(equalTo: centerYAnchor),
//////                    label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
//////                    label.heightAnchor.constraint(equalTo: heightAnchor)
////            ])
////            let attrSring = NSMutableAttributedString()
////            attrSring.append(NSAttributedString(string: "+1", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: frame.width * 0.3), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .systemBlue : survey!.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
////            label.attributedText = attrSring
////            UIView.animate(withDuration: 1.4, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
////                label.transform = .identity
////            } completion: { _ in
////                label.removeFromSuperview()
////
////            }
////
////            UIView.animate(withDuration: 0.7, delay: 0, options: UIView.AnimationOptions.curveLinear) {
////                label.alpha = 1
////                self.tableView.scrollToBottom()
////            } completion: { _ in
////                UIView.animate(withDuration: 0.7, delay: 0, options: UIView.AnimationOptions.curveLinear) {
////                    label.alpha = 0
////                } completion: { _ in }
////            }
////        }
////
////        isChoiceEnabled = true
////        isAwaitingVoteResponse = false
////        tableView.visibleCells.forEach {
////            guard let cell = $0 as? VoteCell else { return }
////            cell.isLoading = false
////        }
////        switch result {
////        case .success:
////            //            mode = .ReadOnly
////            updateResults()
////            tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
////            tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .automatic)
////            tableView.reloadSections(IndexSet(arrayLiteral: 3), with: .automatic)
////
////            _hasVoted = true
////            guard choice == survey?.answers.sorted{ $0.totalVotes > $1.totalVotes }.first else {
////                animate()
////                return
////            }
////
////            let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: 0.7)
////            banner.accessibilityIdentifier = "vote"
////            banner.present(content: VoteMessage(imageContent: ImageSigns.flameFilled, color: survey?.topic.tagColor ?? K_COLOR_RED, callbackDelegate: banner))
////        case .failure:
////            self.isChoiceEnabled = true
////            showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: ImageSigns.exclamationMark, dismissAfter: 1)
////        }
////    }
////
////    func onLoad(_ result: Result<Bool, Error>) {
////        switch result {
////        case .success:
////            tableView.reloadData()
////            guard !loadingIndicator.isNil else { return }
////                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
////                        self.loadingIndicator?.alpha = 0
////                        self.loadingIndicator?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
////                    }) {
////                        _ in
////                        self.loadingIndicator?.removeFromSuperview()
////                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
////                            self.tableView.alpha = 1
////                        }) {_ in }
////                    }
////        case .failure:
////            showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: ImageSigns.exclamationMark)
////        }
////
////
//////        let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//////        effectViewOutgoing.frame = view.frame
//////        effectViewOutgoing.addEquallyTo(to: view)
//////        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
//////            effectViewOutgoing.effect = nil
//////        })
//////
////
////    }
////
////    func onCountUpdated() {
////        tableView.visibleCells.forEach {
////            guard let cell = $0 as? AuthorCell else { return }
////            UIView.transition(with: cell.viewsLabel, duration: 0.2, options: .transitionCrossDissolve) {
////                cell.viewsLabel.text = "\(self.survey!.views)"
////            } completion: { _ in}
////        }
////    }
////
////    var survey: Survey? {
////        return viewInput?.survey
////    }
////
////    var surveyReference: SurveyReference {
////        return viewInput!.surveyReference
////    }
////}
////
////// MARK: - UI Setup
////extension PollView {
////    private func setupUI() {
////
////    }
////
////    private func updateResults() {
////        guard !survey.isNil else { return }
////        for (i,answer) in survey!.answers.enumerated() {
////            var resultIndicator: ResultIndicator!
////            if let found = resultIndicators.filter({ $0.answer === answer }).first {
////                resultIndicator = found
////            } else {
////                guard let answerId = survey!.result!.keys.first else { return }
////                resultIndicator = ResultIndicator(delegate: self, answer: answer, color: Colors.tags()[i], isSelected: answer.id == answerId, mode: survey!.isAnonymous ? .Anon : .Stock)
////                resultIndicators.append(resultIndicator)
////            }
////            resultIndicator.needsUIUpdate = true
//////            resultIndicator.isSelected = answer.ID == survey!.result!.keys.first
//////            if survey!.isAnonymous {
//////                resultIndicator.mode = .Anon
//////            } else if answer.voters.isEmpty {
////                if answer.voters.isEmpty {
////                resultIndicator.mode = .Stock
////            }
////            resultIndicator.value = survey!.getPercentForAnswer(answer)
////        }
////    }
////
//////    private func showBanner(callbackDelegate: CallbackObservable? = nil, bannerDelegate: BannerObservable, text: String, imageContent: UIView, color: UIColor = .systemRed, isModal: Bool = false, shouldDismissAfter: TimeInterval = 1, accessibilityIdentifier: String = "") {
//////        let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: callbackDelegate, bannerDelegate: bannerDelegate)
//////        banner.accessibilityIdentifier = accessibilityIdentifier
//////        banner.present(subview: PlainBannerContent(text: text, imageContent: imageContent, color: color), isModal: isModal, shouldDismissAfter: shouldDismissAfter)
//////    }
////}
////
////// MARK: - TableView delegate
////extension PollView: UITableViewDelegate, UITableViewDataSource {
////    private func setupTableView() {
////        tableView.delegate = self
////        tableView.dataSource = self
////        tableView.register(UINib(nibName: "AuthorCell", bundle: nil), forCellReuseIdentifier: "author")
////        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "title")
////        tableView.register(UINib(nibName: "TextCell", bundle: nil), forCellReuseIdentifier: "text")
////        tableView.register(UINib(nibName: "ImagesCell", bundle: nil), forCellReuseIdentifier: "images")
////        tableView.register(UINib(nibName: "HyperlinkCell", bundle: nil), forCellReuseIdentifier: "hyperlink")
////        tableView.register(UINib(nibName: "YoutubeCell", bundle: nil), forCellReuseIdentifier: "youtube")
////        tableView.register(UINib(nibName: "WebCell", bundle: nil), forCellReuseIdentifier: "web")
////        tableView.register(UINib(nibName: "ChoiceCell", bundle: nil), forCellReuseIdentifier: "choice")
////        tableView.register(UINib(nibName: "VoteCell", bundle: nil), forCellReuseIdentifier: "vote")
////        tableView.register(UINib(nibName: "PollResultCell", bundle: nil), forCellReuseIdentifier: "result")
////        tableView.register(UINib(nibName: "StatisticsCell", bundle: nil), forCellReuseIdentifier: "statistics")
////        tableView.register(UINib(nibName: "NextCell", bundle: nil), forCellReuseIdentifier: "next")
//////        tableView.register(UINib(nibName: "Comment", bundle: nil), forCellReuseIdentifier: "result")
////    }
////
////    func numberOfSections(in tableView: UITableView) -> Int {
////        guard !survey.isNil else { return 0 }
////        if mode == .ReadOnly, resultIndicators.isEmpty { updateResults() }
////        return 4
//////        switch mode {
//////        case .ReadOnly:
//////            return 4//2//Body & answers
//////        case .Write:
//////            return 4//Body & answers & vote button
//////        }
////    }
////
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        guard !survey.isNil else { return 0 }
////        if section == 0 {//ОСНОВНОЕ
////            return 6
////        } else if section == 1, survey != nil {//Варианты ответов
////            return survey!.answers.count
////        } else if section == 2 {//ПОСЛЕДНЯЯ СЕКЦИЯ
////            if mode == .Write {
////                return 1
////            } else {
////                return 1
////            }
////        } else if section == 3 {
////            return 1
////        }
////        return 0
////    }
////
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        guard !survey.isNil else { return UITableViewCell() }
////        if indexPath.section == 0 {
////            if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "author", for: indexPath) as? AuthorCell {
////                cell.setupUI(delegate: self, survey: survey!)
////                cell.viewsLabel.text = "\(self.survey!.views)"
////                cell.isUserInteractionEnabled = isChoiceEnabled
////                return cell
////            } else if indexPath.row == 1, let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? TitleCell {
////                cell.setupUI(delegate: self, survey: survey!)
////                return cell
////            } else if indexPath.row == 2, let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as? TextCell {
////                cell.setupUI(delegate: self, survey: survey!)
////                return cell
////            } else if indexPath.row == 3, let cell = tableView.dequeueReusableCell(withIdentifier: "images", for: indexPath) as? ImagesCell {
////                cell.setupUI(delegate: self, survey: survey!)
////                cell.isUserInteractionEnabled = isChoiceEnabled
////                return cell
////            } else if indexPath.row == 4, let url = survey!.url {
////                if foldWebCell {
////                    return UITableViewCell()
////                }
////                if url.absoluteString.isYoutubeLink, let videoID = url.absoluteString.youtubeID, let cell = tableView.dequeueReusableCell(withIdentifier: "youtube") as? YoutubeCell {
////                    cell.setupUI(delegate: self, videoID: videoID, color: surveyReference.topic.tagColor)
////                    return cell
////                } else if url.absoluteString.isTikTokLink, let cell = tableView.dequeueReusableCell(withIdentifier: "web", for: indexPath) as? WebCell {
////                    cell.setupUI(delegate: self, url: url)
////                    return cell
////                } else if let cell = tableView.dequeueReusableCell(withIdentifier: "hyperlink", for: indexPath) as? HyperlinkCell {
////                    cell.setupUI(delegate: self)
////                    cell.isUserInteractionEnabled = isChoiceEnabled
////                    return cell
////                }
////            } else if indexPath.row == 5, let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as? TextCell {
////                cell.setupUI(delegate: self, survey: survey!, isQuestion: true)
////                return cell
////            }
////        } else if indexPath.section == 1 {
////            switch mode {
////            case .Write:
////                if let cell = tableView.dequeueReusableCell(withIdentifier: "choice", for: indexPath) as? ChoiceCell, let answer = survey?.answers[indexPath.row] {
////                    cell.setupUI(delegate: self, answer: answer)
////                    if answersCells.filter({ $0 == cell }).isEmpty { answersCells.append(cell) }
////                    cell.isChecked = answer == choice
////                    cell.isUserInteractionEnabled = isChoiceEnabled
////                    return cell
////                }
////            case .ReadOnly:
////                if let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as? PollResultCell, let answer = survey?.answersSortedByOrder[indexPath.row], let resultIndicator = resultIndicators.filter({ $0.answer === answer }).first {
////                    cell.setupUI(width: frame.width, height: cell.frame.height)
//////                    cell.setNeedsLayout()
//////                    cell.layoutIfNeeded()
////                    resultIndicator.indexPath = indexPath
////                    cell.setResultIndicator(resultIndicator)
////                    cell.answer = answer
////                    cell.userChoice = answer == choice
////                    cell.setText()
////                    return cell
////                }
////                return UITableViewCell()
////            }
////        } else if indexPath.section == 2 {
////            switch mode {
////            case .Write:
////                if let cell = tableView.dequeueReusableCell(withIdentifier: "vote", for: indexPath) as? VoteCell {
////                    cell.setupUI(delegate: self, color: survey!.topic.tagColor)
////                    cell.isLoading = isAwaitingVoteResponse
////                    if !choice.isNil {
////                        cell.enable()
////                    }
////                    return cell
////                }
////            case .ReadOnly:
////                if let cell = tableView.dequeueReusableCell(withIdentifier: "statistics", for: indexPath) as? StatisticsCell {
////                    cell.setupUI(delegate: self, color: survey!.topic.tagColor, progress: CGFloat(survey!.progress)/CGFloat(100), voters: survey!.votesTotal, total: survey!.votesLimit)
////                    return cell
////                } else if let cell = tableView.dequeueReusableCell(withIdentifier: "next", for: indexPath) as? NextCell {
////                    cell.callbackDelegate = self
////                    return cell
////                }
////            }
////        } else if indexPath.section == 3 {
////            if let cell = tableView.dequeueReusableCell(withIdentifier: "next", for: indexPath) as? NextCell {
////                cell.callbackDelegate = self
////                return cell
////            }
////        }
////        return UITableViewCell()
////    }
////
////    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        guard !survey.isNil else { return 0 }
////        if indexPath.section == 0 {
////            if indexPath.row == 0 {//Author & category
////                return 80
////            } else if indexPath.row == 1 {
////                return 140
////            } else if indexPath.row == 3 {//Images
////                if survey!.imagesCount > 0 {
////                    return UIScreen.main.bounds.width/(16/9)
////                }
//////                } else if survey!.imagesURLs != nil, !survey!.imagesURLs!.isEmpty {
//////                    return UIScreen.main.bounds.width/(16/9)
//////                }
////                return 0
////            } else if indexPath.row == 4 {//Web resource
////                if survey!.url == nil || foldWebCell {
////                    return 0
////                } else if survey!.url!.absoluteString.isYoutubeLink {
////                    return UIScreen.main.bounds.width/(16/9)
////                } else if survey!.url!.absoluteString.isTikTokLink {
////                    return 650
////                } else {
////                    return 60
////                }
////            }
////        } else if indexPath.section == 2 {
////
////                switch mode {
////                case .Write:
////                    return 140
////                case .ReadOnly:
////                    return 300
////                }
////
////        } else if indexPath.section == 3 {
////            if mode == .ReadOnly {
////                return showNext ? 60 : 0
////            }
////            return 0
////        }
////        return UITableView.automaticDimension
////    }
////
////    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
////        if section == 2 {
////            return 30
////        }
////        return CGFloat.leastNonzeroMagnitude
////    }
////
////    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
////        return CGFloat.leastNonzeroMagnitude
////    }
////
////    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        if let cell = tableView.cellForRow(at: indexPath) as? ChoiceCell {
////            cell.isChecked = true
////            choice = cell.answer
////        }
////    }
////}
////
////extension PollView: CallbackObservable {
////    func callbackReceived(_ sender: Any) {
////        if sender is Avatar {
////            fatalError()
////        } else if let claim = sender as? Claim {
////            viewInput?.onClaim(claim)
////        } else if let button = sender as? UIButton {
////            if button.accessibilityIdentifier == "vote" {
////                guard !choice.isNil else {
////                    showBanner(bannerDelegate: self, text: "make_choice".localized, content: ImageSigns.exclamationMark, dismissAfter: 1)
////                    return
////                }
////                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? VoteCell {
////                    cell.isLoading = true
////                }
////                isChoiceEnabled = false
////                isAwaitingVoteResponse = true
////                viewInput?.onVote(choice)
////                return
////            } else if button.accessibilityIdentifier == "claim" {
////                let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
////                banner.accessibilityIdentifier = "claim"
////                banner.present(content: ClaimSelection(callbackDelegate: banner))
////            } else if button.accessibilityIdentifier == "next" {
////                viewInput?.onExitWithSkip()
////            }
////        } else if let image = sender as? UIImage {
////            viewInput?.onImageTapped(image: image, title: "")
////        } else if let array = sender as? [AnyObject], let answer = array.filter({ $0 is Answer}).first as? Answer,
////                  let indexPath = array.filter({ $0 is IndexPath}).first as? IndexPath,
////                  let color = array.filter({ $0 is UIColor}).first as? UIColor {
////            viewInput?.onVotersTapped(answer: answer, indexPath: indexPath, color: color)
////        } else if sender is HyperlinkCell {
////            guard let url = survey?.url else {
////                showBanner(bannerDelegate: self, text: AppError.webContent.localizedDescription, content: ImageSigns.exclamationMark, dismissAfter: 0.5)
////                return
////            }
////            viewInput?.onURLTapped(url)
////        } else if let error = AppError.tikTokContent as? AppError {
////            foldWebCell = true
////            let logo = TikTokLogo()
////            logo.isOpaque = false
////            showBanner(bannerDelegate: self, text: error.localizedDescription, content: logo, dismissAfter: 0.5)
////        } else if let error = AppError.tikTokContent as? AppError {
////            foldWebCell = true
////            showBanner(bannerDelegate: self, text: error.localizedDescription, content: ImageSigns.exclamationMark, dismissAfter: 0.5)
////        }
////    }
////}
////
////extension PollView: BannerObservable {
////    func onBannerWillAppear(_ sender: Any) {}
////
////    func onBannerWillDisappear(_ sender: Any) {
////        if let popup = sender as? Popup, popup.accessibilityIdentifier == "vote" {
////            tableView.scrollToBottom()
////        }
////    }
////
////    func onBannerDidAppear(_ sender: Any) {}
////
////    func onBannerDidDisappear(_ sender: Any) {
////        if let banner = sender as? Banner {
////            banner.removeFromSuperview()
////        } else if let popup = sender as? Popup {
////            popup.removeFromSuperview()
////            if popup.accessibilityIdentifier == "exit" {
////                viewInput?.onExitWithSkip()
//////            } else if popup.accessibilityIdentifier == "vote" {
//////                tableView.scrollToBottom()
////            }
////        }
////    }
////}
////
