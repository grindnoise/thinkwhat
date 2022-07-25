//
//  TopicSelection.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

//import UIKit
//
//class TopicSelection: UIView {
//
//    // MARK: - Initialization
//
//    init(isModal: Bool, callbackDelegate: CallbackObservable) {
//        super.init(frame: .zero)
//        self.callbackDelegate = callbackDelegate
//        self.isCancelEnabled = !isModal
//        commonInit()
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        commonInit()
//    }
//
//    private func commonInit() {
//        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
//        addSubview(contentView)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//        ])
//        setupUI()
//    }
//
//    private func setupUI() {
//        setText()
//        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
//        collectionView.delegate = self
//        collectionView.dataSource = self
//    }
//
//    private func setText() {
//        let fontSize: CGFloat = title.bounds.height * 0.3
//        let topicTitleString = NSMutableAttributedString()
//        topicTitleString.append(NSAttributedString(string: parent.isNil ? "choose_topic".localized : "\(parent.title)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//        title.attributedText = topicTitleString
//    }
//
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        back.tintColor = parent.isNil ? .darkGray : traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray
//        cancel.tintColor = isCancelEnabled ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray : .secondaryLabel
//        confirm.tintColor = child.isNil ? .darkGray : traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
//    }
//
//    @objc
//    private func handleTap(_ recognizer: UITapGestureRecognizer) {
//        if let v = recognizer.view {
//            if v === back, mode == .Child {
//                mode = .Parent
//            } else if v === confirm, !child.isNil {
//                callbackDelegate?.callbackReceived(child)
//            } else if v === cancel, isCancelEnabled {
//                callbackDelegate?.callbackReceived("exit")
//            }
//        }
//    }
//
//    // MARK: - IB outlets
//    @IBOutlet var contentView: UIView!
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var title: UILabel!
//    @IBOutlet weak var cancel: UIImageView! {
//        didSet {
//            cancel.isUserInteractionEnabled = true
//            cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
//            cancel.tintColor = isCancelEnabled ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray : .secondaryLabel
//        }
//    }
//    @IBOutlet weak var confirm: UIImageView! {
//        didSet {
//            confirm.isUserInteractionEnabled = true
//            confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
//            confirm.tintColor = child.isNil ? .darkGray : traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
//        }
//    }
//    @IBOutlet weak var back: UIImageView! {
//        didSet {
//            back.isUserInteractionEnabled = true
//            back.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
//            back.tintColor = parent.isNil ? .darkGray : traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
//        }
//    }
//
//
//    // MARK: - Properties
//    private var isCancelEnabled = true
//    private var parent: Topic! {
//        didSet {
//            guard !collectionView.isNil, !back.isNil else { return }
//            UIView.animate(withDuration: 0.2) {
//                self.back.tintColor = self.parent.isNil ? .secondaryLabel : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray
//            }
//            collectionView.reloadSections(IndexSet(arrayLiteral: 0))
//        }
//    }
//    private var child: Topic! {
//        didSet {
//            UIView.animate(withDuration: 0.2) {
//                self.confirm.tintColor = !self.child.isNil ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED : .darkGray
//            }
//        }
//    }
//    private let parents = Topics.shared.all.filter({ $0.isParentNode })
//    private var mode: TopicsController.Mode = .Parent {
//        didSet {
//            guard mode != oldValue else { return }
//            if mode == .Parent {
//                child = nil
//                if let indexPath = collectionView.indexPathsForSelectedItems?.first {
//                    collectionView.deselectItem(at: indexPath, animated: true)
//                }
//            }
//            collectionView.visibleCells.forEach {
//                guard let cell = $0 as? CategoryCollectionViewCell else { return }
//                if self.mode == .Child {
//                    cell.selectionMode = true
//                } else {
//                    cell.selectionMode = false
//                }
//            }
//            collectionView.reloadSections(IndexSet(arrayLiteral: 0))
//        }
//    }
//    private let reuseIdentifier = "category"
//    private var needsAnimation = true
//    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
//    private let itemsPerRow: CGFloat = 3
//    private weak var callbackDelegate: CallbackObservable?
//}
//
//extension TopicSelection: UICollectionViewDelegate, UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return mode == .Parent ? parents.count : parent.children.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell {
//            let dataItems = mode == .Parent ? parents : parent.children
//            if let category = dataItems[indexPath.row] as? Topic {
//                cell.childColor = category.tagColor
//                cell.category = category
//            }
//            if self.mode == .Child {
//                cell.selectionMode = true
//            } else {
//                cell.selectionMode = false
//            }
//            cell.setupUI(false)
//            return cell
//        }
//        return UICollectionViewCell()
//    }
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard mode == .Parent else { return }
//        cell.alpha = 0
//        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        UIView.animate(
//            withDuration: 0.2,
//            delay: (Double(arc4random_uniform(6)) * 0.01) * Double(arc4random_uniform(5)),//Double(indexPath.row),
//            options: [.curveEaseInOut],
//            animations: {
//                cell.alpha = 1
//                cell.transform = .identity
//            }) {
//                _ in
//                self.needsAnimation = (self.collectionView.visibleCells.count < (indexPath.row + 1))
//            }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let category = cell.category {
//            if mode == .Parent {
////                currentIndex = indexPath
//                parent = category
//                mode = .Child
////                viewInput?.mode = .Child
//            } else if mode == .Child {
//                child = cell.category
////                viewInput?.mode = .List
//            }
//        }
//    }
//}
//
//
//extension TopicSelection: UICollectionViewDelegateFlowLayout {
//    //1 collectionView(_:layout:sizeForItemAt:) is responsible for telling the layout the size of a given cell
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //2
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = collectionView.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
//        return CGSize(width: widthPerItem, height: widthPerItem * 1.3)
//    }
//
//    //3
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//
//    // 4
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
//}
