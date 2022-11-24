//
//  TopicsCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TopicsCollectionView: UICollectionView {
    
    // MARK: - Public properties
    public let touchSubject = CurrentValueSubject<[Topic: CGPoint]?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private var source: UICollectionViewDiffableDataSource<TopicHeaderItem, TopicListItem>!
    private let modelObjects: [TopicHeaderItem] = {
        Topics.shared.all.filter({ $0.isParentNode }).map { topic in
            return TopicHeaderItem(topic: topic)
        }
    }()
    
    
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
    
    // MARK: - Initialization
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
    // MARK: - Private
private extension TopicsCollectionView {
    @MainActor
    func setupUI() {
        collectionViewLayout = UICollectionViewCompositionalLayout { [unowned self] section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            layoutConfig.headerMode = .firstItemInSection
            layoutConfig.backgroundColor = .clear
            if #available(iOS 14.5, *) {
                layoutConfig.separatorConfiguration.color = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
            }
//            layoutConfig.showsSeparators = true
//            layoutConfig.footerMode = .supplementary
            
            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
//            sectionLayout.interGroupSpacing = 20
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            return sectionLayout
        }
        
        let cellRegistration = UICollectionView.CellRegistration<TopicCell, TopicItem> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            cell.item = item
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : item.topic.tagColor.withAlphaComponent(0.1)
            cell.backgroundConfiguration = backgroundConfig
            
            cell.touchSubject
                .sink { [weak self] in
                guard let self = self,
                    let key = $0.keys.first,
                    let value = $0.values.first
                else { return }
                
                self.touchSubject.send([key: cell.convert(value, to: self.superview!)])
            }
                .store(in: &self.subscriptions)
            
            let accessoryConfig = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: UIImage(systemName: "chevron.right")),
                                                                          placement: .trailing(displayed: .always, at: { _ in 0 }),
                                                                          isHidden: false,
                                                                          reservedLayoutWidth: nil,
                                                                          tintColor: item.topic.tagColor,
                                                                          maintainsFixedSize: true)
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
                cell.tintColor = headerItem.topic.tagColor
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
    
    // MARK: - Overriden methods
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        refreshControl?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
//        collectionView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//    }
}
