//
//  SurveyLoadingCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveyLoadingCell: UICollectionViewCell {
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private lazy var loadingIndicator: Icon = {
        let instance = Icon(category: Icon.Category.Logo)
        instance.iconColor = Colors.Logo.Flame.rawValue
        instance.isRounded = false
        instance.clipsToBounds = false
        instance.scaleMultiplicator = 1.65
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.heightAnchor.constraint(equalToConstant: 50).isActive = true

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
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension SurveyLoadingCell {
    func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        loadingIndicator.placeInCenter(of: contentView)
    }
}
