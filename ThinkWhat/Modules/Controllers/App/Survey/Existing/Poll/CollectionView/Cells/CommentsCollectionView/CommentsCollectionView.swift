//
//  CommentsCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CommentsCollectionView: UICollectionView {

    enum Section: Int {
        case main
    }
    
    enum mode {
        case Parent, Full
    }
    
    // MARK: - Public properties
    public var dataItems: [Comment] {
        didSet {
            reload()
        }
    }
    public weak var boundsListener: BoundsListener?
    
    // MARK: - Private properties
    private weak var callbackDelegate: CallbackObservable?
    private var source: UICollectionViewDiffableDataSource<Section, Answer>!
//    private let listener: ChoiceSectionCell
    
    // MARK: - Initialization
    init(dataItems: [Answer] = [], callbackDelegate: CallbackObservable) {
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
            var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
//            configuration.headerMode = .firstItemInSection
            configuration.backgroundColor = .clear
            configuration.showsSeparators = false
            
            let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sectionLayout.contentInsets.leading, bottom: 0, trailing: sectionLayout.contentInsets.trailing)
            sectionLayout.interGroupSpacing = 20
            return sectionLayout
        }
        
        let cellRegistration = UICollectionView.CellRegistration<CommentCell, Answer> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            var configuration = UIBackgroundConfiguration.listPlainCell()
            configuration.backgroundColor = .clear
            cell.backgroundConfiguration = configuration
            cell.item = item
            cell.automaticallyUpdatesBackgroundConfiguration = false
            //            }
            cell.mode = self.mode
            //            guard self.shouldChangeColor else { return }
            cell.color = Colors.tags()[indexPath.row]
            cell.index = indexPath.row + 1
            
            self.modeSubject.sink {
#if DEBUG
                print("receiveCompletion: \($0)")
#endif
            } receiveValue: { [weak self] in
                guard let self = self else { return }
                cell.mode = $0
                self.colorSubject.send(completion: .finished)
            }.store(in: &self.subscriptions)

            
//            cell.colorSubject.sink {
//#if DEBUG
//                print("receiveCompletion: \($0)")
//#endif
//            } receiveValue: { [weak self] in
//                guard let self = self,
//                      let color = $0
//                else { return }
//                self.colorSubject.send(color)
//            }.store(in: &self.subscriptions)
        }
        
        source = UICollectionViewDiffableDataSource<Section, Answer>(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
        }
        
    }
    
    private func reload() {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Answer>()
//        snapshot.appendSections([.main,])
//        snapshot.appendItems(dataItems, toSection: .main)
//        source.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate
extension CommentsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ChoiceCell else { return }
//        answerListener?.onChoiceMade(cell.item)
    }
}

