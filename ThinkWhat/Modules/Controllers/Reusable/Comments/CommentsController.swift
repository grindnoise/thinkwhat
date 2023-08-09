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
  
  // MARK: - MVC
  var controllerOutput: CommentsControllerOutput?
  var controllerInput: CommentsControllerInput?
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let item: Comment
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
  init(_ comment: Comment) {
    self.item = comment
    
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
    
    navigationController?.navigationBar.prefersLargeTitles = false
    //    title = "replies".localized + ": \(item.replies)"
    navigationItem.titleView = titleView
    setTasks()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setBarColor()
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark, animated: true)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark, animated: true)
  }
}
  // MARK: - Private extension
private extension CommentsController {
  func setTasks() {
    item.repliesPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in self.titleView.text = "replies".localized.uppercased() + ": \($0)" }
      .store(in: &subscriptions)
    //        tasks.append(Task { [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.ChildrenCountChange) {
    //                guard let self = self,
    //                      let instance = notification.object as? Comment,
    //                      instance == self.item
    //                else { return }
    //
    //                await MainActor.run {
    //                    self.title = "replies".localized + " (\(instance.replies))"
    //                }
    //            }
    //        })
  }
}

// MARK: - View Input
extension CommentsController: CommentsViewInput {
  func deleteComment(_ comment: Comment) {
    controllerInput?.deleteComment(comment)
  }
  
  func postClaim(comment: Comment, reason: Claim) {
    controllerInput?.postClaim(comment: comment, reason: reason)
  }
  
  func postComment(body: String, replyTo: Comment?, username: String? = nil) {
    controllerInput?.postComment(body: body, replyTo: replyTo, username: username)
  }
  
  func requestComments(exclude: [Comment]) {
    controllerInput?.requestComments(rootComment: item, exclude: exclude)
  }
}

// MARK: - Model Output
extension CommentsController: CommentsModelOutput {
  func commentDeleteError() {
    controllerOutput?.commentDeleteError()
  }
  
  func commentPostFailure() {
    controllerOutput?.commentPostFailure()
  }
  
  var survey: Survey? {
    return item.survey
  }
}
