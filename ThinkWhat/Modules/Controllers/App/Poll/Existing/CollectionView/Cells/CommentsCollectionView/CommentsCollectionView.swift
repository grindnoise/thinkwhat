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
  ///**Publishers**
  //  public let updateStatsPublisher = PassthroughSubject<[Comment], Never>()
//  public let getNewCommentsUpdateExistingPublisher = PassthroughSubject<[Comment], Never>() // Timer based. Array of excluded items
  public let getRootCommentsPublisher = PassthroughSubject<[Comment], Never>() // Timer based. Array of excluded items
  public let getThreadCommentsPublisher = PassthroughSubject<[Comment], Never>() // Timer based. Array of excluded items
  public let postCommentPublisher = PassthroughSubject<String, Never>()
  public let postAnonCommentPublisher = PassthroughSubject<[String: String], Never>()
  public let replyPublisher = PassthroughSubject<[Comment: String], Never>()
  public let anonReplyPublisher = PassthroughSubject<[Comment: [String: String]], Never>()
  public let claimPublisher = PassthroughSubject<Comment, Never>()
  public let deletePublisher = PassthroughSubject<Comment, Never>()
  public let threadPublisher = PassthroughSubject<Comment, Never>()
  public let paginationPublisher = PassthroughSubject<[Comment], Never>()
  public let emptyPublisher = PassthroughSubject<Void, Never>()
  
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
          instance.erase()
          
          return
        }
//        instance.staticText = ""
        instance.eraseResponder()
        self.postCommentPublisher.send(text)
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
//        instance.staticText = ""
        instance.eraseResponder()
        
        guard self.replyTo.isNil else {
          guard let item = self.replyTo else { return }
          
          self.anonReplyPublisher.send([item: [username: replaced]])
          return
        }
        self.postAnonCommentPublisher.send([username: replaced])
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
  private var reply: Comment? // Use that to highlight
  private var isRequesting = false {
    didSet {
      guard isRequesting else { return }
      
      requestStartTime = Date()
    }
  }
  private var requestStartTime = Date()
  
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
  public func setDataSource(rootComment: Comment? = nil,
                            survey: Survey,
                            animatingDifferences: Bool = true,
                            completion: Closure? = nil) {
    self.survey = survey
    self.rootComment = rootComment
    self.mode = rootComment.isNil ? .All : .Thread
    
    setupUI()
    setTasks()
    reload(animatingDifferences: animatingDifferences) { completion?() }
  }
  
  public func reload(animatingDifferences: Bool = true, _ completion: Closure? = nil) {
    if !rootComment.isNil, dataItems.count != rootComment?.replies {
      requestData(emptyDataItems: dataItems.isEmpty)
      
    }
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Comment>()
    snapshot.appendSections([.main,])
    snapshot.appendItems(mode == .Thread ? dataItems.sorted { $0.createdAt < $1.createdAt } : dataItems.sorted { $0.createdAt > $1.createdAt },
                         toSection: .main)
    source.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
      guard let self = self else { return }
      
      self.isRequesting = false
      completion?() }
  }
  
  public func scrollToBottom() {
    scrollToItem(at: IndexPath(row: dataItems.count-1, section: 0), at: .top, animated: true)
    //    UIView.animate(withDuration: 0.3) { [weak self] in
    //      guard let self = self else { return }
    //
    //      self.contentOffset.y = self.contentSize.height
    //    }
  }
  
  public func focus(on comment: Comment){
    func highlight(comment: Comment, row: Int) {
      reply = comment
      scrollToItem(at: IndexPath(row: row, section: 0), at: .top, animated: true)
      
      // Highlight reply if cell is visible
      if let cells = visibleCells as? [CommentCell],
         let cell = cells.filter({ $0.item == comment }).first {
        cell.highlight(timeInterval: 3)
        reply = nil
      }
    }
    
    func getCommentAndRow(for item: Comment) -> EnumeratedSequence<[Comment]>.Element? {
      source.snapshot().itemIdentifiers.enumerated().filter({ index, item in item.id == comment.id }).first
    }
    
    if let item = source.snapshot().itemIdentifiers.enumerated().filter({ index, item in item.id == comment.id }).first {
      highlight(comment: item.element, row: item.offset)
    } else {
      var snap = source.snapshot()
      snap.appendItems([comment])
      source.apply(snap)
      
      if let item = self.source.snapshot().itemIdentifiers.enumerated().filter({ index, item in item.id == comment.id }).first {
        highlight(comment: item.element, row: item.offset)
      }
    }
    
//    var item: EnumeratedSequence<[Comment]>.Element! = getCommentAndRow(for: comment)
//
//    if item.isNil {
//      delay(seconds: 0.5) {
//        item = getCommentAndRow(for: comment)
//        if !item.isNil{
//          highlight(comment: item.element, row: item.offset)
//        } else {
//          delay(seconds: 1) {
//            item = getCommentAndRow(for: comment)
//            if !item.isNil{
//              highlight(comment: item.element, row: item.offset)
//            }
//          }
//        }
//      }
//    }
    
//    } else {
//      delay(seconds: 1) { [weak self] in
//        guard let self = self else { return }
//
//        if let item = self.source.snapshot().itemIdentifiers.enumerated().filter({ index, item in item.id == comment.id }).first {
//          highlight(comment: item.element, row: item.offset)
//        }
//      }
//    }
  }
  
  public func commentPostCallback(_ result: Result<Comment, Error>) {
    switch result {
    case .success(let comment):
      textField.erase()
      focus(on: comment)
    case .failure(_): break }
  }
}

private extension CommentsCollectionView {
  // MARK: - UI functions
  func setTasks() {
    // We need to monitor empty comments publisher to set isRequesting to false
    Comments.shared.instancesPublisher
      .collect(.byTimeOrCount(DispatchQueue.main, .seconds(0.25), 1))
      .filter { $0.isEmpty }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in self.isRequesting = false }
      .store(in: &subscriptions)
    
    // We need to set isRequesting to false on timer
    Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in self.isRequesting && self.requestStartTime.distance(to: Date()) > 5 }
      .sink { [weak self] _ in
        guard let self = self else { return }

        self.isRequesting = false
      }
      .store(in: &subscriptions)
    
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
            // 1. Empty
            snap.appendItems([comment])
            self.source.apply(snap, animatingDifferences: true)
            
            return
          }
          
          // 2. Compare
          guard let newest = snap.itemIdentifiers.first,
                let oldest = snap.itemIdentifiers.last
          else { return }
          
          // 3. If newest comment in collection is older than added comment
          if comment.createdAt >= newest.createdAt {
            snap.insertItems([comment], beforeItem: newest)
          } else if oldest.createdAt >= comment.createdAt  {
            // 4. If oldest comment in collection is newer than added comment
            snap.appendItems([comment])
          } else {
            // 5.
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
  
  @MainActor
  func setupUI() {
    backgroundColor = .clear
//    bounces = false
    //    Timer
    //      .publish(every: Constants.commentsStatsUpdateInterval, on: .current, in: .common)
    //      .autoconnect()
    //      .filter { [unowned self] _ in self.mode == .All }
    //      .sink { [weak self] seconds in
    //        guard let self = self else { return }
    //
    //        self.updateStatsPublisher.send(self.dataItems)
    //      }
    //      .store(in: &subscriptions)
    
    // Update comments and get new
    Timer
      .publish(every: AppSettings.TimeIntervals.updateStatsComments, on: .current, in: .common)
      .autoconnect()
      .sink { [weak self] seconds in
        guard let self = self,
              !self.isRequesting
        else { return }
        
        switch self.mode {
        case .All:
          self.getRootCommentsPublisher.send(self.dataItems)
        case .Thread:
          self.getThreadCommentsPublisher.send(self.dataItems)
        }
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
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: sectionLayout.contentInsets.top,//self.mode == .Thread ? 8 : 0,
                                                            leading: self.mode == .Thread ? 16 : sectionLayout.contentInsets.leading,
                                                            bottom: self.mode == .Thread ? 80 : 0,
                                                            trailing: self.mode == .Thread ? 16 : sectionLayout.contentInsets.trailing)
      if #available(iOS 16.0, *) {
        sectionLayout.supplementaryContentInsetsReference = .none
      }
//      sectionLayout.interGroupSpacing = 8
      
      
      return sectionLayout
    }
    
    let commentCellRegistration = UICollectionView.SupplementaryRegistration<CommentSupplementaryCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
      guard let self = self else { return }
      
      supplementaryView.tapPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          //          self.textField.staticText = ""
          self.replyTo = nil
          self.textField.eraseResponder()
          let _ = self.textField.becomeFirstResponder()
          Fade.shared.present()
        }
        .store(in: &self.subscriptions)
    }
    
    let threadCellRegistration = UICollectionView.SupplementaryRegistration<CommentCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
      guard let self = self else { return }
      
      //      supplementaryView.backgroundColor = .black
      supplementaryView.mode = .Root
      supplementaryView.clipsToBounds = false
      supplementaryView.contentView.clipsToBounds = false
      supplementaryView.layer.masksToBounds = false
      supplementaryView.contentView.layer.masksToBounds = false
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
            self.textField.setStaticText("@" + $0.anonUsername)
//            self.textField.staticText = "@" + $0.anonUsername
          } else {
            guard let userprofile = $0.userprofile else { return }
            
            self.textField.setStaticText("@" + userprofile.username)
//            self.textField.staticText = "@" + userprofile.username
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
//            self.textField.staticText = "@" + $0.anonUsername
            self.textField.setStaticText("@" + $0.anonUsername)
          } else {
            guard let userprofile = $0.userprofile else { return }
            
            self.textField.setStaticText("@" + userprofile.username)
//            self.textField.staticText = "@" + userprofile.username
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
    // Immediate request for root
    guard mode == .All else { return }
    
    paginationPublisher.send(dataItems)
  }
  
  func requestData(emptyDataItems: Bool = false) {
    guard !isRequesting else { return }
    
    emptyDataItems ? emptyPublisher.send() : paginationPublisher.send(dataItems)
    isRequesting = true
  }
}

// MARK: - UICollectionViewDelegate
extension CommentsCollectionView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    func reply(username: String) {
      Fade.shared.present()
      textField.setStaticText(username)
      let _ = textField.becomeFirstResponder()
    }
    
    // Skip deleted
    guard let cell = collectionView.cellForItem(at: indexPath) as? CommentCell,
          !cell.item.isDeleted
    else { return }
    
    if mode == .All {
      // Reveal hidden text
      if !cell.isRevealed, cell.item.isClaimed || cell.item.isBanned {
          cell.reveal()
      } else if cell.item.replies != 0 {
        // Open thread
        threadPublisher.send(cell.item)
      } else if !cell.item.isOwn, !cell.item.isClaimed, !cell.item.isBanned {
        var username = ""
        if cell.item.isAnonymous {
          username = "@" + cell.item.anonUsername
        } else if let userprofile = cell.item.userprofile {
          username = "@" + userprofile.username
          replyTo = cell.item
          reply(username: username)
        }
      }
    } else {
      // Reveal hidden text
      if !cell.isRevealed, cell.item.isClaimed || cell.item.isBanned {
        cell.reveal()
      } else if let replyId = cell.item.replyToId,
                let item = source.snapshot().itemIdentifiers.enumerated().filter({ $1.id == replyId }).first {
        // Scroll to reply
        scrollToItem(at: IndexPath(row: item.offset, section: 0), at: .top, animated: true)
        self.reply = item.element
        
        // Highlight reply if cell is visible
        if let cells = visibleCells as? [CommentCell],
           let cell = cells.filter({ $0.item == self.reply }).first {
          cell.highlight(timeInterval: 3)
        }
      } else if !cell.item.isOwn, !cell.item.isClaimed, !cell.item.isBanned {
        var username = ""
        if cell.item.isAnonymous {
          username = "@" + cell.item.anonUsername
        } else if let userprofile = cell.item.userprofile {
          username = "@" + userprofile.username
          replyTo = cell.item
          reply(username: username)
        }
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //    cell.setNeedsLayout()
    //    cell.layoutIfNeeded()
    if mode == .Thread {
      if dataItems.count < 10 {
        requestData()
      } else if (source.snapshot().itemIdentifiers.count - AppSettings.Pagination.threshold == indexPath.row) && indexPath.row > 1 && !isRequesting || // Preload data
                  (source.snapshot().itemIdentifiers.count - 1 == indexPath.row) && !isRequesting { // Last row
//      } else if let biggestRow = collectionView.indexPathsForVisibleItems.sorted(by: { $1.row < $0.row }).first?.row,
//                indexPath.row == biggestRow + 1 && indexPath.row == dataItems.count - 1 {
        requestData()
      }
    }
    
    // Highlight reply
    if let cell = cell as? CommentCell, cell.item == reply {
      cell.highlight(timeInterval: 3)
      reply = nil
    }
//    if let replyIndexPath = replyIndexPath, indexPath == replyIndexPath, let cell = cell as? CommentCell {
//      cell.highlight()
//      self.replyIndexPath = nil
//    }
  }
}

// MARK: - UITextFieldDelegate
extension CommentsCollectionView: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return true
  }
}
