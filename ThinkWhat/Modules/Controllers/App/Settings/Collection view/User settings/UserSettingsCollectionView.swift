//
//  CurrentUserProfileView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserSettingsCollectionView: UICollectionView {
  
  enum Section: Int, CaseIterable {
    case Credentials, Info, Stats, Management
//    case Credentials, About, City, Interests, SocialMedia, Stats, Management
  }
  
  
  
  // MARK: - Public properties
  ///`Publishers`
  public let topicPublisher = PassthroughSubject<Topic, Never>()
  public let namePublisher = CurrentValueSubject<[String: String]?, Never>(nil)
  public let datePublisher = CurrentValueSubject<Date?, Never>(nil)
  public let genderPublisher = CurrentValueSubject<Gender?, Never>(nil)
  public let galleryPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public let cameraPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public let previewPublisher = CurrentValueSubject<UIImage?, Never>(nil)
  public let citySelectionPublisher = PassthroughSubject<City, Never>()
  public let cityFetchPublisher = CurrentValueSubject<String?, Never>(nil)
  public let facebookPublisher = CurrentValueSubject<String?, Never>(nil)
  public let instagramPublisher = CurrentValueSubject<String?, Never>(nil)
  public let tiktokPublisher = CurrentValueSubject<String?, Never>(nil)
  public let googlePublisher = CurrentValueSubject<String?, Never>(nil)
  public let twitterPublisher = CurrentValueSubject<String?, Never>(nil)
  public let openURLPublisher = CurrentValueSubject<URL?, Never>(nil)
  public let publicationsPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public var subscribersPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public var subscriptionsPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public var watchingPublisher = CurrentValueSubject<Bool?, Never>(nil)
  ///`UI`
  public var color: UIColor = Colors.System.Red.rawValue {
    didSet {
      setupUI()
    }
  }
  ///`Publishers`
  @Published public private(set) var userprofileDescription: String?
  
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private var source: UICollectionViewDiffableDataSource<Section, Int>!
  ///`UI`
  private let padding: CGFloat = 8
  
  
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
  init() {
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  }
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Private methods
  private func setupUI() {
    //        delegate = self
    
    collectionViewLayout = UICollectionViewCompositionalLayout{ [unowned self] section, environment -> NSCollectionLayoutSection in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: section == Section.allCases.count-1 ? self.padding : 0, trailing: 0)
      return sectionLayout
    }
    
    let credentialsCellRegistration = UICollectionView.CellRegistration<UserSettingsCredentialsCell, AnyHashable> { [unowned self] cell, indexPath, item in
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.color = self.color
      
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
      }.store(in: &self.subscriptions)
      
      //Catch photo tap
      cell.galleryPublisher.sink { [weak self] in
        guard let self = self, !$0.isNil else { return }
        
        self.galleryPublisher.send(true)
      }.store(in: &self.subscriptions)
      
      cell.previewPublisher.sink { [weak self] in
        guard let self = self,
              let image = $0
        else { return }
        
        self.previewPublisher.send(image)
      }.store(in: &self.subscriptions)
      
      guard let userprofile = Userprofiles.shared.current,
            cell.userprofile.isNil
      else { return }
      
      cell.userprofile = userprofile
      cell.insets = UIEdgeInsets(top: self.padding*2, left: self.padding, bottom: self.padding, right: self.padding)
    }
    
    let infoCellRegistration = UICollectionView.CellRegistration<UserSettingsInfoCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.publisher(for: \.bounds)
        .receive(on: DispatchQueue.main)
        .sink { _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.color = self.color
      cell.$userprofileDescription
        .filter { !$0.isNil }
        .sink { [unowned self] in self.userprofileDescription = $0! }
        .store(in: &self.subscriptions)
      
      let debounced = cell.cityFetchPublisher
//        .filter { !$0.isNil }
        .throttle(for: .seconds(1),
                  scheduler: DispatchQueue.main,
                  latest: true)
      
      cell.citySelectionPublisher
        .sink { [unowned self] in self.citySelectionPublisher.send($0) }
        .store(in: &self.subscriptions)

      debounced
        .sink { [unowned self] in self.cityFetchPublisher.send($0) }
        .store(in: &self.subscriptions)
      
      cell.facebookPublisher
        .sink { [unowned self] in self.facebookPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.instagramPublisher
        .sink { [unowned self] in self.instagramPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.tiktokPublisher
        .sink { [unowned self] in self.tiktokPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.openURLPublisher
        .sink { [unowned self] in self.openURLPublisher.send($0) }
        .store(in: &self.subscriptions)
      
      guard cell.insets == .zero else { return }
      
      cell.setInsets(UIEdgeInsets(top: self.padding*2,
                                  left: self.padding,
                                  bottom: self.padding,
                                  right: self.padding))
    }
    
//    let aboutCellRegistration = UICollectionView.CellRegistration<UserInfoCell, AnyHashable> { [unowned self] cell, _, _ in
//      guard let userprofile = Userprofiles.shared.current else { return }
//
//      cell.publisher(for: \.bounds)
//        .receive(on: DispatchQueue.main)
//        .sink { _ in self.source.refresh() }
//        .store(in: &self.subscriptions)
//      cell.userprofile = userprofile
//
//      guard cell.insets == .zero else { return }
//
//      cell.setInsets(UIEdgeInsets(top: self.padding*2,
//                                  left: self.padding,
//                                  bottom: self.padding,
//                                  right: self.padding))
//    }
//
//    let cityCellRegistration = UICollectionView.CellRegistration<UserSettingsCityCell, AnyHashable> { [unowned self] cell, _, item in
//
//      cell.color = self.color
//      cell.insets = UIEdgeInsets(top: padding*2, left: padding, bottom: padding*1, right: padding)
//      ///Fetch
////      cell.cityFetchPublisher
////        .filter { !$0.isNil }
////        .sink { [unowned self] in self.cityFetchPublisher.send($0!) }
////        .store(in: &self.subscriptions)
//      let debounced = cell.cityFetchPublisher
//        .filter { !$0.isNil }
//        .throttle(for: .seconds(1),
//                  scheduler: DispatchQueue.main,
//                  latest: true)
//
//      debounced
//        .sink { [unowned self] in self.cityFetchPublisher.send($0!) }
//        .store(in: &self.subscriptions)
//
//      ///Selection
//      cell.citySelectionPublisher
//        .sink { [unowned self] in self.citySelectionPublisher.send($0) }
//        .store(in: &self.subscriptions)
//
//      var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//      backgroundConfig.backgroundColor = .clear
//      cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//      cell.backgroundConfiguration = backgroundConfig
//
//      guard let userprofile = Userprofiles.shared.current else { return }
//
//      cell.userprofile = userprofile
//    }
//
//    let interestsCellRegistration = UICollectionView.CellRegistration<UserInterestsCell, AnyHashable> { [unowned self] cell, _, _ in
//      guard let userprofile = Userprofiles.shared.current else { return }
//
//      cell.userprofile = userprofile
//      cell.color = self.color
//      cell.insets = UIEdgeInsets(top: padding*2, left: padding, bottom: padding*1, right: padding)
//      cell.topicPublisher
//        .sink { [unowned self] in self.topicPublisher.send($0) }
//        .store(in: &self.subscriptions)
//
//      var config = UIBackgroundConfiguration.listPlainCell()
//      config.backgroundColor = .clear
//      cell.backgroundConfiguration = config
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//    }
//
//    let socialCellRegistration = UICollectionView.CellRegistration<UserSettingsSocialHeaderCell, AnyHashable> { [unowned self] cell, indexPath, item in
////      cell.keyboardWillAppear
////        .sink { [unowned self] _ in
////          //                    self.scrollToItem(at: indexPath, at: .top, animated: true)
////        }
////        .store(in: &self.subscriptions)
//      cell.insets = UIEdgeInsets(top: padding*2, left: padding, bottom: padding*1, right: padding)
//      //Facebook
//      cell.facebookPublisher.sink { [weak self] in
//        guard let self = self else { return }
//
//        self.facebookPublisher.send($0)
//      }.store(in: &self.subscriptions)
//
//      //Instagram
//      cell.instagramPublisher.sink { [weak self] in
//        guard let self = self else { return }
//
//        self.instagramPublisher.send($0)
//      }.store(in: &self.subscriptions)
//
//      //Instagram
//      cell.tiktokPublisher.sink { [weak self] in
//        guard let self = self else { return }
//
//        self.tiktokPublisher.send($0)
//      }.store(in: &self.subscriptions)
//
//      //URL
//      cell.openURLPublisher.sink { [weak self] in
//        guard let self = self else { return }
//
//        self.openURLPublisher.send($0)
//      }.store(in: &self.subscriptions)
//      //            //Google
//      //            cell.googlePublisher.sink { [weak self] in
//      //                guard let self = self,
//      //                      let string = $0
//      //                else { return }
//      //
//      //            }.store(in: &self.subscriptions)
//      //
//      //            //Twitter
//      //            cell.twitterPublisher.sink { [weak self] in
//      //                guard let self = self,
//      //                      let string = $0
//      //                else { return }
//      //
//      //            }.store(in: &self.subscriptions)
//
//      var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//      backgroundConfig.backgroundColor = .clear
//      cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//      cell.backgroundConfiguration = backgroundConfig
//
//      guard let userprofile = Userprofiles.shared.current else { return }
//
//      cell.userprofile = userprofile
//      cell.color = self.color
//    }
//
    let statsCellRegistration = UICollectionView.CellRegistration<UserStatsCell, AnyHashable> { [unowned self] cell, _, _ in
      guard let userprofile = Userprofiles.shared.current else { return }
      
      cell.userprofile = userprofile
      cell.color = self.color
      cell.insets = UIEdgeInsets(top: padding*2, left: padding, bottom: padding*2, right: padding)
      cell.mode = .Settings
//      cell.publicationsPublisher
//        .sink { [weak self] in
//          guard let self = self else { return }
//          
//          self.publicationsPublisher.send($0)
//        }
//        .store(in: &subscriptions)
//      
//      cell.commentsPublisher
//        .sink { [weak self] in
//          guard let self = self else { return }
//          
//          self.commentsPublisher.send($0)
//        }
//        .store(in: &subscriptions)
//      
//      cell.subscribersPublisher
//        .sink { [weak self] in
//          guard let self = self else { return }
//          
//          self.subscribersPublisher.send($0)
//        }
//        .store(in: &subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let accountManagementCellRegistration = UICollectionView.CellRegistration<AccountManagementHeaderCell, AnyHashable> { cell, _, _ in
      var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
      backgroundConfig.backgroundColor = .clear
      cell.backgroundConfiguration = backgroundConfig
      
      guard let userprofile = Userprofiles.shared.current else { return }
      
      cell.userprofile = userprofile
    }
    
    //        let headerRegistraition = UICollectionView.SupplementaryRegistration<SettingsCellHeader>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, elementKind, indexPath in
    //
    //            guard let section = Section(rawValue: indexPath.section),
    //                  let userprofile = Userprofiles.shared.current
    //            else { return }
    //
    //            switch section {
    //            case .City:
    //                supplementaryView.mode = .City
    //                supplementaryView.isBadgeEnabled = false//userprofile.cityTitle.isEmpty ? true : false
    //            case .SocialMedia:
    //                supplementaryView.mode = .SocialMedia
    //                supplementaryView.isHelpEnabled = true
    //                supplementaryView.isBadgeEnabled = false//userprofile.hasSocialMedia ? false : true
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
    //        }
    
    source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
      if section == .Credentials {
        return collectionView.dequeueConfiguredReusableCell(using: credentialsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Stats {
        return collectionView.dequeueConfiguredReusableCell(using: statsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Management {
        return collectionView.dequeueConfiguredReusableCell(using: accountManagementCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Info {
        return collectionView.dequeueConfiguredReusableCell(using: infoCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      }
//      } else if section == .City {
//        return collectionView.dequeueConfiguredReusableCell(using: cityCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      } else if section == .SocialMedia {
//        return collectionView.dequeueConfiguredReusableCell(using: socialCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      } else if section == .Interests {
//        return collectionView.dequeueConfiguredReusableCell(using: interestsCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      } else if section == .About {
//        return collectionView.dequeueConfiguredReusableCell(using: aboutCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      }
      
      return UICollectionViewCell()
    }
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.Credentials, .Info, .Stats, .Management])
//    snapshot.appendSections([.Credentials, .About, .City, .Interests, .SocialMedia, .Stats, .Management])
    snapshot.appendItems([0], toSection: .Credentials)
    snapshot.appendItems([1], toSection: .Info)
    snapshot.appendItems([2], toSection: .Stats)
    snapshot.appendItems([3], toSection: .Management)
    
//    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
//    snapshot.appendSections([.Credentials, .About, .City, .Interests, .SocialMedia, .Stats, .Management])
//    snapshot.appendItems([0], toSection: .Credentials)
//    snapshot.appendItems([1], toSection: .About)
//    snapshot.appendItems([2], toSection: .City)
//    snapshot.appendItems([3], toSection: .Interests)
//    snapshot.appendItems([4], toSection: .SocialMedia)
//    snapshot.appendItems([5], toSection: .Stats)
//    snapshot.appendItems([6], toSection: .Management)
    
    source.apply(snapshot, animatingDifferences: false)
  }
}

//extension CurrentUserProfileCollectionView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
//    }
//}
