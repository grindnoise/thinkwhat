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
    private let item: Comment
    
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
        title = "replies".localized + " (\(item.replies))"
        setTasks()
    }
    
    // MARK: - Private methods
    private func setTasks() {
        tasks.append(Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.ChildrenCountChange) {
                guard let self = self,
                      let instance = notification.object as? Comment,
                      instance == self.item
                else { return }
                
                title = "replies".localized + " (\(item.replies))"
            }
        })
    }
}

// MARK: - View Input
extension CommentsController: CommentsViewInput {
    func postClaim(comment: Comment, reason: Claim) {
        controllerInput?.postClaim(comment: comment, reason: reason)
    }
    
    func postComment(_ body: String, replyTo: Comment?) {
        controllerInput?.postComment(body, replyTo: replyTo)
    }
    
    func requestComments(exclude: [Comment]) {
        controllerInput?.requestComments(rootComment: item, exclude: exclude)
    }
}

// MARK: - Model Output
extension CommentsController: CommentsModelOutput {
    func commentPostFailure() {
        controllerOutput?.commentPostFailure()
    }
    
    var survey: Survey? {
        return item.survey
    }
}
