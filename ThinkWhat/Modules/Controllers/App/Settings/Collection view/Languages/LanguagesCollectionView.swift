//
//  LanguagesCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//


import UIKit
import Combine
import L10n_swift

class LanguageItem: Hashable {
  static func == (lhs: LanguageItem, rhs: LanguageItem) -> Bool {
    lhs.code == rhs.code
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(code)
  }
  
  let code: String
  var selected: Bool
  
  init(code: String, selected: Bool) {
    self.code = code
    self.selected = selected
  }
}

class LanguagesCollectionView: UICollectionView {
  
  enum Section { case main }
  
  typealias Source = UICollectionViewDiffableDataSource<Section, LanguageItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, LanguageItem>
  
  // MARK: - Public properties
  public let selectionPublisher = PassthroughSubject<Void, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var source: UICollectionViewDiffableDataSource<Section, LanguageItem>!
  private let dataItems: [LanguageItem]
  ///**UI**
  private let insets: UIEdgeInsets
  
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
  init(dataItems: [LanguageItem], insets: UIEdgeInsets = .zero) {
    self.dataItems = dataItems
    self.insets = insets
    
    super.init(frame: .zero, collectionViewLayout: .init())
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overridden methods
//  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//    super.traitCollectionDidChange(previousTraitCollection)
//    
//    guard let cells = visibleCells as? [UICollectionViewListCell] else { return }
//    
////    cells.forEach {
////      $0.accessories = [UICellAccessory.checkmark(displayed: .always,
////                                                  options: .init(isHidden: !$0.isSelected,
////                                                                 tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen))]
////    }
//  }
}

private extension LanguagesCollectionView {
  
  func setupUI() {
    delegate = self
    allowsMultipleSelection = true
    collectionViewLayout = UICollectionViewCompositionalLayout.list(using: {
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.showsSeparators = false
      configuration.backgroundColor = .clear
//      if #available(iOS 14.5, *) {
//        configuration.itemSeparatorHandler = { indexPath, config -> UIListSeparatorConfiguration in
//          var config = UIListSeparatorConfiguration(listAppearance: .plain)
//          config.color = .systemGray5
//          config.bottomSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1.2, trailing: 0)
//          config.bottomSeparatorVisibility = .visible
//          
//          return config
//        }
//      }
      
      return configuration
    }())
    
    let cellRegistration = UICollectionView.CellRegistration<LanguageCell, LanguageItem> { [unowned self] cell, indexPath, item in
      var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
      backgroundConfig.backgroundColor = .clear
      cell.backgroundConfiguration = backgroundConfig
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      // Set data
      cell.insets = self.insets
      cell.item = item
      
      // Selection listener
      cell.selectionPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.selectionPublisher.send()
        }
        .store(in: &subscriptions)
    }
    
    source = UICollectionViewDiffableDataSource<Section, LanguageItem>(collectionView: self) { collectionView, indexPath, itemIdentifier -> UICollectionViewCell? in
      
      let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                              for: indexPath,
                                                              item: itemIdentifier)
      return cell
    }
    
    var snap = NSDiffableDataSourceSnapshot<Section, LanguageItem>()
    snap.appendSections([.main])
    snap.appendItems(dataItems)
    source.apply(snap, animatingDifferences: false)
  }
  
  func setTasks() {}
}

extension LanguagesCollectionView: UICollectionViewDelegate {
////    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
////        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }
////
////        cell.isSelected = true//UserDefaults.App.contentLanguages.filter({ $0 == item.code }).isEmpty
////    }
//
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return true }
//
//        guard !cell.isSelected else {
//            collectionView.deselectItem(at: indexPath, animated: true)
//
//            return false
//        }
//        return true
//    }
//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? LanguageCell else { return }

      cell.item.selected = !cell.item.selected
//        cell.accessories = [UICellAccessory.checkmark(displayed: .always,
//                                                      options: .init(isHidden: false,
//                                                                     tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED))]
//        print(dataItems[indexPath.row])
    }
//
//    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        collectionView.deselectItem(at: indexPath, animated: true)
//
//        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return false }
//
//        cell.accessories = [UICellAccessory.checkmark(displayed: .always,
//                                                      options: .init(isHidden: true,
//                                                                     tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED))]
//        print(dataItems[indexPath.row])
//
//        return true
//    }
}
