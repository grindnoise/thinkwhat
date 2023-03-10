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
    public let userPublisher = CurrentValueSubject<[Userprofile: IndexPath]?, Never>(nil)
    public let footerPublisher = CurrentValueSubject<UserprofilesViewMode?, Never>(nil)
    public let dataItemsCountPublisher = CurrentValueSubject<Bool?, Never>(nil)
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Collection
    private let maxUsers = 20
    private var source: Source!
    private var dataItems: [Userprofile] {
        switch mode {
        case .Subscribers:
          let userprofiles = userprofile.subscribers.suffix(maxUsers)
          guard userprofiles.count >= maxUsers else {
            return userprofile.subscribers.suffix(maxUsers)
          }
          return userprofile.subscribers.suffix(maxUsers) + [Userprofile.anonymous]
        case .Subscriptions:
          let userprofiles = userprofile.subscriptions.suffix(maxUsers)
          guard userprofiles.count >= maxUsers else {
            return userprofile.subscriptions.suffix(maxUsers)
          }
          return userprofile.subscriptions.suffix(maxUsers) + [Userprofile.anonymous]
        default: return [] }
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
    public func removeItem(_ userprofile: Userprofile) {
        var snap = source.snapshot()
        guard !snap.itemIdentifiers.filter({ $0 == userprofile }).isEmpty else { return }
        
        snap.deleteItems([userprofile])
        if snap.itemIdentifiers.count == 1, let anon = snap.itemIdentifiers.filter({ $0 == Userprofile.anonymous }).first {
            snap.deleteItems([anon])
        }
        source.apply(snap, animatingDifferences: true) { [weak self] in
            guard let self = self else { return }

            self.dataItemsCountPublisher.send(snap.itemIdentifiers.isEmpty)
        }
    }
    
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
}

private extension UserprofilesFeedCollectionView {
    
    func setupUI() {
        alwaysBounceVertical = false
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)))
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
            
//            let footerHeaderSize = NSCollectionLayoutSize(widthDimension: .absolute(90),
//                                                          heightDimension: .absolute(90))
//            let footer = NSCollectionLayoutBoundarySupplementaryItem(
//                layoutSize: footerHeaderSize,
//                elementKind: UICollectionView.elementKindSectionFooter,
//                alignment: .trailing)
//            section.boundarySupplementaryItems = [footer]
            
            return section
        }
        
//        let footerRegistraition = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionFooter) { supplementaryView, elementKind, indexPath in
//
//            var configuration = supplementaryView.defaultContentConfiguration()
//            configuration.text = "All"
//            configuration.textProperties.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline)!
//            configuration.textProperties.color = .white
//            configuration.textProperties.alignment = .center
//            configuration.directionalLayoutMargins = .init(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
//
//            var config = UIBackgroundConfiguration.listPlainCell()
//            config.backgroundColor = .systemRed
//            supplementaryView.backgroundConfiguration = config
//            supplementaryView.contentConfiguration = configuration
//            supplementaryView.automaticallyUpdatesContentConfiguration = false
//        }
        
        let cellRegistration = UICollectionView.CellRegistration<UserprofileCell, Userprofile> { [unowned self] cell, indexPath, userprofile in
            cell.userprofile = userprofile
            cell.avatar.mode = self.isEditing ? .Selection : .Default
            cell.textStyle = .footnote
            cell.userPublisher
                .sink { [unowned self] in
                    guard let instance = $0 else { return }
                    
                    self.userPublisher.send([instance: indexPath])
                }
                .store(in: &self.subscriptions)
            
            cell.footerPublisher
                .sink { [unowned self] in
                    guard !$0.isNil else { return }
                    
                    self.footerPublisher.send(self.mode)
                }
                .store(in: &self.subscriptions)
        }
        
        source = Source(collectionView: self) { [unowned self] collectionView, indexPath, userprofile -> UICollectionViewCell? in
            return dequeueConfiguredReusableCell(using: cellRegistration,
                                                 for: indexPath,
                                                 item: userprofile)
        }
        
//        source.supplementaryViewProvider = {
//            collectionView, elementKind, indexPath -> UICollectionReusableView? in
//
//            return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistraition, for: indexPath)
//        }
        
        var snap = Snapshot()
        snap.appendSections([.Main])
        snap.appendItems(dataItems)
        source.apply(snap) { [weak self] in
            guard let self = self else { return }

            self.dataItemsCountPublisher.send(snap.itemIdentifiers.isEmpty)
        }
    }
    
    func setTasks() {
        
//        Timer
//            .publish(every: 2, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                guard let self = self,
//                      self.source.snapshot().itemIdentifiers.count != self.dataItems.count
//                else { return }
//
//                var snap = Snapshot()
//                snap.appendSections([.Main])
//                snap.appendItems(self.dataItems)
//                self.source.apply(snap) { [weak self] in
//                    guard let self = self else { return }
//
//                    self.dataItemsCountPublisher.send(snap.itemIdentifiers.isEmpty)
//                }
//            }
//            .store(in: &subscriptions)
      
      userprofile.subscriptionsPublisher
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: {
          if case .failure(let error) = $0 {
  #if DEBUG
            print(error)
  #endif
          }
        }, receiveValue: { [weak self] subscribers in
          guard let self = self,
                self.mode == .Subscriptions
          else { return }
          
          var snap = self.source.snapshot()
          let existingSet = Set(snap.itemIdentifiers)
          let appendingSet = Set(subscribers.filter { !$0.isBanned })
          snap.appendItems(existingSet.isEmpty ? Array(appendingSet) : Array(appendingSet.subtracting(existingSet)),
                           toSection: .Main)
          
          self.source.apply(snap, animatingDifferences: true) { [unowned self] in self.dataItemsCountPublisher.send(snap.itemIdentifiers.isEmpty) }
        })
        .store(in: &subscriptions)
      
      userprofile.subscriptionsRemovePublisher
        .filter { !$0.isEmpty }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: {
          if case .failure(let error) = $0 {
  #if DEBUG
            print(error)
  #endif
          }
        }, receiveValue: { [weak self] in
          guard let self = self,
                self.mode == .Subscriptions,
                let inputView = self.getSuperview(type: SubscriptionsView.self),
                !inputView.isCardOnScreen
          else { return }
          
          var snap = self.source.snapshot()
          let existingSet = Set(self.source.snapshot().itemIdentifiers)
          let deletingSet = Set($0)
          let crossingSet = existingSet.intersection(deletingSet)
          
          guard !crossingSet.isEmpty else { return }
          
          snap.deleteItems(Array(deletingSet))
          self.source.apply(snap, animatingDifferences: true) { [unowned self] in self.dataItemsCountPublisher.send(snap.itemIdentifiers.isEmpty) }
        })
        .store(in: &subscriptions)
      
//      ///Unsubscribed
//      Userprofiles.shared.unsubscribedPublisher
//        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] unsubscribed in
//          guard self.source.snapshot().itemIdentifiers.contains(unsubscribed),
//                let inputView = self.getSuperview(type: SubscriptionsView.self),
//                let viewInput = inputView.viewInput,
//                !viewInput.isOnScreen,
//                self.source.snapshot().itemIdentifiers.contains(userprofile)
//          else { return }
//          
//          var snap = self.source.snapshot()
//          snap.deleteItems([unsubscribed])
//          self.source.apply(snap) { [weak self] in
//              guard let self = self else { return }
//              
//              self.dataItemsCountPublisher.send(snap.itemIdentifiers.isEmpty)
//          }
//        }
//        .store(in: &subscriptions)
      
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsAppend) {
//                guard let self = self,
//                      let dict = notification.object as? [Userprofile: Userprofile],
//                      let owner = dict.keys.first,
//                      owner == self.userprofile,
//                      let userprofile = dict.values.first
//                else { return }
//
//                var snap = self.source.snapshot()
//                guard snap.itemIdentifiers.filter({ $0 == userprofile }).isEmpty else { return }
//
//                if snap.itemIdentifiers.count > 1, let lastItem = snap.itemIdentifiers.last {
//                    snap.insertItems([userprofile], beforeItem: lastItem)
//                } else {
//                    snap.appendItems([userprofile])
//                }
//                self.source.apply(snap) { [weak self] in
//                    guard let self = self else { return }
//
//                    self.dataItemsCountPublisher.send(snap.itemIdentifiers.isEmpty)
//                }
//            }
//        })
        
//        tasks.append( Task { [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
//                guard let self = self,
//                      let dict = notification.object as? [Userprofile: Userprofile],
//                      let owner = dict.keys.first,
//                      owner == self.userprofile,
//                      let userprofile = dict.values.first,
//                      self.source.snapshot().itemIdentifiers.contains(userprofile),
//                      let inputView = self.getSuperview(type: SubscriptionsView.self),
//                      let viewInput = inputView.viewInput,
//                      viewInput.isOnScreen
//                else { return }
//                
//                await MainActor.run {
//                    var snap = self.source.snapshot()
//                    snap.deleteItems([userprofile])
//                    self.source.apply(snap) { [weak self] in
//                        guard let self = self else { return }
//                        
//                        self.dataItemsCountPublisher.send(snap.itemIdentifiers.isEmpty)
//                    }
//                }
//            }
//        })
    }
}
