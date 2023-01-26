//
//  UserStatsCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserStatsCollectionView: UICollectionView {
  
  enum Section: Int, CaseIterable {
    case DateJoined,
         Subscribers,
         Publications,
         VotesReceived,
         CommentsReceived,
         Completed,
         CommentsPosted
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
  //UI
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
  init(color: UIColor) {
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setTasks()
    
    self.color = color
  }
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
    
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension UserStatsCollectionView {
  @MainActor
  func setupUI() {
    
    collectionViewLayout = UICollectionViewCompositionalLayout{ [unowned self] section, environment -> NSCollectionLayoutSection in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
//      return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: self.padding, leading: 0, bottom: self.padding, trailing: 0)
//      sectionLayout.interGroupSpacing = 8
      return sectionLayout
    }
    
    let dateJoinedCellRegistration = UICollectionView.CellRegistration<UserStatsPlainCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.color = self.color
      cell.mode = .DateJoined
      cell.userprofile = userprofile
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    let publicationsCellRegistration = UICollectionView.CellRegistration<UserStatsPlainCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.mode = .Publications
      cell.userprofile = userprofile

      cell.buttonPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }

          self.publicationsPublisher.send(self.userprofile)
        }
        .store(in: &self.subscriptions)
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    let votesReceivedCellRegistration = UICollectionView.CellRegistration<UserStatsPlainCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.mode = .Votes
      cell.userprofile = userprofile
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    let commentsCellRegistration = UICollectionView.CellRegistration<UserStatsPlainCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.mode = .CommentsPosted
      cell.userprofile = userprofile

      cell.buttonPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }

          self.commentsPublisher.send(self.userprofile)
        }
        .store(in: &self.subscriptions)
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    let commentsReceivedCellRegistration = UICollectionView.CellRegistration<UserStatsPlainCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.mode = .CommentsReceived
      cell.userprofile = userprofile
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    let completedCellRegistration = UICollectionView.CellRegistration<UserStatsPlainCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.mode = .Completed
      cell.userprofile = userprofile
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    let subscribersCellRegistration = UICollectionView.CellRegistration<UserStatsPlainCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.mode = .Subscribers
      cell.userprofile = userprofile

      cell.buttonPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }

          self.subscribersPublisher.send(self.userprofile)
        }
        .store(in: &self.subscriptions)
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self) {
      (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
      guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
      
      if section == .DateJoined {
        return collectionView.dequeueConfiguredReusableCell(using: dateJoinedCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Publications {
        return collectionView.dequeueConfiguredReusableCell(using: publicationsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .VotesReceived {
        return collectionView.dequeueConfiguredReusableCell(using: votesReceivedCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .CommentsReceived {
        return collectionView.dequeueConfiguredReusableCell(using: commentsReceivedCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .CommentsPosted {
        return collectionView.dequeueConfiguredReusableCell(using: commentsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Completed {
        return collectionView.dequeueConfiguredReusableCell(using: completedCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Subscribers {
        return collectionView.dequeueConfiguredReusableCell(using: subscribersCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Subscribers {
        return collectionView.dequeueConfiguredReusableCell(using: subscribersCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      }
      
      return UICollectionViewCell()
    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([
      .DateJoined,
      .Subscribers,
      .Publications,
      .VotesReceived,
      .CommentsReceived,
      .Completed,
      .CommentsPosted
    ])
    snapshot.appendItems([0], toSection: .DateJoined)
    snapshot.appendItems([1], toSection: .Subscribers)
    snapshot.appendItems([2], toSection: .Publications)
    snapshot.appendItems([3], toSection: .VotesReceived)
    snapshot.appendItems([4], toSection: .CommentsReceived)
    snapshot.appendItems([5], toSection: .Completed)
    snapshot.appendItems([6], toSection: .CommentsPosted)
    
    source.apply(snapshot, animatingDifferences: false)
  }
  
  func setTasks() {
    
  }
}

