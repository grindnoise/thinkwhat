//
//  SurveysList.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol SurveyDataSource: class {
    var category: Survey.SurveyCategory { get set }
    var topic: Topic? { get set }
    var fetchResult: [SurveyReference] { get set }
    
    func reload()
}

class SurveysCollection: UIView, SurveyDataSource {
    
    deinit {
        print("SurveysCollection deinit")
    }

    enum Section {
        case main
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        self.category = .All
        super.init(frame: frame)
        commonInit()
    }
    
    init(delegate: CallbackObservable, category: Survey.SurveyCategory) {
        self.category = category
        super.init(frame: .zero)
        callbackDelegate = delegate
        commonInit()
    }
    
    init(delegate: CallbackObservable, topic: Topic?) {
        self.topic = topic
        self.category = .Topic
        super.init(frame: .zero)
        callbackDelegate = delegate
        commonInit()
    }

    init(delegate: CallbackObservable, items: [SurveyReference]) {
        self.fetchResult = items
        self.category = .Search
        super.init(frame: .zero)
        callbackDelegate = delegate
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.category = .All
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setObservers()
        setupUI()
        ProtocolSubscriptions.subscribe(self)
    }
    
    private func setObservers() {
        let pagination = [Notifications.Surveys.UpdateSubscriptions,
                          Notifications.Surveys.UpdateTopSurveys,
                          Notifications.Surveys.UpdateOwn,
//                          Notifications.Surveys.UpdateFavorite,
                          Notifications.Surveys.SetFavorite,
                          Notifications.Surveys.UpdateAll,
                          Notifications.Surveys.UpdateNewSurveys,]
        let remove      = [Notifications.Surveys.Claim,
                           Notifications.Surveys.UnsetFavorite,
//                           Notifications.Surveys.Completed,
                           Notifications.Surveys.Rejected]
        let zeroEmitted = [Notifications.Surveys.Empty]
//        let zeroEmitted = [Notifications.Surveys.ZeroOwn,
//                           Notifications.Surveys.ZeroNew,
//                           Notifications.Surveys.ZeroTop,
//                           Notifications.Surveys.ZeroFavorites,
//                           Notifications.Surveys.ZeroSubscriptions]
        
        pagination.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.onPagination), name: $0, object: nil) }
        zeroEmitted.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.endRefreshing), name: $0, object: nil) }
        remove.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.onRemove), name: $0, object: nil) }
    }
    
    private func setupUI() {
        let pagination = [Notifications.Surveys.UpdateSubscriptions,
                          Notifications.Surveys.UpdateTopSurveys,
                          Notifications.Surveys.UpdateOwn,
//                          Notifications.Surveys.UpdateFavorite,
                          Notifications.Surveys.SetFavorite,
                          Notifications.Surveys.UpdateAll,
                          Notifications.Surveys.UpdateNewSurveys,]
        let remove      = [Notifications.Surveys.Claim,
                           Notifications.Surveys.UnsetFavorite,
//                           Notifications.Surveys.Completed,
                           Notifications.Surveys.Rejected]
        let zeroEmitted = [Notifications.Surveys.Empty]
//        let zeroEmitted = [Notifications.Surveys.ZeroOwn,
//                           Notifications.Surveys.ZeroNew,
//                           Notifications.Surveys.ZeroTop,
//                           Notifications.Surveys.ZeroFavorites,
//                           Notifications.Surveys.ZeroSubscriptions]
        
        pagination.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.onPagination), name: $0, object: nil) }
        zeroEmitted.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.endRefreshing), name: $0, object: nil) }
        remove.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.onRemove), name: $0, object: nil) }
        
        // Create cell registration that defines how data should be shown in a cell
        let cellRegistration = UICollectionView.CellRegistration<SurveyCollectionCell, SurveyReference> { (cell, indexPath, item) in
            cell.item = item
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, SurveyReference>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: SurveyReference) -> SurveyCollectionCell? in
            
            // Dequeue reusable cell using cell registration (Reuse identifier no longer needed)
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
//            // Configure cell appearance
//            cell.accessories = [.disclosureIndicator()]
            
            return cell
        }
        // Create a snapshot that define the current state of data source's data
        snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)

        // Display data in the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: false)
        refreshControl.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
        guard category != .Search, dataItems.isEmpty else { return }
        callbackDelegate?.callbackReceived(self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        refreshControl.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
        collectionView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//        collectionView.alpha = dataItems.isEmpty ? 0 : 1
    }
    
    func reload() {
        collectionView.reloadData()//reloadSections(IndexSet(arrayLiteral: 0))
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            // Create list layout
            layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
            layoutConfig.backgroundColor = .clear
//            layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
            
            let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
            // Create collection view with list layout
            collectionView.collectionViewLayout = listLayout
            collectionView.delegate = self
            
            guard category != .Search else { return }
            refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
            collectionView.refreshControl = refreshControl
        }
    }
    
    var topic: Topic?
    var category: Survey.SurveyCategory {
        didSet {
            guard oldValue != category else { return }
//            collectionView.alpha = dataItems.isEmpty ? 0 : 1
            setDataSource()
            guard !dataItems.isEmpty else { return }
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    var fetchResult: [SurveyReference] = [] {
        didSet {
            setDataSource()
        }
    }
    
    private var dataItems: [SurveyReference] {
        if category == .Topic {
            let items = category.dataItems(topic)
//            collectionView.alpha = items.isEmpty ? 0 : 1
            return items
        } else if category == .Search {
//            collectionView.alpha = fetchResult.isEmpty ? 0 : 1
            return fetchResult
        }
        return category.dataItems()
    }
    var dataSource: UICollectionViewDiffableDataSource<Section, SurveyReference>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, SurveyReference>!
    weak var callbackDelegate: CallbackObservable?
    private var layoutConfig: UICollectionLayoutListConfiguration!
    private let refreshControl = UIRefreshControl()
}

@available(iOS 14, *)
extension SurveysCollection: UICollectionViewDelegate {
    
    func deselect() {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SurveyCollectionCell else { return }
        callbackDelegate?.callbackReceived(cell.item as Any)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        if dataItems.count < 10 {
            callbackDelegate?.callbackReceived(self)
        } else if let biggestRow = collectionView.indexPathsForVisibleItems.sorted{ $1.row < $0.row }.first?.row, indexPath.row == biggestRow + 1 && indexPath.row == dataItems.count - 1 {
                callbackDelegate?.callbackReceived(self)
        }
    }
    
    @objc
    private func refresh() {
        callbackDelegate?.callbackReceived(self)
    }
    
    @objc
    private func endRefreshing() {
//        switch category {
//        case .New:
//
//        case .Top:
//
//        case .Own:
//
//        case.Favorite:
//
//        default:
//            print("")
//        }
        refreshControl.endRefreshing()
    }
    
    @objc
    private func onRemove(_ notification: Notification) {
//        setDataSource()
        let instance = notification.object as? SurveyReference ?? Surveys.shared.rejected.last?.reference ?? Surveys.shared.banned.last?.reference
        var snapshot = dataSource.snapshot()
        guard !instance.isNil, snapshot.itemIdentifiers.contains(instance!) else { return }
        snapshot.deleteItems([instance!])

        // Display data in the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc
    private func onPagination() {
        endRefreshing()
        appendToDataSource()
    }
    
    func appendToDataSource() {
        var snapshot = dataSource.snapshot()
        guard let newInstance = dataItems.last, !snapshot.itemIdentifiers.contains(newInstance) else { return }
        snapshot.appendItems([newInstance], toSection: .main)

        // Display data in the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setDataSource() {
        snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)
        
        // Display data in the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

@available(iOS 14, *)
extension SurveysCollection: CallbackCallable {}
