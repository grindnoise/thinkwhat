//
//  PollDescriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollDescriptionCell: UICollectionViewCell {
    
    // MARK: - Overriden properties
    override var isSelected: Bool {
        didSet {
            guard isFoldable else { return }
            updateAppearance()
        }
    }
    
    // MARK: - Public Properties
    public var item: Survey! {
        didSet {
            guard !item.isNil else { return }
            textView.text = item.description
        }
    }
    public var isFoldable = true {
        didSet {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0) {
                self.disclosureIndicator.alpha = self.isFoldable ? 1 : 0
            }
        }
    }
    
    // MARK: - Private Properties
    private var notifications: [Task<Void, Never>?] = []
    private lazy var headerContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 10),
            horizontalStack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -10),
            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor, constant: -10),
        ])
        
        return instance
    }()
    private lazy var disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
        instance.text = "details".localized.uppercased()
        return instance
    }()
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
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
        constraint.identifier = "height"
        constraint.isActive = true
        
        observers.append(instance.observe(\UITextView.contentSize, options: .new) { [weak self] view, change in
            guard let self = self,
                  let constraint = view.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue else { return }
            self.setNeedsLayout()
            constraint.constant = value.height// + self.padding*2
            self.layoutIfNeeded()
        })
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private lazy var icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        
        observers.append(imageView.observe(\UIImageView.bounds, options: .new, changeHandler: { view, change in
            guard let newValue = change.newValue else { return }
            
            view.image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height, weight: .light, scale: .medium))
        }))
        
        return instance
    }()
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.tintColor = .secondaryLabel
        disclosureIndicator.widthAnchor.constraint(equalTo: disclosureIndicator.heightAnchor, multiplier: 1/1).isActive = true
        disclosureIndicator.contentMode = .center
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    // Stacks
    private lazy var horizontalStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
        let constraint = rootStack.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: contentView.bounds.width, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)!))
        constraint.identifier = "height"
        constraint.isActive = true
        rootStack.alignment = .center
        rootStack.spacing = 4
        rootStack.distribution = .fillProportionally
        return rootStack
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [headerContainer, textView])
        verticalStack.layer.masksToBounds = false
        verticalStack.axis = .vertical
        verticalStack.spacing = 0
        return verticalStack
    }()
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    // Layout
    private let padding: CGFloat = 8
    
    // MARK: - Destructor
    deinit {
        notifications.forEach { $0?.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        layer.masksToBounds = false
        setObservers()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = false
        layer.masksToBounds = false
        contentView.layer.masksToBounds = false
        
        disclosureLabel.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor).isActive = true
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

        closedConstraint =
            disclosureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
        openConstraint?.priority = .defaultLow
        
        guard isFoldable else {
            openConstraint?.isActive = true
            return
        }
        updateAppearance(animated: false)
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance(animated: Bool = true) {
        closedConstraint?.isActive = isSelected
        openConstraint?.isActive = !isSelected

        guard animated else {
            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
            self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
            self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
        }
    }
    
    private func setObservers() {
        if #available(iOS 15, *) {
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Completed) {
                    guard let self = self,
                          let instance = notification.object as? SurveyReference,
                          let survey = instance.survey,
                          survey == self.item
                    else { return }
                    
                    await MainActor.run {
                        self.isFoldable = true
                    }
                }
            })
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.observeCompletion(notification:)),
                                                   name: Notifications.Surveys.Completed,
                                                   object: nil)
        }
    }
    
    //Old-fashioned observation
    @objc func observeCompletion(notification: Notification) {
        guard notification.name == Notifications.Surveys.Completed,
                let instance = notification.object as? SurveyReference,
                let survey = instance.survey,
                survey == item
        else { return }
        
        isFoldable = true
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
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                 forTextStyle: .caption1)
        guard let constraint_1 = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
              let constraint_2 = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint_1.constant = textView.contentSize.height + padding*2
        constraint_2.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
        layoutIfNeeded()
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
//            guard isFoldable else { return }
//            updateAppearance()
//        }
//    }
//
//    // MARK: - Public Properties
//    public var item: Survey! {
//        didSet {
//            guard !item.isNil else { return }
//            color = item.topic.tagColor
//            textView.text = item.description
//        }
//    }
//    public var isFoldable = true {
//        didSet {
//            guard let constraint = horizontalStack.getConstraint(identifier: "height") else { return }
//            setNeedsLayout()
//            constraint.constant = isFoldable ? 40 : 0
//            layoutIfNeeded()
//            horizontalStack.alpha = isFoldable ? 1 : 0
//        }
//    }
////    public var isColored = true {
////        didSet {
////            guard let constraint = horizontalStack.getConstraint(identifier: "height") else { return }
////            setNeedsLayout()
////            constraint.constant = isFoldable ? 40 : 0
////            layoutIfNeeded()
////        }
////    }
//
//
//    // MARK: - Private Properties
//    private let disclosureLabel: UILabel = {
//        let instance = UILabel()
//        instance.textColor = .systemBlue
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
//        instance.text = "details".localized.uppercased()
//        return instance
//    }()
//    private lazy var background: UIView = {
//        let instance = UIView()
//        instance.accessibilityIdentifier = "bg"
//        instance.layer.masksToBounds = false
//        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
//        instance.addEquallyTo(to: shadowView)
//        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
//            guard let value = change.newValue else { return }
//            view.cornerRadius = value.width * 0.05
//        })
//        return instance
//    }()
//
//    private lazy var shadowView: UIView = {
//        let instance = UIView()
//        instance.layer.masksToBounds = false
//        instance.clipsToBounds = false
//        instance.backgroundColor = .clear
//        instance.accessibilityIdentifier = "shadow"
//        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
//        instance.layer.shadowRadius = 4
//        instance.layer.shadowOffset = .zero
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
//        constraint.identifier = "height"
//        constraint.isActive = true
//        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
//            guard let newValue = change.newValue else { return }
//            view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.width*0.05).cgPath
//        })
//        return instance
//    }()
//    private lazy var textView: UITextView = {
//        let instance = UITextView()
//        instance.isUserInteractionEnabled = false
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
//        instance.backgroundColor = .clear
//        instance.isEditable = false
//        instance.isSelectable = false
//        background.addSubview(instance)
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            instance.topAnchor.constraint(equalTo: background.topAnchor, constant: padding),
//            instance.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -padding),
//            instance.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: padding),
//            instance.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -padding),
//        ])
//        observers.append(instance.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
//            guard let self = self,
//                  let constraint = self.shadowView.getAllConstraints().filter({ $0.identifier == "height" }).first,
//                  let value = change.newValue else { return }
//            self.setNeedsLayout()
//            constraint.constant = value.height + self.padding*2
//            self.layoutIfNeeded()
//        })
//        return instance
//    }()
//    private var observers: [NSKeyValueObservation] = []
//    private let icon: UIView = {
//        let instance = UIView()
//        instance.backgroundColor = .clear
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
//        imageView.tintColor = .systemBlue
//        imageView.contentMode = .center
//        imageView.addEquallyTo(to: instance)
//        return instance
//    }()
//    private let disclosureIndicator: UIImageView = {
//        let disclosureIndicator = UIImageView()
//        disclosureIndicator.image = UIImage(systemName: "chevron.down")
//        disclosureIndicator.tintColor = .systemBlue
//        disclosureIndicator.widthAnchor.constraint(equalTo: disclosureIndicator.heightAnchor, multiplier: 1/1).isActive = true
//        disclosureIndicator.contentMode = .center
//        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
//        return disclosureIndicator
//    }()
//    // Stacks
//    private lazy var horizontalStack: UIStackView = {
//        let rootStack = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
//        let constraint = rootStack.heightAnchor.constraint(equalToConstant: 40)
//        constraint.identifier = "height"
//        constraint.isActive = true
//        rootStack.alignment = .center
//        rootStack.distribution = .fillProportionally
//        return rootStack
//    }()
//    private lazy var verticalStack: UIStackView = {
//        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, shadowView])
//        verticalStack.layer.masksToBounds = false
//        verticalStack.axis = .vertical
//        verticalStack.spacing = padding
//        return verticalStack
//    }()
//    private var color: UIColor = .systemBlue {
//        didSet {
//            background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : color.withAlphaComponent(0.2)
//            disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//            disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//            guard let imageView = icon.get(all: UIImageView.self).first else { return }
//            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        }
//    }
//    // Constraints
//    private var closedConstraint: NSLayoutConstraint?
//    private var openConstraint: NSLayoutConstraint?
//    // Layout
//    private let padding: CGFloat = 8
//
//    // MARK: - Destructor
//    deinit {
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
//            shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        openConstraint?.priority = .defaultLow
//
//        guard !isFoldable else {
//            openConstraint?.isActive = true
//            return
//        }
//        updateAppearance()
//    }
//
//    /// Updates the views to reflect changes in selection
//    private func updateAppearance() {
//        closedConstraint?.isActive = isSelected
//        openConstraint?.isActive = !isSelected
//
//        UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
//            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
//            self.disclosureIndicator.transform = !self.isSelected ? upsideDown :.identity
//            self.shadowView.alpha = self.isSelected ? 0.5 : 1
//        }
//    }
//
//    private func setObservers() {
//
//    }
//
//    // MARK: - Overriden methods
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
//        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : color.withAlphaComponent(0.2)
//        verticalStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
//            $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        }
//        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        if let imageView = icon.get(all: UIImageView.self).first {
//            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        }
//
//        //Set dynamic font size
//        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
//
//        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                          forTextStyle: .body)
//        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
//                                                 forTextStyle: .footnote)
//        guard let constraint_1 = self.shadowView.getAllConstraints().filter({ $0.identifier == "height" }).first,
//              let constraint_2 = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
//        setNeedsLayout()
//        constraint_1.constant = textView.contentSize.height + padding*2
//        constraint_2.constant = max(String(describing: item.rating).height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font), 40)
//        layoutIfNeeded()
//    }
//}
//
