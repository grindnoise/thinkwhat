//
//  TopicsCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopicsCollectionView: UICollectionView {
    
    // MARK: - Private properties
    private var notifications: [Task<Void, Never>?] = []
    private var source: UICollectionViewDiffableDataSource<TopicHeaderItem, TopicListItem>!
    private let modelObjects: [TopicHeaderItem] = {
        Topics.shared.all.filter({ $0.isParentNode }).map { topic in
            return TopicHeaderItem(topic: topic)
        }
    }()
    private weak var callbackDelegate: CallbackObservable?
    private var observers: [NSKeyValueObservation] = []
    
    // MARK: - Destructor
    deinit {
        notifications.forEach { $0?.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    init(callbackDelegate: CallbackObservable) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.callbackDelegate = callbackDelegate
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        delegate = self
        
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            layoutConfig.headerMode = .firstItemInSection
            layoutConfig.backgroundColor = .clear
            if #available(iOS 14.5, *) {
                layoutConfig.separatorConfiguration.color = .tertiarySystemFill
            }
//            layoutConfig.showsSeparators = true
//            layoutConfig.footerMode = .supplementary
            
            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
//            sectionLayout.interGroupSpacing = 20
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            return sectionLayout
        }
        
        let cellRegistration = UICollectionView.CellRegistration<TopicCell, TopicItem> { [weak self ] cell, indexPath, item in
            guard let self = self else { return }
            cell.item = item
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : item.topic.tagColor.withAlphaComponent(0.075)
            cell.backgroundConfiguration = backgroundConfig
            
            let accessoryConfig = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: UIImage(systemName: "chevron.right")), placement: .trailing(displayed: .always, at: {
                _ in 0
            }), isHidden: false, reservedLayoutWidth: nil, tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor, maintainsFixedSize: true)
            cell.accessories = [UICellAccessory.customView(configuration: accessoryConfig)]
//            cell.accessories = [.outlineDisclosure(displayed: .always, options: .init(style: .cell, isHidden: false, reservedLayoutWidth: nil, tintColor: item.topic.tagColor), actionHandler: nil)]//[.outlineDisclosure(options:headerDisclosureOption)
            
//            cell.callback = {
//                self.callbackDelegate?.callbackReceived(cell.item.topic as Any)
//            }
        }
        
//        let footerRegistration = UICollectionView.SupplementaryRegistration
//        <SeparatorCell>(elementKind: UICollectionView.elementKindSectionFooter) {
//            [unowned self] (footerView, elementKind, indexPath) in
//            
////            let headerItem = self.source.snapshot().sectionIdentifiers[indexPath.section]
////            let symbolCount = headerItem.topics.count
////
////            // Configure footer view content
////            var configuration = footerView.defaultContentConfiguration()
////            configuration.text = "Topics count: \(symbolCount)"
////            footerView.contentConfiguration = configuration
////            footerView
//        }

        let headerCellRegistration = UICollectionView.CellRegistration<TopicCellHeader, TopicHeaderItem> {
            (cell, indexPath, headerItem) in
            
            cell.item = headerItem
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .clear
            cell.backgroundConfiguration = backgroundConfig
            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption) {
                var currentSectionSnapshot = self.source.snapshot(for: headerItem)
                if currentSectionSnapshot.items.filter({ currentSectionSnapshot.isExpanded($0) }).isEmpty {
//                    self.scrollToItem(at: indexPath, at: .top, animated: true)
                    currentSectionSnapshot.expand(currentSectionSnapshot.items)
                } else {
                    currentSectionSnapshot.collapse(currentSectionSnapshot.items)
                }
                self.source.apply(currentSectionSnapshot, to: headerItem, animatingDifferences: true)
            }]
        }
        
        source = UICollectionViewDiffableDataSource<TopicHeaderItem, TopicListItem>(collectionView: self) {
            (collectionView, indexPath, listItem) -> UICollectionViewCell? in
            
            switch listItem {
            case .header(let headerItem):
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration,
                                                                        for: indexPath,
                                                                        item: headerItem)
                cell.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : headerItem.topic.tagColor
                return cell
            
            case .topic(let symbolItem):
                let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                        for: indexPath,
                                                                        item: symbolItem)
                return cell
            }
        }
        
//        source.supplementaryViewProvider = { [unowned self]
//            (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
//
//            if elementKind == UICollectionView.elementKindSectionFooter {
//                return dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
//            }
//            return nil
//        }
        
        for headerItem in modelObjects {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<TopicListItem>()
            
            let headerListItem = TopicListItem.header(headerItem)
            sectionSnapshot.append([headerListItem])
            
            let topicListItemArray = headerItem.topics.map { TopicListItem.topic($0) }
            sectionSnapshot.append(topicListItemArray, to: headerListItem)
            
            sectionSnapshot.collapse([headerListItem])
            source.apply(sectionSnapshot, to: headerItem, animatingDifferences: false)
        }
    }
    
    private func setObservers() {
//        if #available(iOS 15, *) {
//
//            //Update survey stats every n seconds
//            let events = EventEmitter().emit(every: 5)
//            notifications.append(Task { [weak self] in
//                for await _ in events {
//                    guard let self = self,
//                          let cells = visibleCells.filter({ $0.isKind(of: SurveyCell.self) }) as? [SurveyCell] else { return }
//                    self.callbackDelegate?.callbackReceived(cells.compactMap({ $0.item }))
//                }
//            })
//
//            //Survey claimed by user
//            notifications.append(Task { [weak self] in
//                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Claim) {
//                    guard let self = self,
//                          let instance = notification.object as? SurveyReference,
//                          self.source.snapshot().itemIdentifiers.contains(instance)
//                    else { return }
//
//                    var snap = self.source.snapshot()
//                    snap.deleteItems([instance])
//                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
//                }
//            })
//
//            //Survey banned on server
//            notifications.append(Task { [weak self] in
//                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Ban) {
//                    guard let self = self,
//                          let instance = notification.object as? SurveyReference,
//                          self.source.snapshot().itemIdentifiers.contains(instance)
//                    else { return }
//
//                    var snap = self.source.snapshot()
//                    snap.deleteItems([instance])
//                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
//                }
//            })
//
//
//            //Subscriptions added
//            notifications.append(Task { [weak self] in
//                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SubscriptionAppend) {
//                    guard let self = self,
//                          self.category == .Subscriptions,
//                          let instance = notification.object as? SurveyReference,
//                          !self.source.snapshot().itemIdentifiers.contains(instance)
//                    else { return }
//
//                    var snap = self.source.snapshot()
//                    snap.appendItems([instance], toSection: .main)
//                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
//                }
//            })
//
//            //New added
//            notifications.append(Task { [weak self] in
//                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.NewAppend) {
//                    guard let self = self,
//                          self.category == .New,
//                          let instance = notification.object as? SurveyReference,
//                          !self.source.snapshot().itemIdentifiers.contains(instance)
//                    else { return }
//
//                    var snap = self.source.snapshot()
//                    snap.appendItems([instance], toSection: .main)
//                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
//                }
//            })
//
//            //Top added
//            notifications.append(Task { [weak self] in
//                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.TopAppend) {
//                    guard let self = self,
//                          self.category == .Top,
//                          let instance = notification.object as? SurveyReference,
//                          !self.source.snapshot().itemIdentifiers.contains(instance)
//                    else { return }
//
//                    var snap = self.source.snapshot()
//                    snap.appendItems([instance], toSection: .main)
//                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
//                }
//            })
//
//            //Own added
//            notifications.append(Task { [weak self] in
//                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.OwnAppend) {
//                    guard let self = self,
//                          self.category == .Own,
//                          let instance = notification.object as? SurveyReference,
//                          !self.source.snapshot().itemIdentifiers.contains(instance)
//                    else { return }
//
//                    var snap = self.source.snapshot()
//                    snap.appendItems([instance], toSection: .main)
//                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
//                }
//            })
//
//            //Favorite added
//            notifications.append(Task { [weak self] in
//                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.FavoriteAppend) {
//                    guard let self = self,
//                          self.category == .Favorite,
//                          let instance = notification.object as? SurveyReference,
//                          !self.source.snapshot().itemIdentifiers.contains(instance)
//                    else { return }
//
//                    var snap = self.source.snapshot()
//                    snap.appendItems([instance], toSection: .main)
//                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
//                }
//            })
//
//        } else {
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.appendItemIdentifier(notification:)),
//                                                   name: Notifications.Surveys.SubscriptionAppend,
//                                                   object: self)
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.appendItemIdentifier(notification:)),
//                                                   name: Notifications.Surveys.Claim,
//                                                   object: self)
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.appendItemIdentifier(notification:)),
//                                                   name: Notifications.Surveys.Ban,
//                                                   object: self)
//        }
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        refreshControl?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
//        collectionView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
}

extension TopicsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TopicCell,
              let item = cell.item
        else { return }
        
        callbackDelegate?.callbackReceived(item.topic)
    }
}
