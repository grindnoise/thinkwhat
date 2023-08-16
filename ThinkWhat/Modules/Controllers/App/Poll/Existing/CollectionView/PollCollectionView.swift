//
//  PollCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class PollCollectionView: UICollectionView {
  
  enum Section: Int {
    case title, description, image, youtube, web, question, answers, comments
    
    var localized: String {
      switch self {
      case .title:
        return "title".localized
      case .description:
        return "description".localized
      case .image:
        return "images".localized
      case .youtube:
        return "YouTube"
      case .web:
        return "web".localized
      case .question:
        return "question".localized
      case .answers:
        return "poll_choices".localized
        //      case .vote:
        //        return "vote".localized
      case .comments:
        return "comments".localized
      }
    }
  }
  
  enum ViewMode { case Default, Preview, Transition }
  
  typealias Source = UICollectionViewDiffableDataSource<Section, Int>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Int>
  
  // MARK: - Public properties
  ///**Publishers**
  public let profileTapPublisher = PassthroughSubject<Bool, Never>()
  public var imagePublisher = PassthroughSubject<Mediafile, Never>()
  public var webPublisher = PassthroughSubject<URL, Never>()
  public let answerSelectionPublisher = PassthroughSubject<Answer, Never>()
  public let answerDeselectionPublisher = PassthroughSubject<Bool, Never>()
  public let isVotingSubscriber = PassthroughSubject<Bool, Never>()
  public let votersPublisher = PassthroughSubject<Answer, Never>()
  public var postCommentPublisher = PassthroughSubject<String, Never>()
  public var postAnonCommentPublisher = PassthroughSubject<[String: String], Never>()
//  public var updateCommentsStatsPublisher = PassthroughSubject<[Comment], Never>()
  public let updateCommentsPublisher = PassthroughSubject<[Comment], Never>()
//  public let commentsCellBoundsPublisher = PassthroughSubject<Bool, Never>()
  public var replyPublisher = PassthroughSubject<[Comment: String], Never>()
  public var anonReplyPublisher = PassthroughSubject<[Comment: [String: String]], Never>()
//  public var commentClaimPublisher = PassthroughSubject<Comment, Never>()
  public var deletePublisher = PassthroughSubject<Comment, Never>()
  public var threadPublisher = PassthroughSubject<Comment, Never>()
  //  public var paginationPublisher = PassthroughSubject<[Comment], Never>()
  ///**Logic**
  public var viewMode: ViewMode {
    didSet {
//      guard oldValue != mode else { return }
      
      modeChangePublisher.send(viewMode)
    }
  }
  public var mode: PollController.Mode
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Publishers**
  private var modeChangePublisher = CurrentValueSubject<ViewMode?, Never>(nil)
  ///**Logic**
  private let item: Survey
  private var source: Source!
  private var isFirstAnswerSelection = true
  private var isBannerOnScreen = false
  ///**UI**
  private let padding: CGFloat = 8
  
  
  
  // MARK: - Initialization
  init(item: Survey,
       mode: PollController.Mode,
       viewMode: ViewMode = .Default) {
    self.mode = mode
    self.viewMode = viewMode
    self.item = item
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    item.reference.isCompletePublisher
      .receive(on: DispatchQueue.main)
      .filter { $0 }
      .sink { [weak self] _ in
        guard let self = self,
              let source = self.source
        else { return }
        
        source.refresh() {
          delay(seconds: 0.25) { [weak self] in
            guard let self = self else { return }
            
            self.scrollToItem(at: IndexPath(row: 0, section: self.numberOfSections - 1),
                              at: .bottom,
                              animated: true)
          }
        }
      }
      .store(in: &subscriptions)
    
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

private extension PollCollectionView {
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
    
    let titleCellRegistration = UICollectionView.CellRegistration<PollTitleCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.mode = self.viewMode
      cell.item = self.item
      cell.isUserInteractionEnabled = self.mode != .Preview
      cell.profileTapPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.profileTapPublisher.send(true)
        }
        .store(in: &self.subscriptions)
      
      ///Animation for transition
      self.modeChangePublisher
        .receive(on: DispatchQueue.main)
        .filter { !$0.isNil }
        .sink { _ in cell.onModeChanged(mode: .Default) }
        .store(in: &self.subscriptions)
    }
    
    //        let descriptionCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnyHashable> { [unowned self] cell, _, _ in
    //            var conte  nt = cell.defaultContentConfiguration()
    //            content.directionalLayoutMargins = .zero
    //            content.attributedText  = NSAttributedString(string: self.item!.description,
    //                                                         attributes: [
    //                                                            .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
    //                                                         ])
    //            cell.contentConfiguration = content
    //        }
    let descriptionCellRegistration = UICollectionView.CellRegistration<TextCell, AnyHashable> { [unowned self] cell, _, _ in
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.firstLineHeadIndent = 20
      paragraphStyle.paragraphSpacing = 20
      paragraphStyle.lineSpacing = 4
//      if #available(iOS 15.0, *) {
//        paragraphStyle.usesDefaultHyphenation = true
//      } else {
        paragraphStyle.hyphenationFactor = 1
//      }
      cell.attributes = [
        .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
        .foregroundColor: UIColor.label,
        .paragraphStyle: paragraphStyle
      ]
      
      cell.insets = .uniform(size: self.padding)
      // Set right text container inset if transition
      cell.padding = self.viewMode == .Default ? self.padding*2 : self.viewMode == .Transition ? self.padding*2 : 0
      cell.text = self.item.detailsDescription
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .filter { $0 != .zero }
        .sink { [unowned self] _ in self.source.refresh(animatingDifferences: false) }//commentsCellBoundsPublisher.send($0)
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let imagesCellRegistration = UICollectionView.CellRegistration<ImageCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.mode = self.viewMode
      if cell.item.isNil {
        cell.item = self.item
      }
      cell.isUserInteractionEnabled = self.mode != .Preview
      cell.contentView.layer.masksToBounds = false
      cell.imagePublisher
        .sink {[unowned self] in self.imagePublisher.send($0) }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let youtubeCellRegistration = UICollectionView.CellRegistration<YoutubeCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.mode = self.viewMode
      if cell.item.isNil {
        cell.item = self.item
      }
      cell.contentView.layer.masksToBounds = false
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let webCellRegistration = UICollectionView.CellRegistration<LinkPreviewCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.mode = self.viewMode
      if cell.item.isNil {
        
      }
      cell.item = self.item
      cell.isUserInteractionEnabled = self.mode != .Preview
      cell.contentView.layer.masksToBounds = false
      cell.tapPublisher
        .sink {[weak self] in
          guard let self = self else { return }
          
          self.webPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let questionCellRegistration = UICollectionView.CellRegistration<TextCell, AnyHashable> { [unowned self] cell, _, _ in
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.firstLineHeadIndent = 20
      paragraphStyle.paragraphSpacing = 20
      paragraphStyle.lineSpacing = 4
      if #available(iOS 15.0, *) {
        paragraphStyle.usesDefaultHyphenation = true
      } else {
        paragraphStyle.hyphenationFactor = 1
      }
      cell.insets = .init(top: !self.item.media.isEmpty || !self.item.mediaWithImageURLs.isEmpty || !self.item.url.isNil ? self.padding*3 : self.padding*2,
                          left: self.padding,
                          bottom: self.padding,
                          right: self.padding)
      cell.attributes = [
        .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
        .foregroundColor: UIColor.label,
        .paragraphStyle: paragraphStyle
      ]
      cell.text = self.item.question
      cell.boundsPublisher
        .sink { [unowned self] _ in self.source.refresh(animatingDifferences: false) }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let answersCellRegistration = UICollectionView.CellRegistration<AnswersCell, AnyHashable> { [weak self] cell, _, _ in
      guard let self = self else { return }
      
      if cell.item.isNil {
        cell.item = self.item
      }
      cell.contentView.layer.masksToBounds = false
      cell.isUserInteractionEnabled = self.mode != .Preview
      cell.selectionPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.answerSelectionPublisher.send($0)
          
          guard self.isFirstAnswerSelection else { return }
          
          self.isFirstAnswerSelection = false
//          delay(seconds: 0.2) { [weak self] in
//            guard let self = self else { return }
//
            self.scrollToItem(at: IndexPath(row: 0, section: self.numberOfSections-1), at: .bottom, animated: true)
//          }
        }
        .store(in: &self.subscriptions)
      cell.deselectionPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.answerDeselectionPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      cell.updatePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.source.refresh()
        }
        .store(in: &self.subscriptions)
      cell.votersPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.votersPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      self.isVotingSubscriber
        .sink {
          cell.isVotingPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let commentsCellRegistration = UICollectionView.CellRegistration<CommentsSectionCell, AnyHashable> { [weak self] cell, _, _ in
      guard let self = self else { return }
      
      cell.item = self.item
      cell.isUserInteractionEnabled = self.mode != .Preview
      cell.contentView.layer.masksToBounds = false
      //Claim
      //      cell.claimPublisher
      //        .sink { [weak self] in
      //          guard let self = self else { return }
      //
      //          //        self.claimSubject.send($0)
      //        }
      //        .store(in: &self.subscriptions)
      
      cell.boundsPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.source.refresh(animatingDifferences: false)//commentsCellBoundsPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
//      //Update comments stats (replies count)
//      cell.updateStatsPublisher
//        .sink { [weak self] in
//          guard let self = self else { return }
//
//          self.updateCommentsStatsPublisher.send($0)
//        }
//        .store(in: &self.subscriptions)
      
      //Update comments
      cell.getRootCommentsPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.updateCommentsPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      // Post comment
      cell.postCommentPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.postCommentPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      // Post anon comment
      cell.postAnonCommentPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.postAnonCommentPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      //Subscription for commenting
      cell.deletePublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.deletePublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      //Reply to user
      cell.replyPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.replyPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      //Anon reply
      cell.anonReplyPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.anonReplyPublisher.send($0)
        }
      .store(in: &self.subscriptions)
      
      //Open thread
      cell.threadPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.threadPublisher.send($0)
        }
      .store(in: &self.subscriptions)
      
//
//      //Subscription for request comments
//      cell.commentsRequestSubject.sink { [weak self] in
//        guard let self = self,
//              let comments = $0 as? [Comment],
//              comments.count > 0
//        else { return }
//
//        fatalError()
//        //        self.host.requestComments(comments)
//      }.store(in: &self.subscriptions)
//
//      //Subscibe for thread disclosure
//      cell.commentThreadSubject.sink { [weak self] in
//        guard let self = self,
//              let comment = $0 as? Comment
//        else { return }
//
//        fatalError()
//        //        self.commentThreadSubject.send(comment)
//      }.store(in: &self.subscriptions)
//
//      //      //Subscibe for posted comment
//      //      self.lastPostedComment.sink {
//      //        guard let comment = $0 else { return }
//      //
//      //        cell.lastPostedComment = comment
//      //      }.store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
      
      if section == .title {
        return collectionView.dequeueConfiguredReusableCell(using: titleCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .description {
        return collectionView.dequeueConfiguredReusableCell(using: descriptionCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .image {
        return collectionView.dequeueConfiguredReusableCell(using: imagesCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .youtube {
        return collectionView.dequeueConfiguredReusableCell(using: youtubeCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .web {
        return collectionView.dequeueConfiguredReusableCell(using: webCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .question {
        return collectionView.dequeueConfiguredReusableCell(using: questionCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .answers {
        return collectionView.dequeueConfiguredReusableCell(using: answersCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .comments {
        return collectionView.dequeueConfiguredReusableCell(using: commentsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      }
      return UICollectionViewCell()
    }
    
    applySnapshot()
  }
  
  func applySnapshot(animated: Bool = false) {
    var snapshot = Snapshot()
    snapshot.appendSections([.title, .description,])
    snapshot.appendItems([0], toSection: .title)
    snapshot.appendItems([1], toSection: .description)
    if item.imagesCount != 0 {
      snapshot.appendSections([.image])
      snapshot.appendItems([2], toSection: .image)
    }
    if let url = item.url {
      if url.absoluteString.isYoutubeLink {
        snapshot.appendSections([.youtube])
        snapshot.appendItems([3], toSection: .youtube)
      } else {
        snapshot.appendSections([.web])
        snapshot.appendItems([4], toSection: .web)
      }
    }
    if !item.question.isEmpty {
      snapshot.appendSections([.question])
      snapshot.appendItems([5], toSection: .question)
    }
    if viewMode == .Default {
      snapshot.appendSections([.answers])
      snapshot.appendItems([6], toSection: .answers)
      snapshot.appendSections([.comments])
      snapshot.appendItems([7], toSection: .comments)
    }
    source.apply(snapshot, animatingDifferences: false)
//    source.refresh(animatingDifferences: false)
    
    //        snapshot.appendSections([.title, .description,])
    //        snapshot.appendItems([0], toSection: .title)
    //        snapshot.appendItems([1], toSection: .description)
    //        if poll.imagesCount != 0 {
    //            snapshot.appendSections([.image])
    //            snapshot.appendItems([2], toSection: .image)
    //        }
    //        if let url = poll.url {
    //            if url.absoluteString.isYoutubeLink {
    //                snapshot.appendSections([.youtube])
    //                snapshot.appendItems([3], toSection: .youtube)
    //            } else {
    //                snapshot.appendSections([.web])
    //                snapshot.appendItems([4], toSection: .web)
    //            }
    //        }
    //        snapshot.appendSections([.question])
    //        snapshot.appendItems([5], toSection: .question)
    //        ////        snapshot.appendSections([.choices])
    //        ////        snapshot.appendItems([6], toSection: .choices)
    //        snapshot.appendSections([.comments])
    //        snapshot.appendItems([8], toSection: .comments)
  }
}

extension PollCollectionView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if let cell = cellForItem(at: indexPath) as? CommentsSectionCell {
      guard cell.item.isComplete else {
        guard !isBannerOnScreen else { return false }
        isBannerOnScreen = true
        let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "dollarsign")!,
                                                              icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: .systemOrange),
                                                              text: "vote_to_view_comments"),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { [unowned self] _ in banner.removeFromSuperview(); self.isBannerOnScreen = false }
          .store(in: &self.subscriptions)

        return false
      }
      
      collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [.bottom])
      source.refresh() {
//        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
      }
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
