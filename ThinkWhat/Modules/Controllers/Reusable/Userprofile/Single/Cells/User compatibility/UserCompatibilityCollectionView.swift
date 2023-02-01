//
//  UserCompatibilityCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

final class UserCompatibilityCollectionView: UICollectionView {
  enum Section: Int, CaseIterable {
    case Header, Details
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
  @Published public var color: UIColor = .clear
  public let foldPublisher = PassthroughSubject<Bool, Never>()
  public let refreshPublisher = PassthroughSubject<Bool, Never>()
  public let foldDetailsPublisher = PassthroughSubject<Bool, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //Collection
  private var source: Source!
  //Logic
  private var showDetails = false {
    didSet {
      guard oldValue != showDetails else { return }
      
      disclose()
    }
  }
  
  
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

private extension UserCompatibilityCollectionView {
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
    
    let headerCellRegistration = UICollectionView.CellRegistration<UserCompatibilityHeaderCell, AnyHashable> { [unowned self] cell, indexPath, item in
      cell.userprofile = self.userprofile
      
      self.$color
        .filter { $0 != .clear }
        .sink {
          cell.color = $0
        }
        .store(in: &self.subscriptions)
      
      cell.$showDetails
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in
            self.showDetails = $0
        }
        .store(in: &self.subscriptions)
//      self.colorPublisher
//        .filter { !$0.isNil }
//        .sink {
//          cell.color = $0!
//        }
//        .store(in: &self.subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let detailsCellRegistration = UICollectionView.CellRegistration<TopicCompatibilityHeaderCell, AnyHashable> { [unowned self] cell, indexPath, item in
      cell.compatibility = self.userprofile.compatibility

      
//      self.foldDetailsPublisher
//        .sink { [weak self] _ in
//          guard let self = self else { return }
//
//          self.foldDetailsPublisher.send(true)
//        }
//        .store(in: &self.subscriptions)
      
      self.$color
        .filter { $0 != .clear }
        .sink {
          cell.color = $0
        }
        .store(in: &self.subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
      
      if section == .Header {
        return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Details {
        return collectionView.dequeueConfiguredReusableCell(using: detailsCellRegistration,
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
      .Header,
      .Details
    ])
    snapshot.appendItems([0], toSection: .Header)
    source.apply(snapshot, animatingDifferences: false)
  }
  
  func disclose() {
    var snapshot = source.snapshot()
    if showDetails {
      if snapshot.itemIdentifiers(inSection: .Details).isEmpty {
        snapshot.appendItems([1], toSection: .Details)
      } else {
        self.foldPublisher.send(false)
      }
    } else if !showDetails{
      self.foldPublisher.send(true)
    }
    source.apply(snapshot, animatingDifferences: true)
    refreshPublisher.send(true)
  }
}
