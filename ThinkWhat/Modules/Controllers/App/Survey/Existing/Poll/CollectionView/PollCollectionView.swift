//
//  PollCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollCollectionView: UICollectionView {
    
    enum Section: Int {
        case title, description, image, youtube, web
        
        var localized: String {
            switch self {
            case .title:
                return "title".localized
            case .description:
                return "description".localized
            case .image:
                return "images".localized
            case .youtube:
                return "YouTube"
            case .web:
                return "web".localized
            }
        }
    }
    
    // MARK: - Private properties
    private let poll: Survey
    private weak var callbackDelegate: CallbackObservable?
    private var source: UICollectionViewDiffableDataSource<Section, Int>!
    private var imageCellRegistration: UICollectionView.CellRegistration<ImageCell, AnyHashable>!
    
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
    
    deinit {
        print("\(String(describing: type(of: self))).\(#function)")
    }
    
    // MARK: - UI functions
    private func setupUI() {
        delegate = self
//        allowsMultipleSelection = true
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
//            cell.collectionView = self
            cell.item = self.poll
        }
        
        imageCellRegistration = UICollectionView.CellRegistration<ImageCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.item.isNil else { return }
            cell.item = self.poll
            cell.callbackDelegate = self
        }
        
        let youtubeCellRegistration = UICollectionView.CellRegistration<YoutubeCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.url.isNil else { return }
            cell.url = self.poll.url
        }
        
        let webCellRegistration = UICollectionView.CellRegistration<WebViewCell, AnyHashable> { [weak self] cell, indexPath, item in
            guard let self = self, cell.url.isNil else { return }
            cell.url = self.poll.url
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
        
        source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { [unowned self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
            if section == .title {
                return collectionView.dequeueConfiguredReusableCell(using: titleCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .description {
                return collectionView.dequeueConfiguredReusableCell(using: descriptionCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .image {
                return collectionView.dequeueConfiguredReusableCell(using: self.imageCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .youtube {
                return collectionView.dequeueConfiguredReusableCell(using: youtubeCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .web {
                return collectionView.dequeueConfiguredReusableCell(using: webCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            }
            return UICollectionViewCell()
        }
        
//        source.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
//            guard let self = self else { return nil }
//            return self.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
//        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.title, .description,])
        snapshot.appendItems([0], toSection: .title)
        snapshot.appendItems([1], toSection: .description)
        if poll.imagesCount != 0 {
            snapshot.appendSections([.image])
            snapshot.appendItems([2], toSection: .image)
        }
        if let url = poll.url {
            if url.absoluteString.isYoutubeLink {
                snapshot.appendSections([.youtube])
                snapshot.appendItems([3], toSection: .youtube)
            } else if url.absoluteString.isTikTokLink {
                
            } else {
                snapshot.appendSections([.web])
                snapshot.appendItems([4], toSection: .web)
            }
        }
        source.apply(snapshot, animatingDifferences: false)
    }
    
//    public func refresh() {
//        source.refresh()
//    }
    
    public func onImageScroll(_ index: Int) {
        guard let cell = cellForItem(at: IndexPath(row: 0, section: 2)) as? ImageCell else { return }
        cell.scrollToImage(at: index)
    }
}

extension PollCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        // Allows for closing an already open cell
//        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
//            collectionView.deselectItem(at: indexPath, animated: true)
//        } else {
//            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
//        }
//
//        source.refresh()
//
//        return false // The selecting or deselecting is already performed above
        
        guard let cell = collectionView.cellForItem(at: indexPath), !cell.isSelected else {
            collectionView.deselectItem(at: indexPath, animated: true)
            source.refresh()
            return false
        }
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        source.refresh()
        return true
    }
}

extension PollCollectionView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let mediafile = sender as? Mediafile {
            callbackDelegate?.callbackReceived(mediafile)
        }
    }
}
