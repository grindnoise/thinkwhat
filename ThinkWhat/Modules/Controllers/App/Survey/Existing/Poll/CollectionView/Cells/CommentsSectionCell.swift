//
//  CommentsSectionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CommentsSectionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    override var isSelected: Bool {
        didSet {
            guard let item = item,
                  item.isCommentingAllowed
            else { return }
            updateAppearance()
        }
    }
    //    public weak var boundsListener: BoundsListener? {
//        didSet {
//            collectionView.boundsListener = boundsListener
//        }
//    }
    
    var item: Survey! {
        didSet {
            guard !item.isNil else { return }
            collectionView.survey = item
            disclosureIndicator.alpha = item.isCommentingAllowed ? 1 : 0
//            if item.reference.isComplete || item.reference.isOwn {
//                openConstraint.isActive = true
//            }
            if item.isCommentingAllowed {
                
                disclosureLabel.text = "comments".localized.uppercased() + " (\(String(describing: item.commentsTotal)))"
//                collectionView.survey = item
//                collectionView.dataItems = item.commentsSortedByDate
            } else {
                disclosureLabel.text = "comments_disabled".localized.uppercased()
                closedConstraint.isActive = true
                openConstraint.isActive = false
            }
            let constraint = collectionView.heightAnchor.constraint(equalToConstant: 1)
            constraint.priority = .defaultHigh
            constraint.identifier = "height"
            constraint.isActive = true
            
            if let labelConstraint = disclosureLabel.getConstraint(identifier: "width") {
                labelConstraint.constant = disclosureLabel.text!.width(withConstrainedHeight: disclosureLabel.bounds.height, font: disclosureLabel.font)
            }
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    public let commentSubject = CurrentValueSubject<String?, Never>(nil)
    public let replySubject = CurrentValueSubject<[Comment: String]?, Never>(nil)
    public let claimSubject = CurrentValueSubject<Comment?, Never>(nil)
    public let commentThreadSubject = CurrentValueSubject<Comment?, Never>(nil)
    public let commentsRequestSubject = CurrentValueSubject<[Comment], Never>([])
    public var lastPostedComment: Comment? {
        didSet {
            collectionView.lastPostedComment = lastPostedComment
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private lazy var headerContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 10),
//            horizontalStack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -10),
            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        
        return instance
    }()
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
        instance.text = "comments".localized.uppercased()
        
        let constraint = instance.widthAnchor.constraint(equalToConstant: 100)
        constraint.identifier = "width"
        constraint.isActive = true
        
        return instance
    }()
    private lazy var disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.tintColor = .secondaryLabel
        disclosureIndicator.contentMode = .center
        disclosureIndicator.widthAnchor.constraint(equalTo: disclosureIndicator.heightAnchor, multiplier: 1/1).isActive = true
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    private lazy var collectionView: CommentsCollectionView = {
        let instance = CommentsCollectionView(rootComment: nil)
        
        instance.claimSubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                  let string = $0
            else { return }
            
            self.claimSubject.send($0)
//            self.claimSubject.send(completion: .finished)
        }.store(in: &subscriptions)
        
        instance.commentSubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                  let string = $0
            else { return }
            
            self.commentSubject.send($0)
//            self.commentSubject.send(completion: .finished)
        }.store(in: &subscriptions)
        
        instance.replySubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                  let string = $0
            else { return }
            
            self.replySubject.send($0)
//            self.commentSubject.send(completion: .finished)
        }.store(in: &subscriptions)
        
        instance.commentsRequestSubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                  let comments = $0
            else { return }
            
            self.commentsRequestSubject.send(comments)
        }.store(in: &subscriptions)
        
        instance.commentThreadSubject.sink { [weak self] in
            guard let self = self,
                  let value = $0
            else { return }
            
            self.commentThreadSubject.send(value)
        }.store(in: &subscriptions)
        
        return instance
        }()
    private lazy var containerView: UIView = {
       let instance = UIView()
        instance.isUserInteractionEnabled = true
        instance.backgroundColor = .clear
        instance.heightAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView.addEquallyTo(to: instance)
        
        return instance
    }()
    private lazy var icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "bubble.right.fill"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        
        observers.append(imageView.observe(\UIImageView.bounds, options: .new, changeHandler: { view, change in
            guard let newValue = change.newValue else { return }
            
            view.image = UIImage(systemName: "bubble.right.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height, weight: .light, scale: .medium))
        }))
        
        return instance
    }()
    // Stacks
    private lazy var horizontalStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
        let constraint = rootStack.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: contentView.bounds.width, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)!))
        constraint.identifier = "height"
        constraint.isActive = true
        rootStack.alignment = .center
        rootStack.spacing = 4
        return rootStack
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [headerContainer, containerView])// collectionView])//, containerView])
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    // Layout
    private let padding: CGFloat = 8
    // Constraints
    private var closedConstraint: NSLayoutConstraint!
    private var openConstraint: NSLayoutConstraint!
    
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
        setObservers()
        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
        ])
        
        closedConstraint = disclosureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        closedConstraint.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        openConstraint.priority = .defaultLow
        
        updateAppearance(animated: false)
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance(animated: Bool = true) {
        closedConstraint.isActive = !isSelected
        openConstraint.isActive = isSelected

        guard animated else {
            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
            self.disclosureIndicator.transform = !self.isSelected ? upsideDown : .identity
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
            self.disclosureIndicator.transform = !self.isSelected ? upsideDown : .identity
        }
    }
    
    private func setObservers() {
        observers.append(collectionView.observe(\CommentsCollectionView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.collectionView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue,
                      value.height != constraint.constant else { return }
            self.setNeedsLayout()
            constraint.constant = value.height
            self.layoutIfNeeded()
//            self.boundsListener?.onBoundsChanged(view.frame)
        })
//        observers.append(collectionView.observe(\CommentsCollectionView.bounds, options: .new) { view, change in
//            guard let value = change.newValue else { return }
//            view.cornerRadius = value.width * 0.05
//        })
    }
    
    private func setTasks() {
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.CommentsTotal) {
                guard let self = self,
                      let item = self.item,
                      let object = notification.object as? SurveyReference,
                      item.reference == object
                else { return }
                
                self.disclosureLabel.text = "comments".localized.uppercased() + " (\(String(describing: item.commentsTotal)))"
                guard let constraint = self.disclosureLabel.getConstraint(identifier: "width") else { return }
                self.setNeedsLayout()
                constraint.constant = self.disclosureLabel.text!.width(withConstrainedHeight: 100, font: self.disclosureLabel.font)
                self.layoutIfNeeded()
            }
        })
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                 forTextStyle: .caption1)
        guard let constraint = horizontalStack.getConstraint(identifier: "height"),
              let constraint_2 = disclosureLabel.getConstraint(identifier: "width")
        else { return }
        setNeedsLayout()
        constraint.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
        constraint_2.constant = disclosureLabel.text!.width(withConstrainedHeight: 100, font: disclosureLabel.font)
        layoutIfNeeded()
    }
}

// MARK: - CallbackObservable
extension CommentsSectionCell: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        
    }
}
