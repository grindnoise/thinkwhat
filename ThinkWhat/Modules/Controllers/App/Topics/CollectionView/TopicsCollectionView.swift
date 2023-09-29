//
//  TopicsCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

enum TopicListItem: Hashable {
    case header(TopicHeaderItem)
    case topic(TopicItem)
}

struct TopicHeaderItem: Hashable {
    let title: String
    let description: String
    let topic: Topic
    let topics: [TopicItem]
    
    init(topic: Topic) {
        self.topic = topic
        self.title = topic.title
        self.description = topic.description
        self.topics = topic.children.map {
            return TopicItem(topic: $0)
        }
    }
}

struct TopicItem: Hashable {
    let title: String
    let description: String
    let topic: Topic
    
    init(topic: Topic) {
        self.topic = topic
        self.title = topic.title
        self.description = topic.description
    }
}

class TopicsCollectionView: UICollectionView {
  enum Mode { case Default, Selection }
  // MARK: - Public properties
  ///**Publishers**
  public let topicSelected = PassthroughSubject<Topic, Never>()
  public let touchSubject = CurrentValueSubject<[Topic: CGPoint]?, Never>(nil)
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var mode: Mode
  private var source: UICollectionViewDiffableDataSource<TopicHeaderItem, TopicListItem>!
  private let modelObjects: [TopicHeaderItem] = {
    Topics.shared.all.filter({ $0.isParentNode }).map { topic in
      return TopicHeaderItem(topic: topic)
    }
  }()
  
  
  // MARK: - Destructor
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
  init(mode: Mode = .Default) {
    self.mode = mode
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Private
private extension TopicsCollectionView {
  @MainActor
  func setupUI() {
    delegate = self.mode == .Selection ? self : nil
    collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
      var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      layoutConfig.headerMode = .firstItemInSection
      layoutConfig.backgroundColor = .clear
      layoutConfig.showsSeparators = false
      //            if #available(iOS 14.5, *) {
      //                layoutConfig.separatorConfiguration.color = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
      //            }
      ////            layoutConfig.showsSeparators = true
      ////            layoutConfig.footerMode = .supplementary
      
      let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
      //            sectionLayout.interGroupSpacing = 20
      sectionLayout.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
      return sectionLayout
    }
    
    let cellRegistration = UICollectionView.CellRegistration<TopicCell, TopicItem> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      cell.mode = self.mode
      cell.item = item
      var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
      backgroundConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : item.topic.tagColor.withAlphaComponent(0.1)
      cell.backgroundConfiguration = backgroundConfig
      
      cell.touchSubject
        .sink { [weak self] in
          guard let self = self,
                let key = $0.keys.first,
                let value = $0.values.first
          else { return }
          
          self.touchSubject.send([key: cell.convert(value, to: self.superview!)])
        }
        .store(in: &self.subscriptions)
      
      if self.mode == .Default {
        cell.accessories = [.disclosureIndicator(options: UICellAccessory.DisclosureIndicatorOptions(tintColor: item.topic.activeCount.isZero ? .clear : item.topic.tagColor))]
      }
    }
    
    //        let footerRegistration = UICollectionView.SupplementaryRegistration
    //        <SeparatorCell>(elementKind: UICollectionView.elementKindSectionFooter) {
    //            [unowned self] (footerView, elementKind, indexPath) in
    //
    ////            let headerItem = self.source.snapshot().sectionIdentifiers[indexPath.section]
    ////            let symbolCount = headerItem.topics.count
    ////
    ////            // Configure footer view content
    ////            var configuration = footerView.defaultContentConfiguration()
    ////            configuration.text = "Topics count: \(symbolCount)"
    ////            footerView.contentConfiguration = configuration
    ////            footerView
    //        }
    
    let headerCellRegistration = UICollectionView.CellRegistration<TopicCellHeader, TopicHeaderItem> { [unowned self] cell, indexPath, headerItem in
      
      cell.mode = self.mode
      cell.item = headerItem
      let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header, tintColor: headerItem.topic.tagColor)
      var backgroundConfig = UIBackgroundConfiguration.listPlainHeaderFooter()
      backgroundConfig.backgroundColor = .clear
      cell.backgroundConfiguration = backgroundConfig
      cell.accessories = [.outlineDisclosure(options:headerDisclosureOption) { [unowned self] in
        var currentSectionSnapshot = self.source.snapshot(for: headerItem)
        if currentSectionSnapshot.items.filter({ currentSectionSnapshot.isExpanded($0) }).isEmpty {
          if self.mode == .Selection {
            self.scrollToItem(at: indexPath, at: .top, animated: true)
          }
          currentSectionSnapshot.expand(currentSectionSnapshot.items)
          let otherHeaders = self.source.snapshot().sectionIdentifiers.filter({ $0 != headerItem })
          otherHeaders.forEach { otherHeader in
            var otherSectionSnapshot = self.source.snapshot(for: otherHeader)
            otherSectionSnapshot.items.forEach { otherItem in
              if otherSectionSnapshot.isExpanded(otherItem) {
                otherSectionSnapshot.collapse(otherSectionSnapshot.items)
                self.source.apply(otherSectionSnapshot, to: otherHeader, animatingDifferences: true)
              }
            }
          }
        } else {
          currentSectionSnapshot.collapse(currentSectionSnapshot.items)
        }
        self.source.apply(currentSectionSnapshot, to: headerItem, animatingDifferences: true) 
      }]
    }
    
    source = UICollectionViewDiffableDataSource<TopicHeaderItem, TopicListItem>(collectionView: self) {
      (collectionView, indexPath, listItem) -> UICollectionViewCell? in
      
      switch listItem {
      case .header(let headerItem):
        let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration,
                                                                for: indexPath,
                                                                item: headerItem)
        cell.tintColor = headerItem.topic.tagColor
        return cell
        
      case .topic(let symbolItem):
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: symbolItem)
        cell.tintColor = symbolItem.topic.tagColor
        return cell
      }
    }
    
    //        source.supplementaryViewProvider = { [unowned self]
    //            (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
    //
    //            if elementKind == UICollectionView.elementKindSectionFooter {
    //                return dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
    //            }
    //            return nil
    //        }
    
    for headerItem in modelObjects {
      var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<TopicListItem>()
      
      let headerListItem = TopicListItem.header(headerItem)
      sectionSnapshot.append([headerListItem])
      
      let topicListItemArray = headerItem.topics.map { TopicListItem.topic($0) }
      sectionSnapshot.append(topicListItemArray, to: headerListItem)
      
      sectionSnapshot.collapse([headerListItem])
      source.apply(sectionSnapshot, to: headerItem, animatingDifferences: false)
    }
  }
  
  // MARK: - Overriden methods
  //    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
  //        refreshControl?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
  //        collectionView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
  //        layoutConfig.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
  //    }
}

extension TopicsCollectionView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = cellForItem(at: indexPath) as? TopicCell,
          let topic = cell.item?.topic
    else { return }
    
    topicSelected.send(topic)
  }
}
