//
//  UserprofilesFeedCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

import UIKit
import Combine

class UserprofilesFeedCollectionView: UICollectionView {
    enum Section {
        case Main
    }
    
    typealias Source = UICollectionViewDiffableDataSource<Section, Userprofile>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Userprofile>
    
    // MARK: - Overridden properties
    
    
    
    // MARK: - Public properties
    public let userPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Collection
    private var source: Source!
    private var dataItems: [Userprofile] {
        switch mode {
        case .Subscribers:
            return userprofile.subscribers
        case .Subscriptions:
            return userprofile.subscriptions
        default:
            return []
        }
    }
    private let userprofile: Userprofile
    private let mode: UserprofilesViewMode
    
    
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
    init(userprofile: Userprofile, mode: UserprofilesViewMode) {
        self.userprofile = userprofile
        self.mode = mode
        
        super.init(frame: .zero, collectionViewLayout: .init())
        
        setupUI()
        setTasks()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        fatalError("init(frame:, collectionViewLayout:) has not been implemented")
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

private extension UserprofilesFeedCollectionView {
    
    func setupUI() {
        alwaysBounceVertical = false
//        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
//
//            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
//            layoutConfig.backgroundColor = .clear
//            layoutConfig.showsSeparators = false
//
//            let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
//            sectionLayout.orthogonalScrollingBehavior = .continuous
//                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//
//
//            return sectionLayout
//        }
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
//            let item = NSCollectionLayoutItem(
//                layoutSize: NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1/5),
//                    heightDimension: .fractionalWidth(1/5)))
////            item.contentInsets = .init(horizontal: 0, vertical: 0)
//
//            let group = NSCollectionLayoutGroup.horizontal(
//                layoutSize: NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1),
//                    heightDimension: .fractionalHeight(1)),
//                subitem: item,
//                count: 5)
//
//            let section = NSCollectionLayoutSection(group: group)
//            section.contentInsets = .init(top: 10,
//                                          leading: 0,
//                                          bottom: 0,
//                                          trailing: 0)
//            section.orthogonalScrollingBehavior = .continuous
//            return section
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)))
//                    heightDimension: .absolute(90)))
            item.contentInsets = .init(horizontal: 10, vertical: 5)

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .fractionalHeight(1)),
                subitem: item,
                count: 5)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 5,
                                          leading: 10,
                                          bottom: 5,
                                          trailing: 10)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UserprofileCell, Userprofile> { [unowned self] cell, indexPath, userprofile in
            cell.userprofile = userprofile
            cell.avatar.mode = self.isEditing ? .Selection : .Default
            cell.textStyle = .footnote
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
        
        var snap = Snapshot()
        snap.appendSections([.Main])
        snap.appendItems(dataItems)
        source.apply(snap)
    }
    
    func setTasks() {
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
//                guard let self = self else { return }
//
//
//            }
//        })
    }
}

extension UserprofilesFeedCollectionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
}
