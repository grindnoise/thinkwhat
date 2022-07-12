//
//  PollCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

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
    
    // MARK: - Private properties
    private weak var host: PollView!
    private let poll: Survey
    private weak var callbackDelegate: CallbackObservable?
    private var source: UICollectionViewDiffableDataSource<Section, Int>!
    private var imageCellRegistration: UICollectionView.CellRegistration<ImageCell, AnyHashable>!
    private var answer: Answer? {
        didSet {
            guard host.mode == .Write else { return }
            guard oldValue.isNil else {
                if let cell = cellForItem(at: IndexPath(item: 0, section: numberOfSections-1)) as? VoteCell {
                    cell.answer = answer!
                }
                return
            }
            var snapshot = source.snapshot()
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .comments))
            snapshot.deleteSections([.comments])
            snapshot.appendSections([.vote])
            snapshot.appendItems([7], toSection: .vote)
            snapshot.appendSections([.comments])
            snapshot.appendItems([8], toSection: .comments)
            source.apply(snapshot, animatingDifferences: true) //{
//                self.scrollToItem(at: IndexPath(item: 0, section: self.numberOfSections-1), at: .bottom, animated: true)
//            }
            if let cell = cellForItem(at: IndexPath(item: 0, section: numberOfSections-2)) as? VoteCell {
                cell.answer = answer!
            }
        }
    }
    
    // MARK: - Initialization
    init(host: PollView?, poll: Survey, callbackDelegate: CallbackObservable) {
        self.poll = poll
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.host = host
        self.callbackDelegate = callbackDelegate
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(String(describing: type(of: self))).\(#function)")
    }
    
    // MARK: - UI functions
    private func setupUI() {
        delegate = self
        allowsMultipleSelection = true
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            layoutConfig.headerMode = .firstItemInSection
            layoutConfig.backgroundColor = .clear
            layoutConfig.showsSeparators = false
//            layoutConfig.headerMode = .supplementary
            
            return NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
        }
        
        let titleCellRegistration = UICollectionView.CellRegistration<PollTitleCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
        }
        
        let descriptionCellRegistration = UICollectionView.CellRegistration<PollDescriptionCell, AnyHashable> { [weak self] cell, indexPath, item in
            cell.layer.masksToBounds = false
            guard let self = self, cell.item.isNil else { return }
//            cell.collectionView = self
            cell.item = self.poll
        }
        imageCellRegistration = UICollectionView.CellRegistration<ImageCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
            cell.callbackDelegate = self
        }
        let youtubeCellRegistration = UICollectionView.CellRegistration<YoutubeCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
        }
        let webCellRegistration = UICollectionView.CellRegistration<WebViewCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
            cell.callbackDelegate = self
        }
        let questionCellRegistration = UICollectionView.CellRegistration<QuestionCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            cell.mode = self.host.mode
            guard cell.item.isNil else { return }
            cell.callbackDelegate = self
            cell.boundsListener = self
            cell.answerListener = self
            cell.item = self.poll
        }
        
        let choicesCellRegistration = UICollectionView.CellRegistration<ChoiceSectionCell, AnyHashable> { [weak self] cell, indexPath, item in
            cell.boundsListener = self
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
        }

        let voteCellRegistration = UICollectionView.CellRegistration<VoteCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.color.isNil else { return }
            cell.callbackDelegate = self
            cell.color = self.poll.topic.tagColor
        }
        
        let commentsCellRegistration = UICollectionView.CellRegistration<CommentsSectionCell, AnyHashable> { [weak self] cell, indexPath, item in
            cell.boundsListener = self
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
        }

//        let headerRegistration = UICollectionView.SupplementaryRegistration <UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, elementKind, indexPath in
//            
//            guard let section = Section.init(rawValue: indexPath.section) else { return }
//            
//            if section == .title {
//                headerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
//                return
//            }
//            
//            var configuration = headerView.defaultContentConfiguration()
//            configuration.text = "hide".localized
//            configuration.textProperties.font = UIFont(name: Fonts.Regular, size: 14)!
//            configuration.textProperties.color = .secondaryLabel
//            configuration.directionalLayoutMargins = .init(top: 20.0, leading: 0.0, bottom: 10.0, trailing: 0.0)
//            
//            headerView.contentConfiguration = configuration
//            headerView.accessories = [.outlineDisclosure(options: UICellAccessory.OutlineDisclosureOptions(style: .header)) {
//                var currentSectionSnapshot = self.source.snapshot(for: section)
//                if currentSectionSnapshot.items.filter { currentSectionSnapshot.isExpanded($0) }.isEmpty {
//                    currentSectionSnapshot.collapse(currentSectionSnapshot.items)
//                } else {
//                    currentSectionSnapshot.expand(currentSectionSnapshot.items)
//                }
//                self.source.apply(currentSectionSnapshot, to: section, animatingDifferences: true)
//            }]
//        }
        
        source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { [unowned self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
            if section == .title {
                return collectionView.dequeueConfiguredReusableCell(using: titleCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .description {
                let cell = collectionView.dequeueConfiguredReusableCell(using: descriptionCellRegistration,
                                                                        for: indexPath,
                                                                        item: identifier)
                cell.layer.masksToBounds = false
                return cell
            } else if section == .image {
                return collectionView.dequeueConfiguredReusableCell(using: self.imageCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .youtube {
                return collectionView.dequeueConfiguredReusableCell(using: youtubeCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .web {
                return collectionView.dequeueConfiguredReusableCell(using: webCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .question {
                return collectionView.dequeueConfiguredReusableCell(using: questionCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .choices {
                return collectionView.dequeueConfiguredReusableCell(using: choicesCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .vote {
                return collectionView.dequeueConfiguredReusableCell(using: voteCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            }  else if section == .comments {
                return collectionView.dequeueConfiguredReusableCell(using: commentsCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            }

            return UICollectionViewCell()
        }
        
//        source.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
//            guard let self = self else { return nil }
//            return self.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
//        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.title, .description,])
        snapshot.appendItems([0], toSection: .title)
        snapshot.appendItems([1], toSection: .description)
        if poll.imagesCount != 0 {
            snapshot.appendSections([.image])
            snapshot.appendItems([2], toSection: .image)
        }
        if let url = poll.url {
            if url.absoluteString.isYoutubeLink {
                snapshot.appendSections([.youtube])
                snapshot.appendItems([3], toSection: .youtube)
            } else {
                snapshot.appendSections([.web])
                snapshot.appendItems([4], toSection: .web)
            }
        }
        snapshot.appendSections([.question])
        snapshot.appendItems([5], toSection: .question)
//        snapshot.appendSections([.choices])
//        snapshot.appendItems([6], toSection: .choices)
        snapshot.appendSections([.comments])
        snapshot.appendItems([8], toSection: .comments)

        source.apply(snapshot, animatingDifferences: false)
    }
    
//    public func refresh() {
//        source.refresh()
//    }
    
    // MARK: - Public methods
    public func onImageScroll(_ index: Int) {
        guard let cell = cellForItem(at: IndexPath(row: 0, section: 2)) as? ImageCell else { return }
        cell.scrollToImage(at: index)
    }
    
    public func onVoteCallback(_ result: Result<Bool, Error>){
        switch result {
        case .success:
            //Remove .vote section
//            guard let _ = visibleCells.filter({ $0.isKind(of: VoteCell.self) }).first as? VoteCell else { return }
            var snapshot = source.snapshot()
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .vote))
            snapshot.deleteSections([.vote])
            source.apply(snapshot, animatingDifferences: true)
//            scrollToItem(at: IndexPath(item: 0, section: numberOfSections-1), at: .bottom, animated: true)
            //Chmod visible .choices cells & reorder desc
            guard let cell = visibleCells.filter({ $0.isKind(of: QuestionCell.self) }).first as? QuestionCell,
                  let mode = host?.mode else { return }
            cell.mode = mode
            guard let details = poll.resultDetails else { return }
            if details.isPopular {
                let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: host, heightScaleFactor: 0.5)
                banner.accessibilityIdentifier = "vote"
                let imageView = ImageSigns.flameFilled
                imageView.contentMode = .scaleAspectFit
                delayAsync(delay: 1.5) { [self] in
                    banner.present(content: VoteMessage(imageContent: imageView, points: self.poll.resultDetails?.points ?? 0, color: self.poll.topic.tagColor, callbackDelegate: banner))
                }
            } else {
                
            }
        case .failure(let error):
#if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
#endif
            showBanner(callbackDelegate: host, bannerDelegate: host!, text: "backend_error".localized, content: ImageSigns.exclamationMark, dismissAfter: 1)
        }
    }
}

// MARK: - BoundsListener
extension PollCollectionView: BoundsListener {
    func onBoundsChanged(_ rect: CGRect) {
        source.refresh()
    }
}

extension PollCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let _ = cellForItem(at: indexPath) as? CommentsSectionCell {
            guard host?.mode == .ReadOnly else {
                showBanner(callbackDelegate: host, bannerDelegate: host!, text: "vote_to_view_comments".localized, content: ImageSigns.exclamationMark, dismissAfter: 1)
                return false
            }
            return true
        }
//        // Allows for closing an already open cell
//        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
//            collectionView.deselectItem(at: indexPath, animated: true)
//        } else {
//            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
//        }
//
//        source.refresh()
//
//        return false // The selecting or deselecting is already performed above
        
//        guard let cell = collectionView.cellForItem(at: indexPath), !cell.isSelected else {
//            collectionView.deselectItem(at: indexPath, animated: true)
//            source.refresh()
//            return false
//        }
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        source.refresh()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        collectionView.deselectItem(at: indexPath, animated: true)
        source.refresh()
        return false
    }
}

// MARK: - CallbackObservable
extension PollCollectionView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        ///Passthrouth
//        if let mediafile = sender as? Mediafile {
            callbackDelegate?.callbackReceived(sender)
//        }
    }
}

// MARK: - AnswerListener
extension PollCollectionView: AnswerListener {
    func onChoiceMade(_ answer: Answer) {
        self.answer = answer
    }
}
