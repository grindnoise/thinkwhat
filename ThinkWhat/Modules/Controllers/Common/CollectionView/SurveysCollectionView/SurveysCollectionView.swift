//
//  SurveysCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveysCollectionView: UICollectionView {
    
    // MARK: - Enums
    private enum Section { case main }
    
    // MARK: - Public properties
    public var topic: Topic? {
        didSet {
            guard !topic.isNil else { return }
            category = .Topic
//            setDataSource()
        }
    }
    public var category: Survey.SurveyCategory {
        didSet {
//            guard oldValue != category else { return }
            setDataSource(animatingDifferences: (category == .Topic || category == .Search) ? false : true)
            guard !dataItems.isEmpty else { return }
            scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    public var fetchResult: [SurveyReference] = [] {
        didSet {
            setDataSource()
        }
    }
    
    // MARK: - Private properties
    private var notifications: [Task<Void, Never>?] = []
    private var source: UICollectionViewDiffableDataSource<Section, SurveyReference>!
    private var dataItems: [SurveyReference] {
        if category == .Topic, !topic.isNil {
            return category.dataItems(topic)
        } else if category == .Search {
            return fetchResult
        }
        return category.dataItems()
    }
    private weak var callbackDelegate: CallbackObservable?
//    private var hMaskLayer: CAGradientLayer!
    private var observers: [NSKeyValueObservation] = []
    private lazy var searchSpinner: UIActivityIndicatorView = {
        let instance = UIActivityIndicatorView(style: .large)
        instance.color = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.alpha = 0
        instance.layoutCentered(in: self)
        return instance
    }()
    
    // MARK: - Destructor
    deinit {
        notifications.forEach { $0?.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        fatalError("init(frame:) has not been implemented")
//        super.init(frame: .zero, collectionViewLayout: .init())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(delegate: CallbackObservable, category: Survey.SurveyCategory) {
        self.category = category
        super.init(frame: .zero, collectionViewLayout: .init())
        callbackDelegate = delegate
        setupUI()
        setObservers()
    }
    
    init(delegate: CallbackObservable, topic: Topic?) {
        self.topic = topic
        self.category = .Topic
        super.init(frame: .zero, collectionViewLayout: .init())
        callbackDelegate = delegate
        setupUI()
        setObservers()
    }

    init(delegate: CallbackObservable, items: [SurveyReference]) {
        self.fetchResult = items
        self.category = .Search
        super.init(frame: .zero, collectionViewLayout: .init())
        callbackDelegate = delegate
        setupUI()
        setObservers()
    }
    
    // MARK: - Private methods
    private func setupUI() {
        delegate = self
//        bounces = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
//            layoutConfig.headerMode = .firstItemInSection
            layoutConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground
            layoutConfig.showsSeparators = false//true
//            if #available(iOS 14.5, *) {
//                var separatorConfig = UIListSeparatorConfiguration(listAppearance: UICollectionLayoutListConfiguration.Appearance.grouped)
//                separatorConfig.bottomSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: .greatestFiniteMagnitude)
//                layoutConfig.separatorConfiguration = separatorConfig
//            }
            
            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            sectionLayout.interGroupSpacing = 16
            return sectionLayout
        }
        
        let cellRegistration = UICollectionView.CellRegistration<SurveyCell, SurveyReference> { cell, indexPath, item in
            cell.item = item
            
            var config = UIBackgroundConfiguration.listPlainCell()
            config.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
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
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)
        source.apply(snapshot, animatingDifferences: false)
    }
    
    private func setObservers() {
        if #available(iOS 15, *) {
            
            //Update survey stats every n seconds
            let events = EventEmitter().emit(every: 5)
            notifications.append(Task { [weak self] in
                for await _ in events {
                    guard let self = self,
                          let cells = visibleCells.filter({ $0.isKind(of: SurveyCell.self) }) as? [SurveyCell] else { return }
                    self.callbackDelegate?.callbackReceived(cells.compactMap({ $0.item }))
                }
            })
            
            //Survey claimed by user
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Claim) {
                    guard let self = self,
                          let instance = notification.object as? SurveyReference,
                          self.source.snapshot().itemIdentifiers.contains(instance)
                    else { return }

                    var snap = self.source.snapshot()
                    snap.deleteItems([instance])
                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
                }
            })

            //Survey banned on server
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Ban) {
                    guard let self = self,
                          let instance = notification.object as? SurveyReference,
                          self.source.snapshot().itemIdentifiers.contains(instance)
                    else { return }

                    var snap = self.source.snapshot()
                    snap.deleteItems([instance])
                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
                }
            })


            //Subscriptions added
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SubscriptionAppend) {
                    guard let self = self,
                          self.category == .Subscriptions,
                          let instance = notification.object as? SurveyReference,
                          !self.source.snapshot().itemIdentifiers.contains(instance)
                    else { return }

                    var snap = self.source.snapshot()
                    snap.appendItems([instance], toSection: .main)
                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
                }
            })

            //New added
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.NewAppend) {
                    guard let self = self,
                          self.category == .New,
                          let instance = notification.object as? SurveyReference,
                          !self.source.snapshot().itemIdentifiers.contains(instance)
                    else { return }

                    var snap = self.source.snapshot()
                    snap.appendItems([instance], toSection: .main)
                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
                }
            })

            //Top added
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.TopAppend) {
                    guard let self = self,
                          self.category == .Top,
                          let instance = notification.object as? SurveyReference,
                          !self.source.snapshot().itemIdentifiers.contains(instance)
                    else { return }

                    var snap = self.source.snapshot()
                    snap.appendItems([instance], toSection: .main)
                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
                }
            })

            //Own added
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.OwnAppend) {
                    guard let self = self,
                          self.category == .Own,
                          let instance = notification.object as? SurveyReference,
                          !self.source.snapshot().itemIdentifiers.contains(instance)
                    else { return }

                    var snap = self.source.snapshot()
                    snap.appendItems([instance], toSection: .main)
                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
                }
            })

            //Favorite added
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.FavoriteAppend) {
                    guard let self = self,
                          self.category == .Favorite,
                          let instance = notification.object as? SurveyReference,
                          !self.source.snapshot().itemIdentifiers.contains(instance)
                    else { return }

                    var snap = self.source.snapshot()
                    snap.appendItems([instance], toSection: .main)
                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
                }
            })

            //Topic added
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.TopicAppend) {
                    guard let self = self,
                          self.category == .Topic,
                          let instance = notification.object as? SurveyReference,
                          !self.source.snapshot().itemIdentifiers.contains(instance)
                    else { return }

                    var snap = self.source.snapshot()
                    snap.appendItems([instance], toSection: .main)
                    await MainActor.run { self.source.apply(snap, animatingDifferences: true) }
                }
            })


        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.appendItemIdentifier(notification:)),
                                                   name: Notifications.Surveys.SubscriptionAppend,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.appendItemIdentifier(notification:)),
                                                   name: Notifications.Surveys.TopicAppend,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.appendItemIdentifier(notification:)),
                                                   name: Notifications.Surveys.FavoriteAppend,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.appendItemIdentifier(notification:)),
                                                   name: Notifications.Surveys.OwnAppend,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.appendItemIdentifier(notification:)),
                                                   name: Notifications.Surveys.TopAppend,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.appendItemIdentifier(notification:)),
                                                   name: Notifications.Surveys.NewAppend,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.removeItemIdentifier(notification:)),
                                                   name: Notifications.Surveys.Claim,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.removeItemIdentifier(notification:)),
                                                   name: Notifications.Surveys.Ban,
                                                   object: nil)
        }
    }
    
    // MARK: - Public methods
    @MainActor @objc
    public func endRefreshing() {
        refreshControl?.endRefreshing()
    }
    
    @MainActor @objc
    public func beginSearchRefreshing() {
        searchSpinner.startAnimating()
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0) {
            self.searchSpinner.alpha = 1
        }
    }
    
    @MainActor @objc
    public func endSearchRefreshing() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.searchSpinner.alpha = 1
        } completion: { _ in self.searchSpinner.stopAnimating() }
    }
    
    //Old-fashioned observation
    @objc func appendItemIdentifier(notification: Notification) {
        if notification.name == Notifications.Surveys.SubscriptionAppend, category == .Subscriptions, let instance = notification.object as? SurveyReference, !source.snapshot().itemIdentifiers.contains(instance) {
            var snap = self.source.snapshot()
            snap.appendItems([instance], toSection: .main)
            source.apply(snap, animatingDifferences: true)
        } else if notification.name == Notifications.Surveys.NewAppend, category == .New, let instance = notification.object as? SurveyReference, !source.snapshot().itemIdentifiers.contains(instance) {
            var snap = self.source.snapshot()
            snap.appendItems([instance], toSection: .main)
            source.apply(snap, animatingDifferences: true)
        } else if notification.name == Notifications.Surveys.TopAppend, category == .Top, let instance = notification.object as? SurveyReference, !source.snapshot().itemIdentifiers.contains(instance) {
            var snap = self.source.snapshot()
            snap.appendItems([instance], toSection: .main)
            source.apply(snap, animatingDifferences: true)
        } else if notification.name == Notifications.Surveys.OwnAppend, category == .Own, let instance = notification.object as? SurveyReference, !source.snapshot().itemIdentifiers.contains(instance) {
            var snap = self.source.snapshot()
            snap.appendItems([instance], toSection: .main)
            source.apply(snap, animatingDifferences: true)
        } else if notification.name == Notifications.Surveys.FavoriteAppend, category == .Favorite, let instance = notification.object as? SurveyReference, !source.snapshot().itemIdentifiers.contains(instance) {
            var snap = self.source.snapshot()
            snap.appendItems([instance], toSection: .main)
            source.apply(snap, animatingDifferences: true)
        }
    }
    
    @objc func removeItemIdentifier(notification: Notification) {
        guard let instance = notification.object as? SurveyReference,
              source.snapshot().itemIdentifiers.contains(instance)
        else { return }

        var snap = self.source.snapshot()
        snap.deleteItems([instance])
        source.apply(snap, animatingDifferences: true)
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
            layoutConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground
            layoutConfig.showsSeparators = false//true

            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            sectionLayout.interGroupSpacing = 16
            return sectionLayout
        }
        refreshControl?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
        searchSpinner.color = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
}

extension SurveysCollectionView: UICollectionViewDelegate {
    
    func deselect() {
        guard let indexPath = indexPathsForSelectedItems?.first else { return }
        deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SurveyCollectionCell {
            callbackDelegate?.callbackReceived(cell.item as Any)
        } else if let cell = collectionView.cellForItem(at: indexPath) as? SurveyCell {
            callbackDelegate?.callbackReceived(cell.item as Any)
        }
        deselect()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        if dataItems.count < 10 {
            callbackDelegate?.callbackReceived(self)
        } else if let biggestRow = collectionView.indexPathsForVisibleItems.sorted(by: { $1.row < $0.row }).first?.row, indexPath.row == biggestRow + 1 && indexPath.row == dataItems.count - 1 {
                callbackDelegate?.callbackReceived(self)
        }
    }
    
    @objc
    private func refresh() {
        callbackDelegate?.callbackReceived(self)
    }
    
    @objc
    private func onRemove(_ notification: Notification) {
//        setDataSource()
        let instance = notification.object as? SurveyReference ?? Surveys.shared.rejected.last?.reference ?? Surveys.shared.banned.last?.reference
        var snapshot = source.snapshot()
        guard !instance.isNil, snapshot.itemIdentifiers.contains(instance!) else { return }
        snapshot.deleteItems([instance!])
        source.apply(snapshot, animatingDifferences: true)
    }
    
//    @objc
//    private func onPagination() {
//        endRefreshing()
//        appendToDataSource()
//    }

    private func appendToDataSource() {
        var snapshot = source.snapshot()
        guard let newInstance = dataItems.last, !snapshot.itemIdentifiers.contains(newInstance) else { return }
        snapshot.appendItems([newInstance], toSection: .main)
        source.apply(snapshot, animatingDifferences: true)
    }
    
    private func setDataSource(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)
        source.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
