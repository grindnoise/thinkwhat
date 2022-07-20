//
//  SubscriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyCell: UICollectionViewCell {
    
    // MARK: - Public properties
    public weak var item: SurveyReference! {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.title
            descriptionLabel.text = item.truncatedDescription
            ratingLabel.text = String(describing: item.rating)
            viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            dateLabel.text = formatter.string(from: item.startDate)
//            dateLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? item.isComplete ? .systemBlue : .systemGray : item.isComplete ? .systemGreen : .systemGray
//            dateLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? item.isComplete ? .systemBlue : .systemGray : item.isComplete ? item.topic.tagColor : .systemGray
            topicLabel.text = item.topic.title.uppercased()
            firstnameLabel.text = item.owner.firstNameSingleWord
            lastnameLabel.text = item.owner.lastNameSingleWord
            
            if let label = progressView.getSubview(type: UILabel.self, identifier: "progressLabel") {
                label.text = String(describing: item.progress) + "%"
            }
            if let progress = progressView.getSubview(type: UIView.self, identifier: "progress") {
                progress.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
            }
            
//            usernameLabel.text = item.owner.firstNameSingleWord + (item.owner.lastNameSingleWord.isEmpty ? "" : "\n" + item.owner.lastNameSingleWord)
            topicLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
//            if !item.owner.lastNameSingleWord.isEmpty { usernameLabel.numberOfLines = 2 }
            if let image = item.owner.image {
                avatar.image = image
            } else {
                Task {
                    let image = try await item.owner.downloadImageAsync()
                    await MainActor.run {
                        avatar.image = image
                    }
                }
            }
            
            if item.isFavorite || item.isComplete || item.isHot {
                let stackView = UIStackView()
                stackView.spacing = 0
                stackView.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
                stackView.accessibilityIdentifier = "marksStackView"
                observers.append(stackView.observe(\UIStackView.bounds, options: [.new]) { view, change in
                    guard let newValue = change.newValue else { return }
                    view.cornerRadius = newValue.height/2.25
                })
                if item.isComplete {
                    let container = UIView()
                    container.backgroundColor = .clear
                    container.accessibilityIdentifier = "isComplete"
                    container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                    
                    let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
//                    instance.accessibilityIdentifier = "isComplete"
//                    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.15/1).isActive = true
//                    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemGreen
                    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : item.topic.tagColor
                    instance.contentMode = .scaleAspectFit
                    instance.addEquallyTo(to: container)
                    stackView.addArrangedSubview(container)
                }
                if item.isFavorite {
                    let container = UIView()
                    container.backgroundColor = .clear
                    container.accessibilityIdentifier = "isFavorite"
                    container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                    
                    let instance = UIImageView(image: UIImage(systemName: "binoculars.fill"))
//                    instance.accessibilityIdentifier = "isFavorite"
//                    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.15/1).isActive = true
                    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
                    instance.contentMode = .scaleAspectFit
                    instance.addEquallyTo(to: container)
                    stackView.addArrangedSubview(container)
                }
                if item.isHot {
                    let container = UIView()
                    container.backgroundColor = .clear
                    container.accessibilityIdentifier = "isHot"
                    container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                    
                    let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
//                    instance.accessibilityIdentifier = "isComplete"
//                    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.15/1).isActive = true
                    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemRed//.white
                    instance.contentMode = .scaleAspectFit
                    instance.addEquallyTo(to: container)
                    stackView.addArrangedSubview(container)
                }
                topicStackView.addArrangedSubview(stackView)
            }
            
//            if item.isHot {
//                let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
//                instance.accessibilityIdentifier = "isHot"
//                instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//                instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemRed
//                instance.contentMode = .scaleAspectFit
//                topicStackView.addArrangedSubview(instance)
//            }
            
            let constraint = titleLabel.heightAnchor.constraint(equalToConstant: 300)
            constraint.identifier = "height"
            constraint.isActive = true
            let constraint_2 = descriptionLabel.heightAnchor.constraint(equalToConstant: 15)
            constraint_2.identifier = "height"
            constraint_2.isActive = true
            let constraint_3 = topicView.heightAnchor.constraint(equalToConstant: 25)
            constraint_3.identifier = "height"
            constraint_3.isActive = true
//                    let constraint_4 = topicLabel.widthAnchor.constraint(equalToConstant: 30)
//            constraint_4.identifier = "width"
//            constraint_4.isActive = true
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - Private properties
    private lazy var titleLabel: InsetLabel = {
        let instance = InsetLabel()
        instance.insets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
        instance.numberOfLines = 0
        instance.lineBreakMode = .byTruncatingTail
        instance.textColor = .label
        observers.append(instance.observe(\InsetLabel.bounds, options: [.new]) { [weak self] view, _ in
            guard let self = self,
                  let item = self.item,
                  let constraint = view.getAllConstraints().filter({$0.identifier == "height"}).first else{ return }
            
            let height = item.title.height(withConstrainedWidth: view.bounds.width, font: view.font)
            guard height != constraint.constant else { return }
            self.setNeedsLayout()
            constraint.constant = height + view.insets.top + view.insets.bottom
            self.layoutIfNeeded()
        })
        return instance
    }()
    private lazy var descriptionLabel: InsetLabel = {
        let instance = InsetLabel()
        instance.insets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline)
        instance.numberOfLines = 0
        instance.lineBreakMode = .byTruncatingTail
        instance.textColor = .label
        observers.append(instance.observe(\InsetLabel.bounds, options: [.new]) { [weak self] view, _ in
            guard let self = self,
                  let item = self.item,
                  let constraint = view.getAllConstraints().filter({$0.identifier == "height"}).first else{ return }
            
            let height = item.truncatedDescription.height(withConstrainedWidth: view.bounds.width, font: view.font)
            guard height != constraint.constant else { return }
            self.setNeedsLayout()
            constraint.constant = height + view.insets.top + view.insets.bottom
            self.layoutIfNeeded()
        })
        return instance
    }()
    private let ratingView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "star.fill"))
        instance.tintColor = Colors.Tags.HoneyYellow
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    private lazy var ratingLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = .secondaryLabel
        observers.append(instance.observe(\UILabel.bounds, options: [.new]) {[weak self] view, _ in
            guard let self = self,
                  let text = view.text else { return }
            //            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.8)
            guard let constraint = self.statsView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
            self.setNeedsLayout()
            constraint.constant = text.height(withConstrainedWidth: view.bounds.width, font: view.font)
            self.layoutIfNeeded()
        })
        return instance
    }()
    private let viewsView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "eye.fill"))
        instance.tintColor = .darkGray
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    private lazy var avatar: Avatar = {
        let instance = Avatar(gender: .Male)
        instance.isBordered = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        return instance
    }()
    private lazy var dateLabel: InsetLabel = {
        let instance = InsetLabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        instance.textColor = .secondaryLabel//.white
//        instance.backgroundColor = .systemGray
        observers.append(instance.observe(\InsetLabel.bounds, options: [.new]) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let text = formatter.string(from: self.item.startDate)
            let height = text.height(withConstrainedWidth: view.bounds.width, font: view.font)
            let width = text.width(withConstrainedHeight: height, font: view.font)
            
            self.setNeedsLayout()
            if let constraint = view.getAllConstraints().filter({ $0.identifier == "width"}).first {
                constraint.constant = width + 8
            } else {
                let constraint = view.widthAnchor.constraint(equalToConstant: width + 8)
                constraint.identifier = "width"
                constraint.isActive = true
            }
            self.layoutIfNeeded()
            view.cornerRadius = newValue.height/2.25
        })
        return instance
    }()
    private lazy var usernameLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = .secondaryLabel
        return instance
    }()
    private lazy var topicLabel: InsetLabel = {
        let instance = InsetLabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote)
        instance.textAlignment = .center
        instance.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        instance.textColor = .white
        observers.append(instance.observe(\InsetLabel.bounds, options: [.new]) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue,
                  let constraint = self.topicView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
            
            let height = self.item.topic.title.height(withConstrainedWidth: view.bounds.width, font: view.font)
            let width = self.item.topic.title.width(withConstrainedHeight: height, font: view.font)
            
            self.setNeedsLayout()
            if let constraint_2 = view.getAllConstraints().filter({ $0.identifier == "width"}).first {
                constraint_2.constant = width + 16
            } else {
                let constraint_2 = view.widthAnchor.constraint(equalToConstant: width + 16)
                constraint_2.identifier = "width"
                constraint_2.isActive = true
            }
//            constraint_2.constant = newValue.width + 8
            constraint.constant = height// + 4
            self.layoutIfNeeded()
            view.cornerRadius = newValue.height/2.25
        })
        return instance
    }()
    private lazy var progressView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .quaternaryLabel
        instance.accessibilityIdentifier = "progressView"
        let constraint = instance.widthAnchor.constraint(equalToConstant: 30)
        constraint.identifier = "width"
        constraint.isActive = true
        observers.append(instance.observe(\UIView.bounds, options: [.new]) { view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height/2.25
        })
        let subview = UIView()
        instance.addSubview(subview)
        subview.accessibilityIdentifier = "progress"
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            subview.topAnchor.constraint(equalTo: instance.topAnchor),
            subview.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        let constraint_2 = subview.widthAnchor.constraint(equalToConstant: 30)
        constraint_2.identifier = "width"
        constraint_2.isActive = true
        
        let label = InsetLabel()
        label.accessibilityIdentifier = "progressLabel"
        label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote)
        label.textAlignment = .center
        label.textColor = .white
        label.insets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        observers.append(label.observe(\InsetLabel.bounds, options: [.new]) { [weak self] view, change in
            guard let self = self,
                  let item = self.item,
                  let newValue = change.newValue,
                  let constraint = self.progressView.getAllConstraints().filter({ $0.identifier == "width" }).first,
                  let progressIndicator = self.progressView.getSubview(type: UIView.self, identifier: "progress"),
                  let constraint_2 = progressIndicator.getConstraint(identifier: "width") else { return }
            
//            guard view.bounds.size != newValue.size else { return }
            
            self.setNeedsLayout()
            constraint.constant = "100%".width(withConstrainedHeight: newValue.height, font: view.font) + view.insets.left + view.insets.right
            constraint_2.constant = constraint.constant * CGFloat(item.progress)/100
            self.layoutIfNeeded()
            
            view.cornerRadius = newValue.height/2.25
        })
        label.addEquallyTo(to: instance)
        return instance
    }()
    private lazy var topicStackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topicLabel, progressView])//, dateLabel])
        instance.alignment = .center
        instance.spacing = 4
        return instance
    }()
    @MainActor private let viewsLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = .secondaryLabel
        return instance
    }()
    private lazy var statsView: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "statsView"
        let constraint = instance.heightAnchor.constraint(equalToConstant: 15)
        constraint.identifier = "height"
        constraint.isActive = true
        instance.backgroundColor = .clear
        instance.addSubview(statsStack)
        instance.addSubview(dateLabel)
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statsStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            statsStack.topAnchor.constraint(equalTo: instance.topAnchor),
            statsStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: instance.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        return instance
    }()
    private lazy var statsStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [ratingView, ratingLabel, viewsView, viewsLabel])
        instance.alignment = .center
        instance.spacing = 2
        return instance
    }()
    private lazy var topicView: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "topicView"
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 15)
//        constraint.identifier = "height"
//        constraint.isActive = true
        instance.backgroundColor = .clear
        instance.addSubview(topicStackView)
        topicStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topicStackView.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            topicStackView.topAnchor.constraint(equalTo: instance.topAnchor),
            topicStackView.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//            topicLabel.widthAnchor.constraint(equalToConstant: 30),
        ])
//        let constraint = topicLabel.widthAnchor.constraint(equalToConstant: 30)
//        constraint.identifier = "width"
//        constraint.isActive = true
//        constraint.priority = .defaultLow
        return instance
    }()
    private lazy var userView: UIView = {
        let instance = UIView()
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "userView"
//        instance.addSubview(dateLabel)
        instance.addSubview(firstnameLabel)
        instance.addSubview(lastnameLabel)
        instance.addSubview(avatar)
//        instance.addSubview(dateLabel)
        firstnameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastnameLabel.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstnameLabel.centerYAnchor.constraint(equalTo: lastnameLabel.centerYAnchor),
            firstnameLabel.centerXAnchor.constraint(equalTo: lastnameLabel.centerXAnchor),
            firstnameLabel.widthAnchor.constraint(equalTo: lastnameLabel.widthAnchor),
//            lastnameLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            lastnameLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            lastnameLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            lastnameLabel.widthAnchor.constraint(equalTo: avatar.widthAnchor, multiplier: 1.7),
            avatar.centerYAnchor.constraint(equalTo: instance.centerYAnchor),
            avatar.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
            avatar.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.8),
//            dateLabel.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//            dateLabel.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
        ])
        return instance
    }()
    private lazy var firstnameLabel: ArcLabel = {
        let instance = ArcLabel()
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.text = "test"
        instance.textColor = .secondaryLabel
        instance.accessibilityIdentifier = "firstnameLabel"
        return instance
    }()
    private lazy var lastnameLabel: ArcLabel = {
        let instance = ArcLabel()
        instance.angle = 4.7
        instance.clockwise = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.text = "test"
        instance.textColor = .secondaryLabel
        instance.accessibilityIdentifier = "lastnameLabel"
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [subHorizontalStack, descriptionLabel, statsView])
        instance.axis = .vertical
        instance.spacing = 4
        return instance
    }()
    private lazy var topVerticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topicView, titleLabel])
        instance.axis = .vertical
        instance.spacing = 4
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [verticalStack])//, userView])
        instance.axis = .horizontal
        instance.spacing = 4
        return instance
    }()
    private lazy var subHorizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topVerticalStack, userView])
        instance.axis = .horizontal
        instance.spacing = 0
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 20
    private var constraint: NSLayoutConstraint!
    ///Store tasks from NotificationCenter's AsyncStream
    private var notifications: [Task<Void, Never>?] = []
    
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
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        setObservers()
        setupUI()
    }

    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true

        contentView.addSubview(horizontalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding/2),
            userView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.175)
        ])
        
        constraint = statsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
    }
    
    private func setObservers() {
        if #available(iOS 15, *) {
//            notifications.append(Task { [weak self] in
//                guard !self.isNil else { return }
//                for await _ in NotificationCenter.default.notifications(for: UIApplication.willResignActiveNotification) {
//                    print("UIApplication.willResignActiveNotification")
//                }
//            })
//            notifications.append(Task { [weak self] in
//                guard !self.isNil else { return }
//                for await _ in NotificationCenter.default.notifications(for: UIApplication.didBecomeActiveNotification) {
//                    print("UIApplication.didBecomeActiveNotification")
//                }
//            })
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Views) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object
                        else { return }
                        self.viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
                    }
                }
            })
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Rating) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object
                        else { return }
                        self.ratingLabel.text = String(describing: String(describing: item.rating))
                    }
                }
            })
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SwitchFavorite) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object
                        else { return }
                        switch item.isFavorite {
                        case true:
                            var stackView: UIStackView!
                            if let _stackView = topicStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first {
                                stackView = _stackView
                            } else {
                                stackView = UIStackView()
                                stackView.spacing = 0
                                stackView.backgroundColor = .clear
                                stackView.accessibilityIdentifier = "marksStackView"
                                observers.append(stackView.observe(\UIStackView.bounds, options: [.new]) { view, change in
                                    guard let newValue = change.newValue else { return }
                                    view.cornerRadius = newValue.height/2.25
                                })
                                topicStackView.addArrangedSubview(stackView)
                            }
                            guard stackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isFavorite"}).isEmpty else { return }
                            let container = UIView()
                            container.backgroundColor = .clear
                            container.accessibilityIdentifier = "isFavorite"
                            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                            
                            let instance = UIImageView(image: UIImage(systemName: "binoculars.fill"))
                            instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
                            instance.contentMode = .scaleAspectFit
                            instance.addEquallyTo(to: container)
                            stackView.insertArrangedSubview(container,
                                                            at: stackView.arrangedSubviews.isEmpty ? 0 : stackView.arrangedSubviews.count > 1 ? stackView.arrangedSubviews.count-1 : stackView.arrangedSubviews.count)
                        case false:
                            guard let stackView = topicStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first,
                                  let mark = stackView.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "isFavorite" }).first else { return }
                            stackView.removeArrangedSubview(mark)
                            mark.removeFromSuperview()
                        }
                    }
                }
            })
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Completed) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object
                        else { return }
//                        self.dateLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? item.isComplete ? .systemBlue : .systemGray : item.isComplete ? .systemGreen : .systemGray
//                        self.dateLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? item.isComplete ? .systemBlue : .systemGray : item.isComplete ? self.item.topic.tagColor : .systemGray
                        switch item.isComplete {
                        case true:
//                            self.dateLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemGray : item.isComplete ? .systemGreen : .systemGray
                            var stackView: UIStackView!
                            if let _stackView = self.topicStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first {
                                stackView = _stackView
                            } else {
                                stackView = UIStackView()
                                stackView.spacing = 0
                                stackView.backgroundColor = .clear
                                stackView.accessibilityIdentifier = "marksStackView"
                                self.observers.append(stackView.observe(\UIStackView.bounds, options: [.new]) { view, change in
                                    guard let newValue = change.newValue else { return }
                                    view.cornerRadius = newValue.height/2.25
                                })
                                self.topicStackView.addArrangedSubview(stackView)
                            }
                            guard stackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isComplete"}).isEmpty else { return }
                            let container = UIView()
                            container.backgroundColor = .clear
                            container.accessibilityIdentifier = "isComplete"
                            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                            
                            let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
                            instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemGreen
                            instance.contentMode = .scaleAspectFit
                            instance.addEquallyTo(to: container)
                            stackView.insertArrangedSubview(container, at: 0)
                        case false:
                            guard let stackView = self.topicStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first,
                                  let mark = stackView.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "isComplete" }).first else { return }
                            stackView.removeArrangedSubview(mark)
                            mark.removeFromSuperview()
                        }
                    }
                }
            })
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SwitchHot) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object
                        else { return }
                        switch item.isHot {
                        case true:
                            var stackView: UIStackView!
                            if let _stackView = self.topicStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first {
                                stackView = _stackView
                            } else {
                                stackView = UIStackView()
                                stackView.spacing = 0
                                stackView.backgroundColor = .clear
                                stackView.accessibilityIdentifier = "marksStackView"
                                self.observers.append(stackView.observe(\UIStackView.bounds, options: [.new]) { view, change in
                                    guard let newValue = change.newValue else { return }
                                    view.cornerRadius = newValue.height/2.25
                                })
                                self.topicStackView.addArrangedSubview(stackView)
                            }
                            guard stackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isHot"}).isEmpty else { return }
                            let container = UIView()
                            container.backgroundColor = .clear
                            container.accessibilityIdentifier = "isHot"
                            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                            
                            let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
                            instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemRed
                            instance.contentMode = .scaleAspectFit
                            instance.addEquallyTo(to: container)
                            stackView.insertArrangedSubview(container, at: stackView.arrangedSubviews.count == 0 ? 0 : stackView.arrangedSubviews.count)
                        case false:
                            guard let stackView = self.topicStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first,
                                  let mark = stackView.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "isHot" }).first else { return }
                            stackView.removeArrangedSubview(mark)
                            mark.removeFromSuperview()
                        }
                    }
                }
            })
            notifications.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Progress) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object,
                              let progressIndicator = self.progressView.getSubview(type: UIView.self, identifier: "progress"),
                              let progressLabel = self.progressView.getSubview(type: UIView.self, identifier: "progressLabel") as? UILabel,
                              let constraint = progressIndicator.getConstraint(identifier: "width") else { return }
                        
                        progressLabel.text = String(describing: item.progress) + "%"
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
                            self.progressView.setNeedsLayout()
                            constraint.constant = constraint.constant * CGFloat(item.progress)/100
                            self.progressView.layoutIfNeeded()
                        }
                    }
                }
            })
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.updateViewsCount),
                                                   name: Notifications.Surveys.Views,
                                                   object: nil)
        }
    }
    
    @objc
    private func updateViewsCount(_ button: UIButton) {
        guard let item = item else { return }
        viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
    }
    
    @objc
    private func updateRating(_ button: UIButton) {
        guard let item = item else { return }
        ratingLabel.text = String(describing: item.rating)
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        topicLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
//        dateLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? item.isComplete ? .systemBlue : .systemGray : item.isComplete ? .systemGreen : .systemGray
//        dateLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? item.isComplete ? .systemBlue : .systemGray : item.isComplete ? item.topic.tagColor : .systemGray
        if let stackView = topicStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "marksStackView" }).first as? UIStackView {
            stackView.arrangedSubviews.forEach { [weak self] in
                guard let self = self,
                      let identifier = $0.accessibilityIdentifier else { return }
                if identifier == "isHot" {
                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemRed
                } else if identifier == "isComplete" {
//                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.item.topic.tagColor
                } else if identifier == "isFavorite" {
                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
                }
            }
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                            forTextStyle: .title1)
        ratingLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        guard let constraint_1 = titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_2 = statsView.getAllConstraints().filter({$0.identifier == "height"}).first,
              let item = item else { return }
        setNeedsLayout()
        constraint_1.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width,
                                                  font: titleLabel.font)
        constraint_2.constant = String(describing: item.rating).height(withConstrainedWidth: ratingLabel.bounds.width,
                                                                       font: ratingLabel.font)
        layoutIfNeeded()
    }
}

