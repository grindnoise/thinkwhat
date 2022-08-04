//
//  ChoiceCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ChoiceCollectionView: UICollectionView {

    // MARK: - Enums
    enum Section: Int {
        case main
    }
    
    // MARK: - Public properties
    public var dataItems: [Answer] {
        didSet {
            reload(sorted: false, animatingDifferences: false, shouldChangeColor: mode == .ReadOnly)
//            reload(sorted: mode == .ReadOnly, animatingDifferences: true, shouldChangeColor: mode == .ReadOnly)
        }
    }
    public weak var answerListener: AnswerListener?
    public weak var boundsListener: BoundsListener?
    
    // MARK: - Private properties
    public var mode: PollController.Mode = .Write {
        didSet {
            allowsMultipleSelection = mode == .ReadOnly ? true : false
                            visibleCells.enumerated().forEach {
                                guard let cell = $1 as? ChoiceCell else { return }
                                cell.color = Colors.tags()[$0]
                                cell.mode = mode
                            }
            if oldValue != mode, mode == .ReadOnly {
//                reload(animatingDifferences: true, shouldChangeColor: true)
//                visibleCells.enumerated().forEach {
//                    guard let cell = $1 as? ChoiceCell else { return }
//                    cell.color = Colors.tags()[$0]
//                    cell.mode = mode
//                }
//                var snapshot = NSDiffableDataSourceSnapshot<Section, Answer>()
//                snapshot.appendSections([.main,])
//                snapshot.appendItems(dataItems, toSection: .main)
//                source.apply(snapshot, animatingDifferences: true)
//                var snap = source.snapshot()
//                snap.reloadSections([.main])
                source.refresh()
            }
        }
    }
    private weak var callbackDelegate: CallbackObservable?
    private var source: UICollectionViewDiffableDataSource<Section, Answer>!
    private var shouldChangeColor = false

    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    init(dataItems: [Answer] = [], answerListener: AnswerListener?, callbackDelegate: CallbackObservable) {
        self.dataItems = dataItems
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.callbackDelegate = callbackDelegate
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func setupUI() {
        delegate = self
        allowsMultipleSelection = mode == .ReadOnly ? true : false

        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
//            configuration.headerMode = .firstItemInSection
            configuration.backgroundColor = .clear
            configuration.showsSeparators = false
            
            let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sectionLayout.contentInsets.leading, bottom: 0, trailing: sectionLayout.contentInsets.trailing)
            sectionLayout.interGroupSpacing = 20
            return sectionLayout
        }
        
        let cellRegistration = UICollectionView.CellRegistration<ChoiceCell, Answer> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            cell.callbackDelegate = self
//            if cell.item.isNil {
                var configuration = UIBackgroundConfiguration.listPlainCell()
                configuration.backgroundColor = .clear
                cell.backgroundConfiguration = configuration
                cell.item = item
                cell.automaticallyUpdatesBackgroundConfiguration = false
//            }
            cell.mode = self.mode
            guard self.shouldChangeColor else { return }
            cell.color = Colors.tags()[indexPath.row]
        }
        
        source = UICollectionViewDiffableDataSource<Section, Answer>(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
        }
        
        reload(animatingDifferences: false)
    }
    
//    private func reload() {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Answer>()
//        snapshot.appendSections([.main,])
//        snapshot.appendItems(dataItems, toSection: .main)
//        source.apply(snapshot, animatingDifferences: false)
//    }
    
    // MARK: - Public methods
    public func refresh() {
        source.refresh()
    }
    
    public func reload(sorted: Bool = false, animatingDifferences: Bool = true, shouldChangeColor: Bool = false) {
        guard !dataItems.isEmpty else { return }
        self.shouldChangeColor = shouldChangeColor
        
        visibleCells.enumerated().forEach {
            guard let cell = $1 as? ChoiceCell else { return }
            cell.color = Colors.tags()[$0]
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Answer>()
        snapshot.appendSections([.main,])
        snapshot.appendItems(sorted ? dataItems.sorted{ $0.totalVotes > $1.totalVotes } : dataItems, toSection: .main)
        source.apply(snapshot, animatingDifferences: animatingDifferences)
//        if animatingDifferences { source.refresh() }
    }
}

// MARK: - UICollectionViewDelegate
extension ChoiceCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ChoiceCell else { return }
        
        answerListener?.onChoiceMade(cell.item)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let _ = cellForItem(at: indexPath) as? ChoiceCell {
            if mode == .ReadOnly {
                selectItem(at: indexPath, animated: true, scrollPosition: [])
                source.refresh {
                    self.boundsListener?.onBoundsChanged(self.frame)
//                    self.boundsListener?.onBoundsChanged(CGRect(origin: .zero, size: self.contentSize))
                }
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        collectionView.deselectItem(at: indexPath, animated: true)
        if mode == .ReadOnly {
            source.refresh {
//                self.boundsListener?.onBoundsChanged(CGRect(origin: .zero, size: self.contentSize))
                //                    self.boundsListener?.onBoundsChanged(CGRect(origin: .zero, size: self.contentSize))
            }
        }
        return false
    }
    
    //    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    //        guard mode == .Write else { return false }
    //        return true
    //    }
}

// MARK: - CallbackObservable
extension ChoiceCollectionView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        callbackDelegate?.callbackReceived(sender)
    }
}
