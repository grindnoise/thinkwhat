//
//  CommentsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CommentsView: UIView {
  
  // MARK: - Public properties
  public weak var viewInput: CommentsViewInput? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
      setTasks()
    }
  }
  public let rootComment: Comment
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private var isReplying = false
  private lazy var collectionView: CommentsCollectionView = {
    //        let instance = CommentsCollectionView(rootComment: rootComment,
    //                                              survey: rootComment.survey)
    let instance = CommentsCollectionView()
    
    instance.claimPublisher.sink {
      print($0)
    } receiveValue: { [weak self] in
      guard let self = self,
            let surveyReference = $0.survey?.reference
      else { return }
      
      let comment = $0
      //            let banner = Popup(heightScaleFactor: 0.7)
      //            banner.accessibilityIdentifier = "claim"
      //            let claimContent = ClaimPopupContent(parent: banner, surveyReference: surveyReference)
      //
      //            claimContent.claimPublisher
      //                .sink { [weak self] in
      //                    guard let self = self else { return }
      //
      //                    self.viewInput?.postClaim(comment: comment, reason: $0)
      //                }
      //                .store(in: &self.subscriptions)
      //
      //            banner.present(content: claimContent)
      //
      //            banner.didDisappearPublisher
      //                .sink { [weak self] _ in
      //                    guard let self = self else { return }
      //                    banner.removeFromSuperview()
      //                }
      //                .store(in: &self.subscriptions)
      
    }.store(in: &subscriptions)
    
    instance.replyPublisher.sink { [weak self] in
      guard let self = self,
            let replyObject = $0.keys.first,
            let body = $0.values.first
      else { return }
      
      self.isReplying = true
      self.viewInput?.postComment(body: body, replyTo: replyObject, username: nil)
    }.store(in: &subscriptions)
    
    instance.anonReplyPublisher.sink { [weak self] in
      guard let self = self,
            let dict = $0.values.first,
            let comment = $0.keys.first,
            let username = dict.values.first,
            let body = dict.keys.first
      else { return }
      
      self.viewInput?.postComment(body: body,
                                  replyTo: comment,
                                  username: username)
    }.store(in: &self.subscriptions)
    
    instance.paginationPublisher
      .throttle(for: .seconds(2),
                scheduler: DispatchQueue.main,
                latest: false)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.getComments(excludeList: $0.map { $0.id }, includeList: [])
      }
      .store(in: &subscriptions)
    
    // Update comments and get new
    instance.getThreadCommentsPublisher
      .sink { [weak self] in
      guard let self = self else { return }
      
        self.viewInput?.updateCommentsAndGetNew(mode: .Thread, excludeList: $0.map { $0.id },
                                                updateList: Comments.shared.all.filter{ $0.parent == self.viewInput?.item }.map { $0.id })
//        self.viewInput?.getComments(excludeList: $0.map { $0.id}, includeList: [])
    }
    .store(in: &subscriptions)
    
    //Delete comment
    instance.deletePublisher
      .sink { [weak self] in
      guard let self = self else { return }
      
      self.viewInput?.deleteComment($0)
    }
      .store(in: &self.subscriptions)
    
    instance.setDataSource(rootComment: rootComment,
                           survey: rootComment.survey!,
                           animatingDifferences: true) { [weak self] in
      guard let self = self,
            let input = self.viewInput,
            let reply = input.reply
      else { return }
      
      delay(seconds: 0.3) {
        instance.focus(on: reply)
      }
    }
    
    return instance
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
  init(comment: Comment) {
    self.rootComment = comment
    
    super.init(frame: .zero)
  }
  
  override init(frame: CGRect) {
    fatalError("init(frame:) has not been implemented")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension CommentsView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    collectionView.addEquallyTo(to: self)
  }
  
  func setTasks() {
    Comments.shared.instancesPublisher
      .filter { [unowned self] in $0.parent == self.rootComment }
      .collect(.byTimeOrCount(DispatchQueue.main, .seconds(0.5), 10))
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] instances in self.collectionView.reload() {
        self.isReplying && !instances.filter { $0.isOwn }.isEmpty ? { self.collectionView.scrollToBottom(); self.isReplying = false }() : {}() }
      }
      .store(in: &subscriptions)
  }
}

// MARK: - Controller Output
extension CommentsView: CommentsControllerOutput {
  func focusOnReply(_ reply: Comment) {
    collectionView.focus(on: reply)
  }
  
    func commentDeleteError() {
      let banner = NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                                                            text: AppError.server.localizedDescription),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
    }
    
    func commentPostFailure() {
      isReplying = false
      let banner = NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                                                            text: AppError.server.localizedDescription),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
    }
}
