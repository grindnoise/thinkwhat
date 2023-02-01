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
    case Credentials, Compatibility, Interests, Stats
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
  public let urlPublisher = PassthroughSubject<URL, Never>()
  public var subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public var imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  public let topicPublisher = PassthroughSubject<Topic, Never>()
  public let publicationsPublisher = PassthroughSubject<Userprofile, Never>()
  public let commentsPublisher = PassthroughSubject<Userprofile, Never>()
  public let subscribersPublisher = PassthroughSubject<Userprofile, Never>()
  public let colorPublisher = CurrentValueSubject<UIColor?, Never>(nil)
  //UI
  public var color: UIColor = .label {
    didSet {
      colorPublisher.send(color)
    }
  }
  

  
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
//  init(color: UIColor) {
//    self.color = color
//    
//    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
//
//    setTasks()
//  }
  
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
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: section == Section.allCases.count-1 ? 80 : 8, trailing: 0)
      return sectionLayout
    }
    
    let compatibilityCellRegistration = UICollectionView.CellRegistration<UserCompatibilityCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink {
          cell.color = $0!
        }
        .store(in: &self.subscriptions)
      
      cell.refreshPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.source.refresh()
        }
        .store(in: &self.subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.userprofile = userprofile
//      cell.imagePublisher
//        .sink { [weak self] in
//          guard let self = self,
//                let image = $0
//          else { return }
//
//          self.imagePublisher.send(image)
//        }
//        .store(in: &self.subscriptions)
    }
    
    let credentialsCellRegistration = UICollectionView.CellRegistration<UserCredentialsCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.userprofile = userprofile
      cell.imagePublisher
        .sink { [weak self] in
          guard let self = self,
                let image = $0
          else { return }
          
          self.imagePublisher.send(image)
        }
        .store(in: &self.subscriptions)
      
      cell.subscriptionPublisher
        .sink { [weak self] in
          guard let self = self,
                let value = $0
          else { return }
          
          self.subscriptionPublisher.send(value)
        }
        .store(in: &self.subscriptions)
      
      cell.urlPublisher
        .sink { [weak self] in
          guard let self = self,
                let image = $0
          else { return }
          
          self.urlPublisher.send(image)
        }
        .store(in: &self.subscriptions)
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink {
          cell.color = $0!
        }
        .store(in: &self.subscriptions)
    }
    
    let interestsCellRegistration = UICollectionView.CellRegistration<UserInterestsCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      cell.color = self.color
      self.colorPublisher
        .filter { !$0.isNil }
        .sink {
          cell.color = $0!
        }
        .store(in: &self.subscriptions)
      cell.topicPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.topicPublisher.send($0)
        }
        .store(in: &subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.userprofile = userprofile
    }
    
    let statsCellRegistration = UICollectionView.CellRegistration<UserStatsCell, AnyHashable> { [unowned self] cell, _, _ in
      guard let userprofile = self.userprofile else { return }
      
      cell.color = self.color
      self.colorPublisher
        .filter { !$0.isNil }
        .sink {
          cell.color = $0!
        }
        .store(in: &self.subscriptions)
      
      cell.publicationsPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.publicationsPublisher.send($0)
        }
        .store(in: &subscriptions)
      
      cell.commentsPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.commentsPublisher.send($0)
        }
        .store(in: &subscriptions)
      
      cell.subscribersPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.subscribersPublisher.send($0)
        }
        .store(in: &subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.userprofile = userprofile
    }
    
    //        let headerRegistraition = UICollectionView.SupplementaryRegistration<SettingsCellHeader>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, elementKind, indexPath in
    //
    //            guard let section = Section(rawValue: indexPath.section),
    //                  let userprofile = self.userprofile
    //            else { return }
    //
    ////            switch section {
    ////            case .City:
    ////                supplementaryView.mode = .City
    ////                supplementaryView.isBadgeEnabled = userprofile.cityTitle.isEmpty ? true : false
    ////            case .SocialMedia:
    ////                supplementaryView.mode = .SocialMedia
    ////                supplementaryView.isHelpEnabled = true
    ////                supplementaryView.isBadgeEnabled = userprofile.hasSocialMedia ? false : true
    ////            case .Interests:
    ////                supplementaryView.mode = .Interests
    ////                supplementaryView.isHelpEnabled = true
    ////            case .Stats:
    ////                supplementaryView.mode = .Stats
    ////                supplementaryView.isHelpEnabled = false
    ////            case .Management:
    ////                supplementaryView.mode = .Management
    ////                supplementaryView.isHelpEnabled = false
    ////            default:
    ////                print("")
    ////            }
    //        }
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
      
      if section == .Credentials {
        return collectionView.dequeueConfiguredReusableCell(using: credentialsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Interests {
        return collectionView.dequeueConfiguredReusableCell(using: interestsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Stats {
        return collectionView.dequeueConfiguredReusableCell(using: statsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Compatibility {
        return collectionView.dequeueConfiguredReusableCell(using: compatibilityCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      }
      
      return UICollectionViewCell()
    }
    
    //        source.supplementaryViewProvider = {
    //            collectionView, elementKind, indexPath -> UICollectionReusableView? in
    //
    //            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistraition, for: indexPath)
    //        }
    
    var snapshot = Snapshot()
    snapshot.appendSections([
      .Credentials,
      .Compatibility,
      .Interests,
      .Stats,
    ])
    snapshot.appendItems([0], toSection: .Credentials)
    snapshot.appendItems([1], toSection: .Compatibility)
    snapshot.appendItems([2], toSection: .Interests)
    snapshot.appendItems([3], toSection: .Stats)
    source.apply(snapshot, animatingDifferences: false)
  }
  
  func setTasks() {
    
  }
}
