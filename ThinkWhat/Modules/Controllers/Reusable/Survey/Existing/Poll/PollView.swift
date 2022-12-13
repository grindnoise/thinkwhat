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
    //UI
    private var isLoadingData = false
    private var loadingIndicator: LoadingIndicator? {
        didSet {
//            loadingIndicator?.color = surveyReference.topic.tagColor
        }
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
    func onLoadCallback() {
        
    }
    
    func onVoteCallback(_: Result<Bool, Error>) {
        
    }
    
    func commentPostCallback(_: Result<Comment, Error>) {
        
    }
    
    func commentDeleteError() {
        
    }
}
