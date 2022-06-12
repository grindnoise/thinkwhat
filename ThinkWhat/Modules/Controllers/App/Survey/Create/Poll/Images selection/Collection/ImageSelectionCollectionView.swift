//
//  ImagesSelectionCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

//@available(iOS 14, *)
struct ImageItem: Hashable {
    
    var title: String
    var image: UIImage
    var shouldBeDeleted = false
    let id: UUID = UUID()
    
    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
    }
}

@available(iOS 14, *)
struct ImageHeaderItem: Hashable {
    var count: Int
    var color: UIColor
    var collectionView: ImageSelectionCollectionView
}

@available(iOS 14, *)
enum ImageListItem: Hashable {
    case headerItem(ImageHeaderItem)
    case imageItem(ImageItem)
}

@available(iOS 14, *)
class ImageSelectionCollectionView: UICollectionView, ImageSelectionProvider {
    
    enum Section {
        case main
    }

    init(dataProvider: ImageSelectionListener, callbackDelegate: CallbackObservable, color: UIColor) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.listener = dataProvider
        self.callbackDelegate = callbackDelegate
        self.color = color
        commonInit()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handleSwipe(for action: UIContextualAction, item: ImageItem) {
        listener.deleteImage(item)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
    
    private func commonInit() {
        isScrollEnabled = false
        observers.append(observe(\ImageSelectionCollectionView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self else { return }
            self.callbackDelegate?.callbackReceived(["imagesHeight": change.newValue?.height])
        })
        
//        observers.append(observe(colorKeyPath, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<UIColor>) in
//            guard let self = self else { return }
//                    var snap = self.source.snapshot()
//
//                    snap.reloadSections([])
//        })
        
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            self.layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            self.layoutConfig.headerMode = .firstItemInSection
            self.layoutConfig.backgroundColor = .clear
            self.layoutConfig.showsSeparators = false
//            self.layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
//                guard let self = self else { return UISwipeActionsConfiguration(actions: []) }
//                guard let item = self.source.itemIdentifier(for: indexPath) else {
//                    return nil
//                }
//
//                let action = UIContextualAction(style: .destructive, title: "delete".localized) { [weak self] (action, view, completion) in
//                    guard let self = self else { return }
//                    self.handleSwipe(for: action, item: item)
//                    var snap = self.source.snapshot()
//                    if let indent = self.source.itemIdentifier(for: indexPath) {
//                        snap.deleteItems([indent])
//                        snap.reloadSections([.main])
//                    }
//                    self.source.apply(snap)
//                    completion(true)
//                }
//                action.backgroundColor = .systemRed
//                action.image = UIImage(systemName: "trash.fill")?.withTintColor(.white)
//
//                return UISwipeActionsConfiguration(actions: [action])
//            }
            return NSCollectionLayoutSection.list(using: self.layoutConfig, layoutEnvironment: env)
        }
        delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<ImageSelectionCell, ImageItem> { (cell, indexPath, item) in
            cell.item = item
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .lightGray.withAlphaComponent(0.1)
            cell.backgroundConfiguration = backgroundConfig
        }
        
//        let headerRegistration = UICollectionView.SupplementaryRegistration
//        <_ImageSelectionHeaderContent>(elementKind: UICollectionView.elementKindSectionHeader) {
//            [unowned self] (headerView, elementKind, indexPath) in
//
//            // Obtain header item using index path
//            let headerItem = self.source.snapshot().sectionIdentifiers[indexPath.section]
//
//            headerView.addButtonTapCallback = { [weak self] in
//                guard self = self else { return }
//                self?.callbackDelegate?.callbackReceived(<#T##sender: Any##Any#>)
//
//            }
//            headerView.titleLabel.text = headerItem.title
//            headerView.infoButtonDidTappedCallback = { [unowned self] in
//
//                // Show an alert when user tap on infoButton
//                let symbolCount = headerItem.symbols.count
//                let alert = UIAlertController(title: "Info", message: "This section has \(symbolCount) symbols.", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alert.addAction(okAction)
//
//                self.present(alert, animated: true)
//            }
//        }
        
//        let headerCellRegistration = UICollectionView.CellRegistration<ImageSelectionHeader, ImageHeaderItem> {
//            (cell, indexPath, headerItem) in
//            cell.item = headerItem
////            cell
////            print(cell.contentView as! ImageSelectionHeaderContent)
//            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//            backgroundConfig.backgroundColor = .red
//            cell.backgroundConfiguration = backgroundConfig
//        }
        
        let headerCellRegistration = UICollectionView.CellRegistration<ImageSelectionHeader, ImageHeaderItem> {
            (cell, indexPath, headerItem) in
            cell.item = headerItem
            cell.collectionView = self
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .red
            cell.backgroundConfiguration = backgroundConfig
        }
        
        source = UICollectionViewDiffableDataSource<ImageHeaderItem, ImageListItem>(collectionView: self) {
            (collectionView, indexPath, listItem) -> UICollectionViewCell? in
            
            switch listItem {
            case .headerItem(let headerItem):
            
                // Dequeue header cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration,
                                                                        for: indexPath,
                                                                        item: headerItem)
                return cell
            
            case .imageItem(let item):
                
                // Dequeue symbol cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                        for: indexPath,
                                                                        item: item)
                return cell
            }
        }
        let headerItem = ImageHeaderItem(count: dataItems.count, color: color, collectionView: self)
//        var snapshot = NSDiffableDataSourceSnapshot<ImageHeaderItem, ImageListItem>()
//        snapshot.appendSections([headerItem])
//        source.apply(snapshot)
        
        
////        let headerItem = ImageHeaderItem(count: 0)
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ImageListItem>()
        let headerListItem = ImageListItem.headerItem(headerItem)
        sectionSnapshot.append([headerListItem])

        let imageListItemArray = dataItems.map({ ImageListItem.imageItem($0) })
        sectionSnapshot.append(imageListItemArray, to: headerListItem)

        sectionSnapshot.expand([headerListItem])
        source.apply(sectionSnapshot, to: headerItem, animatingDifferences: false)
    }
    
    func reload() {
        var snapshot = source.snapshot()
        snapshot.deleteSections(snapshot.sectionIdentifiers)
        source.apply(snapshot)
        let headerItem = ImageHeaderItem(count: dataItems.count, color: color, collectionView: self)
//        var snapshot = NSDiffableDataSourceSnapshot<ImageHeaderItem, ImageListItem>()
//        snapshot.appendSections([headerItem])
//        source.apply(snapshot)
        
        
////        let headerItem = ImageHeaderItem(count: 0)
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ImageListItem>()
        let headerListItem = ImageListItem.headerItem(headerItem)
        sectionSnapshot.append([headerListItem])

        let imageListItemArray = dataItems.map({ ImageListItem.imageItem($0) })
        sectionSnapshot.append(imageListItemArray, to: headerListItem)

        sectionSnapshot.expand([headerListItem])
        source.apply(sectionSnapshot, to: headerItem, animatingDifferences: false)
    }
    
    func append(_ item: ImageItem) {
        var snapshot = source.snapshot()
//        snapshot.reloadSections([snapshot.sectionIdentifiers.first])
//        var snapshot = source.snapshot()
//        guard !snapshot.itemIdentifiers.contains(item) else { return }
//        snapshot.appendItems([item], toSection: .main)
//        snapshot.reloadSections([.main])
//        source.apply(snapshot, animatingDifferences: true)
    }
    
    func delete(_ item: ImageItem) {
//        var snap = self.source.snapshot()
//        guard let existing = snap.itemIdentifiers.filter({ $0.id == item.id }).first else { return }
//        snap.deleteItems([existing])
//        snap.reloadSections([.main])
//        source.apply(snap, animatingDifferences: true)
    }
    
    weak var callbackDelegate: CallbackObservable?
    var listener: ImageSelectionListener!
    var dataItems: [ImageItem] {
        return listener.imageItems
    }
    var source: UICollectionViewDiffableDataSource<ImageHeaderItem, ImageListItem>!
    private var layoutConfig: UICollectionLayoutListConfiguration!
//    @objc dynamic var color: UIColor = .systemGreen
    var color: UIColor = .systemGreen {
        didSet {
            print(color)
            reload()
        }
    }
//    private let colorKeyPath = \ImageSelectionCollectionView.color
    private var observers: [NSKeyValueObservation] = []
}

@available(iOS 14, *)
extension ImageSelectionCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageSelectionCell else { return }
        listener.editImage(cell.item)
    }
}

@available(iOS 14.0, *)
class ImageSelectionCell: UICollectionViewListCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: ImageItem!
//    var selectedCallback: Closure?
//
//    override var isSelected: Bool {
//        didSet {
//            guard !selectedCallback.isNil else { return }
//            selectedCallback!()
//        }
//    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        automaticallyUpdatesBackgroundConfiguration = false
        var newConfiguration = ImageSelectionCellConfiguration().updated(for: state)
        newConfiguration.title = item.title
        newConfiguration.image = item.image
        
        contentConfiguration = newConfiguration
    }
}

@available(iOS 14.0, *)
struct ImageSelectionCellConfiguration: UIContentConfiguration, Hashable {

    var title: String!
    var image: UIImage?
    
    func makeContentView() -> UIView & UIContentView {
        return ImageSelectionCellContent(configuration: self)
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
class ImageSelectionHeader: UICollectionViewListCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: ImageHeaderItem!
    var collectionView: ImageSelectionCollectionView!
//    var callback: Closure!
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundColor = .clear
        var newConfiguration = ImageSelectionHeaderConfiguration().updated(for: state)
        newConfiguration.count = item.count
        newConfiguration.color = item.color
        newConfiguration.collectionView = collectionView
        
        contentConfiguration = newConfiguration
    }
}

@available(iOS 14.0, *)
struct ImageSelectionHeaderConfiguration: UIContentConfiguration, Hashable {

    var count: Int!
    var color: UIColor!
    var collectionView: ImageSelectionCollectionView!
    
    func makeContentView() -> UIView & UIContentView {
        return ImageSelectionHeaderContent(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard state is UICellConfigurationState else {
                return self
            }
        let updatedConfiguration = self
        return updatedConfiguration
    }
}

