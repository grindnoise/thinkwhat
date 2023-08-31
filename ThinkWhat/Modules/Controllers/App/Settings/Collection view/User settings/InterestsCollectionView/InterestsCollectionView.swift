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
  
  enum GridItemSize: CGFloat {
    case half = 0.5
    case third = 0.33333
    case quarter = 0.25
  }
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard !userprofile.isNil else { return }
      
      reload(animated: false)
    }
  }
  
  //Publishers
  public let interestPublisher = PassthroughSubject<Topic, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  //Collection
  private var source: UICollectionViewDiffableDataSource<Section, Topic>!
  
  private var gridItemSize: GridItemSize = .half {
    didSet {
      setCollectionViewLayout(createLayout(), animated: true)
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
    super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private methods
  private func setupUI() {
    
    let layout = TagCellLayout(alignment: .left, delegate: self)
    collectionViewLayout = layout///createLayout()
    
    let interestCellRegistration = UICollectionView.CellRegistration<InterestCell, Topic> { [unowned self] cell, indexPath, item in
      
      //Tap
      cell.interestPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.interestPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
      backgroundConfig.backgroundColor = .clear
      cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : Colors.main
      cell.backgroundConfiguration = backgroundConfig
      
      guard cell.item.isNil else { return }
      
      cell.item = item
    }
    
    
    source = UICollectionViewDiffableDataSource<Section, Topic>(collectionView: self) { [unowned self]
      (collectionView: UICollectionView, indexPath: IndexPath, identifier: Topic) -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(using: interestCellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    guard !userprofile.isNil else { return }
    
    reload(animated: true)
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(gridItemSize.rawValue),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    //      item.contentInsets = .uniform(size: 100)//NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalWidth(gridItemSize.rawValue))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
  }
  
  // MARK: - Public methods
  
  
  // MARK: - Private methods
  private func reload(animated: Bool) {
    
    guard let container = userprofile.preferencesSorted,
          let items = container.compactMap ({ dict in
            return dict.keys.first
          }) as? [Topic]
    else { return }
    
    var snap = NSDiffableDataSourceSnapshot<Section, Topic>()
    snap.appendSections([.Main])
    snap.appendItems(items, toSection: .Main)
    source.apply(snap, animatingDifferences: animated)
  }
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

extension InterestsCollectionView: TagCellLayoutDelegate {
  func tagCellLayoutTagSize(layout: TagCellLayout, atIndex index: Int) -> CGSize {
    guard let container = userprofile.preferencesSorted,
          let items = container.compactMap ({ dict in
            return dict.keys.first
          }) as? [Topic],
          items.count > index
    else { return .zero }
    
    // We need to calculated estimated size 
    let height: CGFloat = "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!) + padding*2//30
//    items[index].title.uppercased().height(withConstrainedWidth: 100,
//                                                        font: UIFont(name: Fonts.Bold, size: 14)!)
    let width = items[index].title.uppercased().width(withConstrainedHeight: 1000,
                                                      font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!) + height + padding//+ 8 + 8 + 4
    
    return CGSize(width: width, height: height)
    
    //        return CGSize(width: items[index].title.width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!) + 18 + 4,
    //                      height: items[index].title.height(withConstrainedWidth: 300, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!) + 2 + 8)
    //        if index == longTagIndex || index == (longTagIndex + 3) {
    //            var s = textSize(text: longString, font: UIFont.systemFont(ofSize: 17.0), collectionView: self)
    //            s.height += 8.0
    //            return s
    //        } else {
    //            let width = CGFloat(index % 2 == 0 ? 80 : 120)
    //            return CGSize(width: width, height: oneLineHeight)
    //        }
  }
}
