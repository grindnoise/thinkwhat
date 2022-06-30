//
//  PollCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollCollectionView: UICollectionView {
    
    enum Section {
        case title, description
    }
    
    // MARK: - Private properties
    private let poll: Survey
    private weak var callbackDelegate: CallbackObservable?
    
    // MARK: - Initialization
    init(poll: Survey, callbackDelegate: CallbackObservable) {
        self.poll = poll
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.callbackDelegate = callbackDelegate
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI functions
    private func setupUI() {
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            layoutConfig.headerMode = .firstItemInSection
            layoutConfig.backgroundColor = .clear
            layoutConfig.showsSeparators = false
            
            return NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
        }
        
        let titleCellRegistration = UICollectionView.CellRegistration<TopicSelectionModernCell, TopicItem> { [weak self ] cell, indexPath, item in
            guard let self = self else { return }
            cell.item = item
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            cell.backgroundConfiguration = backgroundConfig
        }
    }
}
