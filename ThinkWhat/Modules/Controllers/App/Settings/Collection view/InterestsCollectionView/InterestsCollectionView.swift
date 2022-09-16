//
//  InterestsCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class InterestsCollectionView: UICollectionView {
    enum Section { case Main }
    
    // MARK: - Public properties
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Collection
    private var source: UICollectionViewDiffableDataSource<Section, Topic>!
    
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
        super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
//        delegate = self
        
        collectionViewLayout = UICollectionViewCompositionalLayout{ section, environment -> NSCollectionLayoutSection in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.backgroundColor = .clear
            
            let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            return sectionLayout
        }
        
        let interestCellRegistration = UICollectionView.CellRegistration<InterestCell, Topic> { [unowned self] cell, indexPath, item in
            
//            //Twitter
//            cell.twitterPublisher.sink { [weak self] in
//                guard let self = self,
//                      let string = $0
//                else { return }
//
//            }.store(in: &self.subscriptions)
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .clear
            cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            cell.backgroundConfiguration = backgroundConfig
                        
            guard let userprofile = Userprofiles.shared.current else { return }
            
//            cell.userprofile = userprofile
        }
        
        
        source = UICollectionViewDiffableDataSource<Section, Topic>(collectionView: self) { [unowned self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Topic) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: interestCellRegistration,
                                                                for: indexPath,
                                                                item: identifier)
        }
        
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
//        snapshot.appendSections([.Credentials, .City, .SocialMedia, .Interests])
//        snapshot.appendItems([0], toSection: .Credentials)
//        snapshot.appendItems([1], toSection: .City)
//        snapshot.appendItems([2], toSection: .SocialMedia)
//        snapshot.appendItems([3], toSection: .Interests)
//        source.apply(snapshot, animatingDifferences: false)
    }
    // MARK: - Public methods
    
    // MARK: - Private methods
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
}
