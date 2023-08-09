//
//  CommentsCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CommentsCollectionView: UICollectionView {
  
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comment>
  
  struct Constants {
    static let commentsStatsUpdateInterval = 10.0
  }
  
  enum Section: Int {
    case main
  }
  
  enum Mode {
    case All, Thread
  }
  
  enum CommentMode {
    case Root, Reply
  }
  
  // MARK: - Public properties
  public weak var survey: Survey!
  public weak var rootComment: Comment? {
    didSet {
      guard !rootComment.isNil else { return }
      
      mode = .Thread
//      reload()
    }
  }
  public var dataItems: [Comment] {
    if let rootComment = rootComment, mode == .Thread {
      return Comments.shared.all.filter { $0.parent == rootComment && !$0.isClaimed && !$0.isBanned }
    } else if let survey = survey {
      return survey.commentsSortedByDate.filter { $0.isParentNode && !$0.isClaimed && !$0.isBanned }
    }
    return []
  }
  //Publishers
  public let updateStatsPublisher = PassthroughSubject<[Comment], Never>()
  public let commentPublisher = PassthroughSubject<String, Never>()
  public let anonCommentPublisher = PassthroughSubject<[String: String], Never>()
  public let replyPublisher = PassthroughSubject<[Comment: String], Never>()
  public let anonReplyPublisher = PassthroughSubject<[Comment: [String: String]], Never>()
  public let claimPublisher = PassthroughSubject<Comment, Never>()
  public let deletePublisher = PassthroughSubject<Comment, Never>()
  public let threadPublisher = PassthroughSubject<Comment, Never>()
  public let paginationPublisher = PassthroughSubject<[Comment], Never>()
  //    public var commentsRequestSubject: CurrentValueSubject<[Comment], Never>!
  
  
  
  // MARK: - Private properties
  private var mode: Mode = .All
  private var commentMode: CommentMode = .Root
  private weak var replyTo: Comment? {
    didSet {
      commentMode = replyTo.isNil ? .Root : .Reply
    }
  }
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private var source: UICollectionViewDiffableDataSource<Section, Comment>!
  private lazy var textField: AccessoryInputTextField = {
    let instance = AccessoryInputTextField(userprofile: survey.isAnonymous ? Userprofile.anonymous : Userprofiles.shared.current!,
                                           placeholder: "add_comment".localized,
                                           color: survey.topic.tagColor,
                                           font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)!,
                                           minLength: ModelProperties.shared.commentMinLength,
                                           maxLength: ModelProperties.shared.commentMaxLength,
                                           isAnon: survey.isAnonymous)
    //Comment
    instance.messagePublisher
      .filter { !$0.isEmpty }
      .sink { [weak self] in
        guard let self = self else { return }
        
        //UI change
        let _ = self.textField.resignFirstResponder()
        Fade.shared.dismiss()
        let text = self.textField.staticText.isEmpty ? $0 : $0.replacingOccurrences(of: self.textField.staticText + " ", with: "")
        
        guard self.replyTo.isNil else {
          guard let item = self.replyTo else { return }
          
          self.replyPublisher.send([item: text])
          
          return
        }
        instance.staticText = ""
        self.commentPublisher.send(text)
      }
      .store(in: &subscriptions)
    //Comment anon
    instance.messageAnonPublisher
      .sink { [weak self] in
        guard let self = self,
              let username = $0.keys.first,
              let text = $0.values.first
        else { return }
        
        //UI change
        let _ = self.textField.resignFirstResponder()
        Fade.shared.dismiss()
        let replaced = self.textField.staticText.isEmpty ? text : text.replacingOccurrences(of: self.textField.staticText + " ", with: "")
        instance.staticText = ""
        
        
        guard self.replyTo.isNil else {
          guard let item = self.replyTo else { return }
          
          self.anonReplyPublisher.send([item: [username: replaced]])
          return
        }
        self.anonCommentPublisher.send([username: replaced])
      }
      .store(in: &subscriptions)
    
    
    //          guard replyTo.isNil else {
    //              guard let item = replyTo,
    //                    let trimmed = text.replacingOccurrences(of: textField.staticText + " ", with: "") as? String
    //              else { return }
    //            anonReplyPublisher.send([item: [trimmed: username]])
    //              return
    //          }
    //          anonCommentPublisher.send([text: username])
    
    addSubview(instance)
    
    return instance
  }()
  
  
  // MARK: - Initialization
  init() {
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  }
  //  init(rootComment: Comment?, survey: Survey? = nil) {
  //    self.survey = survey
  //    self.rootComment = rootComment
  //    self.mode = rootComment.isNil ? .All : .Thread
  //
  //    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  //
  //    setupUI()
  //    setTasks()
  //
  //    guard let survey = survey else { return }
  //
  //    setTasks(for: survey)
  //  }
  
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
  
  
  
  // MARK: - Public funcs
  public func setDataSource(rootComment: Comment? = nil, survey: Survey, animatingDifferences: Bool = true) {
    self.survey = survey
    self.rootComment = rootComment
    self.mode = rootComment.isNil ? .All : .Thread
    
    setupUI()
    setTasks()
    reload(animatingDifferences: animatingDifferences)
  }
  
  public func reload(animatingDifferences: Bool = true, _ completion: Closure? = nil) {
    if !rootComment.isNil, dataItems.count != rootComment?.replies {
      paginationPublisher.send(dataItems)
    }
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Comment>()
    snapshot.appendSections([.main,])
    snapshot.appendItems(mode == .Thread ? dataItems.sorted { $0.createdAt < $1.createdAt } : dataItems.sorted { $0.createdAt > $1.createdAt },
                         toSection: .main)
    source.apply(snapshot, animatingDifferences: animatingDifferences) { completion?() }
  }
  
  public func scrollToBottom() {
    scrollToItem(at: IndexPath(row: dataItems.count-1, section: 0), at: .top, animated: true)
//    UIView.animate(withDuration: 0.3) { [weak self] in
//      guard let self = self else { return }
//
//      self.contentOffset.y = self.contentSize.height
//    }
  }
}
  
private extension CommentsCollectionView {
  // MARK: - UI functions
  private func setTasks() {
    tasks.append(Task {@MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: Notifications.System.HideKeyboard) {
        guard let self = self else { return }
        
        let _ = self.textField.resignFirstResponder()
      }
    })
    
    survey.commentAppendPublisher
      .filter { [unowned self] _ in self.mode != .Thread }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] comment in
        guard let self = self, !self.source.snapshot().itemIdentifiers.contains(comment) else { return }
        
        var snap = self.source.snapshot()
        
        switch self.mode {
        case .All:
          guard comment.isParentNode else { return }
          
          guard !snap.itemIdentifiers.isEmpty else {
            //1. Empty
            snap.appendItems([comment])
            self.source.apply(snap, animatingDifferences: true)
            
            return
          }
          
          //2. Compare
          guard let newest = snap.itemIdentifiers.first,
                let oldest = snap.itemIdentifiers.last
          else { return }
          
          //3. If newest comment in collection is older than added comment
          if comment.createdAt >= newest.createdAt {
            snap.insertItems([comment], beforeItem: newest)
          } else if oldest.createdAt >= comment.createdAt  {
            //4. If oldest comment in collection is newer than added comment
            snap.appendItems([comment])
          } else {
            //5.
            if let item = snap.itemIdentifiers.filter({ comment.createdAt >= $0.createdAt }).first {
              snap.insertItems([comment], beforeItem: item)
            }
          }
        case .Thread:
          var items = snap.itemIdentifiers
          items.remove(object: self.rootComment!)
          
          snap = Snapshot()
          snap.appendSections([.main])
          snap.appendItems([self.rootComment!])
          
          items.append(comment)
          snap.appendItems(items.sorted { $0.createdAt < $1.createdAt })
        }
        
        self.source.apply(snap, animatingDifferences: true)
      }
      .store(in: &self.subscriptions)

    //Claimed
     survey.commentClaimedPublisher
       .receive(on: DispatchQueue.main)
       .sink { [weak self] comment in
         guard let self = self,
               self.source.snapshot().itemIdentifiers.contains(comment)
         else { return }
         
         var snap = self.source.snapshot()
         snap.deleteItems([comment])
         self.source.apply(snap, animatingDifferences: true)
       }
       .store(in: &self.subscriptions)
  }
  
  private func setupUI() {
    backgroundColor = .clear
    Timer
      .publish(every: Constants.commentsStatsUpdateInterval, on: .current, in: .common)
      .autoconnect()
      .sink { [weak self] seconds in
        guard let self = self,
              let cells = self.visibleCells as? [CommentCell]
        else { return }
        
        let items = cells.compactMap{ $0.item }
        self.updateStatsPublisher.send(items)
      }
      .store(in: &subscriptions)
    
    delegate = self
    
//    switch mode {
//    case .All:
      collectionViewLayout = UICollectionViewCompositionalLayout { [unowned self] section, env -> NSCollectionLayoutSection? in
        
        var configuration = UICollectionLayoutListConfiguration(appearance: self.mode == .Thread ? .plain : .grouped)
        configuration.backgroundColor = .clear
        configuration.showsSeparators = false
        configuration.headerMode = .supplementary
        
        let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0,//self.mode == .Thread ? 8 : 0,
                                                              leading: self.mode == .Thread ? 16 : sectionLayout.contentInsets.leading,
                                                              bottom: self.mode == .Thread ? 60 : 0,
                                                              trailing: sectionLayout.contentInsets.trailing)
        //      sectionLayout.
//        sectionLayout.interGroupSpacing = 8
        
        return sectionLayout
      }
//    default:
//      let layout = UICollectionViewCompositionalLayout { [unowned self] section, env -> NSCollectionLayoutSection? in
//
//        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
////        configuration.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : Colors.lightTheme
//        configuration.showsSeparators = false
////        if #available(iOS 14.5, *) {
////          configuration.itemSeparatorHandler = { indexPath, config -> UIListSeparatorConfiguration in
////            var config = UIListSeparatorConfiguration(listAppearance: .plain)
////            config.topSeparatorVisibility = .hidden
////            if self.mode == .Thread, indexPath.row == 0 {
////              config.bottomSeparatorVisibility = .visible
////            } else {
////              config.bottomSeparatorVisibility = .hidden
////            }
////            return config
////          }
////        }
//        configuration.headerMode = .supplementary
////        configuration.headerMode = self.mode == .All ? .supplementary : .firstItemInSection
//
//        let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
//        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 8,
//                                                              leading: self.mode == .Thread ? 8 : sectionLayout.contentInsets.leading,
//                                                              bottom: 0,
//                                                              trailing: self.mode == .Thread ? 8 : sectionLayout.contentInsets.trailing)
////        sectionLayout.interGroupSpacing = 8
//
//        return sectionLayout
//      }
//
////      let supplementary = NSCollectionLayoutBoundarySupplementaryItem(
////        layoutSize: .init(
////          widthDimension: .fractionalWidth(1),
////          heightDimension: .absolute(150)
////        ),
////        elementKind: UICollectionView.elementKindSectionHeader,
////        alignment: .top
////      )
////      supplementary.pinToVisibleBounds = true
//
//      let configuration = UICollectionViewCompositionalLayoutConfiguration()
////      configuration.interSectionSpacing = 20
////      configuration.boundarySupplementaryItems = [supplementary]
//
//      layout.configuration = configuration
//
//      collectionViewLayout = layout
//    }
//    //        let headerRegistration = UICollectionView.SupplementaryRegistration
//    //        <UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {
//    //            [unowned self] (headerView, elementKind, indexPath) in
//    //        }
    
    let commentCellRegistration = UICollectionView.SupplementaryRegistration<CommentSupplementaryCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
      guard let self = self else { return }
      
      supplementaryView.tapPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
//          self.textField.staticText = ""
          self.replyTo = nil
          let _ = self.textField.becomeFirstResponder()
          Fade.shared.present()
        }
        .store(in: &self.subscriptions)
    }
    
    let threadCellRegistration = UICollectionView.SupplementaryRegistration<CommentCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
      guard let self = self else { return }
      
//      supplementaryView.backgroundColor = .black
      supplementaryView.mode = .Root
      supplementaryView.item = self.rootComment
      supplementaryView.boundsPublisher
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.source.refresh() }
        .store(in: &self.subscriptions)
      
      supplementaryView.replyPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          if $0.isAnonymous {
            self.textField.staticText = "@" + $0.anonUsername
          } else {
            guard let userprofile = $0.userprofile else { return }
            
            self.textField.staticText = "@" + userprofile.username
          }
          self.replyTo = $0
          let _ = self.textField.becomeFirstResponder()
          Fade.shared.present()
        }
        .store(in: &self.subscriptions)
//      supplementaryView.contentView.layer.zPosition = .greatestFiniteMagnitude
//      var configuration = UIBackgroundConfiguration.listPlainCell()
//      configuration.backgroundColor = .red
//      supplementaryView.backgroundConfiguration = configuration
    }
    
    let cellRegistration = UICollectionView.CellRegistration<CommentCell, Comment> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      var configuration: UIBackgroundConfiguration!
      configuration = UIBackgroundConfiguration.listPlainCell()
      configuration.backgroundColor = .clear
      cell.backgroundConfiguration = configuration
      cell.automaticallyUpdatesBackgroundConfiguration = false
      if self.mode == .Thread { cell.mode = .Thread }
      cell.item = item
      
      
      // Reply disclosure
      cell.replyPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          if $0.isAnonymous {
            self.textField.staticText = "@" + $0.anonUsername
          } else {
            guard let userprofile = $0.userprofile else { return }
            
            self.textField.staticText = "@" + userprofile.username
          }
          self.replyTo = $0
          let _ = self.textField.becomeFirstResponder()
          Fade.shared.present()
        }
        .store(in: &self.subscriptions)
      
      //Thread disclosure
      cell.threadPublisher
        .sink { [unowned self] in self.threadPublisher.send($0) }
        .store(in: &self.subscriptions)
      
      //Claim tap
      cell.claimPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.claimPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      //Delete own
      cell.deletePublisher.sink { [weak self] in
        guard let self = self else { return }
        
        self.deletePublisher.send($0)
      }.store(in: &self.subscriptions)
      
      cell.boundsPublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.source.refresh() }
        .store(in: &self.subscriptions)
      //            self.modeSubject.sink {
      //#if DEBUG
      //                print("receiveCompletion: \($0)")
      //#endif
      //            } receiveValue: { [weak self] in
      //                guard let self = self else { return }
      //                cell.mode = $0
      //                self.colorSubject.send(completion: .finished)
      //            }.store(in: &self.subscriptions)
    }
    
    source = UICollectionViewDiffableDataSource<Section, Comment>(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    source.supplementaryViewProvider = { [weak self] (supplementaryView, elementKind, indexPath) in
      guard let self = self else { return UICollectionReusableView() }
      
      if elementKind == UICollectionView.elementKindSectionHeader {
        return self.mode == .Thread ? self.dequeueConfiguredReusableSupplementary(using: threadCellRegistration, for: indexPath) : self.dequeueConfiguredReusableSupplementary(using: commentCellRegistration, for: indexPath)
      }
      
      return UICollectionReusableView()
    }
    
//    reload(animatingDifferences: false)
  }
}

// MARK: - UICollectionViewDelegate
extension CommentsCollectionView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? CommentCell else { return }
    
    if cell.item.replies != 0 {
      threadPublisher.send(cell.item)
    } else if !cell.item.isOwn {
      Fade.shared.present()
      if cell.item.isAnonymous {
        textField.staticText = "@" + cell.item.anonUsername
      } else if let userprofile = cell.item.userprofile {
        if !userprofile.firstNameSingleWord.isEmpty {
          textField.staticText = "@" + userprofile.firstNameSingleWord
        } else if !userprofile.lastNameSingleWord.isEmpty {
          textField.staticText = "@" + userprofile.lastNameSingleWord
        }
      }
      replyTo = cell.item
      let _ = textField.becomeFirstResponder()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//    cell.setNeedsLayout()
//    cell.layoutIfNeeded()
    if dataItems.count < 10 {
      paginationPublisher.send(dataItems)
    } else if let biggestRow = collectionView.indexPathsForVisibleItems.sorted(by: { $1.row < $0.row }).first?.row, indexPath.row == biggestRow + 1 && indexPath.row == dataItems.count - 1 {
      paginationPublisher.send(dataItems)
    }
  }
}

// MARK: - UITextFieldDelegate
extension CommentsCollectionView: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return true
  }
}
