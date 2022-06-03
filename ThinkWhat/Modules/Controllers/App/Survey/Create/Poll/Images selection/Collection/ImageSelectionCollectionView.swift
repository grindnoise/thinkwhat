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
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        layoutConfig = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        layoutConfig.headerMode = .supplementary
        layoutConfig.showsSeparators = false
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
            guard let self = self else { return UISwipeActionsConfiguration(actions: []) }
            // 1
            guard let item = self.source.itemIdentifier(for: indexPath) else {
                return nil
            }
            
            // 2
            // Create action 1
            let action = UIContextualAction(style: .destructive, title: "delete".localized) { [weak self] (action, view, completion) in
                guard let self = self else { return }
                self.handleSwipe(for: action, item: item)
                var snap = self.source.snapshot()
                if let indent = self.source.itemIdentifier(for: indexPath) {
                    snap.deleteItems([indent])
                    snap.reloadSections([.main])
                }
                self.source.apply(snap)
                completion(true)
            }
            action.backgroundColor = .systemRed
            action.image = UIImage(systemName: "trash.fill")?.withTintColor(.white)
            
            return UISwipeActionsConfiguration(actions: [action])
        }
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        // Create collection view with list layout
        collectionViewLayout = listLayout
        delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<ImageSelectionCell, ImageItem> { (cell, indexPath, item) in
            cell.item = item
//            cell.selectedCallback = { [weak self] in
//                guard let self = self else { return }
//                self.listener.editImage(cell.item)
//            }
        }
        
        headerRegistration = UICollectionView.SupplementaryRegistration
        <ImageSelectionHeader>(elementKind: UICollectionView.elementKindSectionHeader) {
            [weak self] (headerView, elementKind, indexPath) in guard let self = self else { return }

//            let totalCount = self.source.snapshot().itemIdentifiers.count
            
//            headerView.titleLabel.text = "Count: \(self.dataItems.count)"
            headerView.color = self.color
            self.observers.append(self.observe(self.colorKeyPath, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<UIColor>) in guard let self = self else { return }
                headerView.color = self.color
            })
//            self.observers.append(self.observe(self.colorKeyPath, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<UIColor>) in guard let self = self else { return }
//                headerView.color = self.color
//            })
                        
            headerView.addButtonTapCallback = { [weak self] in
                guard let self = self else { return }
                self.listener.addImage()
            }
            headerView.configuration = ImageSelectionHeaderConfiguration(count: self.dataItems.count)
        }
        
        source = UICollectionViewDiffableDataSource<Section, ImageItem>(collectionView: self) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: ImageItem) -> ImageSelectionCell? in
            
            // Dequeue reusable cell using cell registration (Reuse identifier no longer needed)
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            return cell
        }
        
        // MARK: Define supplementary view provider
        source.supplementaryViewProvider = { [unowned self]
            (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            
            return self.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: indexPath)
        }
//        // Create a snapshot that define the current state of data source's data
//        snapshot = NSDiffableDataSourceSnapshot<Section, ImageItem>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(dataItems, toSection: .main)
//
//        // Display data in the collection view by applying the snapshot to data source
//        source.apply(snapshot, animatingDifferences: false)
        reload()
    }
    
    func reload() {
        snapshot = NSDiffableDataSourceSnapshot<Section, ImageItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)
//        snapshot.reloadSections([.main])
        source.apply(snapshot, animatingDifferences: true)
    }
    
    func append(_ item: ImageItem) {
        var snapshot = source.snapshot()
        guard !snapshot.itemIdentifiers.contains(item) else { return }
        snapshot.appendItems([item], toSection: .main)
        snapshot.reloadSections([.main])
        source.apply(snapshot, animatingDifferences: true)
    }
    
    func delete(_ item: ImageItem) {
        var snap = self.source.snapshot()
        guard let existing = snap.itemIdentifiers.filter({ $0.id == item.id }).first else { return }
        snap.deleteItems([existing])
        snap.reloadSections([.main])
        source.apply(snap, animatingDifferences: true)
    }
    
    weak var callbackDelegate: CallbackObservable?
//    var dataItems: [ImageItem] = [
//        ImageItem(title: "One", image: UIImage(systemName: "mic.fill")!),
//        ImageItem(title: "Two", image: UIImage(systemName: "sunset.fill")!),
//        ImageItem(title: "Three", image: UIImage(systemName: "message.fill")!)
//    ]
    var listener: ImageSelectionListener!
    var dataItems: [ImageItem] {
        return listener.imageItems
    }
    var source: UICollectionViewDiffableDataSource<Section, ImageItem>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, ImageItem>!
    private var layoutConfig: UICollectionLayoutListConfiguration!
    @objc dynamic var color: UIColor = .systemGreen
    private let colorKeyPath = \ImageSelectionCollectionView.color
    private var observers: [NSKeyValueObservation] = []
    private var headerRegistration: UICollectionView.SupplementaryRegistration
    <ImageSelectionHeader>!
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
        backgroundColor = .clear
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

