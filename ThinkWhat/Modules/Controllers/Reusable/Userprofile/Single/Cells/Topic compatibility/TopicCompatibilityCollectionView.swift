//
//  TopicCompatibilityCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

final class TopicCompatibilityCollectionView: UICollectionView {
  enum Section: Int, CaseIterable {
    case Main
  }
  
  typealias Source = UICollectionViewDiffableDataSource<Section, TopicCompatibility>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TopicCompatibility>
  
  
  
  // MARK: - Public properties
  public var compatibility: UserCompatibility! {
    didSet {
      setupUI()
    }
  }
//  public var userprofile: Userprofile! {
//    didSet {
//      guard !userprofile.isNil else { return }
//
//      setupUI()
//    }
//  }
  //Publishers
  @Published public var color: UIColor = .clear
//  public let refreshPublisher = PassthroughSubject<Bool, Never>()
  
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
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension TopicCompatibilityCollectionView {
  @MainActor
  func setupUI() {
    collectionViewLayout = UICollectionViewCompositionalLayout{ section, environment -> NSCollectionLayoutSection in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
      return sectionLayout
    }
    
    let cellRegistration = UICollectionView.CellRegistration<TopicCompatibilityCell, AnyHashable> { [unowned self] cell, indexPath, item in
      cell.compatibility = self.compatibility.details[indexPath.row]
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    //        source.supplementaryViewProvider = {
    //            collectionView, elementKind, indexPath -> UICollectionReusableView? in
    //
    //            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistraition, for: indexPath)
    //        }
    
    
    var snapshot = Snapshot()
    snapshot.appendSections([
      .Main,
//      .Details
    ])
    snapshot.appendItems(compatibility.details, toSection: .Main)
    source.apply(snapshot, animatingDifferences: false)
  }
}

