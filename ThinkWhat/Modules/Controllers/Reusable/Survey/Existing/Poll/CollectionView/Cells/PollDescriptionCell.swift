//
//  PollDescriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class PollDescriptionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    public var item: Survey! {
        didSet {
            guard let item = item else { return }
            
//            setNeedsLayout()
//            layoutIfNeeded()
            textView.text = item.description
//            let constraint = textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
//            constraint.identifier = "height"
//            constraint.isActive = true
                        setNeedsLayout()
                        layoutIfNeeded()
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private lazy var textView: UITextView = {
        let instance = UITextView()
        instance.contentInset = UIEdgeInsets(top: 0,
                                             left: 0,//,instance.contentInset.left,
                                             bottom: 0,
                                             right: 0)//instance.contentInset.right)
        instance.isUserInteractionEnabled = false
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        instance.backgroundColor = .clear
        instance.isEditable = false
        instance.isSelectable = false
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 1)
        constraint.identifier = "height"
        constraint.isActive = true

        instance.publisher(for: \.contentSize)
            .receive(on: DispatchQueue.main)
            .filter { $0 != .zero && $0.height > 0 }
            .sink { [weak self] in
                guard let self = self else { return }

                self.setNeedsLayout()
                print("height", $0.height)
                constraint.constant = $0.height + self.padding//*2
                self.setNeedsDisplay()
                self.layoutIfNeeded()
            }
            .store(in: &subscriptions)

        return instance
    }()
    private let padding: CGFloat = 8
    
    
    
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

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        //        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        //        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        //        if let imageView = icon.get(all: UIImageView.self).first {
        //            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        //        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                          forTextStyle: .body)
        guard let constraint_1 = self.textView.getConstraint(identifier: "height") else { return }
        setNeedsLayout()
        constraint_1.constant = textView.contentSize.height + padding*2
    }
    
}

// MARK: - Private methods
private extension PollDescriptionCell {
    @MainActor
    func setupUI() {
        backgroundColor = .clear
        
        textView.place(inside: contentView, bottomPriority: .defaultLow)
//        contentView.addSubview(textView)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        textView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//        ])
//
//        let constraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        constraint.priority = .defaultLow
//        constraint.isActive = true
    }
    
    @MainActor
    func updateUI() {
//        guard let constraint = textView.getConstraint(identifier: "height") else { return }
//
//        setNeedsLayout()
//        constraint.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width, font: titleLabel.font)
//        layoutIfNeeded()
    }
}


////
////  PollDescriptionCell.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 01.07.2022.
////  Copyright © 2022 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class PollDescriptionCell: UICollectionViewCell {
//
//    // MARK: - Overriden properties
//    override var isSelected: Bool {
//        didSet {
////            super.isSelected = isSelected
//            guard isFoldable else { return }
////            if isSelected, !closedConstraint.isNil, !closedConstraint!.isActive {
////                updateAppearance()
////            } else if !isSelected, !openConstraint.isNil, !openConstraint!.isActive {
//                updateAppearance()
////            }
//        }
//    }
//
//    // MARK: - Public Properties
//    public var item: Survey! {
//        didSet {
//            guard !item.isNil else { return }
//            textView.text = item.description
//        }
//    }
//    public var isFoldable = true {
//        didSet {
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0) {
//                self.disclosureIndicator.alpha = self.isFoldable ? 1 : 0
//            }
//        }
//    }
//
//    // MARK: - Private Properties
//    private var notifications: [Task<Void, Never>?] = []
//    private lazy var headerContainer: UIView = {
//        let instance = UIView()
//        instance.backgroundColor = .clear
//        instance.addSubview(horizontalStack)
//        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            horizontalStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 10),
////            horizontalStack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -10),
//            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor),
//            horizontalStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//        ])
//
//        return instance
//    }()
//    private lazy var disclosureLabel: UILabel = {
//        let instance = UILabel()
//        instance.textColor = .secondaryLabel
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
//        instance.text = "details".localized.uppercased()
//
//        let constraint = instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100, font: instance.font))
//        constraint.identifier = "width"
//        constraint.isActive = true
//
//        return instance
//    }()
//    private lazy var textView: UITextView = {
//        let instance = UITextView()
//        instance.contentInset = UIEdgeInsets(top: 0,
//                                             left: 0,//,instance.contentInset.left,
//                                             bottom: 0,
//                                             right: 0)//instance.contentInset.right)
//        instance.isUserInteractionEnabled = false
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
//        instance.backgroundColor = .clear
//        instance.isEditable = false
//        instance.isSelectable = false
//
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
//        constraint.identifier = "height"
//        constraint.isActive = true
//
//        observers.append(instance.observe(\UITextView.contentSize, options: .new) { [weak self] view, change in
//            guard let self = self,
//                  let constraint = view.getAllConstraints().filter({ $0.identifier == "height" }).first,
//                  let value = change.newValue else { return }
//            self.setNeedsLayout()
//            constraint.constant = value.height// + self.padding*2
//            self.layoutIfNeeded()
//        })
//        return instance
//    }()
//    private var observers: [NSKeyValueObservation] = []
//    private lazy var icon: UIView = {
//        let instance = UIView()
//        instance.backgroundColor = .clear
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
//        imageView.tintColor = .secondaryLabel
//        imageView.contentMode = .center
//        imageView.addEquallyTo(to: instance)
//
//        observers.append(imageView.observe(\UIImageView.bounds, options: .new, changeHandler: { view, change in
//            guard let newValue = change.newValue else { return }
//
//            view.image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height, weight: .light, scale: .medium))
//        }))
//
//        return instance
//    }()
//    private let disclosureIndicator: UIImageView = {
//        let disclosureIndicator = UIImageView()
//        disclosureIndicator.image = UIImage(systemName: "chevron.down")
//        disclosureIndicator.tintColor = .secondaryLabel
////        disclosureIndicator.widthAnchor.constraint(equalTo: disclosureIndicator.heightAnchor, multiplier: 1/1).isActive = true
//        disclosureIndicator.contentMode = .center
//        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
//        return disclosureIndicator
//    }()
//    // Stacks
//    private lazy var horizontalStack: UIStackView = {
//        let rootStack = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
//        let constraint = rootStack.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: contentView.bounds.width, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)!))
//        constraint.identifier = "height"
//        constraint.isActive = true
//        rootStack.alignment = .center
//        rootStack.spacing = 4
////        rootStack.distribution = .fillProportionally
//
////        disclosureLabel.translatesAutoresizingMaskIntoConstraints = false
////        NSLayoutConstraint.activate([
////            disclosureLabel.heightAnchor.constraint(equalTo: rootStack.heightAnchor),
////            disclosureLabel.widthAnchor.constraint(equalToConstant: self.disclosureLabel.text!.width(withConstrainedHeight: rootStack.frame.height, font: self.disclosureLabel.font))
////        ])
////        disclosureLabel.heightAnchor.constraint(equalToConstant: <#T##CGFloat#>)
//        rootStack.heightAnchor.constraint(equalTo: disclosureLabel.heightAnchor).isActive = true
        
//        observers.append(rootStack.observe(\UIStackView.bounds, options: .new) { [weak self] view, change in
//            guard let self = self,
//                  let constraint = self.disclosureLabel.getAllConstraints().filter({ $0.identifier == "width" }).first,
//                  let value = change.newValue else { return }
//            self.setNeedsLayout()
//            constraint.constant = self.disclosureLabel.text!.width(withConstrainedHeight: value.height, font: self.disclosureLabel.font)
//            self.layoutIfNeeded()
//        })
//
//        return rootStack
//    }()
//    private lazy var verticalStack: UIStackView = {
//        let verticalStack = UIStackView(arrangedSubviews: [headerContainer, textView])
//        verticalStack.layer.masksToBounds = false
//        verticalStack.axis = .vertical
//        verticalStack.spacing = 0
//        return verticalStack
//    }()
//    // Constraints
//    private var closedConstraint: NSLayoutConstraint?
//    private var openConstraint: NSLayoutConstraint?
//    // Layout
//    private let padding: CGFloat = 8
//
//    // MARK: - Destructor
//    deinit {
//        notifications.forEach { $0?.cancel() }
//        NotificationCenter.default.removeObserver(self)
//#if DEBUG
//        print("\(String(describing: type(of: self))).\(#function)")
//#endif
//    }
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        clipsToBounds = false
//        layer.masksToBounds = false
//        setObservers()
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Private methods
//    private func setupUI() {
//        backgroundColor = .clear
//        clipsToBounds = false
//        layer.masksToBounds = false
//        contentView.layer.masksToBounds = false
//
//        disclosureLabel.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor).isActive = true
//        contentView.addSubview(verticalStack)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        verticalStack.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
//            verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            verticalStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
//        ])
//
//        closedConstraint =
//            disclosureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
//        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
//
//        openConstraint =
//            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
//        openConstraint?.priority = .defaultLow
//
////        disclosureLabel.widthAnchor.constraint(equalToConstant: self.disclosureLabel.text!.width(withConstrainedHeight: horizontalStack.frame.height, font: self.disclosureLabel.font)).isActive = true
//
//        guard isFoldable else {
//            openConstraint?.isActive = true
//            return
//        }
//        updateAppearance(animated: false)
//    }
//
//    /// Updates the views to reflect changes in selection
//    private func updateAppearance(animated: Bool = true) {
//        closedConstraint?.isActive = isSelected
//        openConstraint?.isActive = !isSelected
//
//        guard animated else {
//            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
//            self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
//            return
//        }
//        UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
//            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
//            self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
//        }
//    }
//
//    private func setObservers() {
//        if #available(iOS 15, *) {
//            notifications.append(Task { [weak self] in
//                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Completed) {
//                    guard let self = self,
//                          let instance = notification.object as? SurveyReference,
//                          let survey = instance.survey,
//                          survey == self.item
//                    else { return }
//
//                    await MainActor.run {
//                        self.isFoldable = true
//                    }
//                }
//            })
//        } else {
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.observeCompletion(notification:)),
//                                                   name: Notifications.Surveys.Completed,
//                                                   object: nil)
//        }
//    }
//
//    //Old-fashioned observation
//    @objc func observeCompletion(notification: Notification) {
//        guard notification.name == Notifications.Surveys.Completed,
//                let instance = notification.object as? SurveyReference,
//                let survey = instance.survey,
//                survey == item
//        else { return }
//
//        isFoldable = true
//    }
//
//    // MARK: - Overriden methods
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
////        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
////        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
////        if let imageView = icon.get(all: UIImageView.self).first {
////            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
////        }
//
//        //Set dynamic font size
//        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
//
//        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                          forTextStyle: .body)
//        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                                 forTextStyle: .caption1)
//        guard let constraint_1 = self.textView.getConstraint(identifier: "height"),
//              let constraint_2 = horizontalStack.getConstraint(identifier: "height"),
//              let constraint_3 = disclosureLabel.getConstraint(identifier: "width")
//        else { return }
//        setNeedsLayout()
//        constraint_1.constant = textView.contentSize.height + padding*2
//        constraint_2.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
//        constraint_3.constant = disclosureLabel.text!.width(withConstrainedHeight: 100, font: disclosureLabel.font)
//        layoutIfNeeded()
//    }
//
////    override func prepareForReuse() {
////        super.prepareForReuse()
////        openConstraint?.isActive = false
////        closedConstraint?.isActive = true
////        textView.frame = .zero
////    }
//}
