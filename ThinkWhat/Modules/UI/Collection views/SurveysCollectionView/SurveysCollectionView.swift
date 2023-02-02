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
      defer {
        setColors()
      }
      
      setRefreshControl()
      setDataSource(animatingDifferences: (category == .Topic || category == .Search) ? false : true)
      
      guard !dataItems.isEmpty, !visibleCells.isEmpty else { return }
      
      scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
  public var paginationPublisher = PassthroughSubject<[Survey.SurveyCategory: Period], Never>()
  public var paginationByTopicPublisher = PassthroughSubject<[Topic: Period], Never>()
  public var paginationByOwnerPublisher = PassthroughSubject<[Userprofile: Period], Never>()
  public var refreshPublisher = PassthroughSubject<[Survey.SurveyCategory: Period], Never>()
  public var refreshByTopicPublisher = PassthroughSubject<[Topic: Period], Never>()
  public var refreshByOwnerPublisher = PassthroughSubject<[Userprofile: Period], Never>()
  public var rowPublisher = CurrentValueSubject<SurveyReference?, Never>(nil)
  public var updateStatsPublisher = CurrentValueSubject<[SurveyReference]?, Never>(nil)
  public let subscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public let unsubscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public let userprofilePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public let settingsTapPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public var scrollPublisher = PassthroughSubject<Bool, Never>()
  public var deinitPublisher = PassthroughSubject<Bool, Never>()
  //UI
  public var color: UIColor = .secondaryLabel {
    didSet {
      guard oldValue != color else { return }
      
      setColors()
    }
  }
  //Logic
  private let lock = NSRecursiveLock()
  private var loaderStartedAt = Date()
  private var isApplyingSnapshot = false
  private var isLoading = false {
    didSet {
      guard oldValue != isLoading,
            category != .Search
      else { return }
      
      lock.lock()
      
      var snap = source.snapshot()
      if isLoading, snap.sectionIdentifiers.filter({ $0 == .loader }).isEmpty {
        snap.appendSections([.loader])
//        self.isLoadingPublisher.send(self.isLoading)
        
        setLoading(source: self.source, snapshot: snap)
//        self.isApplyingSnapshot = true
//#if DEBUG
//        print("isLoading", isLoading, to: &logger)
//#endif
//        self.source.apply(snap, animatingDifferences: true) { [weak self] in
//          guard let self = self else { return }
//
//          self.isApplyingSnapshot = false
//          self.isLoadingPublisher.send(self.isLoading)
//          self.loaderStartedAt = Date()
//          self.lock.unlock()
//        }
      } else if !isLoading, !snap.sectionIdentifiers.filter({ $0 == .loader }).isEmpty {
        snap.deleteSections([.loader])
//        self.isLoadingPublisher.send(self.isLoading)
                
        setLoading(source: self.source, snapshot: snap)
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
    } else if category == .Search {
      items = fetchResult
    } else {
      items = category.dataItems()
    }
    return items.uniqued().sorted { $0.startDate > $1.startDate }
  }
  private let isLoadingPublisher = PassthroughSubject<Bool, Never>()
  //Scroll direction
  private var lastContentOffsetY: CGFloat = 0 {
    didSet {
      //Pagination
      let _isScrollingDown = lastContentOffsetY > oldValue
      
      if _isScrollingDown, lastContentOffsetY + bounds.height > contentSize.height, !isLoading {
        requestData()
      }
      
      isScrollingDown = lastContentOffsetY > oldValue
      
      guard abs(oldValue - lastContentOffsetY) > 30 else { return }
      
      guard oldValue > 0,
            contentSize.height > lastContentOffsetY + bounds.height
      else { return }
      
      scrollPublisher.send(isScrollingDown)
      //      isScrollingDown = lastContentOffsetY > oldValue
      
      //      guard isScrollingDown, lastContentOffsetY + bounds.height > contentSize.height else { return }
      //
      //      requestData()
      //            guard oldValue > 0,
      //                  contentSize.height > lastContentOffsetY + bounds.height
      //            else { return }
    }
  }
  private var isScrollingDown = false {
    didSet {
      guard oldValue != isScrollingDown else { return }
      
      //      scrollPublisher.send(isScrollingDown)
    }
  }
  private var loadingInProgress = false
  //  private lazy var loadingIndicator: UIActivityIndicatorView = {
  //    let indicator = UIActivityIndicatorView(style: .medium)
  //    indicator.translatesAutoresizingMaskIntoConstraints = false
  //    indicator.hidesWhenStopped = true
  //    indicator.color = .secondaryLabel
  //
  //    return indicator
  //  }()
  //    private var hMaskLayer: CAGradientLayer!
  private lazy var searchSpinner: UIActivityIndicatorView = {
    let instance = UIActivityIndicatorView(style: .large)
    instance.color = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    instance.alpha = 0
    instance.layoutCentered(in: self)
    return instance
  }()
  
  
  
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
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
    
    guard let color = color else { return }
    
    self.color = color
    setColors()
  }
  
  init(topic: Topic,
       color: UIColor? = nil) {
    self.topic = topic
    self.category = .Topic
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
    
    guard let color = color else {
      self.color = topic.tagColor
      
      return
    }
    self.color = color
    setColors()
  }
  
  init(items: [SurveyReference],
       color: UIColor? = nil) {
    self.fetchResult = items
    self.category = .Search
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
    
    guard let color = color else { return }
    
    self.color = color
    setColors()
  }
  
  init(userprofile: Userprofile,
       category: Survey.SurveyCategory,
       color: UIColor? = nil) {
    self.userprofile = userprofile
    self.category = category
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
    
    guard let color = color else { return }
    
    self.color = color
    setColors()
  }
  
  // MARK: - Public methods
  @MainActor @objc
  public func endRefreshing() {
    refreshControl?.endRefreshing()
  }
  
  @MainActor @objc
  public func beginSearchRefreshing() {
    searchSpinner.startAnimating()
    
    let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0) {[weak self] in
      guard let self = self else { return }
      
      self.searchSpinner.alpha = 1
    }
  }
  
  @MainActor @objc
  public func endSearchRefreshing() {
    let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) { [weak self] in
      guard let self = self else { return }
      
      self.searchSpinner.alpha = 1
    } completion: { _ in self.searchSpinner.stopAnimating() }
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    searchSpinner.color = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
  }
}

extension SurveysCollectionView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    lastContentOffsetY = scrollView.contentOffset.y
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
    Timer
      .publish(every: 3, on: .current, in: .common)
      .autoconnect()
      .sink { [weak self] seconds in
        guard let self = self,
              let cells = self.visibleCells as? [SurveyCell]
        else { return }
        
        let items = cells.compactMap{ $0.item }
        self.updateStatsPublisher.send(items)
      }
      .store(in: &subscriptions)
    
    delegate = self
    
    setRefreshControl()
    setColors()
    
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
    
    contentInset.bottom = (category == .ByOwner || category == .Topic) ? 80 : 0
    
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
    //Filter bug fix
    Timer.publish(every: 5, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        guard let self = self,
              self.isOnScreen,
              self.category != .ByOwner,
              self.source.snapshot().itemIdentifiers.count != self.filterByPeriod(self.dataItems).count
        else { return }
        
        var snap = Snapshot()
        snap.appendSections([.main])
        snap.appendItems(self.filterByPeriod(self.dataItems))//self.dataItems)
        self.source.apply(snap, animatingDifferences: true)
      }
      .store(in: &subscriptions)
    
    //    Timer.publish(every: 8, on: .main, in: .common)
    //      .autoconnect()
    //      .sink { [weak self] _ in
    //        guard let self = self,
    //              !self.isLoading,
    //              self.isOnScreen,
    //              self.visibleCells.count < 4,
    //              self.dataItems.count < 4
    //        else { return }
    //
    //        self.requestData()
    //      }
    //      .store(in: &subscriptions)
    
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
    
    //Empty received
    SurveyReferences.shared.instancesPublisher
      .sink { [weak self] instances in
        guard let self = self else { return }
        
        if instances.isEmpty {
          delayAsync(delay: 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
          }
        }
      }
      .store(in: &subscriptions)
    //    tasks.append(Task {@MainActor [weak self] in
    //      for await _ in NotificationCenter.default.notifications(for: Notifications.Surveys.EmptyReceived) {
    //        guard let self = self,
    //              self.isLoading
    //        else { return }
    //
    ////        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
    ////          guard let self = self else { return }
    ////
    //        delayAsync(delay: 0.5) { [weak self] in
    //          guard let self = self else { return }
    //
    //          self.isLoading = false
    //        }
    ////        }
    //
    ////        guard self.indexPathsForVisibleItems.map({ $0.row }).contains(self.dataItems.count-1) else { return }
    ////
    ////        self.scrollToItem(at: IndexPath(row: self.numberOfItems(inSection: 0)-1, section: 0), at: .bottom, animated: true)
    //      }
    //    })
    
    //Survey claimed by user
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Claim) {
        guard let self = self,
              let instance = notification.object as? SurveyReference,
              self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([instance])
        self.source.apply(snap, animatingDifferences: true)
        //                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
      }
    })
    
    //Survey banned on server
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Ban) {
        guard let self = self,
              let instance = notification.object as? SurveyReference,
              self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([instance])
        self.source.apply(snap, animatingDifferences: true)
        //                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
      }
    })
    
    
    //Subscriptions added
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SubscriptionAppend) {
        guard let self = self,
              self.category == .Subscriptions,
              let instance = notification.object as? SurveyReference,
              !self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        //Check by date filter
        guard instance.isValid(byBeriod: self.period) else {
          return
        }
        
        var snap = self.source.snapshot()
        snap.appendItems([instance], toSection: .main)
        self.source.apply(snap, animatingDifferences: true) { [weak self] in
          guard let self = self else { return }
          
          self.isLoading = false
        }
      }
    })
    
    //By userprofile added
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.AppendReference) {
        guard let self = self,
              self.category == .ByOwner,
              let userprofile = self.userprofile,
              let instance = notification.object as? SurveyReference,
              instance.owner == userprofile,
              !self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        //Check by date filter
        guard instance.isValid(byBeriod: self.period) else {
          return
        }
        
        var snap = self.source.snapshot()
        snap.appendItems([instance], toSection: .main)
        self.source.apply(snap, animatingDifferences: true) { [weak self] in
          guard let self = self else { return }
          
          self.isLoading = false
        }
      }
    })
    
    //By userprofile removed
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.RemoveReference) {
        guard let self = self,
              self.category == .ByOwner,
              let userprofile = self.userprofile,
              let instance = notification.object as? SurveyReference,
              instance.owner == userprofile,
              self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([instance])
        self.source.apply(snap, animatingDifferences: true)
      }
    })
    
    //New added
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.NewAppend) {
        guard let self = self,
              self.category == .New,
              let instance = notification.object as? SurveyReference,
              !self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        //        delayAsync(delay: 1) {[weak self] in
        //          guard let self = self else { return }
        
        //          self.isLoading = false
        //        }
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
        //          guard let self = self else { return }
        //
        //          self.isLoading = false
        //        }
        
        //Check by date filter
        guard instance.isValid(byBeriod: self.period) else {
          return
        }
        
        var snap = self.source.snapshot()
        snap.appendItems([instance], toSection: .main)
        self.source.apply(snap, animatingDifferences: true) { [weak self] in
          guard let self = self else { return }
          
          //          delayAsync(delay: 0.3) { [weak self] in
          //            guard let self = self else { return }
          
          self.isLoading = false
          //          }
        }
      }
    })
    
    //Top added
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.TopAppend) {
        guard let self = self,
              self.category == .Top,
              let instance = notification.object as? SurveyReference,
              !self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        //Check by date filter
        guard instance.isValid(byBeriod: self.period) else {
          return
        }
        
        var snap = self.source.snapshot()
        snap.appendItems([instance], toSection: .main)
        self.source.apply(snap, animatingDifferences: true) { [weak self] in
          guard let self = self else { return }
          
          self.isLoading = false
        }
      }
    })
    
    //Own added
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.OwnAppend) {
        guard let self = self,
              self.category == .Own,
              let instance = notification.object as? SurveyReference,
              !self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        //Check by date filter
        guard instance.isValid(byBeriod: self.period) else {
          return
        }
        
        var snap = self.source.snapshot()
        snap.appendItems([instance], toSection: .main)
        self.source.apply(snap, animatingDifferences: true) { [weak self] in
          guard let self = self else { return }
          
          self.isLoading = false
        }
      }
    })
    
    //Favorite added
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.FavoriteAppend) {
        guard let self = self,
              self.category == .Favorite,
              let instance = notification.object as? SurveyReference
        else { return }
        
        //Check by date filter
        guard instance.isValid(byBeriod: self.period) else {
          return
        }
        
        var snap = self.source.snapshot()
        snap.appendItems([instance], toSection: .main)
        self.source.apply(snap, animatingDifferences: true) { [weak self] in
          guard let self = self else { return }
          
          self.isLoading = false
        }
      }
    })
    
    //Favorite toggle
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.FavoriteRemove) {
        guard let self = self,
              self.category == .Favorite,
              let instance = notification.object as? SurveyReference
        else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([instance])
        self.source.apply(snap, animatingDifferences: true)
      }
    })
    
    //Topic added
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.TopicAppend) {
        guard let self = self else { return }
        
        guard self.category == .Topic,
              let instance = notification.object as? SurveyReference,
              !self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        //Check by date filter
        guard instance.isValid(byBeriod: self.period) else {
          return
        }
        
        var snap = self.source.snapshot()
        snap.appendItems([instance], toSection: .main)
        self.source.apply(snap, animatingDifferences: true) { [weak self] in
          guard let self = self else { return }
          
          self.isLoading = false
        }
      }
    })
    
    //Subscribed at added
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsAppend) {
        guard let self = self,
              self.category == .Subscriptions,
              let dict = notification.object as? [Userprofile: Userprofile],
              self.userprofile.isNil,//Current user
              let userprofile = dict.values.first
        else { return }
        
        //Append, sort
        let snap = self.source.snapshot()
        var items = snap.itemIdentifiers
        let difference = SurveyReferences.shared.all
          .filter({ $0.owner == userprofile })
          .filter({ !items.contains($0) })
        items += difference
        
        var newSnap = Snapshot()
        newSnap.appendSections([.main])//, .loader])
        newSnap.appendItems(self.filterByPeriod(items.uniqued().sorted { $0.startDate > $1.startDate }))
        self.source.apply(snap, animatingDifferences: true) { [weak self] in
          guard let self = self else { return }
          
          self.isLoading = false
        }
      }
    })
    
    //Subscribed at removed
    tasks.append(Task {@MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
        guard let self = self,
              self.category == .Subscriptions,
              self.userprofile.isNil//Current user
        else { return }
        
        var snap = Snapshot()
        snap.appendSections([.main])//, .loader])
        snap.appendItems(self.dataItems)
        self.source.apply(snap)
        //Append, sort
        //                var snap = self.source.snapshot()
        //                let ownerSurveys = SurveyReferences.shared.all.filter({ $0.owner == owner })
        //                snap.deleteItems(ownerSurveys)
        //                self.source.apply(snap)
      }
    })
  }
  
  @MainActor
  func setRefreshControl() {
    if category == .Search {
      refreshControl = nil
      //      loadingIndicator.stopAnimating()
    } else {
      refreshControl = UIRefreshControl()
      refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
  }
  
  @MainActor
  func setColors() {
    refreshControl?.tintColor = color
  }
  
  @objc
  func refresh() {
    if category == .Topic, let topic = topic {
      refreshByTopicPublisher.send([topic: period])
    } else if category == .ByOwner, let userprofile = userprofile {
      refreshByOwnerPublisher.send([userprofile: period])
    } else {
      refreshPublisher.send([category: period])
    }
  }
  
  func requestData() {
    guard !isLoading else { return }
    
    if category == .Topic, let topic = topic {
      paginationByTopicPublisher.send([topic: period])
    } else if category == .ByOwner, let userprofile = userprofile {
      paginationByOwnerPublisher.send([userprofile: period])
    } else {
      //      isLoading = true
      paginationPublisher.send([category: period])
    }
    isLoading = true
  }
  
  func appendToDataSource() {
    var snapshot = source.snapshot()
    guard let newInstance = dataItems.last, !snapshot.itemIdentifiers.contains(newInstance) else { return }
    snapshot.appendItems([newInstance], toSection: .main)
    source.apply(snapshot, animatingDifferences: true)
  }
  
  func filterByPeriod(_ items: [SurveyReference]) -> [SurveyReference] {
    return items.filter {
      $0.isValid(byBeriod: period)
    }
  }
  
  func setDataSource(animatingDifferences: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    //    if category != .Search {
    //      snapshot.appendSections([.loader])
    //    }
    snapshot.appendItems(filterByPeriod(dataItems), toSection: .main)
//    fatalError()
//    source.apply(snapshot, animatingDifferences: animatingDifferences)
    setLoading(source: source, snapshot: snapshot)
  }
  
  @MainActor
  func setLoading(source: Source, snapshot: Snapshot) {
    
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
      }
    }
  }
}
