//
//  SubscriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubscriptionCell: UICollectionViewCell {
    
    // MARK: - Public properties
    public weak var item: SurveyReference! {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.title
            descriptionLabel.text = item.truncatedDescription
            ratingLabel.text = String(describing: item.rating)
            viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
            dateLabel.text = item.startDate.toDateString()
            topicLabel.text = item.topic.title.uppercased()
            usernameLabel.text = item.owner.firstNameSingleWord + (item.owner.lastNameSingleWord.isEmpty ? "" : "\n" + item.owner.lastNameSingleWord)
            topicLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
            if !item.owner.lastNameSingleWord.isEmpty { usernameLabel.numberOfLines = 2 }
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
            let constraint = titleLabel.heightAnchor.constraint(equalToConstant: 300)
            constraint.identifier = "height"
            constraint.isActive = true
            let constraint_2 = descriptionLabel.heightAnchor.constraint(equalToConstant: 15)
            constraint_2.identifier = "height"
            constraint_2.isActive = true
            let constraint_3 = topicView.heightAnchor.constraint(equalToConstant: 15)
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
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
        instance.numberOfLines = 1
        instance.lineBreakMode = .byTruncatingTail
        instance.textColor = .label
        observers.append(instance.observe(\UILabel.bounds, options: [.new]) { [weak self] view, _ in
            guard let self = self,
                  let constraint = self.titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
                  let height = "text".height(withConstrainedWidth: view.bounds.width, font: view.font) as? CGFloat,
                  height != constraint.constant else { return }
            self.setNeedsLayout()
            constraint.constant = height
            self.layoutIfNeeded()
        })
        return instance
    }()
    private lazy var descriptionLabel: InsetLabel = {
        let instance = InsetLabel()
        instance.insets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline)
        instance.numberOfLines = 1
        instance.lineBreakMode = .byTruncatingTail
        instance.textColor = .label
        observers.append(instance.observe(\InsetLabel.bounds, options: [.new]) { [weak self] view, _ in
            guard let self = self,
                  let constraint = view.getAllConstraints().filter({$0.identifier == "height"}).first,
                  let height = "text".height(withConstrainedWidth: view.bounds.width, font: view.font) as? CGFloat,
                  height != constraint.constant else { return }
            self.setNeedsLayout()
            constraint.constant = height + view.insets.top + view.insets.bottom
            self.layoutIfNeeded()
        })
        return instance
    }()
    private let ratingView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "star.fill"))
        instance.tintColor = .secondaryLabel
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
        instance.tintColor = .secondaryLabel
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
    private lazy var dateLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = .secondaryLabel
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
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.insets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        instance.textColor = .white
        observers.append(instance.observe(\InsetLabel.bounds, options: [.new]) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue,
                  let constraint = self.topicView.getAllConstraints().filter({$0.identifier == "height"}).first,
                  //                  let constraint_2 = view.getAllConstraints().filter({$0.identifier == "width"}).first,
                  let height = self.item.topic.title.height(withConstrainedWidth: view.bounds.width, font: view.font) as? CGFloat,
                  let width = self.item.topic.title.width(withConstrainedHeight: height, font: view.font) as? CGFloat else { return }
            self.setNeedsLayout()
            if let constraint_2 = view.getAllConstraints().filter({ $0.identifier == "width"}).first {
                constraint_2.constant = width + 16
            } else {
                let constraint_2 = view.widthAnchor.constraint(equalToConstant: width + 16)
                constraint_2.identifier = "width"
                constraint_2.isActive = true
            }
//            constraint_2.constant = newValue.width + 8
            constraint.constant = height + 4
            self.layoutIfNeeded()
            view.cornerRadius = newValue.height/2.25
        })
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
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statsStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            statsStack.topAnchor.constraint(equalTo: instance.topAnchor),
            statsStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        return instance
    }()
    private lazy var statsStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [ratingView, ratingLabel, viewsView, viewsLabel])
        instance.alignment = .center
        instance.spacing = 4
        return instance
    }()
    private lazy var avatarStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [dateLabel, avatar, usernameLabel])
        instance.axis = .vertical
        instance.spacing = 4
        return instance
    }()
    private lazy var topicView: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "topicView"
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 15)
//        constraint.identifier = "height"
//        constraint.isActive = true
        instance.backgroundColor = .clear
        instance.addSubview(topicLabel)
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topicLabel.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            topicLabel.topAnchor.constraint(equalTo: instance.topAnchor),
            topicLabel.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//            topicLabel.widthAnchor.constraint(equalToConstant: 30),
        ])
//        let constraint = topicLabel.widthAnchor.constraint(equalToConstant: 30)
//        constraint.identifier = "width"
//        constraint.isActive = true
//        constraint.priority = .defaultLow
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topicView, titleLabel, descriptionLabel, statsView])
        instance.axis = .vertical
        instance.spacing = 4
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [verticalStack, avatarStack])
        instance.axis = .horizontal
        instance.spacing = 4
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 25
    private var constraint: NSLayoutConstraint!
    ///Store tasks from NotificationCenter's AsyncStream
    private var notifications: [Task<Void, Never>?] = []
    
    // MARK: - Destructor
    deinit {
        ///Destruct notifications
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
//            avatarStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding/2),
            avatarStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2)
        ])
        
        constraint = statsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding/2)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
    }
    
    private func setObservers() {
        if #available(iOS 15, *) {
            notifications.append(Task { [weak self] in
                guard !self.isNil else { return }
                for await _ in await NotificationCenter.default.notifications(for: UIApplication.willResignActiveNotification) {
                    print("UIApplication.willResignActiveNotification")
                }
            })
            notifications.append(Task { [weak self] in
                guard !self.isNil else { return }
                for await _ in await NotificationCenter.default.notifications(for: UIApplication.didBecomeActiveNotification) {
                    print("UIApplication.didBecomeActiveNotification")
                }
            })
            notifications.append(Task { [weak self] in
                for await _ in await NotificationCenter.default.notifications(for: Notifications.Surveys.Views) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item else { return }
                        self.viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
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

