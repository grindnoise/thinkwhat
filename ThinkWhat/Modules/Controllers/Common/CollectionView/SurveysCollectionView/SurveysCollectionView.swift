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
    public var topic: Topic?
    public var category: Survey.SurveyCategory {
        didSet {
            guard oldValue != category else { return }
            setDataSource()
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
    
    // MARK: - Destructor
    deinit {
        ///Destruct notifications
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
        allowsMultipleSelection = true
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            layoutConfig.headerMode = .firstItemInSection
            layoutConfig.backgroundColor = .clear
            layoutConfig.showsSeparators = true
            
            return NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
        }
        
        let subscriptionCellRegistration = UICollectionView.CellRegistration<SubscriptionCell, SurveyReference> { cell, indexPath, item in
            guard cell.item.isNil else { return }
            cell.item = item
        }
        
        let surveyCellRegistration = UICollectionView.CellRegistration<SurveyCell, SurveyReference> { cell, indexPath, item in
            cell.layer.masksToBounds = false
            guard cell.item.isNil else { return }
            cell.item = item
        }
        
        source = UICollectionViewDiffableDataSource<Section, SurveyReference>(collectionView: self) { [weak self]
            collectionView, indexPath, identifier -> UICollectionViewCell? in
            guard let self = self else { return UICollectionViewCell() }
            guard self.category == .Subscriptions else {
                return collectionView.dequeueConfiguredReusableCell(using: surveyCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            }
            return collectionView.dequeueConfiguredReusableCell(using: subscriptionCellRegistration,
                                                                for: indexPath,
                                                                item: identifier)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)
        source.apply(snapshot, animatingDifferences: false)
        
//        let outerColor = UIColor.clear.cgColor
//        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.white.cgColor
//        
//        hMaskLayer = CAGradientLayer()// layer];
//        // without specifying startPoint and endPoint, we get a vertical gradient
//        hMaskLayer.colors = [outerColor, innerColor,innerColor,outerColor]
//        hMaskLayer.locations = [0.0, 0.1, 0.9, 1.0]
//        hMaskLayer.frame = frame;
////        hMaskLayer.anchorPoint = .zero;
////        hMaskLayer.startPoint = CGPoint(x: 0, y: 0.5);
////        hMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5);
//        // you must add the mask to the root view, not the scrollView, otherwise
//        //  the masks will move as the user scrolls!
////        self.layer.addSublayer(hMaskLayer)
//        layer.mask = hMaskLayer
    }
    
    private func setObservers() {
//        observers.append(observe(\SurveysCollectionView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
//            guard let self = self, !self.hMaskLayer.isNil, let newValue = change.newValue, newValue.size != self.hMaskLayer.bounds.size else { return }
//            self.hMaskLayer.frame = newValue
//        })
        
        if #available(iOS 15, *) {
            notifications.append(Task { [weak self] in
                for await _ in await NotificationCenter.default.notifications(for: Notifications.Surveys.Views) {
                    await MainActor.run {
                        guard let self = self else { return }
                        
                    }
                }
            })
        } else {
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.updateViewsCount),
//                                                   name: Notifications.Surveys.Views,
//                                                   object: nil)
        }
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        refreshControl?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
//        collectionView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
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
        } else if let cell = collectionView.cellForItem(at: indexPath) as? SubscriptionCell {
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
        refreshControl?.endRefreshing()
    }
    
    @objc
    private func onRemove(_ notification: Notification) {
//        setDataSource()
        let instance = notification.object as? SurveyReference ?? Surveys.shared.rejected.last?.reference ?? Surveys.shared.banned.last?.reference
        var snapshot = source.snapshot()
        guard !instance.isNil, snapshot.itemIdentifiers.contains(instance!) else { return }
        snapshot.deleteItems([instance!])

        // Display data in the collection view by applying the snapshot to data source
        source.apply(snapshot, animatingDifferences: true)
    }
    
    @objc
    private func onPagination() {
        endRefreshing()
        appendToDataSource()
    }
    
    func appendToDataSource() {
        var snapshot = source.snapshot()
        guard let newInstance = dataItems.last, !snapshot.itemIdentifiers.contains(newInstance) else { return }
        snapshot.appendItems([newInstance], toSection: .main)

        // Display data in the collection view by applying the snapshot to data source
        source.apply(snapshot, animatingDifferences: true)
    }
    
    private func setDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SurveyReference>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataItems, toSection: .main)
        
        // Display data in the collection view by applying the snapshot to data source
        source.apply(snapshot, animatingDifferences: true)
    }
}
