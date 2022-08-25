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
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comment>

    enum Section: Int {
        case main
    }

    enum Mode {
        case Root, Tree
    }
    
    enum CommentMode {
        case Root, Reply
    }

    // MARK: - Public properties
    public weak var survey: Survey! {
        didSet {
            reload()
        }
    }
    public weak var rootComment: Comment? {
        didSet {
            guard !rootComment.isNil else { return }
            mode = .Tree
            reload()
        }
    }
    public var dataItems: [Comment] {
        if let rootComment = rootComment, mode == .Tree {
            return [rootComment] + Comments.shared.all.filter { $0.parentId == rootComment.id }
        }
        guard let survey = survey else { return [] }
        return survey.commentsSortedByDate
    }
    public let commentSubject = CurrentValueSubject<String?, Never>(nil)
    public let replySubject = CurrentValueSubject<[Comment: String]?, Never>(nil)
    public let claimSubject = CurrentValueSubject<Comment?, Never>(nil)
    public let commentThreadSubject = CurrentValueSubject<Comment?, Never>(nil)
    public var commentsRequestSubject = CurrentValueSubject<[Comment]?, Never>(nil)
//    public var commentsRequestSubject: CurrentValueSubject<[Comment], Never>!
    //New user comment publisher
    public var lastPostedComment: Comment? {
        didSet {
//            guard let lastPostedComment = lastPostedComment else {
//                return
//            }
//            dataItems.insert(lastPostedComment, at: 0)
            
            //Clean tf on success
            textField.text = ""
//            var snapshot = source.snapshot()
//            if let firstItem = snapshot.itemIdentifiers.first {
//                snapshot.insertItems([lastPostedComment], beforeItem: firstItem)
//            } else {
//                snapshot.appendSections([.main,])
//                snapshot.appendItems([lastPostedComment], toSection: .main)
//            }
//            source.apply(snapshot, animatingDifferences: true)
        }
    }
//    public weak var boundsListener: BoundsListener?

    
    // MARK: - Private properties
    private var mode: Mode
    private var commentMode: CommentMode = .Root
    private weak var replyTo: Comment? {
        didSet {
            commentMode = replyTo.isNil ? .Root : .Reply
        }
    }
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private var source: UICollectionViewDiffableDataSource<Section, Comment>!
    private lazy var textField: AccessoryInputTextField = {
        let instance = AccessoryInputTextField(placeholder: "add_comment".localized, font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)!, delegate: self, minLength: ModelProperties.shared.commentMinLength, maxLength: ModelProperties.shared.commentMinLength)
//        addSubview(instance)
        
        return instance
    }()
    
    
    // MARK: - Initialization
    init(rootComment: Comment?, survey: Survey? = nil) {
        self.survey = survey
        self.rootComment = rootComment
        self.mode = rootComment.isNil ? .Root : .Tree
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
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
        tasks.append( Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.System.HideKeyboard) {
                guard let self = self else { return }
                await MainActor.run {
                    self.textField.resignFirstResponder()
                }
            }
        })
        tasks.append( Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Append) {
                guard let self = self,
                      self.mode == .Root,
                      let instance = notification.object as? Comment,
                      instance.replyToId.isNil,
                      instance.survey == self.survey,
                      var snap = self.source.snapshot() as? Snapshot
                else { return }
                
                if instance.isOwn && abs(instance.createdAt.days(from: Date())) < 1, let firstItem = snap.itemIdentifiers.first as? Comment {
                    snap.insertItems([instance], beforeItem: firstItem)
                } else {
                    snap.appendItems([instance], toSection: .main)
                }
                
                await MainActor.run {
                    self.source.apply(snap, animatingDifferences: true)
                }
            }
        })
        tasks.append( Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.ChildAppend) {
                guard let self = self,
                      self.mode == .Tree,
                      let instance = notification.object as? Comment,
                      instance.parent == self.rootComment,
                      var snap = self.source.snapshot() as? Snapshot
                else { return }
                
                snap.appendItems([instance], toSection: .main)
                
                await MainActor.run {
                    self.source.apply(snap, animatingDifferences: true)
                }
            }
        })
        tasks.append( Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Claim) {
                guard let self = self,
                      let instance = notification.object as? Comment,
                      instance.survey == self.survey,
                      var snap = self.source.snapshot() as? Snapshot,
                      snap.itemIdentifiers.contains(instance)
                else { return }
                
                snap.deleteItems([instance])
                await MainActor.run {
                    self.source.apply(snap, animatingDifferences: true)
                }
            }
        })
        tasks.append( Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Ban) {
                guard let self = self,
                      let instance = notification.object as? Comment,
                      instance.survey == self.survey,
                      var snap = self.source.snapshot() as? Snapshot,
                      snap.itemIdentifiers.contains(instance)
                else { return }
                
                snap.deleteItems([instance])
                await MainActor.run {
                    self.source.apply(snap, animatingDifferences: true)
                }
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
            if self.mode == .Root {
                configuration.headerMode = .supplementary
            }

            let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sectionLayout.contentInsets.leading, bottom: 0, trailing: sectionLayout.contentInsets.trailing)
            sectionLayout.interGroupSpacing = 10
            return sectionLayout
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<CommentHeaderCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self = self else { return }

            supplementaryView.callback = { [weak self] in
                guard let self = self else { return }

                self.textField.staticText = ""
                self.replyTo = nil
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
            if self.mode == .Tree {
                cell.mode = indexPath.row == 0 ? .Root : .Tree
            } else {
                cell.mode = .Root
            }
                
            
            //Reply disclosure
            cell.replySubject.sink { [weak self] in
                guard let self = self,
                      let item = $0
                else { return }
                
                if let userprofile = item.userprofile {
                    if !userprofile.firstNameSingleWord.isEmpty {
                        self.textField.staticText = "@" + userprofile.firstNameSingleWord
                    } else if !userprofile.lastNameSingleWord.isEmpty {
                        self.textField.staticText = "@" + userprofile.lastNameSingleWord
                    }
                }
                self.replyTo = item
                self.textField.becomeFirstResponder()
                Fade.shared.present()
            }.store(in: &self.subscriptions)
            
            //Thread disclosure
            cell.commentThreadSubject.sink { [weak self] in
                guard let self = self,
                      let item = $0
                else { return }
                
                self.commentThreadSubject.send(item)
            }.store(in: &self.subscriptions)
            
            //Claim tap
            cell.claimSubject.sink { [weak self] in
                guard let self = self,
                      let item = $0
                else { return }
                
                self.claimSubject.send(item)
            }.store(in: &self.subscriptions)

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
        
        reload(animatingDifferences: false)
    }

    private func reload(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Comment>()
        snapshot.appendSections([.main,])
        snapshot.appendItems(dataItems, toSection: .main)
        source.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegate
extension CommentsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CommentCell else { return }
        
        if cell.item.replies != 0 {
            commentThreadSubject.send(cell.item)
        } else if !cell.item.isOwn {
            Fade.shared.present()
            if let userprofile = cell.item.userprofile {
                if !userprofile.firstNameSingleWord.isEmpty {
                    textField.staticText = "@" + userprofile.firstNameSingleWord
                } else if !userprofile.lastNameSingleWord.isEmpty {
                    textField.staticText = "@" + userprofile.lastNameSingleWord
                }
            }
            replyTo = cell.item
            textField.becomeFirstResponder()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        
        if dataItems.count < 10 {
            commentsRequestSubject.send(dataItems)
        } else if let biggestRow = collectionView.indexPathsForVisibleItems.sorted(by: { $1.row < $0.row }).first?.row, indexPath.row == biggestRow + 1 && indexPath.row == dataItems.count - 1 {
            commentsRequestSubject.send(dataItems)
        }
    }
}

// MARK: - UITextFieldDelegate
extension CommentsCollectionView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

}

// MARK: - AccessoryInputTextFieldDelegate
extension CommentsCollectionView: AccessoryInputTextFieldDelegate {
    func onSendEvent(_ string: String) {
        
        textField.resignFirstResponder()
        Fade.shared.dismiss()
        guard !string.isEmpty else { return }
        guard replyTo.isNil else {
            guard let item = replyTo,
                  let trimmed = string.replacingOccurrences(of: textField.staticText + " ", with: "") as? String
            else { return }
            replySubject.send([item: trimmed])
            return
        }
        commentSubject.send(string)
//        commentSubject.send(completion: .finished)
    }
}

// MARK: - BannerObservable
extension CommentsCollectionView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}
