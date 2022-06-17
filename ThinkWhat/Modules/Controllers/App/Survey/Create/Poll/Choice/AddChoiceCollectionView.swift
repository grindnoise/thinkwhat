//
//  AddChoiceCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class AddChoiceCollectionView: UICollectionView {
    
    enum Section {
        case main
    }
    
    //    override var contentSize: CGSize {
    //        didSet {
    //            guard oldValue.height != contentSize.height else { return }
    //            listener.test(contentSize.height)
    //        }
    //    }
    //    override var frame: CGRect {
    //        didSet {
    //            print(frame.height)
    //        }
    //    }
    var dataItems: [ChoiceItem] {
        return listener.choiceItems
    }
    weak var callbackDelegate: CallbackObservable?
    var listener: ChoiceListener!
    @objc dynamic var color: UIColor = .label
//        didSet {
////            guard !oldValue.isNil else { return }
////            reload()
//        }
//    }
    var source: UICollectionViewDiffableDataSource<Section, ChoiceItem>!
    private var observers: [NSKeyValueObservation] = []
    private let colorKeyPath = \AddChoiceCollectionView.color
    private let padding: CGFloat = 12
    
    init(dataProvider: ChoiceListener, callbackDelegate: CallbackObservable, color: UIColor) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.listener = dataProvider
        self.callbackDelegate = callbackDelegate
        self.color = color
        commonInit()
        //        setObservers()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
        //        setObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handleSwipe(for action: UIContextualAction, item: ChoiceItem) {
        listener.deleteChoice(item)
    }
    
    private func commonInit() {
        isScrollEnabled = false
        bounces = false
        register(AddChoiceCell.self, forCellWithReuseIdentifier: String(describing: AddChoiceCell.self))
        // Create list layout
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
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
                    self.listener.deleteChoice(indent)
//                    snap.reloadItems(snap.itemIdentifiers)
                }
//                snap.reloadItems(snap.itemIdentifiers)
                self.source.apply(snap, animatingDifferences: true, completion: {
                    self.listener.onChoicesHeightChange(self.contentSize.height)
//                    snap.reloadItems(snap.itemIdentifiers)
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
        let cellRegistration = UICollectionView.CellRegistration<AddChoiceCell, ChoiceItem> { (cell, indexPath, item) in
            cell.item = item
//            cell.index = indexPath.row + 1
            cell.color = self.color
            cell.collectionView = self
            self.observers.append(self.observe(self.colorKeyPath, options: [.new], changeHandler: { [weak self] (color, change) in
                guard let self = self,
                      let newColor = change.newValue else { return }
                cell.color = newColor
            }))
        }

        delegate = self
        source = UICollectionViewDiffableDataSource<Section, ChoiceItem>(collectionView: self) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: ChoiceItem) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
//            cell.item = identifier
            cell.index = indexPath.row + 1
            return cell
        }
        
        reload()
//        var snapshot = NSDiffableDataSourceSnapshot<Section, ChoiceItem>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(dataItems, toSection: .main)
//        source.apply(snapshot, animatingDifferences: false)
//        source.refresh() { self.listener.onChoicesHeightChange(self.contentSize.height) }
    }
    
    private func setObservers() {
        observers.append(self.observe(\AddChoiceCollectionView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let value = change.newValue,
            let constraint = self.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
            UIView.animate(withDuration: 0.3) {
                self.setNeedsLayout()
                constraint.constant = value.height
                self.layoutIfNeeded()
            }
        })
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // The item and group will share this size to allow for automatic sizing of the cell's height
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .estimated(50))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: padding, leading: padding, bottom: padding, trailing: padding)
        
//        UICollectionViewCompositionalLayout.list(using: <#T##UICollectionLayoutListConfiguration#>)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout

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
    }
}

@available(iOS 14.0, *)
extension AddChoiceCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let dataSource = source else { return false }
        
        // Allows for closing an already open cell
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        
        dataSource.refresh() { self.listener.onChoicesHeightChange(self.contentSize.height) }
        
        return false // The selecting or deselecting is already performed above
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let cell = cellForItem(at: indexPath) as? AddChoiceCell else { return }
//    }
    
//    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
//        guard let cell = dequeueReusableCell(withReuseIdentifier: AddChoiceCell.self, for: indexPath) as? AddChoiceCell else { return UICollectionViewCell() }
//        cell.index = indexPath.row + 1
//    }
}

extension UICollectionViewDiffableDataSource {
    /// Reapplies the current snapshot to the data source, animating the differences.
    /// - Parameters:
    ///   - completion: A closure to be called on completion of reapplying the snapshot.
    func refresh(completion: (() -> Void)? = nil) {
        self.apply(self.snapshot(), animatingDifferences: true, completion: completion)
    }
}

@available(iOS 14.0, *)
extension AddChoiceCollectionView: ChoiceProvider {
    
    func reload() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ChoiceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)
        snapshot.reloadItems(dataItems)
        source.apply(snapshot, animatingDifferences: false)
        source.refresh() {
            self.listener.onChoicesHeightChange(self.contentSize.height)
        }
    }
    
    func append(_: ChoiceItem) {
        source.refresh()
    }
}

//@available(iOS 14.0, *)
//extension AddChoiceCollectionView: CallbackObservable {
//    func callbackReceived(_ sender: Any) {
//        if let choiceItem = sender as? ChoiceItem {
//            callbackDelegate?.callbackReceived(choiceItem)
//        }
//    }
//}
