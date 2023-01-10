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
    weak var viewInput: CommentsViewInput?
    public var rootComment: Comment
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private lazy var collectionView: CommentsCollectionView = {
        let instance = CommentsCollectionView(rootComment: rootComment,
                                              survey: rootComment.survey)
        
        instance.claimPublisher.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                  let surveyReference = $0.survey?.reference
            else { return }
            
            let comment = $0
            let banner = Popup(heightScaleFactor: 0.7)
            banner.accessibilityIdentifier = "claim"
            let claimContent = ClaimPopupContent(parent: banner, surveyReference: surveyReference)
            
            claimContent.claimPublisher
                .sink { [weak self] in
                    guard let self = self else { return }
                    
                    self.viewInput?.postClaim(comment: comment, reason: $0)
                }
                .store(in: &self.subscriptions)
            
            banner.present(content: claimContent)
            
            banner.didDisappearPublisher
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    banner.removeFromSuperview()
                }
                .store(in: &self.subscriptions)
            
        }.store(in: &subscriptions)
        
//        instance.commentSubject.sink { [weak self] in
//            guard let self = self,
//                  let string = $0
//            else { return }
//
//
//        }.store(in: &subscriptions)
        
        instance.replyPublisher.sink { [weak self] in
            guard let self = self,
                  let replyObject = $0.keys.first,
                  let body = $0.values.first
            else { return }
            
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
        
        instance.paginationPublisher.sink { [weak self] in
            guard let self = self else { return }
            
            self.viewInput?.requestComments(exclude: $0)
        }.store(in: &subscriptions)
        
//        instance.threadPublisher.sink { [weak self] in
//            guard let self = self else { return }
//
////          self.viewInput?.
//        }.store(in: &subscriptions)
        
        //Delete comment
        instance.deletePublisher.sink { [weak self] in
            guard let self = self else { return }
            
            self.viewInput?.deleteComment($0)
        }.store(in: &self.subscriptions)
        
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
        setupUI()
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .systemBackground
        collectionView.addEquallyTo(to: self)
    }
    
    // MARK: - Overriden methods
    override func layoutSubviews() {
        
    }
}

// MARK: - Controller Output
extension CommentsView: CommentsControllerOutput {
    func commentDeleteError() {
//        showBanner(bannerDelegate: self, text: "added_to_watch_list".localized, content: UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill")), color: UIColor.white, textColor: .white, dismissAfter: 0.5, backgroundColor: UIColor.systemIndigo.withAlphaComponent(1))
    }
    
    func commentPostFailure() {
//        showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: ImageSigns.exclamationMark)
    }
}

// MARK: - CallbackObservable
extension CommentsView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        
    }
}
