//
//  TopicSelectionModern.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14, *)
class TopicSelectionModernCollectionView: UICollectionView {
    
    enum Section {
        case main
    }
    
    let modelObjects: [TopicHeaderItem] = {
        Topics.shared.all.filter({ $0.isParentNode }).map { topic in
            return TopicHeaderItem(topic: topic)
        }
    }()

    init(callbackDelegate: CallbackObservable) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.callbackDelegate = callbackDelegate
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.headerMode = .firstItemInSection
        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionViewLayout = listLayout
        delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TopicItem> {
            (cell, indexPath, item) in
            
            // Set symbolItem's data to cell
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
        }
        
//        let cellRegistration = UICollectionView.CellRegistration<TopicSelectionModernCell, TopicItem> { (cell, indexPath, item) in
//            cell.topic = item
//        }
        let headerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TopicHeaderItem> {
            (cell, indexPath, headerItem) in
            
            // Set headerItem's data to cell
            var content = cell.defaultContentConfiguration()
            content.text = headerItem.title
            cell.contentConfiguration = content
            
            // Add outline disclosure accessory
            // With this accessory, the header cell's children will expand / collapse when the header cell is tapped.
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption)]
        }
        
        source = UICollectionViewDiffableDataSource<TopicHeaderItem, TopicListItem>(collectionView: self) {
            (collectionView, indexPath, listItem) -> UICollectionViewCell? in
            
            switch listItem {
            case .header(let headerItem):
            
                // Dequeue header cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration,
                                                                        for: indexPath,
                                                                        item: headerItem)
                return cell
            
            case .topic(let symbolItem):
                
                // Dequeue symbol cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                        for: indexPath,
                                                                        item: symbolItem)
                return cell
            }
        }
//        let headerCellRegistration = UICollectionView.CellRegistration <TopicSelectionModernCell, TopicHeaderItem> { [weak self] (headerView, indexPath, topic) in
//            guard let self = self else { return }
//
//            headerView.configuration = TopicSelectionModernCellConfiguration(topic: topic.topic)
//        }

        
        
//        source = UICollectionViewDiffableDataSource<TopicHeaderItem, TopicItem>(collectionView: self) {
//            (collectionView: UICollectionView, indexPath: IndexPath, identifier: TopicItem) -> TopicSelectionModernCell? in
//
//            // Dequeue reusable cell using cell registration (Reuse identifier no longer needed)
//            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            return cell
//        }
        
        var snapshot = NSDiffableDataSourceSnapshot<TopicHeaderItem, TopicListItem>()
        snapshot.appendSections(modelObjects)
        source.apply(snapshot)
        
        // Loop through each header item so that we can create a section snapshot for each respective header item.
        for headerItem in modelObjects {
            
            // Create a section snapshot
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<TopicListItem>()
            
            // Create a header ListItem & append as parent
            let headerListItem = TopicListItem.header(headerItem)
            sectionSnapshot.append([headerListItem])
            
            // Create an array of symbol ListItem & append as child of headerListItem
            let symbolListItemArray = headerItem.topics.map { TopicListItem.topic($0) }
            sectionSnapshot.append(symbolListItemArray, to: headerListItem)
            
            // Expand this section by default
            sectionSnapshot.expand([headerListItem])
            
            // Apply section snapshot to the respective collection view section
            source.apply(sectionSnapshot, to: headerItem, animatingDifferences: false)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var callbackDelegate: CallbackObservable?
    var source: UICollectionViewDiffableDataSource<TopicHeaderItem, TopicListItem>!
}

@available(iOS 14, *)
extension TopicSelectionModernCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

@available(iOS 14.0, *)
class TopicSelectionModernCell: UICollectionViewListCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var currentConfiguration: TopicSelectionModernCellConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? TopicSelectionModernCellConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    
    func apply(configuration: TopicSelectionModernCellConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
    }
    
    var topic: Topic!
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundColor = .clear
        var newConfiguration = TopicSelectionModernCellConfiguration().updated(for: state)
        newConfiguration.topic = topic
        
        contentConfiguration = newConfiguration
    }
}

@available(iOS 14.0, *)
struct TopicSelectionModernCellConfiguration: UIContentConfiguration, Hashable {

    var topic: Topic!
    
    func makeContentView() -> UIView & UIContentView {
        return TopicSelectionModernContent(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard state is UICellConfigurationState else {
                return self
            }
        let updatedConfiguration = self
        return updatedConfiguration
    }
}

///Model
enum TopicListItem: Hashable {
    case header(TopicHeaderItem)
    case topic(TopicItem)
}

struct TopicHeaderItem: Hashable {
    let title: String
    let topic: Topic
    let topics: [TopicItem]
    
    init(topic: Topic) {
        self.topic = topic
        self.title = topic.title
        self.topics = topic.children.map {
            return TopicItem(topic: $0)
        }
    }
}

struct TopicItem: Hashable {
    let title: String
    let topic: Topic
    
    init(topic: Topic) {
        self.topic = topic
        self.title = topic.title
    }
}
