//
//  UserprofileCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserprofileCollectionView: UICollectionView {

    enum Section: Int, CaseIterable {
        case Credentials
    }
    
    typealias Source = UICollectionViewDiffableDataSource<Section, Int>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Int>
    
    
    // MARK: - Public properties
    public var userprofile: Userprofile! {
        didSet {
            guard !userprofile.isNil else { return }
            
            setupUI()
        }
    }
    //Publishers
    public let namePublisher = CurrentValueSubject<[String: String]?, Never>(nil)
    public let urlPublisher = CurrentValueSubject<URL?, Never>(nil)
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Collection
    private var source: Source!
    
    
    
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
        
        setTasks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UserprofileCollectionView {
    @MainActor
    func setupUI() {
        
//        delegate = self
        
        collectionViewLayout = UICollectionViewCompositionalLayout{ section, environment -> NSCollectionLayoutSection in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.backgroundColor = .clear
            
            if #available(iOS 14.5, *) {
                configuration.showsSeparators = true
                configuration.itemSeparatorHandler = { indexPath, config -> UIListSeparatorConfiguration in
                    
                    var config = UIListSeparatorConfiguration(listAppearance: .plain)
                    config.topSeparatorVisibility = .hidden
                    config.bottomSeparatorVisibility = .hidden
                    config.color = .systemGray5
                    
                    guard let section = Section(rawValue: indexPath.section), section != .Credentials else { return config }
                    
                    config.topSeparatorInsets = NSDirectionalEdgeInsets(top: 1.2, leading: 0, bottom: 0, trailing: 0)
                    config.topSeparatorVisibility = .visible
                    config.bottomSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1.2, trailing: 0)
                    config.bottomSeparatorVisibility = .visible
                    
                    return config
                }
            } else {
                configuration.showsSeparators = false
            }
            if section != 0 {
                configuration.headerMode = .supplementary
            }
            
            let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: section == Section.allCases.count-1 ? 30 : 0, trailing: 0)
            return sectionLayout
        }
        
        let credentialsCellRegistration = UICollectionView.CellRegistration<UserCredentialsCell, AnyHashable> { [unowned self] cell, indexPath, item in
            guard let userprofile = self.userprofile else { return }
            
            var config = UIBackgroundConfiguration.listPlainCell()
            config.backgroundColor = .clear
            cell.backgroundConfiguration = config
            cell.automaticallyUpdatesBackgroundConfiguration = false
            cell.userprofile = userprofile
            cell.imagePublisher.sink { [weak self] in
                guard let self = self,
                      let image = $0
                else { return }
                
                fatalError()
//                self.previewPublisher.send(image)
            }.store(in: &self.subscriptions)
            
        }
        
//        let cityCellRegistration = UICollectionView.CellRegistration<UserSettingsCityCell, AnyHashable> { [unowned self] cell, indexPath, item in
//
//            //Fetch
//            cell.cityFetchPublisher.sink { [weak self] in
//                guard let self = self,
//                      let string = $0
//                else { return }
//
//                self.cityFetchPublisher.send(string)
//            }.store(in: &self.subscriptions)
//
//            //Selection
//            cell.citySelectionPublisher.sink { [weak self] in
//                guard let self = self,
//                      let city = $0
//                else { return }
//
//                self.citySelectionPublisher.send(city)
//            }.store(in: &self.subscriptions)
//
////            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .cell)
//            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//            backgroundConfig.backgroundColor = .clear
//            cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//            cell.backgroundConfiguration = backgroundConfig
////            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption)]
//
//            guard let userprofile = Userprofiles.shared.current else { return }
//
//            cell.cityTitle = userprofile.cityTitle
//        }
//
//        let socialCellRegistration = UICollectionView.CellRegistration<UserSettingsSocialMediaCell, AnyHashable> { [unowned self] cell, indexPath, item in
//
//            //Facebook
//            cell.facebookPublisher.sink { [weak self] in
//                guard let self = self,
//                      let url = $0
//                else { return }
//
//                self.facebookPublisher.send(url)
//            }.store(in: &self.subscriptions)
//
//            //Instagram
//            cell.instagramPublisher.sink { [weak self] in
//                guard let self = self,
//                      let url = $0
//                else { return }
//
//                self.instagramPublisher.send(url)
//            }.store(in: &self.subscriptions)
//
//            //Instagram
//            cell.tiktokPublisher.sink { [weak self] in
//                guard let self = self,
//                      let url = $0
//                else { return }
//
//                self.tiktokPublisher.send(url)
//            }.store(in: &self.subscriptions)
//
//            //URL
//            cell.openURLPublisher.sink { [weak self] in
//                guard let self = self,
//                      let url = $0
//                else { return }
//
//                self.openURLPublisher.send(url)
//            }.store(in: &self.subscriptions)
////            //Google
////            cell.googlePublisher.sink { [weak self] in
////                guard let self = self,
////                      let string = $0
////                else { return }
////
////            }.store(in: &self.subscriptions)
////
////            //Twitter
////            cell.twitterPublisher.sink { [weak self] in
////                guard let self = self,
////                      let string = $0
////                else { return }
////
////            }.store(in: &self.subscriptions)
//
//            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//            backgroundConfig.backgroundColor = .clear
//            cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//            cell.backgroundConfiguration = backgroundConfig
//
//            guard let userprofile = Userprofiles.shared.current else { return }
//
//            cell.userprofile = userprofile
//        }
//
//        let interestsCellRegistration = UICollectionView.CellRegistration<UserSettingsInterestsCell, AnyHashable> { [unowned self] cell, indexPath, item in
//
//            //Topic tapped
//            cell.interestPublisher
//                .sink { [weak self] in
//                    guard let self = self,
//                          let topic = $0
//                    else { return }
//
//                    self.interestPublisher.send(topic)
//                }
//                .store(in: &subscriptions)
//
//            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//            backgroundConfig.backgroundColor = .clear
//            cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//            cell.backgroundConfiguration = backgroundConfig
//
//            guard let userprofile = Userprofiles.shared.current else { return }
//
//            cell.userprofile = userprofile
//        }
//
//        let statsCellRegistration = UICollectionView.CellRegistration<UserSettingsStatsCell, AnyHashable> { [unowned self] cell, indexPath, item in
//
//            //Publications
//            cell.publicationsPublisher
//                .sink { [weak self] in
//                    guard let self = self,
//                          !$0.isNil
//                    else { return }
//
//                    self.publicationsPublisher.send($0)
//                }
//                .store(in: &subscriptions)
//
//            //Subscribers
//            cell.subscribersPublisher
//                .sink { [weak self] in
//                    guard let self = self,
//                          !$0.isNil
//                    else { return }
//
//                    self.subscribersPublisher.send($0)
//                }
//                .store(in: &subscriptions)
//
//            //Subscriptions
//            cell.subscriptionsPublisher
//                .sink { [weak self] in
//                    guard let self = self,
//                          !$0.isNil
//                    else { return }
//
//                    self.subscriptionsPublisher.send($0)
//                }
//                .store(in: &subscriptions)
//
//            //Watching
//            cell.watchingPublisher
//                .sink { [weak self] in
//                    guard let self = self,
//                          !$0.isNil
//                    else { return }
//
//                    self.watchingPublisher.send($0)
//                }
//                .store(in: &subscriptions)
//
//            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//            backgroundConfig.backgroundColor = .clear
//            cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//            cell.backgroundConfiguration = backgroundConfig
//
//            guard let userprofile = Userprofiles.shared.current else { return }
//
//            cell.userprofile = userprofile
//        }
//
//        let accountCellRegistration = UICollectionView.CellRegistration<UserSettingsAccountCell, AnyHashable> { [unowned self] cell, indexPath, item in
//
//            //Logout
//            cell.logoutPublisher
//                .sink { [weak self] in
//                    guard let self = self,
//                          !$0.isNil
//                    else { return }
//
////                    self.interestPublisher.send(topic)
//                }
//                .store(in: &subscriptions)
//
//            //Delete
//            cell.deletePublisher
//                .sink { [weak self] in
//                    guard let self = self,
//                          !$0.isNil
//                    else { return }
//
////                    self.interestPublisher.send(topic)
//                }
//                .store(in: &subscriptions)
//
//            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//            backgroundConfig.backgroundColor = .clear
//            cell.backgroundConfiguration = backgroundConfig
//
//            guard let userprofile = Userprofiles.shared.current else { return }
//
//            cell.userprofile = userprofile
//        }
        
        let headerRegistraition = UICollectionView.SupplementaryRegistration<SettingsCellHeader>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, elementKind, indexPath in
            
            guard let section = Section(rawValue: indexPath.section),
                  let userprofile = self.userprofile
            else { return }
            
//            switch section {
//            case .City:
//                supplementaryView.mode = .City
//                supplementaryView.isBadgeEnabled = userprofile.cityTitle.isEmpty ? true : false
//            case .SocialMedia:
//                supplementaryView.mode = .SocialMedia
//                supplementaryView.isHelpEnabled = true
//                supplementaryView.isBadgeEnabled = userprofile.hasSocialMedia ? false : true
//            case .Interests:
//                supplementaryView.mode = .Interests
//                supplementaryView.isHelpEnabled = true
//            case .Stats:
//                supplementaryView.mode = .Stats
//                supplementaryView.isHelpEnabled = false
//            case .Management:
//                supplementaryView.mode = .Management
//                supplementaryView.isHelpEnabled = false
//            default:
//                print("")
//            }
        }
        
        source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { [unowned self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
            if section == .Credentials {
                return collectionView.dequeueConfiguredReusableCell(using: credentialsCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
//            } else if section == .City {
//                return collectionView.dequeueConfiguredReusableCell(using: cityCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            } else if section == .SocialMedia {
//                return collectionView.dequeueConfiguredReusableCell(using: socialCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            } else if section == .Interests {
//                return collectionView.dequeueConfiguredReusableCell(using: interestsCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            } else if section == .Stats {
//                return collectionView.dequeueConfiguredReusableCell(using: statsCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
//            } else if section == .Management {
//                return collectionView.dequeueConfiguredReusableCell(using: accountCellRegistration,
//                                                                    for: indexPath,
//                                                                    item: identifier)
            }

            return UICollectionViewCell()
        }
        
        source.supplementaryViewProvider = {
            collectionView, elementKind, indexPath -> UICollectionReusableView? in
            
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistraition, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([
            .Credentials,
        ])
        snapshot.appendItems([0], toSection: .Credentials)
        source.apply(snapshot, animatingDifferences: false)
    }
    
    func setTasks() {
        
    }
}
