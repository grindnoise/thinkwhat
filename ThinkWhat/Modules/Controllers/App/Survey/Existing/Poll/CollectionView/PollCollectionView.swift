//
//  PollCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

//struct PollItem: Hashable {
//
//}

class PollCollectionView: UICollectionView {
    
    enum Section: Int {
        case title, description, image
        
        var localized: String {
            switch self {
            case .title:
                return "title".localized
            case .description:
                return "description".localized
            case .image:
                return "images".localized
            }
        }
    }
    
    // MARK: - Private properties
    private let poll: Survey
    private weak var callbackDelegate: CallbackObservable?
    private var source: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    
    // MARK: - Initialization
    init(poll: Survey, callbackDelegate: CallbackObservable) {
        self.poll = poll
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.callbackDelegate = callbackDelegate
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI functions
    private func setupUI() {
        delegate = self
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            layoutConfig.headerMode = .firstItemInSection
            layoutConfig.backgroundColor = .clear
            layoutConfig.showsSeparators = false
//            layoutConfig.headerMode = .supplementary
            
            return NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
        }
        
        let titleCellRegistration = UICollectionView.CellRegistration<PollTitleCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
        }
        
        let descriptionCellRegistration = UICollectionView.CellRegistration<PollDescriptionCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
        }
        
        let imageCellRegistration = UICollectionView.CellRegistration<PollImageCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
        }

//        let headerRegistration = UICollectionView.SupplementaryRegistration <UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, elementKind, indexPath in
//            
//            guard let section = Section.init(rawValue: indexPath.section) else { return }
//            
//            if section == .title {
//                headerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
//                return
//            }
//            
//            var configuration = headerView.defaultContentConfiguration()
//            configuration.text = "hide".localized
//            configuration.textProperties.font = UIFont(name: Fonts.Regular, size: 14)!
//            configuration.textProperties.color = .secondaryLabel
//            configuration.directionalLayoutMargins = .init(top: 20.0, leading: 0.0, bottom: 10.0, trailing: 0.0)
//            
//            headerView.contentConfiguration = configuration
//            headerView.accessories = [.outlineDisclosure(options: UICellAccessory.OutlineDisclosureOptions(style: .header)) {
//                var currentSectionSnapshot = self.source.snapshot(for: section)
//                if currentSectionSnapshot.items.filter { currentSectionSnapshot.isExpanded($0) }.isEmpty {
//                    currentSectionSnapshot.collapse(currentSectionSnapshot.items)
//                } else {
//                    currentSectionSnapshot.expand(currentSectionSnapshot.items)
//                }
//                self.source.apply(currentSectionSnapshot, to: section, animatingDifferences: true)
//            }]
//        }
        
        source = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: self) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: AnyHashable) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
            if section == .title {
                return collectionView.dequeueConfiguredReusableCell(using: titleCellRegistration,
                                                                        for: indexPath,
                                                                        item: identifier)
            } else if section == .description {
                return collectionView.dequeueConfiguredReusableCell(using: descriptionCellRegistration,
                                                                        for: indexPath,
                                                                        item: identifier)
            } else if section == .image {
                return collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration,
                                                                        for: indexPath,
                                                                        item: identifier)
            }
            return UICollectionViewCell()
        }
        
//        source.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
//            guard let self = self else { return nil }
//            return self.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
//        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.title, .description, .image])
        snapshot.appendItems([AnyHashable(0)], toSection: .title)
        snapshot.appendItems([AnyHashable(1)], toSection: .description)
        snapshot.appendItems([AnyHashable(2)], toSection: .image)
        source.apply(snapshot, animatingDifferences: false)
    }
}

extension PollCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let dataSource = source else { return false }
        
        // Allows for closing an already open cell
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        
        dataSource.refresh()
        
        return false // The selecting or deselecting is already performed above
    }
}
