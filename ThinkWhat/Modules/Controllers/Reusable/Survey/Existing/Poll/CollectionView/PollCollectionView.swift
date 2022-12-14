//
//  PollCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class PollCollectionView: UICollectionView {

    enum Section: Int {
        case title, description, image, youtube, web, question, choices, vote, comments
        
        var localized: String {
            switch self {
            case .title:
                return "title".localized
            case .description:
                return "description".localized
            case .image:
                return "images".localized
            case .youtube:
                return "YouTube"
            case .web:
                return "web".localized
            case .question:
                return "question".localized
            case .choices:
                return "poll_choices".localized
            case .vote:
                return "vote".localized
            case .comments:
                return "comments".localized
            }
        }
    }
    
    typealias Source = UICollectionViewDiffableDataSource<Section, Int>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Int>

    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Logic
    private weak var item: Survey?
    private var source: Source!
//    private var mode: PollController.Mode {
//        didSet {
//            guard oldValue != mode else { return }
//
//            print(mode)
//        }
//    }
    
    
    
    // MARK: - Initialization
    init(item: Survey) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())

        self.item = item
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
}

private extension PollCollectionView {
    @MainActor
    func setupUI() {
//        delegate = self
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            layoutConfig.backgroundColor = .clear
            layoutConfig.showsSeparators = false
            
            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            return sectionLayout
        }
        
        let titleCellRegistration = UICollectionView.CellRegistration<PollTitleCell, AnyHashable> { [weak self] cell, _, item in
            guard let self = self else { return }
            
            cell.item = self.item
        }
        
        source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
            guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
            
            if section == .title {
                return collectionView.dequeueConfiguredReusableCell(using: titleCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
                //            } else if section == .description {
                //                let cell = collectionView.dequeueConfiguredReusableCell(using: descriptionCellRegistration,
                //                                                                        for: indexPath,
                //                                                                        item: identifier)
                //                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                //                collectionView.deselectItem(at: indexPath, animated: true)
                //                cell.layer.masksToBounds = false
                //                return cell
                //            } else if section == .image {
                //                return collectionView.dequeueConfiguredReusableCell(using: self.imageCellRegistration,
                //                                                                    for: indexPath,
                //                                                                    item: identifier)
                //            } else if section == .youtube {
                //                return collectionView.dequeueConfiguredReusableCell(using: youtubeCellRegistration,
                //                                                                    for: indexPath,
                //                                                                    item: identifier)
                //            } else if section == .web {
                //                return collectionView.dequeueConfiguredReusableCell(using: linkPreviewRegistration,
                //                                                                    for: indexPath,
                //                                                                    item: identifier)
                //            } else if section == .question {
                //                return collectionView.dequeueConfiguredReusableCell(using: questionCellRegistration,
                //                                                                    for: indexPath,
                //                                                                    item: identifier)
                //            } else if section == .vote {
                //                return collectionView.dequeueConfiguredReusableCell(using: voteCellRegistration,
                //                                                                    for: indexPath,
                //                                                                    item: identifier)
                //            }  else if section == .comments {
                //                return collectionView.dequeueConfiguredReusableCell(using: commentsCellRegistration,
                //                                                                    for: indexPath,
                //                                                                    item: identifier)
            }
            return UICollectionViewCell()
        }
        
        applyDifferences()
    }
    
    func applyDifferences(toExistingSnapshot: Bool = false, animated: Bool = false) {
        var snapshot = toExistingSnapshot ? source.snapshot() : Snapshot()
        snapshot.appendSections([.title])
        snapshot.appendItems([0], toSection: .title)
        source.apply(snapshot, animatingDifferences: false)
        
        //        snapshot.appendSections([.title, .description,])
        //        snapshot.appendItems([0], toSection: .title)
        //        snapshot.appendItems([1], toSection: .description)
        //        if poll.imagesCount != 0 {
        //            snapshot.appendSections([.image])
        //            snapshot.appendItems([2], toSection: .image)
        //        }
        //        if let url = poll.url {
        //            if url.absoluteString.isYoutubeLink {
        //                snapshot.appendSections([.youtube])
        //                snapshot.appendItems([3], toSection: .youtube)
        //            } else {
        //                snapshot.appendSections([.web])
        //                snapshot.appendItems([4], toSection: .web)
        //            }
        //        }
        //        snapshot.appendSections([.question])
        //        snapshot.appendItems([5], toSection: .question)
        //        ////        snapshot.appendSections([.choices])
        //        ////        snapshot.appendItems([6], toSection: .choices)
        //        snapshot.appendSections([.comments])
        //        snapshot.appendItems([8], toSection: .comments)
    }
}

//class PollCollectionView: UICollectionView {
//
//    enum Section: Int {
//        case title, description, image, youtube, web, question, choices, vote, comments
//
//        var localized: String {
//            switch self {
//            case .title:
//                return "title".localized
//            case .description:
//                return "description".localized
//            case .image:
//                return "images".localized
//            case .youtube:
//                return "YouTube"
//            case .web:
//                return "web".localized
//            case .question:
//                return "question".localized
//            case .choices:
//                return "poll_choices".localized
//            case .vote:
//                return "vote".localized
//            case .comments:
//                return "comments".localized
//            }
//        }
//    }
//
//    // MARK: - Public properties
//    public let claimSubject = CurrentValueSubject<Comment?, Never>(nil)
//    public var colorSubject = CurrentValueSubject<UIColor?, Never>(nil)
//    public var modeSubject = PassthroughSubject<PollController.Mode, Never>()
//    public var lastPostedComment = CurrentValueSubject<Comment?, Never>(nil)
//    public var commentThreadSubject = CurrentValueSubject<Comment?, Never>(nil)
//
//    // MARK: - Private properties
//    private var subscriptions = Set<AnyCancellable>()
//    private weak var host: PollView!
//    private let poll: Survey
//    private weak var callbackDelegate: CallbackObservable?
//    private var source: UICollectionViewDiffableDataSource<Section, Int>!
//    private var imageCellRegistration: UICollectionView.CellRegistration<ImageCell, AnyHashable>!
//    private var answer: Answer? {
//        didSet {
//            guard host.mode == .Write else { return }
//            if oldValue.isNil {
//                var snapshot = source.snapshot()
//                snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .comments))
//                snapshot.deleteSections([.comments])
//                snapshot.appendSections([.vote])
//                snapshot.appendItems([7], toSection: .vote)
//                snapshot.appendSections([.comments])
//                snapshot.appendItems([8], toSection: .comments)
//                source.apply(snapshot, animatingDifferences: true) {
////                    self.scrollToItem(at: IndexPath(item: 0, section: self.numberOfSections-1), at: .bottom, animated: true)
//                }
//            }
//            if let cell = cellForItem(at: IndexPath(item: 0, section: numberOfSections-2)) as? VoteCell {
//                cell.answer = answer!
//            }
//        }
//    }
////    public var colorSubject = PassthroughSubject<UIColor, Never>()
////    @Published var colorPublisher: UIColor = .clear {
////        didSet {
////            print("received \(colorPublisher)")
////        }
////    }
//
//
//
//    // MARK: - Initialization
//    init(host: PollView?, poll: Survey, callbackDelegate: CallbackObservable) {
//        self.poll = poll
//        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
//        self.host = host
//        self.callbackDelegate = callbackDelegate
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Destructor
//    deinit {
////        observers.forEach { $0.invalidate() }
////        tasks.forEach { $0?.cancel() }
//        subscriptions.forEach { $0.cancel() }
//        NotificationCenter.default.removeObserver(self)
//#if DEBUG
//        print("\(String(describing: type(of: self))).\(#function)")
//#endif
//    }
//
//
//    // MARK: - UI functions
//    private func setupUI() {
//
//        delegate = self
//        allowsMultipleSelection = true
//        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
//            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
////            layoutConfig.headerMode = .firstItemInSection
//            layoutConfig.backgroundColor = .clear
//            layoutConfig.showsSeparators = false
//
//            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
////            sectionLayout.interGroupSpacing = 20
//            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
//            return sectionLayout
//        }
//
//        let titleCellRegistration = UICollectionView.CellRegistration<PollTitleCell, AnyHashable> { [weak self] cell, indexPath, item in
//            guard let self = self, cell.item.isNil else { return }
//            cell.item = self.poll
//        }
//
//        let descriptionCellRegistration = UICollectionView.CellRegistration<PollDescriptionCell, AnyHashable> { [weak self] cell, indexPath, item in
////            cell.layer.masksToBounds = false
//            guard let self = self else { return }
////            guard let self = self, cell.item.isNil else { return }
////            cell.collectionView = self
//            cell.item = self.poll
////            cell.isFoldable = cell.item.isOwn || cell.item.isComplete
//        }
//        imageCellRegistration = UICollectionView.CellRegistration<ImageCell, AnyHashable> { [weak self] cell, indexPath, item in
//            guard let self = self, cell.item.isNil else { return }
//            cell.item = self.poll
//            cell.callbackDelegate = self
//        }
//        let youtubeCellRegistration = UICollectionView.CellRegistration<YoutubeCell, AnyHashable> { [weak self] cell, indexPath, item in
//            guard let self = self, cell.item.isNil else { return }
//            cell.item = self.poll
//        }
////        let webCellRegistration = UICollectionView.CellRegistration<WebViewCell, AnyHashable> { [weak self] cell, indexPath, item in
////            guard let self = self, cell.item.isNil else { return }
////            cell.item = self.poll
////            cell.callbackDelegate = self
////        }
//        let linkPreviewRegistration = UICollectionView.CellRegistration<LinkPreviewCell, AnyHashable> { [weak self] cell, indexPath, item in
//            guard let self = self, cell.item.isNil else { return }
//            cell.item = self.poll
//            cell.callbackDelegate = self
//        }
//        let questionCellRegistration = UICollectionView.CellRegistration<QuestionCell, AnyHashable> { [weak self] cell, indexPath, item in
//            guard let self = self else { return }
//            cell.mode = self.host.mode
//            guard cell.item.isNil else { return }
//            cell.callbackDelegate = self
//            cell.boundsListener = self
//            cell.answerListener = self
//            cell.item = self.poll
//
//            self.modeSubject.sink {
//#if DEBUG
//                print("receiveCompletion: \($0)")
//#endif
//            } receiveValue:  {
//                cell.mode = $0
//            }.store(in: &self.subscriptions)
//
//            cell.colorSubject.sink { [weak self] in
//                guard let self = self,
//                      let color = $0
//                else { return }
//                self.colorSubject.send(color)
////                self.colorSubject.send(completion: .finished)
//            }.store(in: &self.subscriptions)
//
////            cell.$colorPublisher.receive(on: RunLoop.main).sink { [weak self] in
////                guard let self = self else { return }
////                self.colorPublisher = $0
////            }.store(in: &self.subscriptions)
//        }
//
////        let choicesCellRegistration = UICollectionView.CellRegistration<ChoiceSectionCell, AnyHashable> { [weak self] cell, indexPath, item in
////            cell.boundsListener = self
////            guard let self = self, cell.item.isNil else { return }
////            cell.item = self.poll
////        }
//
//        let voteCellRegistration = UICollectionView.CellRegistration<VoteCell, AnyHashable> { [weak self] cell, indexPath, item in
//            guard let self = self else { return }
//            cell.callbackDelegate = self
//
//            self.colorSubject.sink {
//#if DEBUG
//                print("receiveCompletion: \($0)")
//#endif
//            } receiveValue: {
//                guard let color = $0 else { return }
//                cell.color = color
//            }.store(in: &self.subscriptions)
//        }
//
//        let commentsCellRegistration = UICollectionView.CellRegistration<CommentsSectionCell, AnyHashable> { [weak self] cell, indexPath, item in
////            cell.boundsListener = self
//            guard let self = self, cell.item.isNil else { return }
//            cell.item = self.poll
//
//            //Claim
//            cell.claimSubject.sink { [weak self] in
//                guard let self = self, !$0.isNil else { return }
//
//                self.claimSubject.send($0)
//            }.store(in: &self.subscriptions)
//
//            //Subscription for commenting
//            cell.commentSubject.sink { [weak self] in
//                guard let self = self,
//                      let body = $0
//                else { return }
//
//                self.host.postComment(body: body)
//            }.store(in: &self.subscriptions)
//
//            cell.anonCommentSubject.sink { [weak self] in
//                guard let self = self,
//                      let dict = $0,
//                      let username = dict.values.first,
//                      let body = dict.keys.first
//                else { return }
//
//                self.host.postComment(body: body, username: username)
//            }.store(in: &self.subscriptions)
//
//            //Subscription for commenting
//            cell.deleteSubject.sink { [weak self] in
//                guard let self = self,
//                      let comment = $0
//                else { return }
//
//                self.host.deleteComment(comment)
//            }.store(in: &self.subscriptions)
//
//            //Subscription for reply to comment
//            cell.replySubject.sink { [weak self] in
//                guard let self = self,
//                      let dict = $0,
//                      let body = dict.values.first,
//                      let comment = dict.keys.first
//                else { return }
//
//                self.host.postComment(body: body, replyTo: comment)
//            }.store(in: &self.subscriptions)
//
//            cell.anonReplySubject.sink { [weak self] in
//                guard let self = self,
//                      let dict = $0,
//                      let innerDict = dict.values.first,
//                      let comment = dict.keys.first,
//                      let username = innerDict.values.first,
//                      let body = innerDict.keys.first
//                else { return }
//
//                self.host.postComment(body: body, replyTo: comment, username: username)
//            }.store(in: &self.subscriptions)
//
//            //Subscription for request comments
//            cell.commentsRequestSubject.sink { [weak self] in
//                guard let self = self,
//                      let comments = $0 as? [Comment],
//                      comments.count > 0
//                else { return }
//
//                self.host.requestComments(comments)
//            }.store(in: &self.subscriptions)
//
//            //Subscibe for thread disclosure
//            cell.commentThreadSubject.sink { [weak self] in
//                guard let self = self,
//                      let comment = $0 as? Comment
//                else { return }
//
//                self.commentThreadSubject.send(comment)
//            }.store(in: &self.subscriptions)
//
//            //Subscibe for posted comment
//            self.lastPostedComment.sink {
//                guard let comment = $0 else { return }
//
//                cell.lastPostedComment = comment
//            }.store(in: &self.subscriptions)
//        }
//
//        source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { [unowned self]
//            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
//            guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
//            if section == .title {
//                return collectionView.dequeueConfiguredReusableCell(using: titleCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            } else if section == .description {
//                let cell = collectionView.dequeueConfiguredReusableCell(using: descriptionCellRegistration,
//                                                                        for: indexPath,
//                                                                        item: identifier)
//                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
//                collectionView.deselectItem(at: indexPath, animated: true)
//                cell.layer.masksToBounds = false
//                return cell
//            } else if section == .image {
//                return collectionView.dequeueConfiguredReusableCell(using: self.imageCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            } else if section == .youtube {
//                return collectionView.dequeueConfiguredReusableCell(using: youtubeCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            } else if section == .web {
//                return collectionView.dequeueConfiguredReusableCell(using: linkPreviewRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            } else if section == .question {
//                return collectionView.dequeueConfiguredReusableCell(using: questionCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
////            } else if section == .choices {
////                return collectionView.dequeueConfiguredReusableCell(using: choicesCellRegistration,
////                                                                    for: indexPath,
////                                                                    item: identifier)
//            } else if section == .vote {
//                return collectionView.dequeueConfiguredReusableCell(using: voteCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            }  else if section == .comments {
//                return collectionView.dequeueConfiguredReusableCell(using: commentsCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            }
//
//            return UICollectionViewCell()
//        }
//
////        source.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
////            guard let self = self else { return nil }
////            return self.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
////        }
//
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
//        snapshot.appendSections([.title, .description,])
//        snapshot.appendItems([0], toSection: .title)
//        snapshot.appendItems([1], toSection: .description)
//        if poll.imagesCount != 0 {
//            snapshot.appendSections([.image])
//            snapshot.appendItems([2], toSection: .image)
//        }
//        if let url = poll.url {
//            if url.absoluteString.isYoutubeLink {
//                snapshot.appendSections([.youtube])
//                snapshot.appendItems([3], toSection: .youtube)
//            } else {
//                snapshot.appendSections([.web])
//                snapshot.appendItems([4], toSection: .web)
//            }
//        }
//        snapshot.appendSections([.question])
//        snapshot.appendItems([5], toSection: .question)
//////        snapshot.appendSections([.choices])
//////        snapshot.appendItems([6], toSection: .choices)
//        snapshot.appendSections([.comments])
//        snapshot.appendItems([8], toSection: .comments)
//
//        source.apply(snapshot, animatingDifferences: false)
//    }
//
////    public func refresh() {
////        source.refresh()
////    }
//
//    // MARK: - Public methods
//    public func onImageScroll(_ index: Int) {
//        guard let cell = cellForItem(at: IndexPath(row: 0, section: 2)) as? ImageCell else { return }
//        cell.scrollToImage(at: index)
//    }
//
//    public func onVoteCallback(_ result: Result<Bool, Error>){
//        switch result {
//        case .success:
//            modeSubject.send(host.mode)
//            modeSubject.send(completion: .finished)
////            guard let cell = visibleCells.filter({ $0.isKind(of: QuestionCell.self) }).first as? QuestionCell,
////                  let mode = host?.mode else { return }
////            cell.mode = mode
//            //Remove .vote section
//            var snapshot = source.snapshot()
//            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .vote))
//            snapshot.deleteSections([.vote])
//            source.apply(snapshot, animatingDifferences: true)
////            guard let cell = visibleCells.filter({ $0.isKind(of: QuestionCell.self) }).first as? QuestionCell,
////                  let mode = host?.mode else { return }
////            cell.mode = mode
//            source.refresh()
////            scrollToItem(at: IndexPath(item: 0, section: numberOfSections-1), at: .bottom, animated: true)
//            //Chmod visible .choices cells & reorder desc
//
//            guard let details = poll.resultDetails else { return }
//            if details.isPopular {
////                let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: host, heightScaleFactor: 0.5)
////                banner.accessibilityIdentifier = "vote"
////                let imageView = ImageSigns.flameFilled
////                imageView.contentMode = .scaleAspectFit
////                delayAsync(delay: 1.5) { [self] in
////                    banner.present(content: VoteMessage(imageContent: imageView, points: self.poll.resultDetails?.points ?? 0, color: self.poll.topic.tagColor, callbackDelegate: banner))
////                }
//            } else {
//
//            }
//        case .failure(let error):
//#if DEBUG
//            error.printLocalized(class: type(of: self), functionName: #function)
//#endif
//            showBanner(callbackDelegate: host, bannerDelegate: host!, text: "backend_error".localized, content: ImageSigns.exclamationMark, dismissAfter: 1)
//        }
//    }
//}
//
//// MARK: - BoundsListener
//extension PollCollectionView: BoundsListener {
//    func onBoundsChanged(_ rect: CGRect) {
//        source.refresh()//animatingDifferences: true)
//    }
//}
//
//extension PollCollectionView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView,
//                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        if let _ = cellForItem(at: indexPath) as? CommentsSectionCell {
//            guard host?.mode == .ReadOnly else {
//                showBanner(bannerDelegate: host, text: "vote_to_view_comments".localized, content: UIImageView(image: UIImage(systemName: "exclamationmark.icloud.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemOrange.withAlphaComponent(1))
//                return false
//            }
//            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [.bottom])
//            source.refresh()
//            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
//            return true
//        }
////        // Allows for closing an already open cell
////        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
////            collectionView.deselectItem(at: indexPath, animated: true)
////        } else {
////            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
////        }
////
////        source.refresh()
////
////        return false // The selecting or deselecting is already performed above
//
////        guard let cell = collectionView.cellForItem(at: indexPath), !cell.isSelected else {
////            collectionView.deselectItem(at: indexPath, animated: true)
////            source.refresh()
////            return false
////        }
//        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
//        source.refresh()
//        return true
//    }
//
//    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        source.refresh()
//        return false
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        host.lastContentOffsetY = scrollView.contentOffset.y
//    }
//}
//
//// MARK: - CallbackObservable
//extension PollCollectionView: CallbackObservable {
//    func callbackReceived(_ sender: Any) {
//        ///Passthrouth
////        if let mediafile = sender as? Mediafile {
//            callbackDelegate?.callbackReceived(sender)
////        }
//    }
//}
//
//// MARK: - AnswerListener
//extension PollCollectionView: AnswerListener {
//    func onChoiceMade(_ answer: Answer) {
//        self.answer = answer
//    }
//}
