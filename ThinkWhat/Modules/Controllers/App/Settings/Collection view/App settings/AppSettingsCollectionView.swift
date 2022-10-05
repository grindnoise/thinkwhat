//
//  AppSettingsCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AppSettingsCollectionView: UICollectionView {
    
    enum Section: Int, CaseIterable {
        case Notifications
    }
    
    
    
    // MARK: - Public properties
    //Publishers
    public let namePublisher = CurrentValueSubject<[String: String]?, Never>(nil)
    public let datePublisher = CurrentValueSubject<Date?, Never>(nil)
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Collection
    private var source: UICollectionViewDiffableDataSource<Section, Int>!
    
    
    
    // MARK: - Destructor
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
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        collectionViewLayout = UICollectionViewCompositionalLayout{ section, environment -> NSCollectionLayoutSection in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.backgroundColor = .clear
            configuration.showsSeparators = true
            
            if #available(iOS 14.5, *) {
                configuration.itemSeparatorHandler = { indexPath, config -> UIListSeparatorConfiguration in
                    var config = UIListSeparatorConfiguration(listAppearance: .plain)
                    config.color = .systemGray5
                    config.topSeparatorInsets = NSDirectionalEdgeInsets(top: 1.2, leading: 0, bottom: 0, trailing: 0)
                    config.topSeparatorVisibility = .visible
                    config.bottomSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1.2, trailing: 0)
                    config.bottomSeparatorVisibility = .visible
                    
                    return config
                }
            }
            
            configuration.headerMode = .supplementary
            
            let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: section == Section.allCases.count-1 ? 30 : 0, trailing: 0)
            return sectionLayout
        }
        
        let switchCellRegistration = UICollectionView.CellRegistration<AppSettingsSwitchCell, AnyHashable> { [unowned self] cell, indexPath, item in
            
            //Topic tapped
            cell.valuePublisher
                .sink { [weak self] in
                    guard let self = self,
                          let dict = $0,
                          let key = dict.keys.first,
                          let value = dict.values.first
                    else { return }
                    
                    print(key)
                    print(value)
//                    self.interestPublisher.send(topic)
                }
                .store(in: &subscriptions)
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .clear
            cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            cell.backgroundConfiguration = backgroundConfig
            
            switch indexPath.row {
            case 0:
                cell.mode = .notifications(.Allow)
            case 1:
                cell.mode = .notifications(.Subscriptions)
            case 2:
                cell.mode = .notifications(.Watchlist)
            default:
#if DEBUG
      fatalError()
#endif
            }
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<SettingsCellHeader>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, elementKind, indexPath in
            
            guard let section = Section(rawValue: indexPath.section),
                  let userprofile = Userprofiles.shared.current
            else { return }
            
            switch section {
            case .Notifications:
                supplementaryView.mode = .Notifications
                supplementaryView.isHelpEnabled = false
            default:
                print("")
            }
        }
        
        source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { [unowned self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
            
            if section == .Notifications {
                return collectionView.dequeueConfiguredReusableCell(using: switchCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            }

            return UICollectionViewCell()
        }
        
        source.supplementaryViewProvider = {
            collectionView, elementKind, indexPath -> UICollectionReusableView? in
            
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.Notifications, ])
        snapshot.appendItems(Array(0...2), toSection: .Notifications)
        source.apply(snapshot, animatingDifferences: false)
    }
}
