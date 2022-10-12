//
//  LanguagesCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//


import UIKit
import Combine

struct LanguageItem: Hashable {
    let code: String
}

class LanguagesCollectionView: UICollectionView {
    
    enum Section {
        case Main
    }
    
    typealias Source = UICollectionViewDiffableDataSource<Section, LanguageItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, LanguageItem>
    
    
    
    // MARK: - Overridden properties
    
    
    
    // MARK: - Public properties
    public let contentLanguagePublisher = CurrentValueSubject<[LanguageItem: Bool]?, Never>(nil)
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private var source: UICollectionViewDiffableDataSource<Section, LanguageItem>!
    private var dataItems: [LanguageItem] = {
        return AppData.shared.locales.map { return LanguageItem(code: $0) }
    }()
    
    
    // MARK: - Deinitialization
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
        super.init(frame: .zero, collectionViewLayout: .init())
        
        setupUI()
        setTasks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Public methods
    
    
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let cells = visibleCells as? [UICollectionViewListCell] else { return }
        
        cells.forEach {
            $0.accessories = [UICellAccessory.checkmark(displayed: .always,
                                                          options: .init(isHidden: !$0.isSelected,
                                                                         tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED))]
        }
    }
}

private extension LanguagesCollectionView {
    
    func setupUI() {
        allowsMultipleSelection = true
        collectionViewLayout = UICollectionViewCompositionalLayout.list(using: {
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.showsSeparators = true
            configuration.backgroundColor = .clear
            if #available(iOS 14.5, *) {
                configuration.itemSeparatorHandler = { indexPath, config -> UIListSeparatorConfiguration in
                    var config = UIListSeparatorConfiguration(listAppearance: .plain)
                    config.color = .systemGray5
                    config.bottomSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1.2, trailing: 0)
                    config.bottomSeparatorVisibility = .visible
                    
                    return config
                }
            }
            
            return configuration
            }())
        
        let cellRegistration = UICollectionView.CellRegistration<LanguageCell, LanguageItem> { [unowned self] cell, indexPath, item in
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.backgroundColor = .clear
            
            cell.setting = [item: !UserDefaults.App.contentLanguages.filter({ $0 == item.code }).isEmpty]
            cell.backgroundConfiguration = backgroundConfig
            cell.automaticallyUpdatesBackgroundConfiguration = false
            cell.contentLanguagePublisher
                .sink {
                    guard let dict = $0 else { return }
                    
                    self.contentLanguagePublisher.send(dict)
                }
                .store(in: &subscriptions)
        }
        
//        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, LanguageItem> { [unowned self] (cell, indexPath, item) in
//            var contentConfig = cell.defaultContentConfiguration()
//            contentConfig.text = item.code
//            contentConfig.attributedText = NSAttributedString(string: item.code,
//                                                              attributes: [
//                                                                .foregroundColor: UIColor.label as Any,
//                                                                .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
//                                                              ])
//
//            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
//            backgroundConfig.backgroundColor = .clear
////
//            cell.contentConfiguration = contentConfig
//            cell.backgroundConfiguration = backgroundConfig
//            cell.automaticallyUpdatesBackgroundConfiguration = false
//            cell.automaticallyUpdatesContentConfiguration = false
//            cell.isSelected = UserDefaults.App.contentLanguages.filter({ $0 == item.code }).isEmpty
////            print(cell.isSelected)
//            cell.accessories = [UICellAccessory.checkmark(displayed: .always,
//                                                          options: .init(isHidden: cell.isSelected,
//                                                                         tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED))]
//        }
        
        source = UICollectionViewDiffableDataSource<Section, LanguageItem>(collectionView: self) { collectionView, indexPath, itemIdentifier -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: itemIdentifier)
            return cell
        }
        
        var snap = NSDiffableDataSourceSnapshot<Section, LanguageItem>()
        snap.appendSections([.Main])
        snap.appendItems(dataItems)
        source.apply(snap, animatingDifferences: false)
    }
    
    func setTasks() {
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
//                guard let self = self else { return }
//
//
//            }
//        })
    }
}

//extension LanguagesCollectionView: UICollectionViewDelegate {
////    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
////        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }
////
////        cell.isSelected = true//UserDefaults.App.contentLanguages.filter({ $0 == item.code }).isEmpty
////    }
//
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return true }
//
//        guard !cell.isSelected else {
//            collectionView.deselectItem(at: indexPath, animated: true)
//
//            return false
//        }
//        return true
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }
//
//        cell.accessories = [UICellAccessory.checkmark(displayed: .always,
//                                                      options: .init(isHidden: false,
//                                                                     tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED))]
//        print(dataItems[indexPath.row])
//    }
//
//    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        collectionView.deselectItem(at: indexPath, animated: true)
//
//        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return false }
//
//        cell.accessories = [UICellAccessory.checkmark(displayed: .always,
//                                                      options: .init(isHidden: true,
//                                                                     tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED))]
//        print(dataItems[indexPath.row])
//
//        return true
//    }
//}
