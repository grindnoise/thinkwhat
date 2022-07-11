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
    weak var answerListener: AnswerListener?
    
    // MARK: - Private properties
    public var mode: PollController.Mode = .Write {
        didSet {
            visibleCells.forEach {
                guard let cell = $0 as? ChoiceCell else { return }
                cell.mode = mode
            }
        }
    }
    private weak var callbackDelegate: CallbackObservable?
    private var source: UICollectionViewDiffableDataSource<Section, Answer>!
//    private let listener: ChoiceSectionCell
    
    // MARK: - Initialization
    init(dataItems: [Answer] = [], answerListener: AnswerListener?, callbackDelegate: CallbackObservable) {
//        self.listener = listener
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
    
    // MARK: - Public methods
    public func refresh() {
        source.refresh()
    }

    // MARK: - UI functions
    private func setupUI() {
        delegate = self
//        contentInsetAdjustmentBehavior = .never
//        contentInset = UIEdgeInsets.zero
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
            configuration.headerMode = .firstItemInSection
            configuration.backgroundColor = .clear
            configuration.showsSeparators = false
            //            configuration.contentInsetsReference = .none
            
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
        }
        
        let cellRegistration = UICollectionView.CellRegistration<ChoiceCell, Answer> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            cell.mode = self.mode
            guard cell.item.isNil else { return }
            var configuration = UIBackgroundConfiguration.listPlainCell()
            configuration.backgroundColor = .clear
            cell.backgroundConfiguration = configuration
            cell.item = item
            cell.automaticallyUpdatesBackgroundConfiguration = false
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
//        source.refresh() {
//            self.listener.onImagesHeightChange(self.contentSize.height)
//        }
    }
}

// MARK: - UICollectionViewDelegate
extension ChoiceCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ChoiceCell else { return }
        answerListener?.onChoiceMade(cell.item)
    }
}
