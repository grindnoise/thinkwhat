//
//  CommentsCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CommentsCollectionView: UICollectionView {

    enum Section: Int {
        case main
    }

    enum Mode {
        case Root, Reply
    }

    // MARK: - Public properties
    public var dataItems: [Comment] {
        didSet {
            reload()
        }
    }
    public let commentSubject = CurrentValueSubject<String?, Never>(nil)
//    public weak var boundsListener: BoundsListener?

    
    // MARK: - Private properties
    private var mode: Mode
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private weak var callbackDelegate: CallbackObservable?
    private var source: UICollectionViewDiffableDataSource<Section, Comment>!
    private lazy var textField: AccessoryInputTextField = {
        let instance = AccessoryInputTextField(placeholder: "add_comment".localized, font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)!, delegate: self)
//        addSubview(instance)
        
        return instance
    }()
    
    // MARK: - Initialization
    init(dataItems: [Comment] = [], callbackDelegate: CallbackObservable, mode: CommentsCollectionView.Mode) {
        self.mode = mode
        self.dataItems = dataItems
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.callbackDelegate = callbackDelegate
        setupUI()
        setTasks()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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




    // MARK: - UI functions
    private func setTasks() {
        tasks.append( Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.System.HideKeyboard) {
                guard let self = self else { return }
                self.textField.resignFirstResponder()
                Fade.shared.dismiss()
            }
        })
    }
    
    private func setupUI() {
        delegate = self
        addSubview(textField)
        collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
//            configuration.headerMode = .firstItemInSection
            configuration.backgroundColor = .clear
            configuration.showsSeparators = false
            configuration.headerMode = .supplementary

            let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sectionLayout.contentInsets.leading, bottom: 0, trailing: sectionLayout.contentInsets.trailing)
            sectionLayout.interGroupSpacing = 10
            return sectionLayout
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<CommentHeaderCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self = self else { return }

            supplementaryView.callback = { [weak self] in
                guard let self = self else { return }

                self.textField.becomeFirstResponder()
                Fade.shared.present()
            }
        }

        let rootCellRegistration = UICollectionView.CellRegistration<CommentCell, Comment> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            var configuration = UIBackgroundConfiguration.listPlainCell()
            configuration.backgroundColor = .clear
            cell.backgroundConfiguration = configuration
            cell.item = item
            cell.automaticallyUpdatesBackgroundConfiguration = false
            cell.mode = .Root

//            self.modeSubject.sink {
//#if DEBUG
//                print("receiveCompletion: \($0)")
//#endif
//            } receiveValue: { [weak self] in
//                guard let self = self else { return }
//                cell.mode = $0
//                self.colorSubject.send(completion: .finished)
//            }.store(in: &self.subscriptions)
        }
        
        source = UICollectionViewDiffableDataSource<Section, Comment>(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: rootCellRegistration,
                                                                for: indexPath,
                                                                item: identifier)
        }
        
        source.supplementaryViewProvider = { [weak self] (supplementaryView, elementKind, indexPath) in
            guard let self = self else { return UICollectionReusableView() }
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                return self.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
            }
            
            return UICollectionReusableView()
        }
        
        reload()
    }

    private func reload() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Comment>()
        snapshot.appendSections([.main,])
        snapshot.appendItems(dataItems, toSection: .main)
        source.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate
extension CommentsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CommentCell {
            //        answerListener?.onChoiceMade(cell.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - UITextFieldDelegate
extension CommentsCollectionView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

}

extension CommentsCollectionView: AccessoryInputTextFieldDelegate {
    func onSendEvent(_ string: String) {
        textField.resignFirstResponder()
        Fade.shared.dismiss()
        guard !string.isEmpty else { return }
        commentSubject.send(string)
//        commentSubject.send(completion: .finished)
    }
}
