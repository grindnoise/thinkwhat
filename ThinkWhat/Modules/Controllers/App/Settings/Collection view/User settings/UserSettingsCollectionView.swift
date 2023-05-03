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
  
  enum Section: Int, CaseIterable { case Credentials, Info, Stats, Management }
  enum Mode { case Default, Creation }
  
  
  // MARK: - Public properties
  ///**Publishers
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
  public private(set) var accountManagementPublisher = PassthroughSubject<AccountManagementCell.Mode, Never>()
  @Published public private(set) var userprofileDescription: String?
  ///**UI
  public var color: UIColor = Colors.System.Red.rawValue {
    didSet {
      setupUI()
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private var source: UICollectionViewDiffableDataSource<Section, Int>!
  ///**Logic**
  private let userprofile: Userprofile
  private let mode: Mode
  ///**UI**
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
  init(mode: Mode = .Default,
       userprofile: Userprofile,
       color: UIColor = Colors.main) {
    self.mode = mode
    self.userprofile = userprofile
    self.color = color
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  
  init() { fatalError("init(coder:) has not been implemented") }
//    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
//  }
  
override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) { fatalError("init(coder:) has not been implemented") }
//    super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
//
//    setupUI()
//  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Private methods
  private func setupUI() {
    //        delegate = self
    
    collectionViewLayout = UICollectionViewCompositionalLayout{ [unowned self] section, environment -> NSCollectionLayoutSection in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
//      switch self.mode {
//      case .Creation:
//
//      case .Default:
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: section == Section.allCases.count-1 ? (self.mode == .Default ? self.padding : 80) : 0, trailing: 0)
//      }
      return sectionLayout
    }
    
    let credentialsCellRegistration = UICollectionView.CellRegistration<UserSettingsCredentialsCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = Userprofiles.shared.current else { return }
      
      cell.userprofile = userprofile
      cell.color = self.color
      
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
//      cell.setInsets(UIEdgeInsets(top: self.padding*2,
//                                  left: self.padding,
//                                  bottom: self.padding,
//                                  right: self.padding))
    }
    
    let infoCellRegistration = UICollectionView.CellRegistration<UserSettingsInfoCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.insets = .uniform(size: 8)
      cell.mode = self.mode
      cell.userprofile = self.userprofile
      cell.publisher(for: \.bounds)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.source.refresh(animatingDifferences: cell.isAnimationEnabled) }
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
      
      cell.cityFetchPublisher
        .throttle(for: .seconds(1),
                  scheduler: DispatchQueue.main,
                  latest: true)
        .sink { [unowned self] in self.cityFetchPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.citySelectionPublisher
        .sink { [unowned self] in self.citySelectionPublisher.send($0) }
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
      cell.topicPublisher
        .sink { [unowned self] in self.topicPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.$scrollPublisher
        .eraseToAnyPublisher()
        .filter { !$0.isNil }
        .sink { [unowned self] in
          let point = cell.convert($0!, to: self)
          UIView.animate(withDuration: 0.2) { [unowned self] in
            self.contentOffset.y = point.y
          }
        }
        .store(in: &self.subscriptions)
      cell.$boundsPublisher
        .eraseToAnyPublisher()
        .filter { !$0.isNil }
        .sink { [unowned self] in
          self.source.refresh(animatingDifferences: $0!)
        }
        .store(in: &self.subscriptions)
      
      guard cell.insets == .zero else { return }
      
      cell.setInsets(UIEdgeInsets(top: self.padding*2,
                                  left: self.padding,
                                  bottom: self.padding,
                                  right: self.padding))
    }
    
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
    
    let accountManagementCellRegistration = UICollectionView.CellRegistration<AccountManagementHeaderCell, AnyHashable> { [unowned self] cell, _, _ in
      var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
      backgroundConfig.backgroundColor = .clear
      cell.backgroundConfiguration = backgroundConfig
      cell.color = self.color
      cell.actionPublisher
        .sink { [unowned self] in self.accountManagementPublisher.send($0) }
        .store(in: &self.subscriptions)
      
      guard let userprofile = Userprofiles.shared.current else { return }
      
      cell.userprofile = userprofile
    }
    
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
      
      return UICollectionViewCell()
    }
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.Credentials, .Info, .Stats, .Management])
    snapshot.appendItems([0], toSection: .Credentials)
    snapshot.appendItems([1], toSection: .Info)
    if mode == .Default {
      snapshot.appendItems([2], toSection: .Stats)
      snapshot.appendItems([3], toSection: .Management)
    }
    
    source.apply(snapshot, animatingDifferences: false)
  }
}

//extension CurrentUserProfileCollectionView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
//    }
//}
