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
        case main
    }
    
    typealias Source = UICollectionViewDiffableDataSource<Section, SurveyReference>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>
    
    // MARK: - Public properties
    public var topic: Topic? {
        didSet {
            guard !topic.isNil else { return }
            category = .Topic
        }
    }
    public var category: Survey.SurveyCategory {
        didSet {
            defer {
                setColors()
            }
//            guard oldValue != category else { return }
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
    public var userprofile: Userprofile? {
        didSet {
            guard !userprofile.isNil else { return }
            
            category = .Userprofile
        }
    }
    public var fetchResult: [SurveyReference] = [] {
        didSet {
            setDataSource()
        }
    }
    public var refreshColor: UIColor {
        return category == .Topic ? .white : traitCollection.userInterfaceStyle == .dark ? .white : .secondaryLabel
    }
    
    //Publishers
    public var watchSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    public var claimSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    public var shareSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    public var paginationPublisher = CurrentValueSubject<Survey.SurveyCategory?, Never>(nil)
    public var paginationByTopicPublisher = CurrentValueSubject<Topic?, Never>(nil)
    public var paginationByUserprofilePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public var refreshPublisher = CurrentValueSubject<Survey.SurveyCategory?, Never>(nil)
    public var refreshByTopicPublisher = CurrentValueSubject<Topic?, Never>(nil)
    public var refreshByUserprofilePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public var rowPublisher = CurrentValueSubject<SurveyReference?, Never>(nil)
    public var updateStatsPublisher = CurrentValueSubject<[SurveyReference]?, Never>(nil)
    public let subscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public let unsubscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public let userprofilePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private var source: Source!
    private var dataItems: [SurveyReference] {
        var items: [SurveyReference] = []
        if category == .Userprofile, let userprofile = userprofile {
            items = category.dataItems(nil, userprofile)
        } else if category == .Topic, !topic.isNil {
            items = category.dataItems(topic)
        } else if category == .Search {
            items = fetchResult
        } else {
            items = category.dataItems()
        }
        return items.uniqued().sorted { $0.startDate > $1.startDate }
    }
    
    private var loadingInProgress = false
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .secondaryLabel
        
        return indicator
    }()
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
    
    init(category: Survey.SurveyCategory) {
        self.category = category
        super.init(frame: .zero, collectionViewLayout: .init())
        setupUI()
        setTasks()
    }
    
    init(delegate: CallbackObservable, topic: Topic?) {
        self.topic = topic
        self.category = .Topic
        super.init(frame: .zero, collectionViewLayout: .init())
        setupUI()
        setTasks()
    }

    init(items: [SurveyReference]) {
        self.fetchResult = items
        self.category = .Search
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
        searchSpinner.startAnimating()
        
        let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0) {
            self.searchSpinner.alpha = 1
        }
    }
    
    @MainActor @objc
    public func endSearchRefreshing() {
        let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.searchSpinner.alpha = 1
        } completion: { _ in self.searchSpinner.stopAnimating() }
    }
    
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
//            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
//            layoutConfig.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.5)//self.traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground
//            layoutConfig.showsSeparators = false//true
//
//            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
//            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//            sectionLayout.interGroupSpacing = 16
//            return sectionLayout
//        }
        refreshControl?.tintColor = refreshColor
        searchSpinner.color = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
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
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let max = source.snapshot().itemIdentifiers.count-1
        let requestThreshold = 3
        
        if max < 10 {
            requestData()
            
            guard !loadingIndicator.isAnimating else { return }
            
            loadingIndicator.startAnimating()
//        } else if let biggestRow = collectionView.indexPathsForVisibleItems.sorted(by: { $1.row < $0.row }).first?.row, indexPath.row == biggestRow + 1 && indexPath.row == dataItems.count - 1 {
//            requestData()
//
//            guard !loadingIndicator.isAnimating else { return }
//
            //            loadingIndicator.startAnimating()
        } else if indexPath.row - requestThreshold == max - requestThreshold {
            requestData()
            
            guard !loadingIndicator.isAnimating else { return }
            
            loadingIndicator.startAnimating()
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
//        guard !allowsMultipleSelection,
//              let cell = collectionView.cellForItem(at: indexPath) as? SurveyCell
//          else { return nil }
//
//        return UITargetedPreview(view: cell.avatar.imageView)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
//        guard !allowsMultipleSelection,
//              let indexPath = indexPaths.first,
//              let cell = collectionView.cellForItem(at: indexPath) as? SurveyCell
//        else { return nil }
//
//        return UIContextMenuConfiguration(
//            identifier: "\(indexPath.row)" as NSString,
//            previewProvider: { self.makePreview(cell.avatar.userprofile) }) { _ in
//
//                var actions: [UIAction]!
//
//                let subscribe: UIAction = .init(title: "subscribe".localized.capitalized,
//                                             image: UIImage(systemName: "hand.point.left.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
//                                             identifier: nil,
//                                             discoverabilityTitle: nil,
//                                              attributes: .init(),
//                                              state: .off,
//                                              handler: { [weak self] _ in
//                    guard let self = self,
//                          let userprofile = cell.avatar.userprofile
//                    else { return }
//
//                    self.subscribePublisher.send([userprofile])
//                })
//
//                let unsubscribe: UIAction = .init(title: "unsubscribe".localized,
//                                                   image: UIImage(systemName: "hand.raised.slash.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
//                                                   identifier: nil,
//                                                   discoverabilityTitle: nil,
//                                                   attributes: .destructive,
//                                                   state: .off,
//                                                   handler: { [weak self] _ in
//                    guard let self = self,
//                          let userprofile = cell.avatar.userprofile
//                    else { return }
//
//                    self.unsubscribePublisher.send([userprofile])
//                })
//
//                let profile: UIAction = .init(title: "profile".localized,
//                                                   image: UIImage(systemName: "person.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
//                                                   identifier: nil,
//                                                   discoverabilityTitle: nil,
//                                                   attributes: .init(),
//                                                   state: .off,
//                                                   handler: { [weak self] _ in
//                    guard let self = self else { return }
//
//                    self.userprofilePublisher.send([cell.avatar.userprofile])
//                })
//
//                actions = [profile]
//                if cell.avatar.userprofile.subscribedAt {
//                    actions.append(unsubscribe)
//                } else {
//                    actions.append(subscribe)
//                }
//
//
//                return UIMenu(title: "", image: nil, identifier: nil, options: .init(), children: actions)
//            }
//    }
}

extension SurveysCollectionView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}

private extension SurveysCollectionView {
    func setupUI() {
        
        Timer
            .publish(every: 3, on: .current, in: .common)
            .autoconnect()
//            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] seconds in
                guard let self = self,
                      let cells = self.visibleCells as? [SurveyCell],
                      !cells.isEmpty
                else { return }

                self.updateStatsPublisher.send(cells.compactMap { return $0.item })
            }
            .store(in: &subscriptions)
        
        delegate = self
        
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
//            layoutGuide.centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor),
//            layoutGuide.bottomAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 10)
        ])
        
        refreshControl = UIRefreshControl()
        setColors()
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
            layoutConfig.backgroundColor = .clear
            layoutConfig.showsSeparators = false//true
            
            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            sectionLayout.interGroupSpacing = 16
            
            return sectionLayout
        }
        
        contentInset.bottom = category == .Topic ? 80 : 0
        
        let cellRegistration = UICollectionView.CellRegistration<SurveyCell, SurveyReference> { [unowned self] cell, indexPath, item in
            cell.item = item
            
            
            
//            let publisher = Publishers.MergeMany(cell.updatePublisher)
//                .compactMap { $0 as? SurveyReference }
//                .collect(.byTime(DispatchQueue.main, 3))
////                .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
//                .sink { print($0) }
//                .store(in: &self.subscriptions)
            
//            let paginationPublisher = publisher
//                .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            
//            Publishers.MergeMany(cell.updatePublisher)
//                .collect(.byTime(DispatchQueue.main, 5))
////                .collect(.byTimeOrCount(DispatchQueue.main, .seconds(2), 8))
//                .sink { val in
//                    print(val)
//                    print("")
////                    print(val.first?.id)
//                }
//                .store(in: &self.subscriptions)
            
            cell.subscribePublisher
                .sink { [weak self] in
                    guard let self = self,
                          let userprofile = $0
                    else { return }
                    
                    self.subscribePublisher.send(userprofile)
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
            
            //Add to watchlist
            cell.watchSubject
                .sink { [weak self] in
                    guard let self = self,
                          !$0.isNil
                    else { return }
                
                guard $0!.isComplete else {
                    showBanner(bannerDelegate: self, text: "finish_poll".localized, content: UIImageView(image: UIImage(systemName: "exclamationmark.icloud.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemOrange.withAlphaComponent(1))
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
        
        source = UICollectionViewDiffableDataSource<Section, SurveyReference>(collectionView: self) {
            collectionView, indexPath, identifier -> UICollectionViewCell? in
            //            guard let self = self else { return UICollectionViewCell() }
            //            guard self.category == .Subscriptions else {
            //                return collectionView.dequeueConfiguredReusableCell(using: surveyCellRegistration,
            //                                                                    for: indexPath,
            //                                                                    item: identifier)
            //            }
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            //            cell.item = identifier
            return cell
        }
        
        setDataSource(animatingDifferences: true)
//        var snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(dataItems, toSection: .main)
//        source.apply(snapshot, animatingDifferences: false)
    }
    
    func setTasks() {
        
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self,
                      self.source.snapshot().itemIdentifiers.count != self.dataItems.count
                else { return }
                
                var snap = Snapshot()
                snap.appendSections([.main])
                snap.appendItems(self.dataItems)
                self.source.apply(snap, animatingDifferences: true)
            }
            .store(in: &subscriptions)
        
        //Empty received
        tasks.append(Task {@MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.Surveys.EmptyReceived) {
                guard let self = self else { return }
                
                self.loadingIndicator.stopAnimating()
            }
        })
        
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
                
                var snap = self.source.snapshot()
                snap.appendItems([instance], toSection: .main)
                self.source.apply(snap, animatingDifferences: true)
                self.loadingIndicator.stopAnimating()
            }
        })
        
        //By userprofile added
        tasks.append(Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.AppendReference) {
                guard let self = self,
                      self.category == .Userprofile,
                      let userprofile = self.userprofile,
                      let instance = notification.object as? SurveyReference,
                      instance.owner == userprofile,
                      !self.source.snapshot().itemIdentifiers.contains(instance)
                else { return }
                
                var snap = self.source.snapshot()
                snap.appendItems([instance], toSection: .main)
                self.source.apply(snap, animatingDifferences: true)
                self.loadingIndicator.stopAnimating()
            }
        })
        
        //By userprofile removed
        tasks.append(Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.RemoveReference) {
                guard let self = self,
                      self.category == .Userprofile,
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
                
                var snap = self.source.snapshot()
                snap.appendItems([instance], toSection: .main)
                self.source.apply(snap, animatingDifferences: true)
                self.loadingIndicator.stopAnimating()
                //                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
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
                
                var snap = self.source.snapshot()
                snap.appendItems([instance], toSection: .main)
                self.source.apply(snap, animatingDifferences: true)
                self.loadingIndicator.stopAnimating()
                //                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
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
                
                var snap = self.source.snapshot()
                snap.appendItems([instance], toSection: .main)
                self.source.apply(snap, animatingDifferences: true)
                //                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
            }
        })
        
        //Favorite added
        tasks.append(Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.FavoriteAppend) {
                guard let self = self,
                      self.category == .Favorite,
                      let instance = notification.object as? SurveyReference
                else { return }
                
                var snap = self.source.snapshot()
                snap.appendItems([instance], toSection: .main)
                self.source.apply(snap, animatingDifferences: true)
                self.loadingIndicator.stopAnimating()
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
                guard let self = self,
                      self.category == .Topic,
                      let instance = notification.object as? SurveyReference,
                      !self.source.snapshot().itemIdentifiers.contains(instance)
                else { return }
                
                var snap = self.source.snapshot()
                snap.appendItems([instance], toSection: .main)
                self.source.apply(snap, animatingDifferences: true)
                self.loadingIndicator.stopAnimating()
                //                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
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
                var snap = self.source.snapshot()
                var items = snap.itemIdentifiers
                let difference = SurveyReferences.shared.all
                    .filter({ $0.owner == userprofile })
                    .filter({ !items.contains($0) })
                items += difference
                
                var newSnap = Snapshot()
                newSnap.appendSections([.main])
                newSnap.appendItems(items.uniqued().sorted { $0.startDate > $1.startDate })
                self.source.apply(newSnap)
            }
        })
        
        //Subscribed at removed
        tasks.append(Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
                guard let self = self,
                      self.category == .Subscriptions,
//                      let dict = notification.object as? [Userprofile: Userprofile],
                      self.userprofile.isNil//Current user
//                      let owner = dict.values.first
                else { return }
                
                var snap = Snapshot()
                snap.appendSections([.main])
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
    
    func setColors() {
//        refreshControl?.attributedTitle = NSAttributedString(string: "updating_data".localized, attributes: [
//            .foregroundColor: refreshColor as Any,
//            .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .footnote) as Any
//        ])
        refreshControl?.tintColor = refreshColor
    }
    
    @objc
    func refresh() {
        if category == .Topic, let topic = topic {
            refreshByTopicPublisher.send(topic)
        } else if category == .Userprofile, let userprofile = userprofile {
            refreshByUserprofilePublisher.send(userprofile)
        } else {
            refreshPublisher.send(category)
        }
    }
    
    func requestData() {
        if category == .Topic, let topic = topic {
            paginationByTopicPublisher.send(topic)
        } else if category == .Userprofile, let userprofile = userprofile {
            paginationByUserprofilePublisher.send(userprofile)
        } else {
            paginationPublisher.send(category)
        }
    }
    
    @objc
    func onRemove(_ notification: Notification) {
////        setDataSource()
//        let instance = notification.object as? SurveyReference ?? Surveys.shared.rejected.last?.reference ?? Surveys.shared.banned.last?.reference
//        var snapshot = source.snapshot()
//        guard !instance.isNil, snapshot.itemIdentifiers.contains(instance!) else { return }
//        snapshot.deleteItems([instance!])
//        source.apply(snapshot, animatingDifferences: true)
    }
    
//    @objc
//    private func onPagination() {
//        endRefreshing()
//        appendToDataSource()
//    }

    func appendToDataSource() {
        var snapshot = source.snapshot()
        guard let newInstance = dataItems.last, !snapshot.itemIdentifiers.contains(newInstance) else { return }
        snapshot.appendItems([newInstance], toSection: .main)
        source.apply(snapshot, animatingDifferences: true)
    }
    
    func setDataSource(animatingDifferences: Bool = true) {
        func filterByPeriod(_ items: [SurveyReference]) -> [SurveyReference] {
            guard category != .Userprofile else { return items }
            guard let date = period.date() else { return items }
     
            return items.filter {
                $0.startDate >= date
            }
        }
        
        //TODO: Add filtering
        var snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filterByPeriod(dataItems), toSection: .main)
        source.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
//    func makePreview(_ userprofile: Userprofile) -> UIViewController {
//        let viewController = UIViewController()
//        let imageView = UIImageView(image: userprofile.image)
//        imageView.contentMode = .scaleAspectFit
//        viewController.view = imageView
//        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
////        imageView.translatesAutoresizingMaskIntoConstraints = false
//        viewController.preferredContentSize = imageView.frame.size
////        viewController.view.cornerRadius = 50
//        
//        return viewController
//    }
}
