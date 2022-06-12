//
//  ChoiceCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

struct ChoiceItem: Hashable {
    var text: String
}
//
//@available(iOS 14, *)
//struct ChoiceHeaderItem: Hashable {
//    var count: Int
//    var color: UIColor
//    var collectionView: ImageSelectionCollectionView
//}
//
//@available(iOS 14, *)
//enum ChoiceListItem: Hashable {
//    case headerItem(ChoiceHeaderItem)
//    case imageItem(ChoiceItem)
//}

@available(iOS 14, *)
class ChoiceCollectionView: UICollectionView, ChoiceProvider {
    
    enum Section {
        case main
    }

    init(dataProvider: ChoiceListener, callbackDelegate: CallbackObservable, color: UIColor) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.listener = dataProvider
        self.callbackDelegate = callbackDelegate
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
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
    
    private func commonInit() {
        isScrollEnabled = false
        observers.append(observe(\ChoiceCollectionView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
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
        layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
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
        
        let cellRegistration = UICollectionView.CellRegistration<ChoiceSelectionCell, ChoiceItem> { (cell, indexPath, item) in
            cell.item = item
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .lightGray.withAlphaComponent(0.1)
            cell.backgroundConfiguration = backgroundConfig
        }
                
        source = UICollectionViewDiffableDataSource<Section, ChoiceItem>(collectionView: self) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: item)
            return cell
        }
        
    }
    
    func reload() {
        
    }
    
    func append(_ item: ChoiceItem) {
        
    }
    
    weak var callbackDelegate: CallbackObservable?
    var listener: ChoiceListener!
    var dataItems: [ChoiceItem] {
        return listener.choiceItems
    }
    var source: UICollectionViewDiffableDataSource<Section, ChoiceItem>!
    private var layoutConfig: UICollectionLayoutListConfiguration!
    private var observers: [NSKeyValueObservation] = []
}

@available(iOS 14.0, *)
class ChoiceSelectionCell: UICollectionViewListCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: ChoiceItem!
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        automaticallyUpdatesBackgroundConfiguration = false
        var newConfiguration = ImageSelectionCellConfiguration().updated(for: state)
        
        contentConfiguration = newConfiguration
    }
}

@available(iOS 14.0, *)
struct ChoiceSelectionCellConfiguration: UIContentConfiguration, Hashable {

    var text: String!
    
    func makeContentView() -> UIView & UIContentView {
        return ChoiceSelectionCellContent(configuration: self)
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
//class ChoiceSelectionHeader: UICollectionViewListCell {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    var item: ChoiceHeaderItem!
//    var collectionView: ChoiceCollectionView!
////    var callback: Closure!
//
//    override func updateConfiguration(using state: UICellConfigurationState) {
//        backgroundColor = .clear
//        var newConfiguration = ChoiceSelectionHeaderConfiguration().updated(for: state)
//        newConfiguration.count = item.count
//        newConfiguration.color = item.color
//        newConfiguration.collectionView = collectionView
//
//        contentConfiguration = newConfiguration
//    }
//}
//
//@available(iOS 14.0, *)
//struct ChoiceSelectionHeaderConfiguration: UIContentConfiguration, Hashable {
//
//    var count: Int!
//    var color: UIColor!
//    var collectionView: ChoiceCollectionView!
//
//    func makeContentView() -> UIView & UIContentView {
//        return ChoiceSelectionHeaderContent(configuration: self)
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
