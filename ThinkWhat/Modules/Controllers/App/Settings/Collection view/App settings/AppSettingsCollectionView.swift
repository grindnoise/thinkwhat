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
        case Notifications, Languages, About
    }
    
    
    
    // MARK: - Public properties
    //Publishers
    public var notificationSettingsPublisher = CurrentValueSubject<[AppSettings: Bool]?, Never>(nil)
    public var appLanguagePublisher = CurrentValueSubject<[AppSettings: String]?, Never>(nil)
    public var contentLanguagePublisher = CurrentValueSubject<Bool?, Never>(nil)
    public var aboutPublisher = CurrentValueSubject<AppSettingsTextCell.Mode?, Never>(nil)
    
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
        collectionViewLayout = UICollectionViewCompositionalLayout{ [unowned self] section, environment -> NSCollectionLayoutSection in
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
                    
                    //                    if let section = Section(rawValue: indexPath.section) {
                    //                        switch section {
                    //                        case .Notifications:
                    let itemsCount = self.numberOfItems(inSection: indexPath.section)
                    if itemsCount > 1 {
                        if itemsCount == 2 {
                            config.topSeparatorVisibility = indexPath.row == 0 ? .visible : .hidden
                            config.bottomSeparatorVisibility = indexPath.row == 0 ? .hidden : .visible
                        } else {
                            config.topSeparatorVisibility = indexPath.row == 0 ? .visible : .hidden
                            config.bottomSeparatorVisibility = indexPath.row == itemsCount-1 ? .visible : .hidden
                        }
                        //                        case .Languages:
                        //                            config.topSeparatorVisibility = indexPath.row == 0 ? .visible : .hidden
                        //                            config.bottomSeparatorVisibility = indexPath.row == 0 ? .hidden : .visible
                        //                        case .About:
                        //                            config.topSeparatorVisibility = indexPath.row == 0 ? .visible : .hidden
                        //                            config.bottomSeparatorVisibility = indexPath.row == 0 ? .hidden : .visible
                        //                        }
                    }
                    
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
                          let dict = $0
                    else { return }
                    
                    self.notificationSettingsPublisher.send(dict)
                }
                .store(in: &subscriptions)
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .clear
            cell.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            cell.backgroundConfiguration = backgroundConfig
            
            switch indexPath.row {
            case 0:
                cell.mode = .notifications(.Completed)
                cell.isOn = UserDefaults.App.notifyOnOwnCompleted ?? false
            case 1:
                cell.mode = .notifications(.Subscriptions)
                cell.isOn = UserDefaults.App.notifyOnNewSubscription ?? false
            case 2:
                cell.mode = .notifications(.Watchlist)
                cell.isOn = UserDefaults.App.notifyOnWatchlistCompleted ?? false
            default:
#if DEBUG
      fatalError()
#endif
            }
        }
        
        let languageCellRegistration = UICollectionView.CellRegistration<AppSettingsLanguageCell, AnyHashable> { [unowned self] cell, indexPath, item in
            
            cell.appLanguagePublisher
                .sink { [weak self] in
                    guard let self = self,
                          let dict = $0
                    else { return }
                    
                    self.appLanguagePublisher.send(dict)
                }
                .store(in: &subscriptions)
            
            cell.contentLanguagePublisher
                .sink { [weak self] in
                    guard let self = self, !$0.isNil else { return }
                    
                    self.contentLanguagePublisher.send($0)
                }
                .store(in: &subscriptions)
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .clear
            cell.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            cell.backgroundConfiguration = backgroundConfig
            cell.mode = indexPath.row == 0 ? .languages(.App) : .languages(.Content)
        }
        
        let textCellRegistration = UICollectionView.CellRegistration<AppSettingsTextCell, AnyHashable> { cell, indexPath, item in
            if indexPath.row == 0 {
                cell.mode = .TermsOfUse
            } else if indexPath.row == 1 {
                cell.mode = .Licenses
            } else if indexPath.row == 2 {
                cell.mode = .Feedback
            } else if indexPath.row == 3 {
                cell.mode = .AppVersion
            }
            
            cell.tapPublisher
                .sink { [weak self] in
                    guard let self = self,
                          let mode = $0
                    else { return }

                    self.aboutPublisher.send(mode)
                }
                .store(in: &self.subscriptions)
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .clear
            cell.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            cell.backgroundConfiguration = backgroundConfig
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<SettingsCellHeader>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, elementKind, indexPath in
            
            guard let section = Section(rawValue: indexPath.section) else { return }
            
            switch section {
            case .Notifications:
                supplementaryView.mode = .Notifications
                supplementaryView.isHelpEnabled = false
            case .Languages:
                supplementaryView.mode = .Languages
                supplementaryView.isHelpEnabled = false
            case .About:
                supplementaryView.mode = .AboutApp
                supplementaryView.isHelpEnabled = false
            }
        }
        
        source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { [unowned self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
            
            if section == .Notifications {
                return collectionView.dequeueConfiguredReusableCell(using: switchCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .Languages {
                return collectionView.dequeueConfiguredReusableCell(using: languageCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .About {
                return collectionView.dequeueConfiguredReusableCell(using: textCellRegistration,
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
        snapshot.appendSections([.Notifications, .Languages, .About])
        snapshot.appendItems(Array(0...2), toSection: .Notifications)
        snapshot.appendItems([3, 4], toSection: .Languages)
        snapshot.appendItems(Array(5...8), toSection: .About)
        source.apply(snapshot, animatingDifferences: false)
    }
}
