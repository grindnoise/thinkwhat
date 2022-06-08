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
        layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            self.layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            self.layoutConfig.headerMode = .firstItemInSection
            self.layoutConfig.backgroundColor = .clear
            self.layoutConfig.showsSeparators = false
            let section = NSCollectionLayoutSection.list(using: self.layoutConfig, layoutEnvironment: env)
//            section.decorationItems = [
//                NSCollectionLayoutDecorationItem.background(elementKind: RoundedBackgroundView.reuseIdentifier)
//            ]
            return section //NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: env)
        }
//        collectionViewLayout.register(RoundedBackgroundView.self, forDecorationViewOfKind: RoundedBackgroundView.reuseIdentifier)
        collectionViewLayout.collectionView?.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        allowsMultipleSelection = false
        
        let cellRegistration = UICollectionView.CellRegistration<TopicSelectionModernCell, TopicItem> { (cell, indexPath, item) in
            
            cell.item = item
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .lightGray.withAlphaComponent(0.1)
            //            backgroundConfig.backgroundColorTransformer = .grayscale
            cell.backgroundConfiguration = backgroundConfig
            cell.callback = { [weak self] in
                guard let self = self else { return }
                self.callbackDelegate?.callbackReceived(cell.item.topic as Any)
            }
        }

        let headerCellRegistration = UICollectionView.CellRegistration<TopicSelectionModernHeader, TopicHeaderItem> {
            (cell, indexPath, headerItem) in
            
            cell.item = headerItem
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .red
            cell.backgroundConfiguration = backgroundConfig
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
        
//        var snapshot = NSDiffableDataSourceSnapshot<TopicHeaderItem, TopicListItem>()
//        snapshot.appendSections(modelObjects)
//        source.apply(snapshot)

        // Loop through each header item so that we can create a section snapshot for each respective header item.
        for headerItem in modelObjects {
            
            // Create a section snapshot
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<TopicListItem>()
            
            // Create a header ListItem & append as parent
            let headerListItem = TopicListItem.header(headerItem)
            sectionSnapshot.append([headerListItem])
            
            // Create an array of symbol ListItem & append as child of headerListItem
            let topicListItemArray = headerItem.topics.map { TopicListItem.topic($0) }
            sectionSnapshot.append(topicListItemArray, to: headerListItem)
            
            // Expand this section by default
            sectionSnapshot.collapse([headerListItem])//.expand([headerListItem])
            
            // Apply section snapshot to the respective collection view section
            source.apply(sectionSnapshot, to: headerItem, animatingDifferences: false)
        }
//        isEditing = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white
        collectionViewLayout.collectionView?.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        collectionViewLayout.collectionView?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    weak var callbackDelegate: CallbackObservable?
    var source: UICollectionViewDiffableDataSource<TopicHeaderItem, TopicListItem>!
    private var layoutConfig: UICollectionLayoutListConfiguration!
}

@available(iOS 14.0, *)
class TopicSelectionModernCell: UICollectionViewListCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var item: TopicItem!
    
    var callback: Closure?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        automaticallyUpdatesBackgroundConfiguration = false
        
        
//        var modifiedState = state
//        modifiedState.isFocused = false
//        modifiedState.isHighlighted = false
//        modifiedState.isSelected = false
//        modifiedState.isEditing = true
        
//        var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//        backgroundConfig.backgroundColor = .lightGray.withAlphaComponent(0.1)
        
//        // Customize the background color to use the tint color when the cell is highlighted or selected.
//        if state.isSelected {
//            backgroundConfig.backgroundColor = .red
            accessories = state.isSelected ? [.checkmark()] : []
//        }
        
        if state.isSelected, !callback.isNil { callback!() }
    
//        backgroundConfiguration = backgroundConfig
        var newConfiguration = TopicSelectionModernCellConfiguration().updated(for: state)
        newConfiguration.topicItem = item
        
        contentConfiguration = newConfiguration
    }
}

@available(iOS 14.0, *)
class TopicSelectionModernHeader: UICollectionViewListCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var item: TopicHeaderItem!
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundColor = .clear
        var newConfiguration = TopicSelectionModernHeaderConfiguration().updated(for: state)
        newConfiguration.topicItem = item
        contentConfiguration = newConfiguration
    }
}

@available(iOS 14.0, *)
struct TopicSelectionModernCellConfiguration: UIContentConfiguration, Hashable {

    var topicItem: TopicItem!
    
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

@available(iOS 14.0, *)
struct TopicSelectionModernHeaderConfiguration: UIContentConfiguration, Hashable {

    var topicItem: TopicHeaderItem!
    
    func makeContentView() -> UIView & UIContentView {
        return TopicSelectionHeaderModernContent(configuration: self)
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

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

class RoundedBackgroundView: UICollectionReusableView {

    private var insetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemFill
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        addSubview(insetView)

        NSLayoutConstraint.activate([
            insetView.leadingAnchor.constraint(equalTo: leadingAnchor),//, constant: 15),
            trailingAnchor.constraint(equalTo: insetView.trailingAnchor),//, constant: 15),
            insetView.topAnchor.constraint(equalTo: topAnchor),
            insetView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
