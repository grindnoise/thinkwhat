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
    
    enum GridItemSize: CGFloat {
        case half = 0.5
        case third = 0.33333
        case quarter = 0.25
    }
    
    typealias Source = UICollectionViewDiffableDataSource<Section, Userprofile>
    
    
    
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
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //UI
    private var gridItemSize: GridItemSize = .third {
        didSet {
            setCollectionViewLayout(createLayout(), animated: true)
        }
    }
    
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
    
    
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
}

private extension UserprofilesCollectionView {
    
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
    
    func setupUI() {
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
        tasks.append( Task {@MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: UIApplication.keyboardDidShowNotification) {
                guard let self = self else { return }
                
            }
        })
    }
    
    func reloadDataSource(animated: Bool = true) {
        guard !source.isNil else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Userprofile>()
        snapshot.appendSections([.Main])
        snapshot.appendItems(dataItems)
        source.apply(snapshot, animatingDifferences: animated)
    }
}
