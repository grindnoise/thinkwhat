//
//  CommentsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CommentsView: UIView {
    
    // MARK: - Properties
    weak var viewInput: CommentsViewInput?
    
    // MARK: - Destructor
    deinit {
//        observers.forEach { $0.invalidate() }
//        tasks.forEach { $0?.cancel() }
//        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .red
    }
    
    // MARK: - Overriden methods
    override func layoutSubviews() {
        
    }
}

// MARK: - Controller Output
extension CommentsView: CommentsControllerOutput {

}


