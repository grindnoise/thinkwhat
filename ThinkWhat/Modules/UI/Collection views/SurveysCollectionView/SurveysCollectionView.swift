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
  
  // MARK: - Enums
  enum Section {
    case main, loader
  }
  
  typealias Source = UICollectionViewDiffableDataSource<Section, SurveyReference>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>
  
  // MARK: - Public properties
  public weak var topic: Topic? {
    didSet {
      guard let topic = topic else { return }
      
      category = .Topic
      color = topic.tagColor
    }
  }
  public var category: Survey.SurveyCategory {
    didSet {
//      defer {
//        setColors()
//      }
      
      setRefreshControl()
      setDataSource(animatingDifferences: (category == .Topic/* || category == .Search*/) ? false : true)
      
      guard !dataItems.isEmpty, !visibleCells.isEmpty else { return }
      
      scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: category == .Topic ? false : true)
    }
  }
  public var period: Period = .AllTime {
    didSet {
      setDataSource()
    }
  }
  public weak var userprofile: Userprofile? {
    didSet {
      guard !userprofile.isNil else { return }
      
      category = .ByOwner
    }
  }
  public var compatibility: TopicCompatibility? {
    didSet {
      guard !compatibility.isNil else { return }
      
      category = .Compatibility
    }
  }
  public var fetchResult: [SurveyReference] = [] {
    didSet {
      setDataSource()
    }
  }
  public var isOnScreen = true
  //  public var colorTheme: UIColor = Colors.System.Red.rawValue
  
  //Publishers
  public var watchSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
  public var claimSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
  public var shareSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
  public let paginationPublisher = PassthroughSubject<[Survey.SurveyCategory: Period], Never>()
  public let paginationByTopicPublisher = PassthroughSubject<[Topic: Period], Never>()
  public let paginationByOwnerPublisher = PassthroughSubject<[Userprofile: Period], Never>()
  public let paginationByOwnerSearchPublisher = PassthroughSubject<[Userprofile: [SurveyReference]], Never>()
  public let paginationByTopicSearchPublisher = PassthroughSubject<[Topic: [SurveyReference]], Never>()
  public let paginationByCompatibilityPublisher = PassthroughSubject<TopicCompatibility, Never>()
  public let refreshPublisher = PassthroughSubject<[Survey.SurveyCategory: Period], Never>()
  public let refreshByTopicPublisher = PassthroughSubject<[Topic: Period], Never>()
  public let refreshByCompatibilityPublisher = PassthroughSubject<TopicCompatibility, Never>()
  public let refreshByOwnerPublisher = PassthroughSubject<[Userprofile: Period], Never>()
  public var rowPublisher = CurrentValueSubject<SurveyReference?, Never>(nil)
  public var updateStatsPublisher = CurrentValueSubject<[SurveyReference]?, Never>(nil)
  public var subscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public var unsubscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public var userprofilePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public var settingsTapPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public let scrollPublisher = PassthroughSubject<Bool, Never>()
  public let deinitPublisher = PassthroughSubject<Bool, Never>()
  public let emptyPublicationsPublisher = PassthroughSubject<Bool, Never>()
  ///**UI**
  public var color: UIColor = .secondaryLabel {
    didSet {
      guard oldValue != color else { return }
      
      colorPublisher.send(color)
      loadingIndicator.color = color
//      guard let superIndicator = viewByClassName(className: "_UIScrollViewScrollIndicator"),
//            let indicator = superIndicator.subviews.first
//      else { return }
//
//      indicator.backgroundColor = color
//      let colored = UIView()
//      colored.backgroundColor = color
//      colored.place(inside: indicator)
    }
  }
  
  
  
  // MARK: - Public properties
  ///**Logic**
  private let lock = NSRecursiveLock()
  private var loaderStartedAt = Date()
  private var isApplyingSnapshot = false
  private var isLoading = false {
    didSet {
//      if !isLoading, let refreshControl = refreshControl, refreshControl.isRefreshing { refreshControl.endRefreshing() }
//      if let refreshControl = refreshControl, refreshControl.isRefreshing {
//        refreshControl.endRefreshing()
////        return
//      }
      
      guard oldValue != isLoading,
            category != .Search
      else { return }
      
      lock.lock()
      
      var snap = source.snapshot()
      if isLoading, snap.sectionIdentifiers.filter({ $0 == .loader }).isEmpty {
        snap.appendSections([.loader])
        apply(source: self.source, snapshot: snap)
      } else if !isLoading, !snap.sectionIdentifiers.filter({ $0 == .loader }).isEmpty {
        snap.deleteSections([.loader])
        apply(source: self.source, snapshot: snap)
      }
    }
  }
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private var source: Source!
  private var dataItems: [SurveyReference] {
    var items: [SurveyReference] = []
    if category == .ByOwner, let userprofile = userprofile {
      items = category.dataItems(userprofile: userprofile)
    } else if category == .Topic, !topic.isNil {
      items = category.dataItems(topic: topic)
    } else if category == .Compatibility, !compatibility.isNil {
      items = category.dataItems(compatibility: compatibility)
    } else if category == .Search {
      items = fetchResult
    } else {
      items = category.dataItems()
    }
    return items.uniqued().sorted { $0.startDate > $1.startDate }
  }
  private let isLoadingPublisher = PassthroughSubject<Bool, Never>()
  ///Scroll direction
  private var lastStopYPoint: CGFloat = .zero
  private var lastContentOffsetY: CGFloat = 0 {
    didSet {
      guard !source.snapshot().itemIdentifiers.isEmpty else { return }
      
      let isScrollingDown = lastContentOffsetY > oldValue
      
      ///Pagination
      if isScrollingDown,
         contentSize.height > bounds.height,
         lastContentOffsetY + bounds.height > contentSize.height,
         !isLoading {
        requestData()
      }
      
      let distance = lastStopYPoint - lastContentOffsetY
      let threshold: CGFloat = 30
      
      guard abs(distance) > threshold  else { return }
      
      scrollPublisher.send(distance > 0 ? false : true)
    }
  }
  private var isScrollingDown = false {
    didSet {
      guard oldValue != isScrollingDown else { return }
      
      //      scrollPublisher.send(isScrollingDown)
    }
  }
  private var loadingInProgress = false
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var loadingIndicator: LoadingIndicator = {
    let instance = LoadingIndicator(color: color,
                                    duration: 0.5,
                                    shouldSendCompletion: false)
//    instance.didDisappearPublisher
//      .sink { _ in
//        instance.reset()
//      }
//      .store(in: &subscriptions)
    instance.placeInCenter(of: self, widthMultiplier: 0.25)
    
    return instance
  }()
  private let colorPublisher = PassthroughSubject<UIColor, Never>()
//  private lazy var searchSpinner: UIActivityIndicatorView = {
//    let instance = UIActivityIndicatorView(style: .large)
//    instance.color = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//    instance.alpha = 0
//    instance.layoutCentered(in: self)
//    return instance
//  }()
  
  
  
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
    fatalError("init(frame:) has not been implemented")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(category: Survey.SurveyCategory,
       color: UIColor? = nil) {
    self.category = category
    self.color = color ?? .secondaryLabel
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
  }
  
  init(topic: Topic,
       color: UIColor? = nil) {
    self.topic = topic
    self.category = .Topic
    if let color = color {
      self.color = color
    } else {
      self.color = topic.tagColor
    }
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
  }
  
  init(items: [SurveyReference],
       color: UIColor? = nil) {
    self.fetchResult = items
    self.category = .Search
    self.color = color ?? .secondaryLabel
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
  }
  
  init(compatibility: TopicCompatibility,
       color: UIColor? = nil) {
    self.compatibility = compatibility
    self.category = .Compatibility
    self.color = color ?? .secondaryLabel
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
  }
  
  init(userprofile: Userprofile,
       category: Survey.SurveyCategory,
       color: UIColor? = nil) {
    self.userprofile = userprofile
    self.category = category
    self.color = color ?? .secondaryLabel
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
  }
  
  // MARK: - Public methods
  @MainActor @objc
  public func endRefreshing() {
    refreshControl?.endRefreshing()
  }
  
  @MainActor @objc
  public func beginSearchRefreshing() {
    loadingIndicator.start()
  }
  
  @MainActor
  @objc
  public func endSearchRefreshing() {
    delay(seconds: 2) { [weak self] in
      guard let self = self else { return }
      
      self.loadingIndicator.stop(reset: true)
    }
//    let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) { [weak self] in
//      guard let self = self else { return }
//
//      self.searchSpinner.alpha = 1
//    } completion: { _ indff self.searchSpinner.stopAnimating() }
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
      rowPublisher.send(cell.item)
    }
    deselect()
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    switch category {
    case .Topic:
      if dataItems.count < 10, let topic = topic, topic.activeCount > dataItems.count {
        requestData()
      }
    case .ByOwner:
      if dataItems.count < 10, let userprofile = userprofile, userprofile.publicationsTotal > dataItems.count {
        requestData()
      }
    default:
#if DEBUG
      print("")
#endif
    }
    
    guard category != .Search, isScrollingDown, !isLoading else { return }
    
    let max = source.snapshot().itemIdentifiers.count-1
    
    if max < 10 {
      requestData()
    } else if max > 0 {
      
      let requestThreshold = max > 5 ? 5 : max-1
      let triggerRange = max-requestThreshold..<max-1
      
      guard triggerRange.contains(indexPath.row) else { return }
      
      requestData()
    }
  }
}

private extension SurveysCollectionView {
  @MainActor
  func setupUI() {
    delegate = self
    setRefreshControl()
    
    collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
      var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
      layoutConfig.backgroundColor = .clear
      layoutConfig.showsSeparators = false//true
      layoutConfig.footerMode = section == 0 ? .none : .supplementary
      
      let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
      sectionLayout.interGroupSpacing = 20
      
      return sectionLayout
    }
    
    contentInset.bottom = (category == .ByOwner || category == .Topic || category == .Own) ? 80 : 0
    
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
      config.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let loaderRegistration = UICollectionView.SupplementaryRegistration<LoaderCell>(elementKind: UICollectionView.elementKindSectionFooter) { [unowned self] supplementaryView,_,_ in
      
      supplementaryView.color = self.color
      
      self.colorPublisher
        .sink { supplementaryView.color = $0 }
        .store(in: &self.subscriptions)
      
      self.isLoadingPublisher
        .sink { supplementaryView.isLoading = $0 }
        .store(in: &self.subscriptions)
      
      self.deinitPublisher
        .sink { _ in supplementaryView.cancelAllAnimations() }
        .store(in: &self.subscriptions)
    }
    
    source = UICollectionViewDiffableDataSource<Section, SurveyReference>(collectionView: self) {
      collectionView, indexPath, identifier -> UICollectionViewCell? in
      
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    source.supplementaryViewProvider = { collectionView, elementKind, indexPath -> UICollectionReusableView? in
      return collectionView.dequeueConfiguredReusableSupplementary(using: loaderRegistration, for: indexPath)
    }
    
    setDataSource(animatingDifferences: false)
  }
  
  func setTasks() {
    ///**Updaters**
    ///Load data if zero items
    Timer
      .publish(every: 3, on: .current, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in !self.isLoading }
      .sink { [weak self] seconds in
        guard let self = self,
              self.category != .Search,
              let cells = self.visibleCells as? [SurveyCell],
              cells.isEmpty
        else { return }

        self.refresh()
      }
      .store(in: &subscriptions)
    ///Update stats for visible cells
    Timer
      .publish(every: 3, on: .current, in: .common)
      .autoconnect()
      .sink { [weak self] seconds in
        guard let self = self,
              self.category != .Search,
              let cells = self.visibleCells as? [SurveyCell],
              !cells.isEmpty
        else { return }
        
        let items = cells.compactMap{ $0.item }
        self.updateStatsPublisher.send(items)
      }
      .store(in: &subscriptions)
    ///Check if survey became old
    Timer.publish(every: 5, on: .main, in: .common)
      .autoconnect()
      .filter {[weak self] _ in
        guard let self = self else { return false }
        
        return !self.source.snapshot().itemIdentifiers.isEmpty
      }
      .sink { [weak self] _ in
        guard let self = self,
              self.isOnScreen,
              self.category == .New,
              let expiredDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems(snap.itemIdentifiers.filter { $0.startDate < expiredDate })
//        self.source.apply(snap, animatingDifferences: true)
        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    ///If bottom spinner is on screen more than n seconds, then hide it
    Timer.publish(every: 8, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        guard let self = self,
              self.isLoading,
              self.isOnScreen
        else { return }
        
        let diff = self.loaderStartedAt.distance(to: Date())
        
        guard diff > 10 else { return }
#if DEBUG
        print("diff", diff)
#endif
        self.isLoading = false
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
//        self.source.apply(snap, animatingDifferences: true)
        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    ///
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
//        self.source.apply(snap, animatingDifferences: true)
        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    ///
    ///Survey rejected
    SurveyReferences.shared.rejectedPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard self.source.snapshot().itemIdentifiers.contains($0) else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([$0])
//        self.source.apply(snap, animatingDifferences: true)
        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    ///
    ///Survey removed from watchlist
    SurveyReferences.shared.unmarkedFavoritePublisher
      .receive(on: DispatchQueue.main)
      .filter { [unowned self] _ in self.category == .Favorite }
      .sink { [unowned self] in
        guard self.source.snapshot().itemIdentifiers.contains($0) else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([$0])
//        self.source.apply(snap, animatingDifferences: true)
        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    ///
    ///Unsubscribed
    Userprofiles.shared.unsubscribedPublisher
      .filter { [weak self] _ in
        guard let self = self,
              self.category == .Subscriptions
        else { return false }
        
        return true
      }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] unsubscribed in
        var snap = self.source.snapshot()
        let itemsToDelete = snap.itemIdentifiers.filter { $0.owner == unsubscribed }
        snap.deleteItems(itemsToDelete)
//        self.source.apply(snap, animatingDifferences: true)
        self.apply(source: self.source, snapshot: snap)
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
            self.isLoading = false
          }
          return
        }
        
        var snap = self.source.snapshot()
        let existingSet = Set(snap.itemIdentifiers)
        var appendingSet = Set<SurveyReference>()
        
        switch self.category {
        case .New:            appendingSet = Set(instances.filter { $0.isNew && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })//!$0.isRejected &&
        case .Top:            appendingSet = Set(instances.filter { $0.isTop && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })//!$0.isRejected &&
        case .Own:            appendingSet = Set(instances.filter { $0.isOwn && !$0.isBanned && $0.id != Survey.fakeId })
        case .Favorite:       appendingSet = Set(instances.filter { $0.isFavorite && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })
        case .Compatibility:  appendingSet = Set(instances.filter { $0.id != Survey.fakeId && !$0.isBanned })
        case .Subscriptions:  appendingSet = Set(instances.filter { $0.owner.subscribedAt && !$0.isBanned && !$0.isClaimed && !$0.isAnonymous && $0.id != Survey.fakeId })
        case .Topic:
          guard let topic = self.topic else { return }
          
          appendingSet = Set(instances.filter { $0.topic == topic && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })
        case .ByOwner:
          guard let userprofile = self.userprofile else { return }
          
          appendingSet = Set(instances.filter { $0.owner == userprofile && !$0.isBanned && !$0.isClaimed && $0.id != Survey.fakeId })
        default: print("") }
        
        let filteredByPeriod = appendingSet.filter({ $0.isValid(byBeriod: self.period) })
      
        if existingSet.isEmpty {
          snap.appendItems(Array(filteredByPeriod).sorted { $0.startDate > $1.startDate },
                           toSection: .main)
        } else {
          snap.appendItems(Array(filteredByPeriod.subtracting(existingSet)).sorted { $0.startDate > $1.startDate },
                           toSection: .main)
        }
        
//        self.source.apply(snap, animatingDifferences: true) { [weak self] in
//          guard let self = self else { return }
//
//          self.isLoading = false
//        }
        self.apply(source: self.source, snapshot: snap)
      }
      .store(in: &subscriptions)
    ///Subscribed for user
    Userprofiles.shared.newSubscriptionPublisher
      .filter { [weak self] in
        guard let self = self,
              self.category == .Subscriptions,
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
        
        let filteredByPeriod = appendingSet.filter({ $0.isValid(byBeriod: self.period) })
        
        snap.appendItems((existingSet.isEmpty ? Array(filteredByPeriod) : Array(filteredByPeriod.subtracting(existingSet)))
          .sorted { $0.startDate > $1.startDate },
                         toSection: .main)
        
        self.apply(source: self.source, snapshot: snap)
//        self.source.apply(snap, animatingDifferences: true) { [weak self] in
//          guard let self = self else { return }
//
//          self.isLoading = false
//        }
      }
      .store(in: &subscriptions)
    
//    //Filter bug fix
//    Timer.publish(every: 5, on: .main, in: .common)
//      .autoconnect()
//      .sink { [weak self] _ in
//        guard let self = self,
//              self.isOnScreen,
//              self.category != .ByOwner,
//              self.source.snapshot().itemIdentifiers.count != self.filterByPeriod(self.dataItems).count
//        else { return }
//
//        var snap = Snapshot()
//        snap.appendSections([.main])
//        snap.appendItems(self.filterByPeriod(self.dataItems))//self.dataItems)
//        self.source.apply(snap, animatingDifferences: true)
//      }
//      .store(in: &subscriptions)
  }
  
  @MainActor
  func setRefreshControl() {
    if category == .Search {
      refreshControl = nil
      //      loadingIndicator.stopAnimating()
    } else {
      refreshControl = UIRefreshControl()
      refreshControl?.tintColor = color
      refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
  }
  
  @objc
  func refresh() {
    guard !isLoading else { return }
    
//    isLoading = true
    
    if category == .Topic, let topic = topic {
      refreshByTopicPublisher.send([topic: period])
    } else if category == .Compatibility, let compatibility = compatibility {
      refreshByCompatibilityPublisher.send(compatibility)
    } else if category == .ByOwner, let userprofile = userprofile {
      refreshByOwnerPublisher.send([userprofile: period])
    } else {
      refreshPublisher.send([category: period])
    }
  }
  
  func requestData() {
    guard !isLoading else { return }
    
    isLoading = true
    if category == .Topic, let topic = topic {
      paginationByTopicPublisher.send([topic: period])
    } else if category == .ByOwner, let userprofile = userprofile {
      paginationByOwnerPublisher.send([userprofile: period])
    } else if category == .Search, let userprofile = userprofile {
      paginationByOwnerSearchPublisher.send([userprofile: source.snapshot().itemIdentifiers])
    } else if category == .Search, let topic = topic {
      paginationByTopicSearchPublisher.send([topic: source.snapshot().itemIdentifiers])
    } else if category == .Compatibility, let compatibility = compatibility {
      paginationByCompatibilityPublisher.send(compatibility)
    } else {
      paginationPublisher.send([category: period])
    }
  }
  
  func filterByPeriod(_ items: [SurveyReference]) -> [SurveyReference] {
    return items.filter {
      $0.isValid(byBeriod: period)
    }
  }
  
  func setDataSource(animatingDifferences: Bool = true) {
    ///Reset loading state
    self.isLoading = false
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    //    if category != .Search {
    //      snapshot.appendSections([.loader])
    //    }
    snapshot.appendItems(filterByPeriod(dataItems), toSection: .main)
//    fatalError()
//    source.apply(snapshot, animatingDifferences: animatingDifferences)
    
    var closure: Closure? = nil
    ///Immediatly request more items
    if category == .ByOwner,
       let userprofile = userprofile,
       userprofile.publicationsTotal > dataItems.count {
      
      closure = { [weak self] in
        guard let self = self else { return }
        
        self.requestData()
      }
    }
    
    apply(source: source,
          snapshot: snapshot,
          completion: closure)
    
    
  }
  
  @MainActor
  func apply(source: Source,
             snapshot: Snapshot,
             completion: Closure? = nil) {
    guard isApplyingSnapshot else {
      self.isApplyingSnapshot = true
#if DEBUG
      print("isLoading", self.isLoading, to: &logger)
#endif

      if !isLoading {
        self.isLoadingPublisher.send(self.isLoading)
      }
      
      source.apply(snapshot, animatingDifferences: true) { [weak self] in
        guard let self = self else { return }

        self.isApplyingSnapshot = false
        self.lock.unlock()
        if self.isLoading {
          self.isLoadingPublisher.send(self.isLoading)
        }
//        switchEmptyLabel()
        self.emptyPublicationsPublisher.send(self.source.snapshot().itemIdentifiers.isEmpty)
        
        if let completion = completion { completion() }
      }

      return
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
      guard let self = self else { return }
      
      self.isApplyingSnapshot = true
#if DEBUG
      print("isLoading", self.isLoading, to: &logger)
#endif

      if !self.isLoading {
        self.isLoadingPublisher.send(self.isLoading)
      }
      
      source.apply(snapshot, animatingDifferences: true) { [weak self] in
        guard let self = self else { return }
        
        self.isApplyingSnapshot = false
        self.lock.unlock()
        if self.isLoading {
          self.isLoadingPublisher.send(self.isLoading)
        }
//        guard self.traitCollection.userInterfaceStyle == .dark else { return }
        
//        switchEmptyLabel()
        self.emptyPublicationsPublisher.send(self.source.snapshot().itemIdentifiers.isEmpty)
        
        if let completion = completion { completion() }
      }
    }
  }
}
