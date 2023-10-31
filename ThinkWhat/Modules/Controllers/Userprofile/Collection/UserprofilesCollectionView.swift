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
  public var mode: Enums.UserprofilesViewMode = .Subscribers
  public weak var userprofile: Userprofile? {
    didSet {
      guard !userprofile.isNil else { return }
      
      setTasks()
      reloadDataSource()
    }
  }
  public weak var answer: Answer? {
    didSet {
      setTasks()
      reloadDataSource()
    }
  }
  //Publishers
  public let requestPublisher = PassthroughSubject<Void, Never>()
  public let userPublisher = PassthroughSubject<Userprofile, Never>()
  public let selectionPublisher = PassthroughSubject<[Userprofile], Never>()
  public let refreshPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public let gridItemSizePublisher = PassthroughSubject<UserprofilesController.GridItemSize?, Never>()
  public let subscribePublisher = PassthroughSubject<[Userprofile], Never>()
  public let unsubscribePublisher = PassthroughSubject<[Userprofile], Never>()
  //UI
  public var color: UIColor = .clear
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  
  ///**UI**
  private let padding: CGFloat = 8
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
    switch mode {
    case .Subscribers, .Subscriptions:
      guard let userprofile = userprofile else { return [] }

      var items = [Userprofile]()
      if mode == .Subscribers {
        items = userprofile.subscribers.compactMap { id in
          Userprofiles.shared.all.filter({ $0.id == id }).first
        }.sorted { $0.username < $1.username }
        
        if items.count != userprofile.subscribers.count {
          requestPublisher.send()
        }
      } else {
        items = userprofile.subscriptions.compactMap { id in
          Userprofiles.shared.all.filter({ $0.id == id }).first
        }.sorted { $0.username < $1.username }
        
        if items.count != userprofile.subscriptions.count {
          requestPublisher.send()
        }
      }
      return items
    case .Voters:
      guard let answer = answer else { return [] }

      return answer.voters
    }
  }
  private var selectedMinAge: Int = 18
  private var selectedMaxAge: Int = 99
  private var selectedGender: Enums.User.Gender = .Unassigned
  private var filtered: [Userprofile] = [] {
    didSet {
      guard selectedGender == .Unassigned, selectedMaxAge == 99, selectedMinAge == 18 else {
        reloadDataSource(useFilterder: true)
        return
      }
      reloadDataSource()
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
    self.color = .label
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
//    setTasks()
  }
  
  init(userprofile: Userprofile, mode: Enums.UserprofilesViewMode, color: UIColor) {
    self.color = color
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    self.userprofile = userprofile
    self.mode = mode
    
    setupUI()
//    setTasks()
  }
  
  init(answer: Answer, mode: Enums.UserprofilesViewMode, color: UIColor) {
    self.color = color
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    self.answer = answer
    self.mode = mode
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  //  @MainActor @objc
  //  public func endRefreshing() {
  //    refreshControl?.endRefreshing()
  //  }
  
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
    let banner = Popup()
    let filterCollection = UsersFilterCollectionView(userprofiles: dataItems,
                                                     color: color,
                                                     filtered: filtered,
                                                     selectedMinAge: selectedMinAge,
                                                     selectedMaxAge: selectedMaxAge,
                                                     selectedGender: selectedGender)
    
    let content = PopupContent(parent: banner,
                               color: color,
                               systemImage: "slider.horizontal.3",
                               content: filterCollection,
                               buttonTitle: "show",
                               fixedSize: false)
    
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &subscriptions)
    
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
    item.contentInsets = .uniform(size: padding)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalWidth(gridItemSize.rawValue))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = .uniform(size: padding)

    
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
    
    //    refreshControl = UIRefreshControl()
    //    refreshControl?.attributedTitle = NSAttributedString(string: "updating_data".localized, attributes: [
    //      .foregroundColor: UIColor.secondaryLabel,
    //      .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .footnote) as Any
    //    ])
    //    refreshControl?.tintColor = .secondaryLabel
    //    refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    
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
    
//    var snapshot = NSDiffableDataSourceSnapshot<Section, Userprofile>()
//    snapshot.appendSections([.Main])
//    source.apply(snapshot, animatingDifferences: false)
    
    reloadDataSource()
  }
  
  func setTasks() {
    if !userprofile.isNil {
      Userprofiles.shared.instancesPublisher
        .collect(.byTimeOrCount(DispatchQueue.main, 2, 10), options: nil)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.reloadDataSource() }
        .store(in: &subscriptions)
    }
    
    
//    guard let userprofile = userprofile else { return }
//
//    ///**Append**
//    userprofile.subscribersPublisher
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] subscribers in
//        guard let self = self,
//              self.mode == .Subscribers
//        else { return }
//
//        var snap = self.source.snapshot()
//        let existingSet = Set(snap.itemIdentifiers)
//        let appendingSet = Set(subscribers.filter { !$0.isBanned })
//        snap.appendItems(existingSet.isEmpty ? Array(appendingSet) : Array(appendingSet.subtracting(existingSet)),
//                         toSection: .Main)
//
//        self.source.apply(snap, animatingDifferences: true) { [weak self] in
//          guard let self = self else { return }
//
//          self.loadingIndicator.stopAnimating()
//        }
//      }
//      .store(in: &subscriptions)
//    ///
//    userprofile.subscriptionsPublisher
//      .receive(on: DispatchQueue.main)
//      .sink(receiveCompletion: {
//        if case .failure(let error) = $0 {
//#if DEBUG
//          print(error)
//#endif
//        }
//      }, receiveValue: { [weak self] subscribers in
//        guard let self = self,
//              self.mode == .Subscriptions
//        else { return }
//
//        var snap = self.source.snapshot()
//        let existingSet = Set(snap.itemIdentifiers)
//        let appendingSet = Set(subscribers.filter { !$0.isBanned })
//        snap.appendItems(existingSet.isEmpty ? Array(appendingSet) : Array(appendingSet.subtracting(existingSet)),
//                         toSection: .Main)
//
//        self.source.apply(snap, animatingDifferences: true) { [weak self] in
//          guard let self = self else { return }
//
//          self.loadingIndicator.stopAnimating()
//        }
//      })
//      .store(in: &subscriptions)
//
//    ///**Remove**
//    Userprofiles.shared.unsubscribedPublisher
//      .filter { [weak self] in
//        guard let self = self,
//              let userprofile = self.userprofile,
//              userprofile.isCurrent,
//              self.source.snapshot().itemIdentifiers.contains($0)
//        else { return false }
//
//        return true
//      }
//      .receive(on: DispatchQueue.main)
//      .sink { [unowned self] in
//        var snap = self.source.snapshot()
//        snap.deleteItems([$0])
//        self.source.apply(snap, animatingDifferences: true)
//      }
//      .store(in: &subscriptions)
//
//    //    //Subscriber remove
//    //    tasks.append( Task {@MainActor [weak self] in
//    //      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscribersRemove) {
//    //        guard let self = self,
//    //              self.mode == .Subscribers,
//    //              let dict = notification.object as? [Userprofile: Userprofile],
//    //              let owner = dict.keys.first,
//    //              owner == self.userprofile,
//    //              let subscriber = dict.values.first,
//    //              self.source.snapshot().itemIdentifiers.contains(subscriber)
//    //        else { return }
//    //
//    //        self.removeFromDataSource(item: subscriber)
//    //        self.loadingIndicator.stopAnimating()
//    //      }
//    //    })
////    //Subscription remove
////    tasks.append( Task {@MainActor [weak self] in
////      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
////        guard let self = self,
////              self.mode == .Subscriptions,
////              let dict = notification.object as? [Userprofile: Userprofile],
////              let owner = dict.keys.first,
////              owner == self.userprofile,
////              let userprofile = dict.values.first,
////              self.source.snapshot().itemIdentifiers.contains(userprofile)
////        else { return }
////
////        self.removeFromDataSource(item: userprofile)
////      }
////    })
  }
  
  @MainActor
  func reloadDataSource(useFilterder: Bool = false,
                        animated: Bool = true) {
    
    
    
//    guard !source.isNil,
//          !dataItems.isEmpty
//    else {
//      refreshPublisher.send(true)
//      return
//    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([.Main])
    snapshot.appendItems(useFilterder ? filtered : dataItems)
    source.apply(snapshot, animatingDifferences: animated)
  }
  
  @MainActor
  func appendToDataSource(items: [Userprofile], animated: Bool = true) {
    guard !source.isNil else { return }
    
    var snapshot = source.snapshot()
    snapshot.appendItems(items)
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
    if let biggestRow = collectionView.indexPathsForVisibleItems.sorted(by: { $1.row < $0.row }).first?.row, indexPath.row == biggestRow + 1 && indexPath.row == dataItems.count - 1 {
      requestPublisher.send()
      
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
        
        
        return UIMenu(title: cell.userprofile.firstNameSingleWord + (cell.userprofile.lastNameSingleWord.isEmpty ? "" : " \(cell.userprofile.lastNameSingleWord)"), image: nil, identifier: nil, options: .init(), children: actions)
      }
  }
}
