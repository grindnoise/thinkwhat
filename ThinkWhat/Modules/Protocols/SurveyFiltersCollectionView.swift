//
//  SurveyFiltersCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.08.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveyFiltersCollectionView: UICollectionView {
  
  enum Section: Int { case main }
  
  typealias Source = UICollectionViewDiffableDataSource<Section, SurveyFilterItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SurveyFilterItem>
  
  // MARK: - Public properties
  public let filterPublisher = PassthroughSubject<SurveyFilterItem, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  ///**Logic**
  private var period = Enums.Period.unlimited {
    didSet {
      
    }
  }
  private let anonymityEnabled: Bool
  private var source: Source!
 
  // MARK: - Initialization
  init(anonymityEnabled: Bool) {
    self.anonymityEnabled = anonymityEnabled
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension SurveyFiltersCollectionView {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    alwaysBounceVertical = false
    alwaysBounceHorizontal = true
//    bounces = true
    
    collectionViewLayout = UICollectionViewCompositionalLayout { [unowned self] section, env -> NSCollectionLayoutSection? in
      let layoutSize = NSCollectionLayoutSize(
        widthDimension: .estimated(100),
        heightDimension: .fractionalHeight(1))
      
      let item = NSCollectionLayoutItem(
        layoutSize: layoutSize)
//      item.contentInsets = .init(horizontal: 10, vertical: 5)
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: layoutSize,
        subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = self.padding/2
      section.contentInsets.trailing = self.padding
      section.orthogonalScrollingBehavior = .continuous

      return section
    }
    
//    let config = UICollectionViewCompositionalLayoutConfiguration()
//    config.interSectionSpacing = 20
//    config.scrollDirection = .horizontal
//
//    let layout = UICollectionViewCompositionalLayout { [unowned self] section, env -> NSCollectionLayoutSection? in
//      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
//      configuration.backgroundColor = .clear
//      configuration.showsSeparators = false
//      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
//      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//      sectionLayout.interGroupSpacing = self.padding
//
//      return sectionLayout
//    }
//
//    layout.configuration = config
//    collectionViewLayout = layout
    
    let cellRegistration = UICollectionView.CellRegistration<SurveyFilterCell, SurveyFilterItem> { [unowned self] cell, indexPath, item in
      cell.setupUI(item: item)
      item.$isFilterEnabled
        .filter { $0 }
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.source.snapshot().itemIdentifiers
            .filter { $0 != item }
            .forEach { $0.setDisabled() }
        }
        .store(in: &self.subscriptions)
      
      cell.filterPublisher
        .sink { [unowned self] in self.filterPublisher.send($0) }
        .store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([.main,])
    snapshot.appendItems([
      SurveyFilterItem(mode: .all, isFilterEnabled: true, text: "all"),
      SurveyFilterItem(mode: .period, text: "filter_per_\(Enums.Period.unlimited.description)", image: UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small))),
      SurveyFilterItem(mode: .discussed, text: "filter_discussed"),
      SurveyFilterItem(mode: .completed, text: "filter_completed"),
      SurveyFilterItem(mode: .notCompleted, text: "filter_not_completed")
    ], toSection: .main)
    source.apply(snapshot, animatingDifferences: false)
    
    collectionViewLayout.invalidateLayout()
  }
  
  func setTasks() {
    
  }
}
