//
//  UserprofilesCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserprofilesCollectionView: UICollectionView {
    
    enum Section {
        case Main
    }
    
    typealias Source = UICollectionViewDiffableDataSource<Section, Userprofile>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Userprofile>
    
    
    
    // MARK: - Overridden properties
    
    
    
    // MARK: - Public properties
    //Logic
    public var mode: UserprofilesController.Mode = .Subscribers {
        didSet {
            guard !userprofile.isNil else { return }
            
            reloadDataSource()
        }
    }
    public weak var userprofile: Userprofile!
    
    //Publishers
    public let userPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public let refreshPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public let gridItemSizePublisher = PassthroughSubject<UserprofilesController.GridItemSize?, Never>()
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //UI
    private var gridItemSize: UserprofilesController.GridItemSize = .third {
        didSet {
            guard oldValue != gridItemSize else { return }
            
            setCollectionViewLayout(createLayout(), animated: true)
        }
    }
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .label
        
        return indicator
    }()
    
    //Collection view
    private var source: Source!
    private var dataItems: [Userprofile] {
        guard !userprofile.isNil else { return [] }
        
        switch mode {
        case .Subscribers:
            return userprofile.subscribers
        case .Subscriptions:
            return userprofile.subscriptions
        case .Voters:
            fatalError()
        }
    }
    
    
    
    // MARK: - Deinitialization
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
        super.init(frame: .zero, collectionViewLayout: .init())
        
        setupUI()
        setTasks()
    }
    
    init(userprofile: Userprofile, mode: UserprofilesController.Mode) {
        super.init(frame: .zero, collectionViewLayout: .init())
        
        self.userprofile = userprofile
        self.mode = mode
        
        setupUI()
        setTasks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Public methods
    @MainActor @objc
    public func endRefreshing() {
        refreshControl?.endRefreshing()
    }
    
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
}

private extension UserprofilesCollectionView {
    
    @MainActor
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(gridItemSize.rawValue),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .uniform(size: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(gridItemSize.rawValue))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    @MainActor
    func setupUI() {
        
        gridItemSizePublisher
            .sink { [weak self] in
                guard let self = self,
                      let size = $0
                else { return }
                
                self.gridItemSize = size
            }
            .store(in: &subscriptions)
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "updating_data".localized, attributes: [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .footnote) as Any
        ])
        refreshControl?.tintColor = .secondaryLabel
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            safeAreaLayoutGuide.centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 10)
        ])
        
        collectionViewLayout = createLayout()
        
        let cellRegistration = UICollectionView.CellRegistration<UserprofileCell, Userprofile> { [unowned self] cell, indexPath, userprofile in
            cell.userprofile = userprofile
            
            cell.userPublisher
                .sink { [unowned self] in
                    guard let instance = $0 else { return }
                    
                    self.userPublisher.send(instance)
                }
                .store(in: &self.subscriptions)
        }
        
        source = Source(collectionView: self) { [unowned self] collectionView, indexPath, userprofile -> UICollectionViewCell? in
            return dequeueConfiguredReusableCell(using: cellRegistration,
                                                 for: indexPath,
                                                 item: userprofile)
        }
        
        reloadDataSource()
    }
    
    func setTasks() {
        //Subscriber append
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscribersAppend) {
                guard let self = self,
                      self.mode == .Subscribers,
                      let dict = notification.object as? [Userprofile: Userprofile],
                      let owner = dict.keys.first,
                      owner == self.userprofile,
                      let subscriber = dict.values.first,
                      let source = self.source.snapshot() as? Snapshot,
                      !source.itemIdentifiers.contains(subscriber)
                else { return }
                
                self.appendToDataSource(item: subscriber)
            }
        })
        //Subscriber remove
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscribersRemove) {
                guard let self = self,
                      self.mode == .Subscribers,
                      let dict = notification.object as? [Userprofile: Userprofile],
                      let owner = dict.keys.first,
                      owner == self.userprofile,
                      let subscriber = dict.values.first,
                      let source = self.source.snapshot() as? Snapshot,
                      source.itemIdentifiers.contains(subscriber)
                else { return }
                
                self.removeFromDataSource(item: subscriber)
            }
        })
        //End refreshing
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscribersEmpty) {
                guard let self = self,
                      self.mode == .Subscribers,
                      let instance = notification.object as? Userprofile,
                      instance == self.userprofile
                else { return }
                
                self.endRefreshing()
            }
        })
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsEmpty) {
                guard let self = self,
                      self.mode == .Subscriptions,
                      let instance = notification.object as? Userprofile,
                      instance == self.userprofile
                else { return }
                
                self.endRefreshing()
            }
        })
    }
    
    @MainActor
    func reloadDataSource(animated: Bool = true) {
        guard !source.isNil else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Userprofile>()
        snapshot.appendSections([.Main])
        snapshot.appendItems(dataItems)
        source.apply(snapshot, animatingDifferences: animated)
    }
    
    @MainActor
    func appendToDataSource(item: Userprofile, animated: Bool = true) {
        guard !source.isNil else { return }
        
        var snapshot = source.snapshot()
        snapshot.appendItems([item])
        source.apply(snapshot, animatingDifferences: animated)
    }
    
    @MainActor
    func removeFromDataSource(item: Userprofile, animated: Bool = true) {
        guard !source.isNil else { return }
        
        var snapshot = source.snapshot()
        snapshot.deleteItems([item])
        source.apply(snapshot, animatingDifferences: animated)
    }
    
    @MainActor @objc
    func refresh() {
        refreshPublisher.send(true)
    }
}
