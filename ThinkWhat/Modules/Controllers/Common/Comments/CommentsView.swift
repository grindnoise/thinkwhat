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
        let instance = CommentsCollectionView(rootComment: rootComment, survey: rootComment.survey)
        
        instance.claimSubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                  let string = $0
            else { return }
            
        }.store(in: &subscriptions)
        
        instance.commentSubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                  let string = $0
            else { return }
            
            
        }.store(in: &subscriptions)
        
        instance.replySubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                  let dict = $0,
                  let replyObject = dict.keys.first,
                  let body = dict.values.first
            else { return }
            
            self.viewInput?.postComment(body, replyTo: replyObject)
            
        }.store(in: &subscriptions)
        
        instance.commentsRequestSubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                  let comments = $0
            else { return }
            
            self.viewInput?.requestComments(exclude: comments)
        }.store(in: &subscriptions)
        
        instance.commentThreadSubject.sink { [weak self] in
            guard let self = self,
                  let value = $0
            else { return }
            
            
        }.store(in: &subscriptions)
        
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
    func commentPostFailure() {
        showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: ImageSigns.exclamationMark)
    }
}

extension CommentsView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let banner = sender as? Popup {
            banner.removeFromSuperview()
        }
    }
}
