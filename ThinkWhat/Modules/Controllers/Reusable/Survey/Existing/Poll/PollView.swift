//
//  PollView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Agrume
import Combine

class PollView: UIView {
    
    // MARK: - Public properties
    weak var viewInput: (PollViewInput & UIViewController)?
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Logic
    public weak var item: Survey? {
            didSet {
                guard !item.isNil else { return }
                
                collectionView.place(inside: self)
            }
        }
    //UI
    private lazy var collectionView: PollCollectionView = {
            let instance = PollCollectionView(item: item!)
            instance.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: deviceType == .iPhoneSE ? 0 : 60, right: 0.0)
            instance.layer.masksToBounds = false
            instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: instance.contentInset.left, bottom: 100, right: instance.contentInset.right)

    //        //Claim
    //        instance.claimSubject.sink { [unowned self] in
    //            guard let item = $0 else { return }
    //
    //            let banner = Popup()
    //            let claimContent = ClaimPopupContent(parent: banner, surveyReference: self.item?.reference)
    //
    //            claimContent.claimPublisher
    //                .sink { [weak self] in
    //                    guard let self = self else { return }
    //
    //                    self.viewInput?.onCommentClaim(comment: item, reason: $0)
    //                }
    //                .store(in: &self.subscriptions)
    //
    //            banner.present(content: claimContent)
    //            banner.didDisappearPublisher
    //                .sink { [weak self] _ in
    //                    guard let self = self else { return }
    //
    //                    banner.removeFromSuperview()
    //                }
    //                .store(in: &self.subscriptions)
    //
    //        }.store(in: &subscriptions)
    //
    //        //Subscibe for thread disclosure
    //        instance.commentThreadSubject.sink { [weak self] in
    //            guard let self = self,
    //                  let comment = $0
    //            else { return }
    //
    //            self.viewInput?.openCommentThread(comment)
    //        }.store(in: &self.subscriptions)

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
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Private
private extension PollView {
    @MainActor
    func setupUI() {
        backgroundColor = .systemBackground
        
        
    }
    
    func setTasks() {

    }
}

// MARK: - Controller Output
extension PollView: PollControllerOutput {
    func presentView(_ item: Survey) {
        self.item = item
        collectionView.alpha = 0
        collectionView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.collectionView.alpha = 1
            self.collectionView.transform = .identity
        }
    }
    
    func onLoadCallback(_: Result<Bool, Error>) {
        
    }
    
    func onVoteCallback(_: Result<Bool, Error>) {
        
    }
    
    func commentPostCallback(_: Result<Comment, Error>) {
        
    }
    
    func commentDeleteError() {
        
    }
}
