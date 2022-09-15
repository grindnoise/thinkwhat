//
//  CurrentUserProfileView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CurrentUserProfileCollectionView: UICollectionView {
    
    enum Section: Int {
        case Credentials, City
    }
    
    // MARK: - Public properties
    //Publishers
    public let namePublisher = CurrentValueSubject<[String: String]?, Never>(nil)
    public let datePublisher = CurrentValueSubject<Date?, Never>(nil)
    public let genderPublisher = CurrentValueSubject<Gender?, Never>(nil)
    public let galleryPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public let cameraPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public let previewPublisher = CurrentValueSubject<UIImage?, Never>(nil)
    public let cityPublisher = CurrentValueSubject<City?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
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
        delegate = self
        
        collectionViewLayout = UICollectionViewCompositionalLayout{ section, environment -> NSCollectionLayoutSection in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.backgroundColor = .clear

            if #available(iOS 14.5, *) {
                configuration.showsSeparators = true
                configuration.itemSeparatorHandler = { indexPath, config -> UIListSeparatorConfiguration in
                    
                    var config = UIListSeparatorConfiguration(listAppearance: .plain)
                    config.topSeparatorVisibility = .hidden
                    config.bottomSeparatorVisibility = .hidden
                    
                    guard let section = Section(rawValue: indexPath.section), section != .Credentials else { return config }
                    
                    config.topSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                    config.topSeparatorVisibility = .visible
                    config.bottomSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
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
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            return sectionLayout
        }
        
        let credentialsCellRegistration = UICollectionView.CellRegistration<CurrentUserCredentialsCell, AnyHashable> { [unowned self] cell, indexPath, item in
            
            var config = UIBackgroundConfiguration.listPlainCell()
            config.backgroundColor = .clear
            cell.backgroundConfiguration = config
            cell.automaticallyUpdatesBackgroundConfiguration = false
            
            //Name
            cell.namePublisher.sink { [weak self] in
                guard let self = self,
                      let dict = $0
                else { return }
                
                self.namePublisher.send(dict)
            }.store(in: &self.subscriptions)
            
            //Birth date
            cell.datePublisher.sink { [weak self] in
                guard let self = self,
                      let date = $0
                else { return }
                
                self.datePublisher.send(date)
            }.store(in: &self.subscriptions)
            
            //Gender
            cell.genderPublisher.sink { [weak self] in
                guard let self = self,
                      let gender = $0
                else { return }
                
                self.genderPublisher.send(gender)
            }.store(in: &self.subscriptions)
            
            //Catch camera tap
            cell.cameraPublisher.sink { [weak self] in
                guard let self = self, !$0.isNil else { return }
                
                self.cameraPublisher.send(true)
            }.store(in: &subscriptions)
            
            //Catch photo tap
            cell.galleryPublisher.sink { [weak self] in
                guard let self = self, !$0.isNil else { return }
                
                self.galleryPublisher.send(true)
            }.store(in: &subscriptions)
                        
            cell.previewPublisher.sink { [weak self] in
                guard let self = self,
                      let image = $0
                else { return }
                
                self.previewPublisher.send(image)
            }.store(in: &subscriptions)
            
            guard let userprofile = Userprofiles.shared.current,
                  cell.userprofile.isNil
            else { return }
            
            cell.userprofile = userprofile
        }
        
        let cityCellRegistration = UICollectionView.CellRegistration<CurrentUserCityCell, AnyHashable> { [unowned self] cell, indexPath, item in
            
//            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .cell)
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .clear
            cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            cell.backgroundConfiguration = backgroundConfig
//            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption)]
                        
            guard let userprofile = Userprofiles.shared.current else { return }
            
            cell.cityTitle = userprofile.cityTitle
        }
        
        let headerRegistraition = UICollectionView.SupplementaryRegistration<SettingsCellHeader>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, elementKind, indexPath in
            
            guard let section = Section(rawValue: indexPath.section) else { return }
            
            switch section {
            case .City:
                supplementaryView.title = "cityTF"
                guard let userprofile = Userprofiles.shared.current else { return }
                supplementaryView.isBadgeEnabled = userprofile.cityTitle.isEmpty ? true : false
            default:
                print("")
            }
            
        }
        
        source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { [unowned self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
            if section == .Credentials {
                return collectionView.dequeueConfiguredReusableCell(using: credentialsCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            } else if section == .City {
                return collectionView.dequeueConfiguredReusableCell(using: cityCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            }

            return UICollectionViewCell()
        }
        
        source.supplementaryViewProvider = {
            collectionView, elementKind, indexPath -> UICollectionReusableView? in
            
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistraition, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.Credentials, .City])
        snapshot.appendItems([0], toSection: .Credentials)
        snapshot.appendItems([1], toSection: .City)
        source.apply(snapshot, animatingDifferences: false)
    }
}

extension CurrentUserProfileCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CurrentUserCityCell {
            cell.selectCity()
        }
    }
}
