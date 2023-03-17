//
//  NewPollCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollCollectionView: UICollectionView {
  
  typealias Source = UICollectionViewDiffableDataSource<NewPollController.Stage, Int>
  typealias Snapshot = NSDiffableDataSourceSnapshot<NewPollController.Stage, Int>
  
  // MARK: - Public properties
  ///**Publishers**
  public let progressPublisher = PassthroughSubject<Double, Never>()
  public let profileTapPublisher = PassthroughSubject<Bool, Never>()
  public var imagePublisher = PassthroughSubject<Mediafile, Never>()
  public var webPublisher = PassthroughSubject<URL, Never>()
  ///**Logic**
  public private(set) var stage: NewPollController.Stage = .Topic {
    didSet {
      guard oldValue != stage else { return }
      
      progressPublisher.send(stage.percent())
    }
  }
  @Published public private(set) var topic: Topic! {
    didSet {
      guard oldValue.isNil,
            !topic.isNil,
            let stage = stage.next()
      else { return }
      
      self.stage = stage
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var source: Source!
  private var isFirstAnswerSelection = true
  ///**UI**
  private let padding: CGFloat = 8
  
  
  
  // MARK: - Initialization
  init() {
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
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
  
  // MARK: - Public methods
  public func onImageScroll(_ index: Int) {
    guard let cell = cellForItem(at: IndexPath(row: 0, section: 2)) as? ImageCell else { return }
    cell.scrollToImage(at: index)
  }
}

private extension NewPollCollectionView {
  @MainActor
  func setupUI() {
    delegate = self
    allowsMultipleSelection = true
    collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
      var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      layoutConfig.backgroundColor = .clear
      layoutConfig.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
      sectionLayout.interGroupSpacing = 8
      return sectionLayout
    }
    
    let topicCellRegistration = UICollectionView.CellRegistration<NewPollTopicCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.stage = .Topic
      cell.$topic
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
//        .delay(for: .milliseconds(, scheduler: <#T##Scheduler#>)
        .sink { [unowned self] in self.topic = $0 }
        .store(in: &self.subscriptions)
//      cell.color = self.topic.isNil ? Colors.Logo.Flame.rawValue : self.topic.tagColor
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      guard self.stage == .Topic else { return }
      
      cell.present()
    }
    
//    let descriptionCellRegistration = UICollectionView.CellRegistration<TextCell, AnyHashable> { [unowned self] cell, _, _ in
//      let paragraphStyle = NSMutableParagraphStyle()
//      paragraphStyle.firstLineHeadIndent = 20
//      paragraphStyle.paragraphSpacing = 20
//      paragraphStyle.hyphenationFactor = 1
//      cell.attributes = [
//        .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body) as Any,
//        .foregroundColor: UIColor.label,
//        .paragraphStyle: paragraphStyle
//      ]
//
//      cell.insets = .uniform(size: self.padding)
//      ///Set right text container inset if transition
//      cell.padding = self.padding
//      cell.text = self.item.detailsDescription
//      cell.boundsPublisher
//        .eraseToAnyPublisher()
//        .filter { $0 != .zero }
//        .sink { [unowned self] _ in self.source.refresh(animatingDifferences: false) }//commentsCellBoundsPublisher.send($0)
//        .store(in: &self.subscriptions)
//      var config = UIBackgroundConfiguration.listPlainCell()
//      config.backgroundColor = .clear
//      cell.backgroundConfiguration = config
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//    }
//
//    let imagesCellRegistration = UICollectionView.CellRegistration<ImageCell, AnyHashable> { [unowned self] cell, _, _ in
//      cell.item = self.item
//
//      cell.imagePublisher
//        .sink {[unowned self] in self.imagePublisher.send($0) }
//        .store(in: &self.subscriptions)
//      var config = UIBackgroundConfiguration.listPlainCell()
//      config.backgroundColor = .clear
//      cell.backgroundConfiguration = config
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//    }
//
//    let youtubeCellRegistration = UICollectionView.CellRegistration<YoutubeCell, AnyHashable> { [unowned self] cell, _, _ in
//      cell.item = self.item
//      var config = UIBackgroundConfiguration.listPlainCell()
//      config.backgroundColor = .clear
//      cell.backgroundConfiguration = config
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//    }
//
//    let webCellRegistration = UICollectionView.CellRegistration<LinkPreviewCell, AnyHashable> { [unowned self] cell, _, _ in
//      cell.item = self.item
//      cell.tapPublisher
//        .sink {[weak self] in
//          guard let self = self else { return }
//
//          self.webPublisher.send($0)
//        }
//        .store(in: &self.subscriptions)
//      var config = UIBackgroundConfiguration.listPlainCell()
//      config.backgroundColor = .clear
//      cell.backgroundConfiguration = config
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//    }
//
//    let questionCellRegistration = UICollectionView.CellRegistration<TextCell, AnyHashable> { [unowned self] cell, _, _ in
//      let paragraphStyle = NSMutableParagraphStyle()
//      paragraphStyle.firstLineHeadIndent = 20
//      paragraphStyle.paragraphSpacing = 20
//      if #available(iOS 15.0, *) {
//        paragraphStyle.usesDefaultHyphenation = true
//      } else {
//        paragraphStyle.hyphenationFactor = 1
//      }
//      cell.insets = .init(top: padding*3, left: padding, bottom: padding, right: padding)
//      cell.attributes = [
//        .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .body) as Any,
//        .foregroundColor: UIColor.secondaryLabel,
//        .paragraphStyle: paragraphStyle
//      ]
//      cell.text = self.item.question
//      cell.boundsPublisher
//        .sink { [unowned self] _ in self.source.refresh(animatingDifferences: false) }
//        .store(in: &self.subscriptions)
//      var config = UIBackgroundConfiguration.listPlainCell()
//      config.backgroundColor = .clear
//      cell.backgroundConfiguration = config
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//    }
//
//    let answersCellRegistration = UICollectionView.CellRegistration<AnswersCell, AnyHashable> { [weak self] cell, _, _ in
//      guard let self = self else { return }
//
//      cell.item = self.item
//      cell.selectionPublisher
//        .sink { [weak self] in
//          guard let self = self else { return }
//
//          self.answerSelectionPublisher.send($0)
//
//          guard self.isFirstAnswerSelection else { return }
//
//          self.isFirstAnswerSelection = false
//          self.scrollToItem(at: IndexPath(row: 0, section: self.numberOfSections-1), at: .bottom, animated: true)
//        }
//        .store(in: &self.subscriptions)
//      cell.deselectionPublisher
//        .sink { [weak self] in
//          guard let self = self else { return }
//
//          self.answerDeselectionPublisher.send($0)
//        }
//        .store(in: &self.subscriptions)
//      cell.updatePublisher
//        .receive(on: DispatchQueue.main)
//        .sink { [weak self] _ in
//          guard let self = self else { return }
//
//          self.source.refresh()
//        }
//        .store(in: &self.subscriptions)
//      cell.votersPublisher
//        .sink { [weak self] in
//          guard let self = self else { return }
//
//          self.votersPublisher.send($0)
//        }
//        .store(in: &self.subscriptions)
//      self.isVotingSubscriber
//        .sink {
//          cell.isVotingPublisher.send($0)
//        }
//        .store(in: &self.subscriptions)
//      var config = UIBackgroundConfiguration.listPlainCell()
//      config.backgroundColor = .clear
//      cell.backgroundConfiguration = config
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//    }
    
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      guard let section = NewPollController.Stage(rawValue: identifier) else { return UICollectionViewCell() }
      
      if section == .Topic {
        return collectionView.dequeueConfiguredReusableCell(using: topicCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
//      } else if section == .description {
//        return collectionView.dequeueConfiguredReusableCell(using: descriptionCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      } else if section == .image {
//        return collectionView.dequeueConfiguredReusableCell(using: imagesCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      } else if section == .youtube {
//        return collectionView.dequeueConfiguredReusableCell(using: youtubeCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      } else if section == .web {
//        return collectionView.dequeueConfiguredReusableCell(using: webCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      } else if section == .question {
//        return collectionView.dequeueConfiguredReusableCell(using: questionCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
//      } else if section == .answers {
//        return collectionView.dequeueConfiguredReusableCell(using: answersCellRegistration,
//                                                            for: indexPath,
//                                                            item: identifier)
      }
      return UICollectionViewCell()
    }
    
    delay(seconds: 0.5) { [weak self] in
      guard let self = self else { return }
      
      var snapshot = Snapshot()
      snapshot.appendSections([.Topic])
      snapshot.appendItems([self.stage.rawValue], toSection: .Topic)
      self.source.apply(snapshot, animatingDifferences: true)
    }
  }
  
//  func applySnapshot(animated: Bool = false) {
//    var snapshot = Snapshot()
//    snapshot.appendSections([.title, .description,])
//    snapshot.appendItems([0], toSection: .title)
//    snapshot.appendItems([1], toSection: .description)
//    if item.imagesCount != 0 {
//      snapshot.appendSections([.image])
//      snapshot.appendItems([2], toSection: .image)
//    }
//    if let url = item.url {
//      if url.absoluteString.isYoutubeLink {
//        snapshot.appendSections([.youtube])
//        snapshot.appendItems([3], toSection: .youtube)
//      } else {
//        snapshot.appendSections([.web])
//        snapshot.appendItems([4], toSection: .web)
//      }
//    }
//    snapshot.appendSections([.question])
//    snapshot.appendItems([5], toSection: .question)
//    if mode == .Default {
//      snapshot.appendSections([.answers])
//      snapshot.appendItems([6], toSection: .answers)
//      snapshot.appendSections([.comments])
//      snapshot.appendItems([7], toSection: .comments)
//    }
//    source.apply(snapshot, animatingDifferences: false)
////    source.refresh(animatingDifferences: false)
//
//    //        snapshot.appendSections([.title, .description,])
//    //        snapshot.appendItems([0], toSection: .title)
//    //        snapshot.appendItems([1], toSection: .description)
//    //        if poll.imagesCount != 0 {
//    //            snapshot.appendSections([.image])
//    //            snapshot.appendItems([2], toSection: .image)
//    //        }
//    //        if let url = poll.url {
//    //            if url.absoluteString.isYoutubeLink {
//    //                snapshot.appendSections([.youtube])
//    //                snapshot.appendItems([3], toSection: .youtube)
//    //            } else {
//    //                snapshot.appendSections([.web])
//    //                snapshot.appendItems([4], toSection: .web)
//    //            }
//    //        }
//    //        snapshot.appendSections([.question])
//    //        snapshot.appendItems([5], toSection: .question)
//    //        ////        snapshot.appendSections([.choices])
//    //        ////        snapshot.appendItems([6], toSection: .choices)
//    //        snapshot.appendSections([.comments])
//    //        snapshot.appendItems([8], toSection: .comments)
//  }
}

extension NewPollCollectionView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if let cell = cellForItem(at: indexPath) as? CommentsSectionCell {
      guard cell.item.isComplete else {
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                              text: "vote_to_view_comments",
                                                              tintColor: .systemOrange),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
        return false
      }
      
      collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [.bottom])
      source.refresh()
      collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
      return true
    }
    //        // Allows for closing an already open cell
    //        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
    //            collectionView.deselectItem(at: indexPath, animated: true)
    //        } else {
    //            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    //        }
    //
    //        source.refresh()
    //
    //        return false // The selecting or deselecting is already performed above
    
    //        guard let cell = collectionView.cellForItem(at: indexPath), !cell.isSelected else {
    //            collectionView.deselectItem(at: indexPath, animated: true)
    //            source.refresh()
    //            return false
    //        }
    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    source.refresh()
    return true
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    collectionView.deselectItem(at: indexPath, animated: true)
    source.refresh()
    return false
  }
}
