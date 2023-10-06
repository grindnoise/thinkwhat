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
  private var color: UIColor {
    didSet {
      guard oldValue != color else { return }
      
      colorPublisher.send(color)
    }
  }
  private let contentInsets: UIEdgeInsets
  ///**Logic**
  private let dataItems: [SurveyFilterItem]
  private var source: Source!
  private let colorPublisher = PassthroughSubject<UIColor, Never>()
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
    debugPrint("\(String(describing: type(of: self))).\(#function) \(DebuggingIdentifiers.actionOrEventFailed)")
  }
  
  // MARK: - Initialization
  init(items: [SurveyFilterItem], color: UIColor = Colors.filterEnabled, contentInsets: UIEdgeInsets = .zero) {
    self.dataItems = items
    self.color = color
    self.contentInsets = contentInsets
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  public func setColor(_ color: UIColor) {
    self.color = color
  }
  
  /// Resets all filters and scrolls to the first and selects it
  public func resetFilters() {
    // Capture data items
    let items = source.snapshot().itemIdentifiers
    
    // Check if data source is not empty to scroll to the first row
    guard !items.count.isZero else { return }
    
    // Disable filters for all data items
    items.forEach { $0.setDisabled() }
    
    // Scroll to the first row
    scrollToItem(at: .init(row: 0, section: 0), at: .centeredHorizontally, animated: true)
    
    // Select first row and set filter enabled with light delay
    delay(seconds: 0.5) { [weak self] in
      guard let self = self,
            let cell = self.cellForItem(at: .init(row: 0, section: 0)) as? SurveyFilterCell
      else { return }
      
      cell.item.setEnabled()
    }
  }
}

private extension SurveyFiltersCollectionView {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    alwaysBounceVertical = false
    alwaysBounceHorizontal = true
    showsHorizontalScrollIndicator = false
    showsHorizontalScrollIndicator = false
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
      section.contentInsets.leading = self.contentInsets.left
      section.contentInsets.trailing = self.contentInsets.right
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
//      if cell.item.isNil {
//        cell.setupUI(item: item)
//      }
      
//      if cell.item != item {
        cell.item = item
//      }
      
      cell.color = self.color
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      cell.filterPublisher
        .throttle(for: .seconds(0.2), scheduler: DispatchQueue.main, latest: false)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }

          self.source.snapshot().itemIdentifiers
            .filter { $0 != item }
            .forEach { $0.setDisabled() }
          self.filterPublisher.send($0)
          if item.isFilterEnabled {
            self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
          }
        }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .throttle(for: .seconds(0.2), scheduler: DispatchQueue.main, latest: false)
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.collectionViewLayout.invalidateLayout()
        }
        .store(in: &self.subscriptions)
      
      self.colorPublisher
        .sink { cell.color = $0 }
        .store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([.main,])
    snapshot.appendItems(dataItems, toSection: .main)
    source.apply(snapshot, animatingDifferences: false)
    
    collectionViewLayout.invalidateLayout()
  }
  
  func setTasks() {
    
  }
}
