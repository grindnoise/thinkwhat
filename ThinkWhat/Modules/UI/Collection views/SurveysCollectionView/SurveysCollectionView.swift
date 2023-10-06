//
//  SurveysCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveysCollectionView: UICollectionView {
  typealias Source = UICollectionViewDiffableDataSource<Section, SurveyReference>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>
  
  // MARK: - Enums
  enum Section {
    case main, loader
  }

  // MARK: - Public properties
  public var isOnScreen = true
  
  ///**Publishers**
  public let watchSubject = CurrentValueSubject<SurveyReference?, Never>(nil) // Add to favorite
  public let claimSubject = CurrentValueSubject<SurveyReference?, Never>(nil) // Make complaint
  public let shareSubject = CurrentValueSubject<SurveyReference?, Never>(nil) // Share
  public let paginationPublisher = PassthroughSubject<[SurveyReference], Never>() // Request items (excluded items array)
  public let refreshPublisher = PassthroughSubject<Void, Never>() // Refresh all
  public let selectionPublisher = CurrentValueSubject<SurveyReference?, Never>(nil) // Select item
  public let updateStatsPublisher = CurrentValueSubject<[SurveyReference]?, Never>(nil)
  public let subscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public let unsubscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public let userprofilePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public let settingsTapPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public let scrolledDownPublisher = PassthroughSubject<Bool, Never>()
  public let scrolledToTopPublisher = PassthroughSubject<Void, Never>()
  public let deinitPublisher = PassthroughSubject<Bool, Never>()
  public let emptyPublicationsPublisher = CurrentValueSubject<Bool?, Never>(nil)
  ///**UI**
  public var color: UIColor = Colors.main {
    didSet {
      guard oldValue != color else { return }
      
      colorPublisher.send(color)
    }
  }
  
  // MARK: - Private properties
  ///**Publishers**
  private let applyDataSnapshotPublisher = PassthroughSubject<[String: Any], Never>()
  private let applyLoaderSnapshotPublisher = PassthroughSubject<[Bool: Closure], Never>()
  ///**Logic**
  private let lock = NSRecursiveLock() // Lock
  private var loaderStartedAt = Date() // Timestamp to stop loader footer after threshold
  private var isApplyingSnapshot = false
  private var isRequesting = false {
    didSet {
      guard oldValue != isRequesting//,
//            filter.getMain() != .search
      else { return }
      
      debugPrint("Request \(isRequesting ? "started" : "ended") \(isRequesting ? DebuggingIdentifiers.processingBegan : DebuggingIdentifiers.processingEnded)")
//      isRequestingPublisher.send(isRequesting)
      lock.lock()
      
      let snap = source.snapshot()
      if isRequesting, snap.sectionIdentifiers.filter({ $0 == .loader }).isEmpty {
        loaderStartedAt = Date()
//        snap.appendSections([.loader])
        applyLoaderSnapshotPublisher.send([true : { [weak self] in
            guard let self = self else { return }

            self.isRequestingPublisher.send(self.isRequesting)
          }])
//        apply(source: self.source, snapshot: snap) { [weak self] in
//          guard let self = self else { return }
//
//          self.isRequestingPublisher.send(self.isRequesting)
//        }
      } else if !isRequesting, !snap.sectionIdentifiers.filter({ $0 == .loader }).isEmpty {
        applyLoaderSnapshotPublisher.send([false : { [weak self] in
            guard let self = self else { return }

            self.isRequestingPublisher.send(self.isRequesting)
          }])
//        snap.deleteSections([.loader])
//        applyDataSourcePublisher.send([
//          "snapshot": snap,
//          "completion" : { [weak self] in
//            guard let self = self else { return }
//
//            self.isRequestingPublisher.send(self.isRequesting)
//          }
//        ])
//        apply(source: self.source, snapshot: snap) { [weak self] in
//          guard let self = self else { return }
//
//          self.isRequestingPublisher.send(self.isRequesting)
//        }
      }
    }
  }
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private lazy var dataItems = filter.getDataItems()
  private let filter: SurveyFilter // Use to filter dataItems
  private var source: Source!
  private let isRequestingPublisher = CurrentValueSubject<Bool, Never>(false)
  private var searchMode = Enums.SearchMode.off
  private let topicMode: Bool // Use in topics controller only
  private var reloadAnimationsEnabled = true // Flag to control animatingDifference
  ///**UI**
  private var showSeparators: Bool = false
  private let padding: CGFloat = 8
  private lazy var spinner: SpiralSpinner = { SpiralSpinner() }()
  private let colorPublisher = PassthroughSubject<UIColor, Never>()
  ///Scroll direction
  private var lastStopYPoint: CGFloat = .zero
  private var lastContentOffsetY: CGFloat = 0 {
    didSet {
      guard !source.snapshot().itemIdentifiers.isEmpty else { return }
      
      isScrollingDown = lastContentOffsetY > oldValue
      
      ///Pagination
      if isScrollingDown,
         contentSize.height > bounds.height,
         lastContentOffsetY + bounds.height > contentSize.height,
         !isRequesting {
        requestData()
      }
      
      guard lastContentOffsetY > 0 else { scrolledToTopPublisher.send(); return }
      
      let distance = lastStopYPoint - lastContentOffsetY
      let threshold: CGFloat = 50
      
      guard abs(distance) > threshold  else { return }
      
//      scrolledDownPublisher.send(distance > 0 ? false : true)
      scrolledDownPublisher.send(isScrollingDown)
    }
  }
  private var isScrollingDown = true // Indicates scrolling direction
  private var loadingInProgress = false
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
    debugPrint("\(String(describing: type(of: self))).\(#function) \(DebuggingIdentifiers.destructing)")
  }
  
  // MARK: - Initialization
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    fatalError("init(frame:) has not been implemented")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(filter: SurveyFilter, 
       color: UIColor? = nil,
       showSeparators: Bool = false,
       topicMode: Bool = false) {
    self.filter = filter
    self.showSeparators = showSeparators
    self.color = color ?? .secondaryLabel
    self.topicMode = topicMode
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setTasks()
    setupUI()
  }
  
  // MARK: - Public methods
  /// On `didAppear` event
  public func didAppear() {
//    guard category != .Subscriptions, source.snapshot().itemIdentifiers.isEmpty else { return }
//
//    emptyPublicationsView.setAnimationsEnabled(true)
  }
  
  /// On `didDisappear` event
  public func didDisappear() {
//    guard category != .Subscriptions else { return }
//
//    emptyPublicationsView.setAnimationsEnabled(false)
  }
  
  /// Stops spiral spinner
  @MainActor @objc
  public func beginSearchRefreshing() {
    spinner.start(duration: 1)
  }
  
  /// Stops spiral spinner
  @MainActor
  @objc
  public func endSearchRefreshing() {
    delay(seconds: 2) { [weak self] in
      guard let self = self else { return }
      
      self.spinner.stop()
    }
  }
  
  @MainActor
  public func scrollToTop() {
    guard !source.snapshot().itemIdentifiers.isEmpty else { return }
    
    scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)
  }
  
  /// Sets fetch result as data source
  /// - Parameter fetchResult: array of fetched objects
  public func setSearchResult(_ fetchResult: [SurveyReference]) {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(fetchResult, toSection: .main)
    
    
    applyDataSnapshotPublisher.send([
      "snapshot": snapshot,
    ])
//    apply(source: source,
//          snapshot: snapshot,
//          animatingDifferences: true)
  }
  
  public func setSearchModeEnabled(_ enabled: Bool) {
    enabled ? { refreshControl = nil }() : setRefreshControl()
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(enabled ? [] : dataItems, toSection: .main)
    
    // Set search mode flag
    searchMode = enabled ? .on : .off
    
    // Apply new snapshot
    applyDataSnapshotPublisher.send([
      "snapshot": snapshot,
    ])
//    apply(source: source,
//          snapshot: snapshot,
//          animatingDifferences: true)
  }
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
//    guard category != .Subscriptions else { return }
//
//    emptyPublicationsView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
  }
}

extension SurveysCollectionView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    lastContentOffsetY = scrollView.contentOffset.y
    
//    guard let verticalIndicator = scrollView.subviews[(scrollView.subviews.count - 1)] as? UIImageView else { return }
//    verticalIndicator.backgroundColor = color
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    lastStopYPoint = scrollView.contentOffset.y
  }
}

extension SurveysCollectionView: UICollectionViewDelegate {
  func deselect() {
    guard let indexPath = indexPathsForSelectedItems?.first else { return }
    deselectItem(at: indexPath, animated: false)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? SurveyCell {
      selectionPublisher.send(cell.item)
    }
    deselect()
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//    switch filter.getMain() {
//    case .topic:
//      if dataItems.count < 10, let topic = filter.topic, topic.activeCount > dataItems.count {
//        requestData()
//      }
//    case .user:
//      if dataItems.count < 10, let userprofile = filter.userprofile, userprofile.publicationsTotal > dataItems.count {
//        requestData()
//      }
//    default:
//#if DEBUG
//      print("")
//#endif
//    }
//
//    guard filter.getMain() != .search, isScrollingDown, !isRequesting else { return }
//
//    let max = source.snapshot().itemIdentifiers.count-1
//
//    if max < 10 {
//      requestData()
//    } else if max > 0 {
//
//      let requestThreshold = max > 5 ? 5 : max-1
//      let triggerRange = max-requestThreshold..<max-1
//
//      guard triggerRange.contains(indexPath.row) else { return }
//
//      requestData()
//    }
    
    guard isScrollingDown, !isRequesting else { return }
    
//    if dataItems.count < 10 {
//      requestData()
    /*/} else*/ if (source.snapshot().itemIdentifiers.count - AppSettings.Pagination.threshold == indexPath.row) && indexPath.row > 1 || // Preload data
                (source.snapshot().itemIdentifiers.count - 1 == indexPath.row) {
      requestData()
    }
  }
}

private extension SurveysCollectionView {
  @MainActor
  func setupUI() {
    delegate = self
    setRefreshControl()
    
    collectionViewLayout = UICollectionViewCompositionalLayout { [unowned self] section, env -> NSCollectionLayoutSection? in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = showSeparators
      configuration.footerMode = section == 0 ? .none : .supplementary
      if #available(iOS 14.5, *) {
        configuration.itemSeparatorHandler = { indexPath, config -> UIListSeparatorConfiguration in
          var config = UIListSeparatorConfiguration(listAppearance: .plain)
          config.topSeparatorVisibility = .hidden
//          config.bottomSeparatorInsets = .init(top: 0, leading: 0, bottom: 2, trailing: 0)
          if indexPath.row != self.source.snapshot().itemIdentifiers.count - 1 {
            config.bottomSeparatorVisibility = .visible
          } else {
            config.bottomSeparatorVisibility = .hidden
          }
          return config
        }
      }
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
      sectionLayout.interGroupSpacing = showSeparators ? 0 : self.padding
      
      return sectionLayout
    }
    
    let mainFilter = filter.getMain()
    
    contentInset.bottom = (mainFilter == .user || mainFilter == .topic || mainFilter == .own) ? 80 : 0
    
    let cellRegistration = UICollectionView.CellRegistration<SurveyCell, SurveyReference> { [unowned self] cell, indexPath, item in
      cell.item = item
      cell.subscribePublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.subscribePublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      cell.unsubscribePublisher
        .sink { [weak self] in
          guard let self = self,
                let userprofile = $0
          else { return }
          
          self.unsubscribePublisher.send(userprofile)
        }
        .store(in: &self.subscriptions)
      
      cell.profileTapPublisher
        .sink { [weak self] in
          guard let self = self,
                let userprofile = $0
          else { return }
          
          self.userprofilePublisher.send(userprofile)
        }
        .store(in: &self.subscriptions)
      
      cell.settingsTapPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.settingsTapPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      //Add to watchlist
      cell.watchSubject
        .sink { [weak self] in
          guard let self = self,
                !$0.isNil
          else { return }
          
          guard $0!.isComplete else {
            let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                                  text: "finish_poll",
                                                                  tintColor: .systemOrange,
                                                                  fontName: Fonts.Semibold,
                                                                  textStyle: .headline,
                                                                  textAlignment: .natural),
                                   contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                   isModal: false,
                                   useContentViewHeight: true,
                                   shouldDismissAfter: 2)
            banner.didDisappearPublisher
              .sink { _ in banner.removeFromSuperview() }
              .store(in: &self.subscriptions)
            
            return
          }
          
          self.watchSubject.send($0)
        }.store(in: &self.subscriptions)
      
      //Share
      cell.shareSubject
        .sink { [weak self] in
          guard let self = self,
                !$0.isNil
          else { return }
          
          self.shareSubject.send($0)
        }
        .store(in: &self.subscriptions)
      
      //Claim
      cell.claimSubject
        .sink { [weak self] in
          guard let self = self,
                !$0.isNil
          else { return }
          
          self.claimSubject.send($0)
        }
        .store(in: &self.subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear//self.traitCollection.userInterfaceStyle == .dark ? Colors.surveyCellDark : Colors.surveyCellLight
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let loaderRegistration = UICollectionView.SupplementaryRegistration<LoaderCell>(elementKind: UICollectionView.elementKindSectionFooter) { [unowned self] supplementaryView,_,_ in
      
//      supplementaryView.setupUI()
      supplementaryView.color = self.color
      
      self.colorPublisher
        .sink { supplementaryView.color = $0 }
        .store(in: &self.subscriptions)
      
      self.isRequestingPublisher
        .receive(on: DispatchQueue.main)
        .throttle(for: .seconds(0.1), scheduler: DispatchQueue.main, latest: false)
        .sink { supplementaryView.isLoading = $0 }
        .store(in: &self.subscriptions)
      
      self.deinitPublisher
        .sink { _ in supplementaryView.cancelAllAnimations() }
        .store(in: &self.subscriptions)
    }
    
    source = UICollectionViewDiffableDataSource<Section, SurveyReference>(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    source.supplementaryViewProvider = { collectionView, elementKind, indexPath -> UICollectionReusableView? in
      collectionView.dequeueConfiguredReusableSupplementary(using: loaderRegistration, for: indexPath)
    }
    
//    if category != .Subscriptions {
//      addSubview(emptyPublicationsView)
////      emptyPublicationsView.translatesAutoresizingMaskIntoConstraints = false
////      emptyPublicationsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
////      emptyPublicationsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
////      emptyPublicationsView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
////      emptyPublicationsView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
////      emptyPublicationsView.place(inside: self)
//    }
    
    // If empty, then request with small delay
    if dataItems.isEmpty {
      delay(seconds: 0.1) { [weak self] in
        guard let self = self else { return }
       
        self.requestData()
      }
    } else if self.filter.getMain() == .topic, let topic = self.filter.topic {
      // If topic active publications count is not equal to data items count
      // than request data
      if topic.activeCount != dataItems.count {
        requestData()
      }
    }
    
    setDataSource(animatingDifferences: false)
  }
  
  func setTasks() {
    // Toggle loader throttled
    applyLoaderSnapshotPublisher
      .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
      .filter { !$0.isEmpty }
      .sink { [weak self] in
        guard let self = self else { return }
        
        var snap = self.source.snapshot()
        let append = $0.keys.first!
        // Check if loader isn't presented
        if append && snap.sectionIdentifiers.filter({ $0 == .loader }).isEmpty {
          snap.appendSections([.loader])
        } else if !append && !snap.sectionIdentifiers.filter({ $0 == .loader }).isEmpty {
          snap.deleteSections([.loader])
        } else { return }
        
        let completion = $0.values.first
        self.apply(snapshot: snap, animatingDifferences: true) { completion?() }
      }
      .store(in: &subscriptions)
    
    // Apply snapshot throttled
    applyDataSnapshotPublisher
      .throttle(for: .seconds(0.25), scheduler: DispatchQueue.main, latest: true)
      .filter { !$0.isEmpty }
      .sink { [weak self] in
        guard let self = self,
              let snapshot = $0["snapshot"] as? Snapshot
        else { return }
        
        let completion = $0["completion"] as? Closure
        let animatingDifferences = $0["animatingDifferences"] as? Bool ?? true
        self.apply(snapshot: snapshot, animatingDifferences: animatingDifferences) { completion?() }
      }
      .store(in: &subscriptions)
    
    // This case is used in TopicsView when user taps topic,
    // then we need to temporary turn off reload animations
    filter.topicPublisher
      .filter { !$0.isNil}
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.reloadAnimationsEnabled = false
        delay(seconds: 0.2) { [weak self] in
          guard let self = self else { return }
          
          self.reloadAnimationsEnabled = true
        }
      }
      .store(in: &subscriptions)
    
    ///Update data items when filter changes
    filter.changePublisher
      .filter { [unowned self] _ in self.searchMode == .off }
      .receive(on: DispatchQueue.main)
//      .throttle(for: .seconds(0.1), scheduler: DispatchQueue.main, latest: false)
      .sink { [unowned self] in
        
        // If topic case
        if self.filter.getMain() == .topic, let topic = self.filter.topic {
          
          // Set color for loader
          self.color = topic.tagColor
          
          // If topic active publications count is not equal to 
          // data items count then request data
          if topic.totalCount != $0.count {
            self.requestData()
          }
        }
        
        // Update data source
        self.dataItems = $0
        
        // Disable animations in topic mode
        self.setDataSource(animatingDifferences: reloadAnimationsEnabled/*self.filter.topic.isNil*/)
      }
      .store(in: &subscriptions)
    
    ///**Updaters**
//    ///Load data if zero items
//    Timer
//      .publish(every: 10, on: .current, in: .common)
//      .autoconnect()
//      .filter { [weak self] seconds in
//        guard let self = self,
//              !self.isRequesting,
//              self.filter.getMain() != .search,
//              let cells = self.visibleCells as? [SurveyCell],
//              cells.isEmpty
//        else { return false }
//
//        return true
//      }
//      .sink { [unowned self] _ in self.paginationPublisher.send([]); self.emptyPublicationsPublisher.send(true) }
//      .store(in: &subscriptions)
    
    // Update stats for visible cells
    Timer
      .publish(every: 10, on: .current, in: .common)
      .autoconnect()
      .sink { [weak self] seconds in
        guard let self = self,
              self.filter.getMain() != .search,
              let cells = self.visibleCells as? [SurveyCell],
              !cells.isEmpty
        else { return }
        
        let items = cells.compactMap{ $0.item }
        self.updateStatsPublisher.send(items)
      }
      .store(in: &subscriptions)
    
    // Check if survey became old
    Timer.publish(every: 5, on: .main, in: .common)
      .autoconnect()
      .filter {[weak self] _ in
        guard let self = self else { return false }

        return !self.source.snapshot().itemIdentifiers.isEmpty
      }
      .sink { [weak self] _ in
        guard let self = self,
              self.isOnScreen,
              self.filter.getMain() == .new,
              let expiredDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        else { return }

        var snap = self.source.snapshot()
        snap.deleteItems(snap.itemIdentifiers.filter { $0.startDate < expiredDate })
      }
      .store(in: &subscriptions)
    
    ///If bottom spinner is on screen more than n seconds, then hide it
    Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in self.isRequesting && self.isOnScreen && self.loaderStartedAt.distance(to: Date()) > 5 }
      .sink { [weak self] _ in
        guard let self = self else { return }

        self.isRequesting = false
      }
      .store(in: &subscriptions)
    
    ///**Delete items**
    ///Survey claimed
    SurveyReferences.shared.claimedPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard self.source.snapshot().itemIdentifiers.contains($0) else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([$0])
        
        self.applyDataSnapshotPublisher.send([
          "snapshot": snap,
        ])
//        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    
    ///Survey banned
    SurveyReferences.shared.bannedPublisher
      .collect(.byTimeOrCount(DispatchQueue.main, .seconds(1), 10))
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        var snap = self.source.snapshot()
        let existingSet = Set(self.source.snapshot().itemIdentifiers)
        let deletingSet = Set($0)
        let crossingSet = existingSet.intersection(deletingSet)
        
        guard !crossingSet.isEmpty else { return }
        
        snap.deleteItems(Array(deletingSet))
        self.applyDataSnapshotPublisher.send([
          "snapshot": snap,
        ])
//        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)

    ///Survey rejected
    SurveyReferences.shared.rejectedPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard self.source.snapshot().itemIdentifiers.contains($0) else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([$0])
        self.applyDataSnapshotPublisher.send([
          "snapshot": snap,
        ])
//        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    
    ///Survey removed from watchlist
    SurveyReferences.shared.unmarkedFavoritePublisher
      .receive(on: DispatchQueue.main)
      .filter { [unowned self] _ in self.filter.getAdditional() == .watchlist }
      .sink { [unowned self] in
        guard self.source.snapshot().itemIdentifiers.contains($0) else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([$0])
        self.applyDataSnapshotPublisher.send([
          "snapshot": snap,
        ])
//        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    
    ///Unsubscribed
    Userprofiles.shared.unsubscribedPublisher
      .filter { [weak self] _ in
        guard let self = self,
              self.filter.getMain() == .subscriptions
        else { return false }
        
        return true
      }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] unsubscribed in
        var snap = self.source.snapshot()
        let itemsToDelete = snap.itemIdentifiers.filter { $0.owner == unsubscribed }
        snap.deleteItems(itemsToDelete)
        self.applyDataSnapshotPublisher.send([
          "snapshot": snap,
        ])
//        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    
    ///**Append items**
    SurveyReferences.shared.instancesPublisher
      .eraseToAnyPublisher()
      .receive(on: DispatchQueue.main)
      .delay(for: .seconds(0.3), scheduler: DispatchQueue.main)
      .sink { [unowned self] instances in
        guard !instances.isEmpty else {
          delayAsync(delay: 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.refreshControl?.endRefreshing()
            self.isRequesting = false
          }
          return
        }
        
        var snap = self.source.snapshot()
        if snap.numberOfSections.isZero {
          snap.appendSections([.main])
        }
        let existingSet = Set(snap.itemIdentifiers)
        var appendingSet = Set<SurveyReference>()
        
        switch self.filter.getMain() {
        case .new:            appendingSet = Set(instances.filter { $0.isNew && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })//!$0.isRejected &&
        case .rated:          appendingSet = Set(instances.filter { $0.isTop && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })//!$0.isRejected &&
        case .own:            appendingSet = Set(instances.filter { $0.isOwn && !$0.isBanned && $0.id != Survey.fakeId })
//        case .favorite:       appendingSet = Set(instances.filter { $0.isFavorite && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })
        case .compatible:     appendingSet = Set(instances.filter { $0.id != Survey.fakeId && !$0.isBanned })
        case .subscriptions:  appendingSet = Set(instances.filter { $0.owner.subscribedAt && !$0.isBanned && !$0.isClaimed && !$0.isAnonymous && $0.id != Survey.fakeId })
        case .topic:
          guard let topic = self.filter.topic else { return }
          
          appendingSet = Set(instances.filter { $0.topic == topic && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })
        case .user:
          guard let userprofile = self.filter.userprofile else { return }
          
          appendingSet = Set(instances.filter { $0.owner == userprofile && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })
          default: print("") }
        
        switch self.filter.getAdditional() {
        case .watchlist:
          appendingSet = Set(instances.filter { $0.isFavorite && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })
        default: debugPrint("")
        }
        
        let filteredByPeriod = appendingSet.filter({ $0.isValid(byBeriod: self.filter.getPeriod()) })
        
        if existingSet.isEmpty {
          snap.appendItems(Array(filteredByPeriod.sorted { $0.startDate > $1.startDate }))
        } else {
          snap.appendItems(Array(filteredByPeriod.subtracting(existingSet)).sorted { $0.startDate > $1.startDate })
        }
        
        self.applyDataSnapshotPublisher.send([
          "snapshot": snap,
        ])
        
        // Update data items
        self.dataItems = self.filter.getDataItems(publish: true)
      }
      .store(in: &subscriptions)
    
    ///Subscribed for user
    Userprofiles.shared.newSubscriptionPublisher
      .filter { [weak self] in
        guard let self = self,
              self.filter.getMain() == .subscriptions,
              !$0.isBanned,
              $0.subscribedAt
        else { return false }
        
        return true
      }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] newSubscription in
        var snap = self.source.snapshot()
        let existingSet = Set(snap.itemIdentifiers)
        let appendingSet = Set(newSubscription.surveys)
        
        let filteredByPeriod = appendingSet.filter({ $0.isValid(byBeriod: self.filter.period) })
        
        snap.appendItems((existingSet.isEmpty ? Array(filteredByPeriod) : Array(filteredByPeriod.subtracting(existingSet)))
          .sorted { $0.startDate > $1.startDate },
                         toSection: .main)
        
        self.applyDataSnapshotPublisher.send([
          "snapshot": snap,
        ])
//        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
  }
  
  @MainActor
  func setRefreshControl() {
    refreshControl = UIRefreshControl()
    refreshControl?.tintColor = color
    refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
  }
  
  @objc
  func refresh() {
    guard !isRequesting else { return }
    
    refreshPublisher.send()
  }
  
  func requestData() {
    guard !isRequesting else { return }
    
    isRequesting = true
    paginationPublisher.send(source.snapshot().itemIdentifiers)
  }
  
//  func filterByPeriod(_ items: [SurveyReference]) -> [SurveyReference] {
//    return items.filter {
////      $0.isValid(byBeriod: period)
//      $0.isValid(byBeriod: filter.period)
//    }
//  }
  
  func setDataSource(animatingDifferences: Bool?) {
    ///Reset loading state
    isRequesting = false
    
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    // In topic mode we don't need to populate data if topic isn't selected
    snapshot.appendItems(topicMode && filter.topic.isNil ? [] : dataItems, toSection: .main)

    var closure: Closure? = nil
    ///Immediatly request more items
    if filter.getMain() == .user,
       let userprofile = filter.userprofile,
       userprofile.publicationsTotal > dataItems.count {
      
      closure = { [weak self] in
        guard let self = self else { return }
        
        self.requestData()
      }
    }
    
    applyDataSnapshotPublisher.send([
      "snapshot": snapshot,
      "animatingDifferences": animatingDifferences ?? filter.topic.isNil,
      "completion": closure as Any])
    
//    apply(source: source,
//          snapshot: snapshot,
//          animatingDifferences: !filter.topic.isNil,
//          completion: closure)
  }
  
  /// Refreshes collection view
  /// - Parameters:
  ///   - source: collection view source
  ///   - snapshot: snapshot to apply
  ///   - completion: completion closure
  @MainActor
  func apply(snapshot: Snapshot,
             animatingDifferences: Bool = true,
             completion: Closure? = nil) {
    guard isApplyingSnapshot else {
      self.isApplyingSnapshot = true
      self.emptyPublicationsPublisher.send(snapshot.itemIdentifiers.isEmpty)
      
      DispatchQueue.main.async { [weak self] in
        guard let self = self,
              let source = self.source
        else { return }
        
        source.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
          guard let self = self else { return }
          
          self.isApplyingSnapshot = false
          self.lock.unlock()
          completion?()
        }
      }
      
      return
    }
    
    //    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
    DispatchQueue.main.async() { [weak self] in
      guard let self = self else { return }
      
      self.isApplyingSnapshot = true
      
      source.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
        guard let self = self else { return }
        
        self.isApplyingSnapshot = false
        self.lock.unlock()
        self.emptyPublicationsPublisher.send(self.source.snapshot().itemIdentifiers.isEmpty)
        completion?()
      }
    }
  }
}
