////
////  CommentHeaderCell.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 26.08.2022.
////  Copyright © 2022 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//import Combine
//
//class CommentHeaderCell: UICollectionViewListCell {
//    
//    // MARK: - Override
//    override var isSelected: Bool { didSet { updateAppearance() }}
//    
//    // MARK: - Public properties
//    public var cellType: CommentHeaderItem! {
//        didSet {
//            guard let cellType = cellType else { return }
//            item = cellType.comment
//        }
//    }
//    public var item: Comment! {
//        didSet {
//            guard !item.isNil else { return }
//            
//            if !item.isOwn {
//                supplementaryStack.addArrangedSubview(claimButton)
//            }
//            
//            setHeader()
//            setBody()
//            
//            replyButton.alpha = item.isOwn ? 0 : 1
//            
//            avatar.userprofile = item.userprofile.isNil ? Userprofile.anonymous : item.userprofile!
//            disclosureButton.alpha = 0
//            
//            if mode == .Root, item.replies != 0 {
//                disclosureButton.alpha = 1
//                let attrString = NSMutableAttributedString(string: "\(item.replies)", attributes: [
//                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote) as Any,
//                    NSAttributedString.Key.foregroundColor: UIColor.systemBlue
//                ])
//                disclosureButton.setAttributedTitle(attrString, for: .normal)
//                
////                if let constraint = disclosureButton.getConstraint(identifier: "width") {
////                    repliesView.setNeedsLayout()
////                    constraint.constant = disclosureButton.titleLabel!.text!.width(withConstrainedHeight: disclosureButton.bounds.height, font: disclosureButton.titleLabel!.font)
////                    repliesView.layoutIfNeeded()
////                }
//            }
//        }
//    }
//    public var mode: CommentsCollectionView.Mode = .Root {
//        didSet {
//            guard oldValue != mode else { return }
//            
//            setBody()
//            
//            if mode == .Tree {
//                disclosureButton.alpha = 0
//            }
//            
//            guard let constraint = horizontalStack.getConstraint(identifier: "leadingAnchor") else { return }
//            
//            setNeedsLayout()
//            constraint.constant = mode == .Tree ? avatar.bounds.width/2 : 0
//            layoutIfNeeded()
//        }
//    }
//    public var commentThreadSubject = CurrentValueSubject<Comment?, Never>(nil)
//    public var replySubject = CurrentValueSubject<Comment?, Never>(nil)
//    public var claimSubject = CurrentValueSubject<Comment?, Never>(nil)
//    
//    // MARK: - Private properties
//    private var observers: [NSKeyValueObservation] = []
//    private var subscriptions = Set<AnyCancellable>()
//    private var tasks: [Task<Void, Never>?] = []
//    private lazy var textView: UITextView = {
//        let instance = UITextView()
//        instance.isUserInteractionEnabled = false
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
//        instance.isEditable = false
//        instance.isSelectable = false
//        instance.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
//        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reply)))
//        
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
//        constraint.identifier = "height"
//        constraint.isActive = true
//        
//        instance.publisher(for: \.contentSize, options: .new)
//            .sink { [unowned self] size in
//                guard let constraint = instance.getConstraint(identifier: "height") else { return }
//                
//                self.setNeedsLayout()
//                constraint.constant = size.height// * 1.5
//                self.layoutIfNeeded()
//                let space = constraint.constant - size.height
//                let inset = max(0, space/2)
//                instance.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
//            }
//            .store(in: &subscriptions)
//        
//        return instance
//    }()
//    private let padding: CGFloat = 8
//    private lazy var avatar: NewAvatar = {
//        let instance = NewAvatar(isShadowed: true)
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//        return instance
//    }()
//    private lazy var userView: UIView = {
//        let instance = UIView()
//        instance.clipsToBounds = false
//        instance.backgroundColor = .clear
//        instance.accessibilityIdentifier = "userView"
//
////        instance.addSubview(firstnameLabel)
////        instance.addSubview(lastnameLabel)
//        instance.addSubview(avatar)
//
////        firstnameLabel.translatesAutoresizingMaskIntoConstraints = false
////        lastnameLabel.translatesAutoresizingMaskIntoConstraints = false
//        avatar.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
////            firstnameLabel.topAnchor.constraint(equalTo: instance.topAnchor),
////            firstnameLabel.centerYAnchor.constraint(equalTo: lastnameLabel.centerYAnchor),
////            firstnameLabel.centerXAnchor.constraint(equalTo: lastnameLabel.centerXAnchor),
////            firstnameLabel.widthAnchor.constraint(equalTo: lastnameLabel.widthAnchor),
////            lastnameLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
////            lastnameLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
////            lastnameLabel.widthAnchor.constraint(equalTo: avatar.widthAnchor, multiplier: 1.8),
//////            avatar.topAnchor.constraint(equalTo: instance.topAnchor),
//            avatar.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
//            avatar.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
//            avatar.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.75),
//        ])
//        return instance
//    }()
//    //Date & claim
//    private lazy var dateLabel: UITextView = {
//        let instance = UITextView()
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
//        instance.textAlignment = .left
//        instance.text = "1234"
//        instance.isUserInteractionEnabled = false
//        instance.isSelectable = false
//        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        
//        let constraint = instance.heightAnchor.constraint(equalToConstant: instance.contentSize.height/1.5)//instance.contentSize.height)//"text".height(withConstrainedWidth: 100, font: instance.font!))
//        constraint.identifier = "height"
//        constraint.isActive = true
//        
//        instance.publisher(for: \.contentSize, options: .new)
//            .sink { [unowned self] size in
//                guard let constraint = self.dateLabel.getConstraint(identifier: "height") else { return }
//                
//                self.setNeedsLayout()
//                constraint.constant = size.height// * 1.5
//                self.layoutIfNeeded()
//                let space = constraint.constant - size.height//self.textView.contentSize.height
//                let inset = max(0, space/2)
//                self.dateLabel.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
//            }
//            .store(in: &subscriptions)
//
//        return instance
//    }()
//    private lazy var claimButton: UIButton = {
//        let instance = UIButton()
//        instance.setImage(UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
//        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        instance.addTarget(self, action: #selector(self.claim), for: .touchUpInside)
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
////        instance.contentMode = .bottom
////        instance.alpha = 0
//        
//        return instance
//    }()
//    private lazy var supplementaryStack: UIStackView = {
//        let instance = UIStackView(arrangedSubviews: [dateLabel])//, claimButton])
//        instance.axis = .horizontal
//        instance.clipsToBounds = false
//        instance.spacing = 4
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            instance.heightAnchor.constraint(equalTo: dateLabel.heightAnchor)
//        ])
//
//        return instance
//    }()
//    private lazy var disclosureButton: UIButton = {
//        let instance = UIButton()
//        instance.setImage(UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration:  UIImage.SymbolConfiguration(font: UIFont.scaledFont(fontName: Fonts.OpenSans.Light.rawValue, forTextStyle: .caption2)!, scale: .medium)), for: .normal)
////        instance.semanticContentAttribute = .forceRightToLeft
//        instance.tintColor = .systemBlue//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
//        instance.addTarget(self, action: #selector(self.replies), for: .touchUpInside)
////        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//        
////        let constraint = instance.widthAnchor.constraint(equalToConstant: "text".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote)!))
////        constraint.identifier = "width"
////        constraint.isActive = true
//
//        return instance
//    }()
//    private lazy var repliesView: UIView = {
//       let instance = UIView()
//        instance.backgroundColor = .clear
//        instance.isUserInteractionEnabled = true
////        instance.addSubview(replyButton)
////        instance.addSubview(disclosureButton)
////        instance.translatesAutoresizingMaskIntoConstraints = false
//        
//    
//        let innerView = UIView()
//        innerView.backgroundColor = .clear
//        innerView.addSubview(disclosureButton)
//        innerView.addSubview(replyButton)
//        
//        instance.addSubview(innerView)
//        
//        innerView.translatesAutoresizingMaskIntoConstraints = false
//        replyButton.translatesAutoresizingMaskIntoConstraints = false
//        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            innerView.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
//            innerView.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
//            innerView.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//            innerView.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
//            innerView.heightAnchor.constraint(equalTo: replyButton.heightAnchor),
//            replyButton.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
//            disclosureButton.leadingAnchor.constraint(equalTo: replyButton.trailingAnchor, constant: 16),
//            disclosureButton.heightAnchor.constraint(equalTo: replyButton.heightAnchor),
//            
//            
//            
////            replyButton.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
////            disclosureButton.leadingAnchor.constraint(equalTo: replyButton.trailingAnchor, constant: 8),
//////            instance.heightAnchor.constraint(equalTo: replyButton.heightAnchor),
////            disclosureButton.heightAnchor.constraint(equalTo: replyButton.heightAnchor),
////            instance.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
////            instance.trailingAnchor.constraint(equalTo: innerView.trailingAnchor),
////            instance.bottomAnchor.constraint(equalTo: innerView.bottomAnchor),
////            instance.topAnchor.constraint(equalTo: innerView.topAnchor, constant: 8),
//        ])
//        
////        instance.heightAnchor.constraint(equalTo: supplementaryStack.heightAnchor).isActive = true
//        
//        return instance
//    }()
//    private lazy var replyButton: UIButton = {
//        let instance = UIButton()
//        instance.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill", withConfiguration:  UIImage.SymbolConfiguration(font: UIFont.scaledFont(fontName: Fonts.OpenSans.Light.rawValue, forTextStyle: .caption2)!, scale: .medium)), for: .normal)
//        instance.tintColor = .systemBlue //traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
//        instance.addTarget(self, action: #selector(self.reply), for: .touchUpInside)
//        let attrString = NSMutableAttributedString(string: "reply".localized.uppercased(), attributes: [
//            NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote) as Any,
//            NSAttributedString.Key.foregroundColor: UIColor.systemBlue
//        ])
//        instance.setAttributedTitle(attrString, for: .normal)
////        instance.contentVerticalAlignment = .fill
////        instance.contentHorizontalAlignment = .fill
////        instance.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        let constraint = instance.heightAnchor.constraint(equalToConstant: "text".height(withConstrainedWidth: 1000, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote)!))
//        constraint.identifier = "height"
//        constraint.isActive = true
//        
//        return instance
//    }()
//    private lazy var horizontalStack: UIStackView = {
//        let instance = UIStackView(arrangedSubviews: [userView, verticalStack])
//        instance.axis = .horizontal
//        instance.clipsToBounds = false
//        instance.spacing = 0
//        
//        userView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.125).isActive = true
//        
////        NSLayoutConstraint.activate([
////            userView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: mode == .Root ? 0.125 : 0.2),
////        ])
//
//        return instance
//    }()
//    
//    private lazy var verticalStack: UIStackView = {
//        let instance = UIStackView(arrangedSubviews: [supplementaryStack, textView, repliesView])
//        instance.axis = .vertical
//        instance.alignment = .center
//        instance.clipsToBounds = false
//        instance.spacing = 0
//        
//        supplementaryStack.translatesAutoresizingMaskIntoConstraints = false
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            supplementaryStack.widthAnchor.constraint(equalTo: instance.widthAnchor),
//            textView.widthAnchor.constraint(equalTo: instance.widthAnchor),
//            repliesView.widthAnchor.constraint(equalTo: instance.widthAnchor),
//        ])
//        
//        return instance
//    }()
//    // Constraints
////    private var closedConstraint: NSLayoutConstraint!
////    private var openConstraint: NSLayoutConstraint!
//    
//    // MARK: - Destructor
//    deinit {
//        observers.forEach { $0.invalidate() }
//        tasks.forEach { $0?.cancel() }
//        subscriptions.forEach { $0.cancel() }
//        NotificationCenter.default.removeObserver(self)
//#if DEBUG
//        print("\(String(describing: type(of: self))).\(#function)")
//#endif
//    }
//
//    
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setTasks()
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Public methods
//    public func hideDisclosure() {
//        disclosureButton.alpha = 0
//    }
//    
//    // MARK: - Private methods
//    private func setupUI() {
//        backgroundColor = .clear
//        clipsToBounds = true
//        
//        contentView.addSubview(horizontalStack)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor),// constant: padding),
////            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),// constant: padding),
//            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),// constant: padding),
//        ])
//        
//        let constraint = horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
//        constraint.identifier = "leadingAnchor"
//        constraint.isActive = true
//        
////        openConstraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
////        openConstraint.priority = .defaultLow
//        
//        let bottomAnchor = repliesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        bottomAnchor.priority = .defaultLow
//        bottomAnchor.isActive = true
//    }
//    
//    private func setTasks() {
////        tasks.append(Task {@MainActor [weak self] in
////            for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.ChildrenCountChange) {
////                guard let self = self,
////                      let instance = notification.object as? Comment,
////                      instance == self.item
////                else { return }
////
////                self.disclosureButton.alpha = self.mode == .Root ? 1 : 0
////                let attrString = NSMutableAttributedString(string: "\(instance.replies)", attributes: [
////                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote) as Any,
////                    NSAttributedString.Key.foregroundColor: UIColor.systemBlue
////                ])
////                self.disclosureButton.setAttributedTitle(attrString, for: .normal)
////            }
////        })
//    }
//    
//    private func updateAppearance() {
//
//    }
//    
//    @objc
//    private func reply() {
//        guard let item = item else { return }
//        
//        replySubject.send(item)
//    }
//    
//    @objc
//    private func claim() {
//        guard let item = item else { return }
//        
//        claimSubject.send(item)
//    }
//    
//    @objc
//    private func replies() {
//        guard let item = item,
//              item.replies != 0
//        else { return }
//        
//        commentThreadSubject.send(item)
//    }
//    
//    private func setHeader() {
//        let attrString = NSMutableAttributedString()
//        if !item.isAnonymous, let userprofile = item.userprofile {
//            if !userprofile.firstNameSingleWord.isEmpty {
//                let instance = NSAttributedString(string: userprofile.firstNameSingleWord + " ",
//                                                         attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2) as Any,
//                                                                      NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
//                attrString.append(instance)
//                if !userprofile.lastNameSingleWord.isEmpty {
//                    let lastname = NSAttributedString(string: userprofile.lastNameSingleWord + " ",
//                                                             attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2) as Any,
//                                                                          NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
//                    attrString.append(lastname)
//                }
//            } else {
//                let instance = NSAttributedString(string: userprofile.lastNameSingleWord + " ",
//                                                         attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2) as Any,
//                                                                      NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
//                attrString.append(instance)
//            }
//        }
//        let date = NSAttributedString(string: item.createdAt.timeAgoDisplay(),
//                                      attributes: [NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2) as Any,
//                                                   NSAttributedString.Key.foregroundColor : traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.darkGray])
//        attrString.append(date)
//        dateLabel.attributedText = attrString
//    }
//    
//    private func setBody() {
//        if mode == .Tree {
//            if let survey = item.survey, survey.isAnonymous {
//                
//            } else if let replyItem = item.replyTo, !replyItem.isParentNode, let userprofile = replyItem.userprofile {
//                let attrString = NSMutableAttributedString()
//                if !userprofile.firstNameSingleWord.isEmpty {
//                    let reply = NSAttributedString(string: "@" + userprofile.firstNameSingleWord, attributes: [
//                        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote) as Any,
//                        NSAttributedString.Key.foregroundColor: UIColor.systemBlue
//                    ])
//                    let body = NSAttributedString(string: " " + item.body, attributes: [
//                        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote) as Any,
//                        NSAttributedString.Key.foregroundColor: UIColor.label
//                    ])
//                    attrString.append(reply)
//                    attrString.append(body)
//                } else if !userprofile.lastNameSingleWord.isEmpty {
//                    let reply = NSAttributedString(string: "@" + userprofile.lastNameSingleWord, attributes: [
//                        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote) as Any,
//                        NSAttributedString.Key.foregroundColor: UIColor.systemBlue
//                    ])
//                    let body = NSAttributedString(string: " " + item.body, attributes: [
//                        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote) as Any,
//                        NSAttributedString.Key.foregroundColor: UIColor.label
//                    ])
//                    attrString.append(reply)
//                    attrString.append(body)
//                }
//                textView.attributedText = attrString
//            }
//        } else {
//            textView.text = item.body
//        }
//    }
//    
//    // MARK: - Overriden methods
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        dateLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        claimButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        setHeader()
//        
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        //Set dynamic font size
//        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
//        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                          forTextStyle: .footnote)
//        guard let constraint = textView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
//        setNeedsLayout()
//        constraint.constant = textView.contentSize.height
//        layoutIfNeeded()
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        commentThreadSubject = .init(nil)
//        replySubject = .init(nil)
//        claimSubject = .init(nil)
//        avatar.clearImage()
//        item = nil
//        supplementaryStack.removeArrangedSubview(claimButton)
//        claimButton.removeFromSuperview()
//    }
//
//        override func updateConstraints() {
//            super.updateConstraints()
//    
//            separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -100).isActive = true
//            separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 100).isActive = true
//        }
//}
