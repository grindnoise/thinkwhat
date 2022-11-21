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
            
            category = .Userprofile
        }
    }
    public var fetchResult: [SurveyReference] = [] {
        didSet {
            setDataSource()
        }
    }
    
    //Publishers
    public var watchSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    public var claimSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    public var shareSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    public var paginationPublisher = PassthroughSubject<[Survey.SurveyCategory: Period], Never>()
    public var paginationByTopicPublisher = PassthroughSubject<[Topic: Period], Never>()
    public var paginationByUserprofilePublisher = PassthroughSubject<[Userprofile: Period], Never>()
    public var refreshPublisher = PassthroughSubject<[Survey.SurveyCategory: Period], Never>()
    public var refreshByTopicPublisher = PassthroughSubject<[Topic: Period], Never>()
    public var refreshByUserprofilePublisher = PassthroughSubject<[Userprofile: Period], Never>()
    public var rowPublisher = CurrentValueSubject<SurveyReference?, Never>(nil)
    public var updateStatsPublisher = CurrentValueSubject<[SurveyReference]?, Never>(nil)
    public let subscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public let unsubscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public let userprofilePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public let settingsTapPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public var scrollPublisher = PassthroughSubject<Bool, Never>()
    //UI
    public var color: UIColor = .secondaryLabel {
        didSet {
            guard oldValue != color else { return }
            
            setColors()
        }
    }
    
    
    
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
    //Scroll direction
    private var lastContentOffsetY: CGFloat = 0 {
        didSet {
            guard oldValue != lastContentOffsetY else { return }
            
            isScrollingDown = lastContentOffsetY > oldValue
            
            guard oldValue > 0,
                  contentSize.height > lastContentOffsetY + bounds.height
            else { return }
            
            scrollPublisher.send(isScrollingDown)
        }
    }
    private var isScrollingDown = true
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
    
    init(category: Survey.SurveyCategory, color: UIColor? = nil) {
        self.category = category
        
        super.init(frame: .zero, collectionViewLayout: .init())
        
        setupUI()
        setTasks()
        guard let color = color else { return }
        self.color = color
    }
    
    init(topic: Topic?, color: UIColor? = nil) {
        self.topic = topic
        self.category = .Topic
        
        super.init(frame: .zero, collectionViewLayout: .init())
        
        setupUI()
        setTasks()
        guard let color = color else { return }
        self.color = color
    }

    init(items: [SurveyReference], color: UIColor? = nil) {
        self.fetchResult = items
        self.category = .Search
        
        super.init(frame: .zero, collectionViewLayout: .init())
        
        setupUI()
        setTasks()
        guard let color = color else { return }
        self.color = color
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
        super.traitCollectionDidChange(previousTraitCollection)
        
//        refreshControl?.tintColor = color
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
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        guard category != .Search, isScrollingDown else { loadingIndicator.stopAnimating(); return }
        
        let max = source.snapshot().itemIdentifiers.count-1
        
        if max < 10 {
            requestData()
            
            guard !loadingIndicator.isAnimating else { return }
            
            loadingIndicator.startAnimating()
        } else if max > 0 {
            
            let requestThreshold = max > 5 ? 5 : max-1
            let triggerRange = max-requestThreshold...max
            
            guard triggerRange.contains(indexPath.row) else { return }
            
            requestData()
            
            guard !loadingIndicator.isAnimating else { return }
            
            loadingIndicator.startAnimating()
        }
    }
}

private extension SurveysCollectionView {
    @MainActor
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

        setRefreshControl()
        setColors()

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
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            return cell
        }

        setDataSource(animatingDifferences: false)
    }
    
    func setTasks() {
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self,
                      self.category != .Userprofile,
                      self.source.snapshot().itemIdentifiers.count != self.filterByPeriod(self.dataItems).count
                else { return }

                var snap = Snapshot()
                snap.appendSections([.main])
                snap.appendItems(self.filterByPeriod(self.dataItems))//self.dataItems)
                self.source.apply(snap, animatingDifferences: true)
            }
            .store(in: &subscriptions)
        
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self,
                      self.visibleCells.count < 4
                else { return }

                self.requestData()
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
                
                //Check by date filter
                guard instance.isValid(byBeriod: self.period) else {
                    self.loadingIndicator.stopAnimating()
                    return
                }

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
                
                //Check by date filter
                guard instance.isValid(byBeriod: self.period) else {
                    self.loadingIndicator.stopAnimating()
                    return
                }

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
                
                //Check by date filter
                guard instance.isValid(byBeriod: self.period) else {
                    self.loadingIndicator.stopAnimating()
                    return
                }

                var snap = self.source.snapshot()
                snap.appendItems([instance], toSection: .main)
                self.source.apply(snap, animatingDifferences: true)
                self.loadingIndicator.stopAnimating()
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
                    self.loadingIndicator.stopAnimating()
                    return
                }

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
                
                //Check by date filter
                guard instance.isValid(byBeriod: self.period) else {
                    self.loadingIndicator.stopAnimating()
                    return
                }

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
                
                //Check by date filter
                guard instance.isValid(byBeriod: self.period) else {
                    self.loadingIndicator.stopAnimating()
                    return
                }

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
                guard let self = self else { return }

                guard self.category == .Topic,
                      let instance = notification.object as? SurveyReference,
                      !self.source.snapshot().itemIdentifiers.contains(instance)
                else { return }

                //Check by date filter
                guard instance.isValid(byBeriod: self.period) else {
                    self.loadingIndicator.stopAnimating()
                    return
                }
                
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
                let snap = self.source.snapshot()
                var items = snap.itemIdentifiers
                let difference = SurveyReferences.shared.all
                    .filter({ $0.owner == userprofile })
                    .filter({ !items.contains($0) })
                items += difference

                var newSnap = Snapshot()
                newSnap.appendSections([.main])
                newSnap.appendItems(self.filterByPeriod(items.uniqued().sorted { $0.startDate > $1.startDate }))
                self.source.apply(newSnap)
                self.loadingIndicator.stopAnimating()
            }
        })

        //Subscribed at removed
        tasks.append(Task {@MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
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
    
    @MainActor
    func setRefreshControl() {
        if category == .Search {
            refreshControl = nil
            loadingIndicator.stopAnimating()
        } else {
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        }
    }
    
    @MainActor
    func setColors() {
//        refreshControl?.attributedTitle = NSAttributedString(string: "updating_data".localized, attributes: [
//            .foregroundColor: refreshColor as Any,
//            .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .footnote) as Any
//        ])
        refreshControl?.tintColor = color
    }
    
    @objc
    func refresh() {
        if category == .Topic, let topic = topic {
            refreshByTopicPublisher.send([topic: period])
        } else if category == .Userprofile, let userprofile = userprofile {
            refreshByUserprofilePublisher.send([userprofile: period])
        } else {
            refreshPublisher.send([category: period])
        }
    }
    
    func requestData() {
        if category == .Topic, let topic = topic {
            paginationByTopicPublisher.send([topic: period])
        } else if category == .Userprofile, let userprofile = userprofile {
            paginationByUserprofilePublisher.send([userprofile: period])
        } else {
            paginationPublisher.send([category: period])
        }
    }
    
//    @objc
//    func onRemove(_ notification: Notification) {
////        setDataSource()
//        let instance = notification.object as? SurveyReference ?? Surveys.shared.rejected.last?.reference ?? Surveys.shared.banned.last?.reference
//        var snapshot = source.snapshot()
//        guard !instance.isNil, snapshot.itemIdentifiers.contains(instance!) else { return }
//        snapshot.deleteItems([instance!])
//        source.apply(snapshot, animatingDifferences: true)
//    }
    
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filterByPeriod(dataItems), toSection: .main)
        source.apply(snapshot, animatingDifferences: animatingDifferences)
    }
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
