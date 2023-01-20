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
    case Root, Tree
  }
  
  enum CommentMode {
    case Root, Reply
  }
  
  // MARK: - Public properties
  public weak var survey: Survey! {
    didSet {
      guard let survey = survey else { return }
      
      survey.commentAppendPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
          
          var snap = self.source.snapshot()
          
          switch self.mode {
          case .Root:
            //TODO: - Time sorting
            guard let firstItem = snap.itemIdentifiers.first else  {
              snap.appendItems([$0])
              return
            }
            snap.appendItems([$0])
//            snap.insertItems([$0], beforeItem: firstItem)
          case .Tree:
            fatalError()
          }
          self.source.apply(snap, animatingDifferences: true)
        }
        .store(in: &subscriptions)
      
//      tasks.append( Task { [weak self] in
//        for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Append) {
//          guard let self = self,
//                self.mode == .Root,
//                let instance = notification.object as? Comment,
//                !instance.isDeleted,
//                instance.replyToId.isNil,
//                instance.survey == self.survey
//          else { return }
//
//          var snap = self.source.snapshot()
//
//          if instance.isOwn && abs(instance.createdAt.days(from: Date())) < 1, let firstItem = snap.itemIdentifiers.first, self.mode == .Root {
//            snap.insertItems([instance], beforeItem: firstItem)
//          } else {
//            snap.appendItems([instance], toSection: .main)
//          }
//
//          await MainActor.run {
//            self.source.apply(snap, animatingDifferences: true)
//          }
//        }
//      })
      
      reload()
    }
  }
  public weak var rootComment: Comment? {
    didSet {
      guard !rootComment.isNil else { return }
      mode = .Tree
      reload()
    }
  }
  public var dataItems: [Comment] {
    if let rootComment = rootComment, mode == .Tree {
      return [rootComment] + Comments.shared.all.filter { $0.parentId == rootComment.id && !$0.isClaimed && !$0.isBanned }
    }
    guard let survey = survey else { return [] }
    
    return survey.commentsSortedByDate
  }
  //Publishers
  public var commentPublisher = PassthroughSubject<String, Never>()
  public var anonCommentPublisher = PassthroughSubject<[String: String], Never>()
  public var replyPublisher = PassthroughSubject<[Comment: String], Never>()
  public var anonReplyPublisher = PassthroughSubject<[Comment: [String: String]], Never>()
  public var claimPublisher = PassthroughSubject<Comment, Never>()
  public var deletePublisher = PassthroughSubject<Comment, Never>()
  public var threadPublisher = PassthroughSubject<Comment, Never>()
  public var paginationPublisher = PassthroughSubject<[Comment], Never>()
  //    public var commentsRequestSubject: CurrentValueSubject<[Comment], Never>!
  //New user comment publisher
  public var lastPostedComment: Comment? {
    didSet {
      //            guard let lastPostedComment = lastPostedComment else {
      //                return
      //            }
      //            dataItems.insert(lastPostedComment, at: 0)
      
      //Clean tf on success
      textField.text = ""
      //            var snapshot = source.snapshot()
      //            if let firstItem = snapshot.itemIdentifiers.first {
      //                snapshot.insertItems([lastPostedComment], beforeItem: firstItem)
      //            } else {
      //                snapshot.appendSections([.main,])
      //                snapshot.appendItems([lastPostedComment], toSection: .main)
      //            }
      //            source.apply(snapshot, animatingDifferences: true)
    }
  }
  //    public weak var boundsListener: BoundsListener?
  
  
  // MARK: - Private properties
  private var mode: Mode
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
    let instance = AccessoryInputTextField(placeholder: "add_comment".localized,
                                           font: UIFont.scaledFont(fontName: Fonts.Regular,
                                                                   forTextStyle: .body)!,
                                           //                                               delegate: self,
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
        
        guard self.replyTo.isNil else {
          guard let item = self.replyTo else { return }
          
          self.replyPublisher.send([item: $0.replacingOccurrences(of: self.textField.staticText + " ", with: "")])
          return
        }
        self.commentPublisher.send($0)
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
        
        guard self.replyTo.isNil else {
          guard let item = self.replyTo else { return }
          
          self.anonReplyPublisher.send([item: [username: text.replacingOccurrences(of: self.textField.staticText + " ", with: "")]])
          return
        }
        self.anonCommentPublisher.send([username: text.replacingOccurrences(of: self.textField.staticText + " ", with: "")])
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
  init(rootComment: Comment?, survey: Survey? = nil) {
    self.survey = survey
    self.rootComment = rootComment
    self.mode = rootComment.isNil ? .Root : .Tree
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
    setTasks()
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
  
  
  
  
  // MARK: - UI functions
  private func setTasks() {
//    tasks.append( Task { [weak self] in
//      for await _ in NotificationCenter.default.notifications(for: Notifications.Comments.Post) {
//        guard let self = self else { return }
//        //Post notification
//        await MainActor.run {
//          let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "checkmark.bubble.fill")!,
//                                                                text: "comment_posted",
//                                                                tintColor: .systemRed),
//                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                                 isModal: false,
//                                 useContentViewHeight: true,
//                                 shouldDismissAfter: 1)
//          banner.didDisappearPublisher
//            .sink { _ in banner.removeFromSuperview() }
//            .store(in: &self.subscriptions)
//        }
//      }
//    })
    tasks.append(Task {@MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: Notifications.System.HideKeyboard) {
        guard let self = self else { return }
        
        //                await MainActor.run {
        let _ = self.textField.resignFirstResponder()
        //                }
      }
    })
//    tasks.append( Task { [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Append) {
//        guard let self = self,
//              self.mode == .Root,
//              let instance = notification.object as? Comment,
//              !instance.isDeleted,
//              instance.replyToId.isNil,
//              instance.survey == self.survey
//        else { return }
//
//        var snap = self.source.snapshot()
//
//        if instance.isOwn && abs(instance.createdAt.days(from: Date())) < 1, let firstItem = snap.itemIdentifiers.first, self.mode == .Root {
//          snap.insertItems([instance], beforeItem: firstItem)
//        } else {
//          snap.appendItems([instance], toSection: .main)
//        }
//
//        await MainActor.run {
//          self.source.apply(snap, animatingDifferences: true)
//        }
//      }
//    })
    tasks.append( Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.ChildAppend) {
        guard let self = self,
              self.mode == .Tree,
              let instance = notification.object as? Comment,
              !instance.isDeleted,
              instance.parent == self.rootComment
        else { return }
        
        var snap = self.source.snapshot()
        snap.appendItems([instance], toSection: .main)
        
        //                await MainActor.run {
        self.source.apply(snap, animatingDifferences: true)
        //                }
      }
    })
    tasks.append( Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Claim) {
        guard let self = self,
              let instance = notification.object as? Comment,
              instance.survey == self.survey,
              self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([instance])
        //                await MainActor.run {
        self.source.apply(snap, animatingDifferences: true)
        //                }
      }
    })
    tasks.append( Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Delete) {
        guard let self = self,
              let instance = notification.object as? Comment,
              instance.survey == self.survey,
              self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([instance])
        self.source.apply(snap, animatingDifferences: true)
        
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "trash.fill")!,
                                                              text: "comment_deleted",
                                                              tintColor: .systemRed),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 1)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
    })
    tasks.append( Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Ban) {
        guard let self = self,
              let instance = notification.object as? Comment,
              instance.survey == self.survey,
              self.source.snapshot().itemIdentifiers.contains(instance)
        else { return }
        
        var snap = self.source.snapshot()
        snap.deleteItems([instance])
        self.source.apply(snap, animatingDifferences: true)
      }
    })
  }
  
  private func setupUI() {
    delegate = self
    //        addSubview(textField)
    collectionViewLayout = UICollectionViewCompositionalLayout { [unowned self] section, env -> NSCollectionLayoutSection? in
      var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
      //            configuration.headerMode = .supplementary
      configuration.backgroundColor = .clear
      configuration.showsSeparators = true
      if #available(iOS 14.5, *) {
        configuration.itemSeparatorHandler = { indexPath, config -> UIListSeparatorConfiguration in
          var config = UIListSeparatorConfiguration(listAppearance: .plain)
          config.topSeparatorVisibility = .hidden
          if self.mode == .Tree, indexPath.row == 0 {
            config.bottomSeparatorVisibility = .visible
          } else {
            config.bottomSeparatorVisibility = .hidden
          }
          return config
        }
      }
      
      configuration.headerMode = self.mode == .Root ? .supplementary : .firstItemInSection
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: self.mode == .Tree ? 8 : 0,
                                                            leading: self.mode == .Tree ? 8 : sectionLayout.contentInsets.leading,
                                                            bottom: self.mode == .Tree ? 8 : 0,
                                                            trailing: self.mode == .Tree ? 8 : sectionLayout.contentInsets.trailing)
      sectionLayout.interGroupSpacing = 16
      return sectionLayout
    }
    
    //        let headerRegistration = UICollectionView.SupplementaryRegistration
    //        <UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {
    //            [unowned self] (headerView, elementKind, indexPath) in
    //        }
    
    let headerCellRegistration = UICollectionView.SupplementaryRegistration<CommentSupplementaryCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
      guard let self = self else { return }
      
      supplementaryView.tapPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.textField.staticText = ""
          self.replyTo = nil
          let _ = self.textField.becomeFirstResponder()
          Fade.shared.present()
        }
        .store(in: &self.subscriptions)
    }
    
    let rootCellRegistration = UICollectionView.CellRegistration<CommentCell, Comment> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      var configuration: UIBackgroundConfiguration!
      if self.mode == .Tree {
        configuration =  indexPath.row == 0 ? UIBackgroundConfiguration.listGroupedHeaderFooter() : UIBackgroundConfiguration.listGroupedCell()
      } else {
        configuration = UIBackgroundConfiguration.listPlainCell()
      }
      configuration.backgroundColor = .clear
      cell.backgroundConfiguration = configuration
      cell.item = item
      cell.automaticallyUpdatesBackgroundConfiguration = false
      if self.mode == .Tree {
        cell.mode = indexPath.row == 0 ? .Root : .Tree
        cell.hideDisclosure()
      } else {
        cell.mode = .Root
      }
      
      
      //Reply disclosure
      cell.replyPublisher.sink { [weak self] in
        guard let self = self else { return }
        
        if $0.isAnonymous {
          self.textField.staticText = "@" + $0.anonUsername
        } else if let userprofile = $0.userprofile {
          if !userprofile.firstNameSingleWord.isEmpty {
            self.textField.staticText = "@" + userprofile.firstNameSingleWord
          } else if !userprofile.lastNameSingleWord.isEmpty {
            self.textField.staticText = "@" + userprofile.lastNameSingleWord
          }
        }
        self.replyTo = $0
        let _ = self.textField.becomeFirstResponder()
        Fade.shared.present()
      }.store(in: &self.subscriptions)
      
      //Thread disclosure
      cell.threadPublisher.sink { [weak self] in
        guard let self = self else { return }
        
        self.threadPublisher.send($0)
      }.store(in: &self.subscriptions)
      
      //Claim tap
      cell.claimPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.claimPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      //Claim tap
      cell.deletePublisher.sink { [weak self] in
        guard let self = self else { return }
        
        self.deletePublisher.send($0)
      }.store(in: &self.subscriptions)
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
      return collectionView.dequeueConfiguredReusableCell(using: rootCellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    source.supplementaryViewProvider = { [weak self] (supplementaryView, elementKind, indexPath) in
      guard let self = self else { return UICollectionReusableView() }
      
      if elementKind == UICollectionView.elementKindSectionHeader {
        return self.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
      }
      
      return UICollectionReusableView()
    }
    
    reload(animatingDifferences: false)
  }
  
  private func reload(animatingDifferences: Bool = true) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Comment>()
    snapshot.appendSections([.main,])
    snapshot.appendItems(dataItems, toSection: .main)
    source.apply(snapshot, animatingDifferences: animatingDifferences)
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
    cell.setNeedsLayout()
    cell.layoutIfNeeded()
    
    
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
