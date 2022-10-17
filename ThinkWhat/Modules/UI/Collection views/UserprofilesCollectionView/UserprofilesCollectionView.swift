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
    public var mode: UserprofilesViewMode = .Subscribers {
        didSet {
            guard !userprofile.isNil else { return }
            
            reloadDataSource(items: dataItems)
        }
    }
    public weak var userprofile: Userprofile!
    
    //Publishers
    public var paginationPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public let userPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public let selectionPublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
    public let refreshPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public let gridItemSizePublisher = PassthroughSubject<UserprofilesController.GridItemSize?, Never>()
    public let subscribePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
    public let unsubscribePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //UI
//    private var isEditing = false
    private var selectedItems: [Userprofile] = []
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
    private var selectedMinAge: Int = 18
    private var selectedMaxAge: Int = 99
    private var selectedGender: Gender = .Unassigned
    private var filtered: [Userprofile] = [] {
        didSet {
            reloadDataSource(items: filtered, animated: true)
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
    
    init(userprofile: Userprofile, mode: UserprofilesViewMode) {
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
    
    public func editingMode(_ on: Bool) {
        allowsMultipleSelection = on ? true : false
        
        isEditing = on
        
        visibleCells.forEach {
            guard let cell = $0 as? UserprofileCell else { return }
            
            cell.isSelected = false
            cell.avatar.isSelected = false
            
            cell.avatar.mode = on ? .Selection : .Default
        }
    }
    
    public func filter() {
        let banner = Popup(callbackDelegate: nil, bannerDelegate: self)
        let filterCollection = UsersFilterCollectionView(userprofiles: dataItems,
                                                         filtered: filtered,
                                                         selectedMinAge: selectedMinAge,
                                                         selectedMaxAge: selectedMaxAge,
                                                         selectedGender: selectedGender)
        
        let content = PopupContent(parent: banner,
                                   systemImage: "slider.horizontal.3",
                                   content: filterCollection,
                                   buttonTitle: "show",
                                   fixedSize: false)
        
        filterCollection.buttonTitlePublisher
            .sink {
                guard let text = $0 else { return }

                content.buttonTitle = text
            }
            .store(in: &banner.subscriptions)
        
        content.exitPublisher
            .sink { [weak self] in
                guard let self = self,
                      !$0.isNil
                else { return }
                
                self.selectedMinAge = filterCollection.selectedMinAge
                self.selectedMaxAge = filterCollection.selectedMaxAge
                self.selectedGender = filterCollection.selectedGender
                self.filtered = filterCollection.filtered
            }
            .store(in: &banner.subscriptions)
        
        banner.present(content: content)
    }
    
    public func cancelSelection() {
        selectedItems.removeAll()
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
        
        delegate = self
        
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
            cell.avatar.mode = self.isEditing ? .Selection : .Default
            cell.userPublisher
                .sink { [unowned self] in
                    guard let instance = $0 else { return }
                    
                    self.userPublisher.send(instance)
                }
                .store(in: &self.subscriptions)
            
            cell.selectionPublisher
                .sink { [unowned self] in
                    guard let instance = $0,
                          let userprofile = instance.keys.first,
                          let isSelected = instance.values.first
                    else { return }
                    
                    if isSelected, !selectedItems.contains(userprofile) {
                        selectedItems.append(userprofile)
                    } else if !isSelected, selectedItems.contains(userprofile) {
                        selectedItems.remove(object: userprofile)
                    }
                    
                    self.selectionPublisher.send(selectedItems)
                }
                .store(in: &self.subscriptions)
        }
        
        source = Source(collectionView: self) { [unowned self] collectionView, indexPath, userprofile -> UICollectionViewCell? in
            return dequeueConfiguredReusableCell(using: cellRegistration,
                                                 for: indexPath,
                                                 item: userprofile)
        }
        
        reloadDataSource(items: dataItems)
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
                self.loadingIndicator.stopAnimating()
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
                self.loadingIndicator.stopAnimating()
            }
        })
        //Subscription append
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsAppend) {
                guard let self = self,
                      self.mode == .Subscriptions,
                      let dict = notification.object as? [Userprofile: Userprofile],
                      let owner = dict
.keys.first,
                      owner == self.userprofile,
                      let userprofile = dict.values.first,
                      let source = self.source.snapshot() as? Snapshot,
                      !source.itemIdentifiers.contains(userprofile)
                else { return }
                
                self.appendToDataSource(item: userprofile)
                self.loadingIndicator.stopAnimating()
            }
        })
        //Subscription remove
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
                guard let self = self,
                      self.mode == .Subscriptions,
                      let dict = notification.object as? [Userprofile: Userprofile],
                      let owner = dict.keys.first,
                      owner == self.userprofile,
                      let userprofile = dict.values.first,
                      let source = self.source.snapshot() as? Snapshot,
                      source.itemIdentifiers.contains(userprofile)
                else { return }
                
                self.removeFromDataSource(item: userprofile)
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
                self.loadingIndicator.stopAnimating()
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
                self.loadingIndicator.stopAnimating()
            }
        })
    }
    
    @MainActor
    func reloadDataSource(items: [Userprofile], animated: Bool = true) {
        guard !source.isNil else { return }
        guard !dataItems.isEmpty else {
            refreshPublisher.send(true)
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Userprofile>()
        snapshot.appendSections([.Main])
        snapshot.appendItems(items)
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

extension UserprofilesCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if dataItems.count < 10 {
            paginationPublisher.send(true)
            
            guard !loadingIndicator.isAnimating else { return }
            
            loadingIndicator.startAnimating()
        } else if let biggestRow = collectionView.indexPathsForVisibleItems.sorted(by: { $1.row < $0.row }).first?.row, indexPath.row == biggestRow + 1 && indexPath.row == dataItems.count - 1 {
            paginationPublisher.send(true)
            
            guard !loadingIndicator.isAnimating else { return }
            
            loadingIndicator.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard !allowsMultipleSelection,
              let cell = collectionView.cellForItem(at: indexPath) as? UserprofileCell
          else { return nil }
        
        return UITargetedPreview(view: cell.avatar.getSubview(type: UIView.self, identifier: "bg") ?? cell.avatar)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard !allowsMultipleSelection,
              let indexPath = indexPaths.first,
              let cell = collectionView.cellForItem(at: indexPath) as? UserprofileCell
        else { return nil }
        
        return UIContextMenuConfiguration(
            identifier: "\(indexPath.row)" as NSString, previewProvider: nil) { _ in
                var actions: [UIAction]!
                
                let profile: UIAction = .init(title: "profile".localized.capitalized,
                                             image: UIImage(systemName: "person.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                             identifier: nil,
                                             discoverabilityTitle: nil,
                                              attributes: .init(),
                                              state: .off,
                                              handler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.subscribePublisher.send([cell.userprofile])
                })
                
                let subscription: UIAction = .init(title: "delete".localized,
                                                   image: UIImage(systemName: "person.fill.badge.minus", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                                   identifier: nil,
                                                   discoverabilityTitle: nil,
                                                   attributes: [.destructive],
                                                   state: .off,
                                                   handler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.unsubscribePublisher.send([cell.userprofile])
                })
                
                actions = [profile, subscription]
                
                
                return UIMenu(title: cell.userprofile.name, image: nil, identifier: nil, options: .init(), children: actions)
            }
    }
}


extension UserprofilesCollectionView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let banner = sender as? Popup {
            banner.removeFromSuperview()
        }
    }
}
