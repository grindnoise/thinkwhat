//
//  TopicsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopicsView: UIView {
    
    enum Mode {
        case Parent, Child, List
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setupUI()
    }

    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: TopicsViewInput?
    private var isSetupCompleted = false
    private var shadowPath: CGPath!
    private let reuseIdentifier = "category"
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    private var needsAnimation = true
    private let parents = Topics.shared.all.filter({ $0.isParentNode })
    private var parent: Topic!
    private var child: Topic!
    private var list: (UIView & SurveyDataSource)! {
        didSet {
            guard !list.isNil else { return }
            list.addEquallyTo(to: card)
            list.alpha = 0
        }
    }
    var currentIndex: IndexPath = IndexPath(row: 0, section: 0)
    var mode: TopicsController.Mode {
        return viewInput?.mode ?? .Parent
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var card: UIView! {
        didSet {
            card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var cardShadow: UIView!
    @IBOutlet weak var icon: Icon! {
        didSet {
            icon.alpha = 0
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
//            collectionView.delegate = self
//            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelConstraint: NSLayoutConstraint!
//    @IBOutlet weak var back: UIImageView! {
//        didSet {
//            back.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .secondaryLabel
//            back.alpha = 0
//            back.isUserInteractionEnabled = true
//            back.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped)))
//        }
//    }
}

// MARK: - Controller Output
extension TopicsView: TopicsControllerOutput {
    func onWillAppear() {
        setText()
    }
    
    func onDidLayout() {
        guard !isSetupCompleted else { return }
        isSetupCompleted = true
        ///Add shadow
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        alpha = 0
        cardShadow.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        shadowPath = UIBezierPath(roundedRect: cardShadow.bounds, cornerRadius: cardShadow.frame.width * 0.05).cgPath
        cardShadow.layer.shadowPath = shadowPath
        cardShadow.layer.shadowRadius = 7
        cardShadow.layer.shadowOffset = .zero
        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.alpha = 1
            self.transform = .identity
        } completion: { _ in
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
    }
    
    func onChildMode() {
        guard let currentCell = collectionView.cellForItem(at: currentIndex) as? CategoryCollectionViewCell else { return }
        
        icon.backgroundColor = currentCell.icon.backgroundColor
        icon.category = currentCell.icon.category
        
        let temp = Icon(frame: CGRect(origin: currentCell.icon.superview!.convert(currentCell.icon.frame.origin, to: card),
                                                    size: currentCell.icon.frame.size))
        temp.iconColor = currentCell.icon.iconColor
        temp.backgroundColor = currentCell.icon.backgroundColor
        temp.category = currentCell.icon.category
        card.addSubview(temp)
        currentCell.icon.alpha = 0
        
        let destinationLayer = icon.icon as! CAShapeLayer
        let destinationPath = destinationLayer.path
        let anim = Animations.get(property: .Path,
                                  fromValue: (currentCell.icon.icon as! CAShapeLayer).path as Any,
                                      toValue: destinationPath as Any,
                                      duration: 0.28,
                                      delay: 0,
                                      repeatCount: 0,
                                      autoreverses: false,
                                      timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                      delegate: nil,
                                      isRemovedOnCompletion: false)
        temp.icon.add(anim, forKey: nil)
        (temp.icon as! CAShapeLayer).path = destinationPath
            
        let destinationOrigin = icon.superview!.convert(icon.frame.origin, to: card)
        let destinationSize = icon.frame.size
        UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.label.text = currentCell.category.title.uppercased()
        }) { _ in }

        collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.label.setNeedsLayout()
            self.labelConstraint.constant += self.icon.frame.width
            self.label.layoutIfNeeded()
            temp.frame.origin = destinationOrigin
            temp.frame.size = destinationSize
//            self.back.alpha = 1
        } completion: { _ in
            temp.removeFromSuperview()
            self.icon.alpha = 1
            currentCell.icon.alpha = 1
        }
    }
    
    func onParentMode() {
        collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        guard let currentCell = collectionView.cellForItem(at: currentIndex) as? CategoryCollectionViewCell else { return }
        
        let temp = Icon(frame: CGRect(origin: icon.superview!.convert(icon.frame.origin, to: card),
                                                    size: icon.frame.size))
        temp.iconColor = currentCell.icon.iconColor
        temp.backgroundColor = currentCell.icon.backgroundColor
        temp.category = currentCell.icon.category
        card.addSubview(temp)
        icon.alpha = 0
        currentCell.icon.alpha = 0
        
        let destinationLayer = currentCell.icon.icon as! CAShapeLayer
        let destinationPath = destinationLayer.path
        let anim = Animations.get(property: .Path,
                                      fromValue: (icon.icon as! CAShapeLayer).path as Any,
                                      toValue: destinationPath as Any,
                                      duration: 0.28,
                                      delay: 0,
                                      repeatCount: 0,
                                      autoreverses: false,
                                      timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                      delegate: nil,
                                      isRemovedOnCompletion: false)
        temp.icon.add(anim, forKey: nil)
        (temp.icon as! CAShapeLayer).path = destinationPath
            
        let destinationOrigin = currentCell.icon.superview!.convert(currentCell.icon.frame.origin, to: card)
        let destinationSize = currentCell.icon.frame.size
        
        UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.setText()
//            self.back.alpha = 0
        }) { _ in }

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.label.setNeedsLayout()
            self.labelConstraint.constant -= self.icon.frame.width
            self.label.layoutIfNeeded()
            temp.frame.origin = destinationOrigin
            temp.frame.size = destinationSize
        } completion: { _ in
            temp.removeFromSuperview()
            currentCell.icon.alpha = 1
            
        }
    }
    
    func onListMode() {
        if list.isNil {
            if #available(iOS 14, *)  {
                list = SurveysCollection(delegate: self, topic: child)
            } else {
                list = SurveyTable(delegate: self, category: .Topic)//topic: child), topic: child)
            }
        }

        list.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.collectionView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.collectionView.alpha = 0
            self.icon.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.icon.alpha = 0
            self.label.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.label.alpha = 0
            self.list.alpha = 1
            self.list.transform = .identity
        } completion: { _ in
//            self.list.reload()
        }
    }
    
    func onListToChildMode() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.collectionView.alpha = 1
            self.collectionView.transform = .identity
            self.icon.alpha = 1
            self.icon.transform = .identity
            self.label.alpha = 1
            self.label.transform = .identity
            self.list.alpha = 0
            self.list.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.list.removeFromSuperview()
            self.list = nil
        }
    }
    
    func onError() {
        showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, imageContent: ImageSigns.exclamationMark, shouldDismissAfter: 1)
    }
}

// MARK: - UI Setup
extension TopicsView {
    private func setupUI() {
        card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        card.layer.masksToBounds = true
        card.layer.cornerRadius = card.frame.width * 0.05
        alpha = 0
        collectionView?.register(UINib(nibName: "CategoryCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//        back.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .secondaryLabel
    }
    
    private func setText() {
//        let paragraph = NSMutableParagraphStyle()
//        if #available(iOS 15.0, *) {
//            paragraph.usesDefaultHyphenation = true
//        } else {
//            paragraph.hyphenationFactor = 1
//        }
//        paragraph.alignment = .center
//        let string = text
//        let attributedText = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
//        attributedText.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: string.fullRange())
//        label.attributedText = attributedText
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "\(Topics.shared.active) " + "publications".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: label.frame.height * 0.2), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        label.textAlignment = .center
        label.attributedText = attributedText
    }
}

extension TopicsView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let instance = sender as? SurveyReference {
            viewInput?.onSurveyTapped(instance)
        } else if #available(iOS 14, *) {
            if sender is SurveysCollection || sender is SurveyTable {
                viewInput?.onDataSourceRequest(child)
            }
        } else {
            if sender is SurveyTable {
                viewInput?.onDataSourceRequest(child)
            }
        }
    }
}

extension TopicsView: BannerObservable {
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

extension TopicsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mode == .Parent ? parents.count : parent.children.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell {
            let dataItems = mode == .Parent ? parents : parent.children
            if let category = dataItems[indexPath.row] as? Topic {
                cell.childColor = category.tagColor
                cell.category = category
            }
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard mode == .Parent else { return }
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(
            withDuration: 0.2,
            delay: (Double(arc4random_uniform(6)) * 0.01) * Double(arc4random_uniform(5)),//Double(indexPath.row),
            options: [.curveEaseInOut],
            animations: {
                cell.alpha = 1
                cell.transform = .identity
            }) {
                _ in
                self.needsAnimation = (self.collectionView.visibleCells.count < (indexPath.row + 1))
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let category = cell.category {
            if mode == .Parent {
                currentIndex = indexPath
                parent = cell.category
                viewInput?.mode = .Child
            } else if mode == .Child {
                child = cell.category
                viewInput?.mode = .List
            }
        }
    }
}


extension TopicsView: UICollectionViewDelegateFlowLayout {
    //1 collectionView(_:layout:sizeForItemAt:) is responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem * 1.3)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


