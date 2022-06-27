//
//  ImagesSelectionCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

//@available(iOS 14, *)
//struct ImageHeaderItem: Hashable {
//    var count: Int
//    var color: UIColor
//    var collectionView: ImageSelectionCollectionView
//}
//
//@available(iOS 14, *)
//enum ImageListItem: Hashable {
//    case headerItem(ImageHeaderItem)
//    case imageItem(ImageItem)
//}

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
        listener?.deleteImage(item)
    }
    
    private func commonInit() {
        isScrollEnabled = false
        bounces = false
//        observers.append(observe(\ImageSelectionCollectionView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
//            guard let self = self else { return }
//            self.callbackDelegate?.callbackReceived(["imagesHeight": change.newValue?.height])
//        })

//        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//        layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//
//        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
//            self.layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//            self.layoutConfig.headerMode = .firstItemInSection
//            self.layoutConfig.backgroundColor = .clear
//            self.layoutConfig.showsSeparators = false
//            self.layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
//                guard let self = self else { return UISwipeActionsConfiguration(actions: []) }
//                guard let item = self.source.itemIdentifier(for: indexPath) else {
//                    return nil
//                }
//
//                let action = UIContextualAction(style: .destructive, title: "delete".localized) { [weak self] (action, view, completion) in
//                    guard let self = self else { return }
////                    self.handleSwipe(for: action, item: item)
////                    var snap = self.source.snapshot()
////                    if let indent = self.source.itemIdentifier(for: indexPath) {
////                        snap.deleteItems([indent])
////                        snap.reloadSections([.main])
////                    }
////                    self.source.apply(snap)
////                    completion(true)
//                }
//                action.backgroundColor = .systemRed
//                action.image = UIImage(systemName: "trash.fill")?.withTintColor(.white)
//
//                return UISwipeActionsConfiguration(actions: [action])
//            }
//            return NSCollectionLayoutSection.list(using: self.layoutConfig, layoutEnvironment: env)
//        }
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.backgroundColor = .clear
        layoutConfig.showsSeparators = false
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
            guard let self = self else { return UISwipeActionsConfiguration(actions: []) }
            guard let item = self.source.itemIdentifier(for: indexPath) else {
                return nil
            }
            
            let action = UIContextualAction(style: .destructive, title: "delete".localized) { [weak self] (action, view, completion) in
                guard let self = self else { return }
                self.handleSwipe(for: action, item: item)
                var snap = self.source.snapshot()
                if let indent = self.source.itemIdentifier(for: indexPath) {
                    snap.deleteItems([indent])
                    self.listener?.deleteImage(indent)
                }
                self.source.apply(snap, animatingDifferences: true, completion: {
                    self.listener?.onImagesHeightChange(self.contentSize.height)
                    self.reload()
                })
                completion(true)
            }
            action.backgroundColor = .systemRed
            action.image = UIImage(systemName: "trash.fill")?.withTintColor(.white)

            return UISwipeActionsConfiguration(actions: [action])
        }
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        collectionViewLayout = listLayout//createLayout()//
        delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<ImageSelectionCell, ImageItem> { (cell, indexPath, item) in
            cell.item = item
            cell.automaticallyUpdatesBackgroundConfiguration = false
            var bgConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            bgConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            cell.backgroundConfiguration = bgConfig
//            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//            backgroundConfig.backgroundColor = .lightGray.withAlphaComponent(0.1)
//            cell.backgroundConfiguration = backgroundConfig
        }
        
        source = UICollectionViewDiffableDataSource<Section, ImageItem>(collectionView: self) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: ImageItem) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
//            cell.item = identifier
//            cell.index = indexPath.row + 1
            return cell
        }
        
        reload()
    }
    
    func reload() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ImageItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)
        snapshot.reloadItems(dataItems)
        source.apply(snapshot, animatingDifferences: false)
        source.refresh() {
            self.listener?.onImagesHeightChange(self.contentSize.height)
        }
    }
    
    func append(_: ImageItem) {
        source.refresh()
    }

    func delete(_ item: ImageItem) {
//        var snap = self.source.snapshot()
//        guard let existing = snap.itemIdentifiers.filter({ $0.id == item.id }).first else { return }
//        snap.deleteItems([existing])
//        snap.reloadSections([.main])
//        source.apply(snap, animatingDifferences: true)
    }
    
    weak var callbackDelegate: CallbackObservable?
    weak var listener: ImageSelectionListener?
    var dataItems: [ImageItem] {
        guard !listener.isNil else { return [] }
        return listener!.imageItems
    }
    var source: UICollectionViewDiffableDataSource<Section, ImageItem>!
//    @objc dynamic var color: UIColor = .systemGreen
    var color: UIColor = .systemGreen {
        didSet {
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
        listener?.editImage(cell.item)
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var config = UIBackgroundConfiguration.listGroupedHeaderFooter()
        config.backgroundColor = self.traitCollection.userInterfaceStyle != .dark ? .secondarySystemBackground : .tertiarySystemBackground
        backgroundConfiguration = config
    }
    
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

//@available(iOS 14.0, *)
//class ImageSelectionHeader: UICollectionViewListCell {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    var item: ImageHeaderItem!
//    var collectionView: ImageSelectionCollectionView!
////    var callback: Closure!
//
//    override func updateConfiguration(using state: UICellConfigurationState) {
//        backgroundColor = .clear
//        var newConfiguration = ImageSelectionHeaderConfiguration().updated(for: state)
//        newConfiguration.count = item.count
//        newConfiguration.color = item.color
//        newConfiguration.collectionView = collectionView
//
//        contentConfiguration = newConfiguration
//    }
//}
//
//@available(iOS 14.0, *)
//struct ImageSelectionHeaderConfiguration: UIContentConfiguration, Hashable {
//
//    var count: Int!
//    var color: UIColor!
//    var collectionView: ImageSelectionCollectionView!
//
//    func makeContentView() -> UIView & UIContentView {
//        return ImageSelectionHeaderContent(configuration: self)
//    }
//
//    func updated(for state: UIConfigurationState) -> Self {
//        guard state is UICellConfigurationState else {
//                return self
//            }
//        let updatedConfiguration = self
//        return updatedConfiguration
//    }
//}

