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
    case DateJoined
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
  public let somePublisher = PassthroughSubject<AnyObject, Never>()
  
  
  
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

private extension UserStatsCollectionView {
  @MainActor
  func setupUI() {
    
    collectionViewLayout = UICollectionViewCompositionalLayout{ section, environment -> NSCollectionLayoutSection in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
    }
    
    let dateJoinedCellRegistration = UICollectionView.CellRegistration<UserStatsPlainCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let userprofile = self.userprofile else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.userprofile = userprofile
      
//      cell.urlPublisher
//        .sink { [weak self] in
//          guard let self = self,
//                let image = $0
//          else { return }
//
//          self.urlPublisher.send(image)
//        }
//        .store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self) { [unowned self]
      (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
      guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
      
      if section == .DateJoined {
        return collectionView.dequeueConfiguredReusableCell(using: dateJoinedCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
//      } else if section == .Interests {
//        return collectionView.dequeueConfiguredReusableCell(using: interestsCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      } else if section == .Stats {
//        return collectionView.dequeueConfiguredReusableCell(using: statsCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
      }
      
      return UICollectionViewCell()
    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([
      .DateJoined,
    ])
    snapshot.appendItems([0], toSection: .DateJoined)
//    snapshot.appendItems([1], toSection: .Interests)
//    snapshot.appendItems([2], toSection: .Stats)
    source.apply(snapshot, animatingDifferences: false)
  }
  
  func setTasks() {
    
  }
}

