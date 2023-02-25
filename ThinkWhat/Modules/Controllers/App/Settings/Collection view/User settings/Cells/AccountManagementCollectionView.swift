//
//  AccountManagementCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AccountManagementCollectionView: UICollectionView {
  
  enum Section: Int, CaseIterable { case Logout, Delete }
  
  typealias Source = UICollectionViewDiffableDataSource<Section, Int>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Int>
  
  
  // MARK: - Public properties
  ///`Publishers`
  public let logoutPublisher = PassthroughSubject<Bool, Never>()
  public let deletePublisher = PassthroughSubject<Bool, Never>()
  
  
  
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
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension AccountManagementCollectionView {
  @MainActor
  func setupUI() {
    collectionViewLayout = UICollectionViewCompositionalLayout{ [unowned self] section, environment -> NSCollectionLayoutSection in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: self.padding, leading: 0, bottom: self.padding, trailing: 0)
      return sectionLayout
    }

    let cellRegistration = UICollectionView.CellRegistration<AccountManagementCell, AnyHashable> { [weak self] cell, indexPath, _ in
      guard let self = self,
            let section = Section(rawValue: indexPath.section)
      else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.mode = section == .Logout ? .Logout : .Delete
      cell.tapPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          switch $0 {
          case .Logout:
            self.logoutPublisher.send(true)
          case .Delete:
            self.deletePublisher.send(true)
          }
        }
        .store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self) {
      (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                   for: indexPath,
                                                   item: identifier)
    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([
      .Logout,
      .Delete
    ])
    snapshot.appendItems([0], toSection: .Logout)
    snapshot.appendItems([1], toSection: .Delete)
    source.apply(snapshot, animatingDifferences: false)
  }
}
