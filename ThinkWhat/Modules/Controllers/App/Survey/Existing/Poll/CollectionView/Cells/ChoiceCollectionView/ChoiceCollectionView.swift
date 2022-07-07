//
//  ChoiceCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ChoiceCollectionView: UICollectionView {

    enum Section: Int {
        case main
    }
    
    // MARK: - Public properties
    public var dataItems: [Answer] {
        didSet {
            reload()
        }
    }
    
    // MARK: - Private properties
    private weak var callbackDelegate: CallbackObservable?
    private var source: UICollectionViewDiffableDataSource<Section, Answer>!
    private let listener: ChoiceSectionCell
    
    // MARK: - Initialization
    init(dataItems: [Answer] = [], listener: ChoiceSectionCell, callbackDelegate: CallbackObservable) {
        self.listener = listener
        self.dataItems = dataItems
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.callbackDelegate = callbackDelegate
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(String(describing: type(of: self))).\(#function)")
    }

    // MARK: - UI functions
    private func setupUI() {
        delegate = self
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            layoutConfig.headerMode = .firstItemInSection
            layoutConfig.backgroundColor = .clear
            layoutConfig.showsSeparators = false
            
            return NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
        }
        
        let cellRegistration = UICollectionView.CellRegistration<ChoiceCell, Answer> { cell, indexPath, item in
            guard cell.item.isNil else { return }
            cell.item = item
        }
        
        source = UICollectionViewDiffableDataSource<Section, Answer>(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
        }
        reload()
    }
    
    private func reload() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Answer>()
        snapshot.appendSections([.main,])
        snapshot.appendItems(dataItems, toSection: .main)
        source.apply(snapshot, animatingDifferences: false)
        source.refresh() {
            self.listener.onImagesHeightChange(self.contentSize.height)
        }
    }
}

extension ChoiceCollectionView: UICollectionViewDelegate {
    
}
