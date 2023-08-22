//
//  CommentsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CommentsController: UIViewController {
  
  // MARK: - Public properties
  var controllerOutput: CommentsControllerOutput?
  var controllerInput: CommentsControllerInput?
  ///**UI**
  public let item: Comment
  public private(set) var reply: Comment?
  public private(set) var isOnScreen = false
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let shouldRequest: Bool // Flag for loading new comments
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var titleView: TagCapsule = { TagCapsule(text: "replies".localized.uppercased() + ": \(item.replies)",
                                                        padding: padding/2,
                                                        textPadding: .init(top: padding/2, left: 0, bottom: padding/2, right: padding),
                                                        color: item.survey?.topic.tagColor ?? .lightGray,
                                                        font: UIFont(name: Fonts.Rubik.SemiBold, size: 20)!,
                                                        isShadowed: false,
                                                        iconCategory: nil,
                                                        image: UIImage(systemName: "bubble.right.fill"))
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
  init(root: Comment,
       shouldRequest: Bool = true,
       reply: Comment? = nil) {
    self.item = root
    self.shouldRequest = shouldRequest
    self.reply = reply
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    let view = CommentsView(comment: item)
    let model = CommentsModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    
    // Refresh comments
    if shouldRequest {
      controllerInput?.loadThread(root: item)
    }
    
    setTasks()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setupUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    isOnScreen = true
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
     
    isOnScreen = false
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark, animated: true)
  }
  
  // MARK: - Public methods
  public func setReply(_ replyId: Int) {
    // Check if exists
    if let reply = Comments.shared.all.filter({ $0.id == replyId }).first {
      controllerOutput?.focusOnReply(reply)
    } else {
      // Download reply
      controllerInput?.getReply(threadId: item.id, replyId: replyId)
    }
  }
}
  // MARK: - Private extension
private extension CommentsController {
  @MainActor
  func setupUI() {
    navigationController?.setNavigationBarHidden(false, animated: true)
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark, animated: true)
    navigationController?.setBarTintColor(item.survey?.topic.tagColor ?? .systemGray)
    navigationController?.setBarColor()
    navigationItem.titleView = titleView
  }
  
  func setTasks() {
    // Update title count
    item.repliesPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in self.titleView.text = "replies".localized.uppercased() + ": \($0)" }
      .store(in: &subscriptions)
    
    // Control shadow
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.willEnterForegroundNotification) {
        guard let self = self, self.isOnScreen else { return }
        
        self.navigationController?.setBarShadow(on: self.traitCollection.userInterfaceStyle != .dark, animated: true)
      }
    })
  }
}

// MARK: - View Input
extension CommentsController: CommentsViewInput {
  func reportComment(_ comment: Comment) {
    let popup = NewPopup(padding: self.padding,
                         contentPadding: .uniform(size: self.padding*2))
    let content = ClaimPopupContent(parent: popup,
                                    object: comment)
    content.$claim
      .filter { !$0.isNil && !$0!.isEmpty && $0!.keys.first is Comment }
      .map { [$0!.keys.first as! Comment: $0!.values.first!] as! [Comment: Claim]}
      .sink { [unowned self] in self.controllerInput?.reportComment(comment: $0.keys.first!, reason: $0.values.first!) }
      .store(in: &popup.subscriptions)
    popup.setContent(content)
    popup.didDisappearPublisher
      .sink { _ in popup.removeFromSuperview() }
      .store(in: &self.subscriptions)
  }
  
  func updateCommentsAndGetNew(mode: CommentsCollectionView.Mode, excludeList: [Int], updateList: [Int]) {
    controllerInput?.updateCommentsAndGetNew(mode: mode, excludeList: excludeList, updateList: updateList)
  }
  
  func deleteComment(_ comment: Comment) {
    controllerInput?.deleteComment(comment)
  }
  
  func postClaim(comment: Comment, reason: Claim) {
    controllerInput?.postClaim(comment: comment, reason: reason)
  }
  
  func postComment(body: String, replyTo: Comment?, username: String? = nil) {
    controllerInput?.postComment(body: body, replyTo: replyTo, username: username)
  }
  
  func getComments(excludeList: [Int], includeList: [Int]) {
    controllerInput?.getComments(rootComment: item, excludeList: excludeList, includeList: includeList)
  }
}

// MARK: - Model Output
extension CommentsController: CommentsModelOutput {
  func commentReportError() {
    Banners.error(container: &subscriptions)
  }
  
  func getReplyCallback(_ result: Result<Comment?, Error>) {
    switch result {
    case .success(let reply):
      guard let reply = reply else { return }
      
      controllerOutput?.focusOnReply(reply)
    case .failure(let error):
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
      Banners.error(container: &subscriptions)
    }
  }
  
  func commentDeleteError() {
    controllerOutput?.commentDeleteError()
  }
  
  func commentPostCallback(_ result: Result<Comment, Error>) {
    controllerOutput?.commentPostCallback(result)
  }
  
  var survey: Survey? {
    return item.survey
  }
}
