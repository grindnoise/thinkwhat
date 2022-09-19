//
//  SurveysView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveysView: UIView {
    
    // MARK: - Public properties
    weak var viewInput: SurveysViewInput? {
        didSet {
            collectionView.topic = viewInput?.topic
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private lazy var collectionView: SurveysCollectionView = {
        let instance = SurveysCollectionView(delegate: self, topic: viewInput?.topic)
        
        return instance
    }()
    
    // MARK: - Deinitialization
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
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
    
    override func layoutSubviews() {
        
    }
}

// MARK: - Controller Output
extension SurveysView: SurveysControllerOutput {
    
    // Implement methods
    
}

private extension SurveysView {
    
    private func setupUI() {
        backgroundColor = .systemGroupedBackground
        collectionView.addEquallyTo(to: self)
    }
}

extension SurveysView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        
    }
}
