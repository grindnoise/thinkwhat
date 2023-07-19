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
    case Credentials, Compatibility, Info, /*About,  Interests, */ Stats
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
  ///**Publishers**
  public let urlPublisher = PassthroughSubject<URL, Never>()
  public var subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public var imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  public let topicPublisher = PassthroughSubject<Topic, Never>()
  public let publicationsPublisher = PassthroughSubject<Userprofile, Never>()
  public let commentsPublisher = PassthroughSubject<Userprofile, Never>()
  public let subscribersPublisher = PassthroughSubject<Userprofile, Never>()
  public let subscriptionsPublisher = PassthroughSubject<Userprofile, Never>()
  public let colorPublisher = CurrentValueSubject<UIColor?, Never>(nil)
  public let disclosurePublisher = PassthroughSubject<TopicCompatibility, Never>()
  ///**UI**
  public var color: UIColor = .label {
    didSet {
      colorPublisher.send(color)
    }
  }
  

  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`Collection`
  private var source: Source!
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
    collectionViewLayout = UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection in
      
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                            leading: 0,
                                                            bottom: section == Section.allCases.count-1 ? 80 : 0,
                                                            trailing: 0)
      return sectionLayout
    }
    
//    let aboutCellRegistration = UICollectionView.CellRegistration<UserInfoCell, AnyHashable> { [unowned self] cell, _, _ in
//      guard let userprofile = self.userprofile else { return }
//
//      cell.userprofile = userprofile
//      cell.$boundsPublisher
////        .eraseToAnyPublisher()
//        .filter { !$0.isNil }
//        .sink { [unowned self] in
//          self.source.refresh(animatingDifferences: $0!)}
//        .store(in: &self.subscriptions)
//    }
    
    let infoCellRegistration = UICollectionView.CellRegistration<UserSettingsInfoCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.insets = .init(top: self.padding*2, left: self.padding*2, bottom: self.padding*2, right: self.padding*2)
      cell.userprofile = self.userprofile
      cell.isShadowed = true
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
      cell.openURLPublisher
        .sink { [unowned self] in self.urlPublisher.send($0) }
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
    
    let compatibilityCellRegistration = UICollectionView.CellRegistration<UserCompatibilityCell, AnyHashable> { [unowned self] cell, _, _ in
      guard let userprofile = self.userprofile else { return }
      
      cell.insets = .init(top: self.padding, left: self.padding*2, bottom: self.padding, right: self.padding*2)
      cell.isShadowed = !userprofile.isCurrent
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)

      cell.refreshPublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      
      cell.disclosurePublisher
        .sink { [unowned self] in self.disclosurePublisher.send($0) }
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
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
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
    }
    
//    let interestsCellRegistration = UICollectionView.CellRegistration<UserInterestsCell, AnyHashable> { [unowned self] cell, indexPath, item in
//      guard let userprofile = self.userprofile else { return }
//
//      cell.color = self.color
//      cell.insets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
//      self.colorPublisher
//        .filter { !$0.isNil }
//        .sink {
//          cell.color = $0!
//        }
//        .store(in: &self.subscriptions)
//      cell.topicPublisher
//        .sink { [weak self] in
//          guard let self = self else { return }
//
//          self.topicPublisher.send($0)
//        }
//        .store(in: &subscriptions)
//
//      var config = UIBackgroundConfiguration.listPlainCell()
//      config.backgroundColor = .clear
//      cell.backgroundConfiguration = config
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//      cell.userprofile = userprofile
//    }
    
    let statsCellRegistration = UICollectionView.CellRegistration<UserStatsCell, AnyHashable> { [unowned self] cell, _, _ in
      guard let userprofile = self.userprofile else { return }
      
      cell.userprofile = userprofile
      cell.isShadowed = true
      cell.insets = UIEdgeInsets(top: self.padding*1, left: self.padding*2, bottom: self.padding*1, right: self.padding*2)
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
      
      cell.subscriptionsPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.subscriptionsPublisher.send($0)
        }
        .store(in: &subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
      
      if section == .Credentials {
        return collectionView.dequeueConfiguredReusableCell(using: credentialsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
//      } else if section == .Interests {
//        return collectionView.dequeueConfiguredReusableCell(using: interestsCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
      } else if section == .Stats {
        return collectionView.dequeueConfiguredReusableCell(using: statsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Compatibility {
        return collectionView.dequeueConfiguredReusableCell(using: compatibilityCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
//      } else if section == .About {
//        return collectionView.dequeueConfiguredReusableCell(using: aboutCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
      } else if section == .Info {
        return collectionView.dequeueConfiguredReusableCell(using: infoCellRegistration,
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
      .Info,
      .Stats,
    ])
    snapshot.appendItems([0], toSection: .Credentials)
//    if !userprofile.description.isEmpty {
//      snapshot.appendSections([
//        .About,
//      ])
//      snapshot.appendItems([1], toSection: .About)
//    }
//    snapshot.appendSections([
//      .Compatibility,
//      .Interests,
//      .Stats,
//    ])
    //    snapshot.appendItems([1], toSection: .Credentials)
    snapshot.appendItems([1], toSection: .Compatibility)
    snapshot.appendItems([2], toSection: .Info)
    snapshot.appendItems([3], toSection: .Stats)
    source.apply(snapshot, animatingDifferences: false)
  }
  
  func setTasks() {
    
  }
}
