//
//  SubscriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public weak var item: SurveyReference! {
        didSet {
            guard let item = item else { return }
            defer {
                setProgress()
                refreshConstraints()
                setColors()
            }
            titleLabel.text = item.title
            descriptionLabel.text = item.truncatedDescription
            ratingLabel.text = String(describing: item.rating)
            viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            dateLabel.text = formatter.string(from: item.startDate)
            topicLabel.text = item.topic.title.uppercased()
            firstnameLabel.text = item.owner.firstNameSingleWord
            lastnameLabel.text = item.owner.lastNameSingleWord
            avatar.userprofile = item.owner
            
            if item.isComplete {
                titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
                descriptionLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
            } else {
                if !item.isOwn {
                    topicStackView.removeArrangedSubview(progressView)
                    progressView.removeFromSuperview()
                }
                titleLabel.textColor = .label
                descriptionLabel.textColor = .label
            }
            
            commentsLabel.text = String(describing: item.commentsTotal.roundedWithAbbreviations)
            commentsView.alpha = item.commentsTotal == 0 ? 0 : 1
            commentsLabel.alpha = item.commentsTotal == 0 ? 0 : 1
            //NSObject observation
//            observers.append(item.observe(\SurveyReference.title, options: .new) { [weak self] _, change in
//                guard let self = self,
//                      let title = change.newValue,
//                      let label = self.titleLabel as? InsetLabel,
//                      let constraint = label.getAllConstraints().filter({$0.identifier == "height"}).first else{ return }
//
//                let height = title.height(withConstrainedWidth: label.bounds.width, font: label.font)
//                guard height != constraint.constant else { return }
//                self.setNeedsLayout()
//                constraint.constant = height + label.insets.top + label.insets.bottom
//                self.layoutIfNeeded()
//            })
            
//            avatar.shadowColor = item.topic.tagColor
//            descriptionLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : item.topic.tagColor.withAlphaComponent(0.075)
            
            if let label = progressView.getSubview(type: UILabel.self, identifier: "progressLabel") {
                label.text = String(describing: item.progress) + "%"
            }
            if let progress = progressView.getSubview(type: UIView.self, identifier: "progress") {
                progress.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
            }
            
            topicLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor

            var marksStackView: UIStackView!
            if let instance = topicStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "marksStackView" }).first as? UIStackView {
                marksStackView = instance
            } else {
                let stackView = UIStackView()
                stackView.clipsToBounds = false
                stackView.spacing = 2
                stackView.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
                stackView.accessibilityIdentifier = "marksStackView"
                observers.append(stackView.observe(\UIStackView.bounds, options: [.new]) { view, change in
                    guard let newValue = change.newValue else { return }
                    view.cornerRadius = newValue.height/2.25
                })
                topicStackView.addArrangedSubview(stackView)
                marksStackView = stackView
            }
            marksStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            if item.isOwn {
                let container = UIView()
                container.backgroundColor = .clear
                container.accessibilityIdentifier = "isOwn"
                container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                
                let instance = UIImageView(image: UIImage(systemName: "figure.wave"))
                instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
                instance.contentMode = .scaleAspectFit
                instance.addEquallyTo(to: container)
                marksStackView.addArrangedSubview(container)
            } else if item.isComplete {
                let container = UIView()
                container.backgroundColor = .clear
                container.accessibilityIdentifier = "isComplete"
                container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                
                let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill",
                                                          withConfiguration: UIImage.SymbolConfiguration(pointSize: marksStackView.frame.height, weight: .semibold, scale: .medium)))
                instance.contentMode = .center
                instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : item.topic.tagColor
                instance.contentMode = .scaleAspectFit
                instance.addEquallyTo(to: container)
                marksStackView.addArrangedSubview(container)
            }
            if item.isFavorite {
                let container = UIView()
                container.backgroundColor = .clear
                container.accessibilityIdentifier = "isFavorite"
                container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                
                let instance = UIImageView(image: UIImage(systemName: "binoculars.fill"))
                instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
                instance.contentMode = .scaleAspectFit
                instance.addEquallyTo(to: container)
                marksStackView.addArrangedSubview(container)
            }
            if item.isHot {
                let container = UIView()
                container.backgroundColor = .clear
                container.accessibilityIdentifier = "isHot"
                container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                
                let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
                instance.tintColor = .systemRed
                instance.contentMode = .scaleAspectFit
                instance.addEquallyTo(to: container)
                marksStackView.addArrangedSubview(container)
            }
            
            if titleLabel.getConstraint(identifier: "height").isNil, descriptionLabel.getConstraint(identifier: "height").isNil, topicView.getConstraint(identifier: "height").isNil {
                let constraint = titleLabel.heightAnchor.constraint(equalToConstant: 300)
                constraint.identifier = "height"
                constraint.isActive = true
                let constraint_2 = descriptionLabel.heightAnchor.constraint(equalToConstant: 15)
                constraint_2.identifier = "height"
                constraint_2.isActive = true
                let constraint_3 = topicView.heightAnchor.constraint(equalToConstant: 25)
                constraint_3.identifier = "height"
                constraint_3.isActive = true
                
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
//    override var separatorLayoutGuide: UILayoutGuide = {
//        return UILayoutGuide()
//    }()
    
    // MARK: - Private properties
    private var tasks: [Task<Void, Never>?] = []
    private var observers: [NSKeyValueObservation] = []
    private lazy var titleLabel: InsetLabel = {
        let instance = InsetLabel()
        instance.insets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)
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
        instance.insets = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .callout)
        instance.numberOfLines = 0
        instance.lineBreakMode = .byTruncatingTail
        instance.textColor = .label
        observers.append(instance.observe(\InsetLabel.bounds, options: [.new]) { [weak self] view, change in
            guard let self = self,
                  let item = self.item,
                  let newValue = change.newValue,
                  let constraint = view.getAllConstraints().filter({$0.identifier == "height"}).first else{ return }
            
            let height = item.truncatedDescription.height(withConstrainedWidth: view.bounds.width, font: view.font)
            guard height != constraint.constant else { return }
            self.setNeedsLayout()
            constraint.constant = height + view.insets.top + view.insets.bottom
            self.layoutIfNeeded()
//            view.cornerRadius = newValue.width * 0.05
        })
        return instance
    }()
    private let ratingView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small)))
        instance.tintColor = Colors.Tags.HoneyYellow
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    @MainActor private lazy var ratingLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
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
    private lazy var viewsView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "eye.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small)))
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    private lazy var commentsView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "bubble.right.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small)))
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    @MainActor private lazy var commentsLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        return instance
    }()
    private lazy var avatar: NewAvatar = {
        let instance = NewAvatar(isShadowed: true)
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        return instance
    }()
    private lazy var dateLabel: InsetLabel = {
        let instance = InsetLabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
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
                constraint_2.constant = width + view.insets.right*2.5 + view.insets.left*2.5
            } else {
                let constraint_2 = view.widthAnchor.constraint(equalToConstant: width + view.insets.right*2.5 + view.insets.left*2.5)
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
        instance.backgroundColor = .systemGray4
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
        instance.clipsToBounds = false
        instance.alignment = .center
        instance.spacing = 4
        return instance
    }()
    @MainActor private lazy var viewsLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
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
        let instance = UIStackView(arrangedSubviews: [ratingView, ratingLabel, viewsView, viewsLabel, commentsView, commentsLabel])
//        instance.alignment = .center
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
            lastnameLabel.widthAnchor.constraint(equalTo: avatar.widthAnchor, multiplier: 1.6),
//            avatar.centerYAnchor.constraint(equalTo: instance.centerYAnchor),
            avatar.topAnchor.constraint(equalTo: instance.topAnchor),
            avatar.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
            avatar.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.6),
//            dateLabel.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//            dateLabel.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
        ])
        return instance
    }()
    private lazy var firstnameLabel: ArcLabel = {
        let instance = ArcLabel()
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.font = UIFont(name: Fonts.Semibold, size: 9)//UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.text = "test"
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .darkGray
        instance.accessibilityIdentifier = "firstnameLabel"
        return instance
    }()
    private lazy var lastnameLabel: ArcLabel = {
        let instance = ArcLabel()
        instance.angle = 4.7
        instance.clockwise = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.font = UIFont(name: Fonts.Semibold, size: 9)//UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.text = "test"
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .darkGray
        instance.accessibilityIdentifier = "lastnameLabel"
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [subHorizontalStack, descriptionLabel, statsView])
        instance.axis = .vertical
        instance.spacing = 0
        return instance
    }()
    private lazy var topVerticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topicView, titleLabel])
        instance.axis = .vertical
        instance.spacing = 0
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
    private let padding: CGFloat = 20
    private var constraint: NSLayoutConstraint!
    ///Store tasks from NotificationCenter's AsyncStream
    
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
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
        setTasks()
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
    
    private func setTasks() {
//        if #available(iOS 15, *) {
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
            tasks.append(Task { [weak self] in
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
            tasks.append(Task { [weak self] in
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
            tasks.append(Task { [weak self] in
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
                                stackView.spacing = 2
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
                            instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
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
            tasks.append(Task { [weak self] in
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
                            self.titleLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
                            self.descriptionLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
                            self.topicStackView.insertArrangedSubview(self.progressView, at: 1)

//                            self.dateLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemGray : item.isComplete ? .systemGreen : .systemGray
                            var stackView: UIStackView!
                            if let _stackView = self.topicStackView.getSubview(type: UIStackView.self, identifier: "marksStackView") {
                                stackView = _stackView
                            } else {
                                stackView = UIStackView()
                                stackView.spacing = 2
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
                            instance.contentMode = .center
                            instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .white : self.item.topic.tagColor
                            instance.contentMode = .scaleAspectFit
                            instance.addEquallyTo(to: container)
                            stackView.insertArrangedSubview(container, at: 0)
                            self.observers.append(instance.observe(\UIImageView.bounds, options: .new) { view, change in
                                guard let newValue = change.newValue else { return }
                                view.cornerRadius = newValue.size.height/2
                                let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height * 1.9, weight: .semibold, scale: .medium)
                                let image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: largeConfig)
                                view.image = image
                            })
                        case false:
                            guard let stackView = self.topicStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first,
                                  let mark = stackView.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "isComplete" }).first else { return }
                            stackView.removeArrangedSubview(mark)
                            mark.removeFromSuperview()
                        }
                    }
                }
            })
            tasks.append(Task { [weak self] in
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
                            instance.tintColor = .systemRed
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
            tasks.append(Task { [weak self] in
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
        tasks.append(Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.CommentsTotal) {
                await MainActor.run {
                    guard let self = self,
                          let item = self.item,
                          let object = notification.object as? SurveyReference,
                          item === object
                    else { return }
                    self.commentsView.alpha = 1
                    self.commentsLabel.alpha = 1
                    self.commentsLabel.text = String(describing: item.commentsTotal.roundedWithAbbreviations)
                }
            }
        })
//        } else {
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.updateViewsCount),
//                                                   name: Notifications.Surveys.Views,
//                                                   object: nil)
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.switchFavorite),
//                                                   name: Notifications.Surveys.SwitchFavorite,
//                                                   object: nil)
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.setCompleted),
//                                                   name: Notifications.Surveys.Completed,
//                                                   object: nil)
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.switchHot),
//                                                   name: Notifications.Surveys.SwitchHot,
//                                                   object: nil)
//        }
    }
    
    private func setProgress() {
        guard let progressIndicator = self.progressView.getSubview(type: UIView.self, identifier: "progress"),
              let progressLabel = self.progressView.getSubview(type: UIView.self, identifier: "progressLabel") as? UILabel,
              let constraint = progressIndicator.getConstraint(identifier: "width") else { return }
        
        progressLabel.text = String(describing: item.progress) + "%"
        self.progressView.setNeedsLayout()
        constraint.constant = constraint.constant * CGFloat(item.progress)/100
        self.progressView.layoutIfNeeded()
    }
    
    private func setColors() {
        guard let stackView = topicStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "marksStackView" }).first as? UIStackView else { return }
        stackView.arrangedSubviews.forEach { [weak self] in
            guard let self = self,
                  let identifier = $0.accessibilityIdentifier else { return }
            if identifier == "isHot" {
//                $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemRed
            } else if identifier == "isComplete" {
                //                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
                $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.item.topic.tagColor
            } else if identifier == "isFavorite" {
                $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
            } else if identifier == "isOwn" {
                //                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
                $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.item.topic.tagColor
            }
        }
    }
    
    private func refreshConstraints() {
        guard let constraint = titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_2 = descriptionLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_3 = topicLabel.getAllConstraints().filter({ $0.identifier == "width"}).first
        else { return }
        
        let height = item.title.height(withConstrainedWidth: titleLabel.bounds.width, font: titleLabel.font)
        let height_2 = item.truncatedDescription.height(withConstrainedWidth: descriptionLabel.bounds.width, font: descriptionLabel.font)
        let width = item.topic.title.width(withConstrainedHeight: topicLabel.bounds.height, font: topicLabel.font)
//        guard height != constraint.constant else { return }
        setNeedsLayout()
        constraint.constant = height + titleLabel.insets.top + titleLabel.insets.bottom
        constraint_2.constant = height_2 + descriptionLabel.insets.top + descriptionLabel.insets.bottom
        constraint_3.constant = width + topicLabel.insets.right*2.5 + topicLabel.insets.left*2.5
        layoutIfNeeded()
        topicStackView.updateConstraints()
        topicLabel.frame.origin = .zero
//        avatar.imageView.image = UIImage(systemName: "face.smiling.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: avatar.bounds.size.height*0.5, weight: .regular, scale: .medium))
    }
    
    @objc
    private func updateViewsCount(notification: Notification) {
        guard let item = item else { return }
        viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
    }
    
    @objc
    private func switchFavorite(notification: Notification) {
        guard let item = item else { return }
        ratingLabel.text = String(describing: item.rating)
    }
    
    @objc
    private func setCompleted(notification: Notification) {
        guard let item = item else { return }
        ratingLabel.text = String(describing: item.rating)
    }
    
    @objc
    private func switchHot(notification: Notification) {
        guard let item = item else { return }
        ratingLabel.text = String(describing: item.rating)
    }
    
    // MARK: - Overriden methods
    override func updateConstraints() {
        super.updateConstraints()
        
        separatorLayoutGuide.leadingAnchor.constraint(equalTo: ratingView.trailingAnchor, constant: 10).isActive = true
        separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: .greatestFiniteMagnitude).isActive = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        progressView.getSubview(type: UIView.self, identifier: "progress")?.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
        viewsView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        topicLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
//        descriptionLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .label : .darkGray
        dateLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        descriptionLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : item.topic.tagColor.withAlphaComponent(0.075)
        firstnameLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .darkGray
        lastnameLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .darkGray
        
        if !item.isNil {
            if item.isComplete {
                titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
                descriptionLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
            } else {
                titleLabel.textColor = .label
                descriptionLabel.textColor = .label
            }
        }
        
        if let stackView = topicStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "marksStackView" }).first as? UIStackView {
            stackView.arrangedSubviews.forEach { [weak self] in
                guard let self = self,
                      let identifier = $0.accessibilityIdentifier else { return }
                if identifier == "isHot" {
//                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemRed
                } else if identifier == "isComplete" {
//                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.item.topic.tagColor
                } else if identifier == "isFavorite" {
                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
                } else if identifier == "isOwn" {
                    //                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.item.topic.tagColor
                }
            }
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
                                            forTextStyle: .title2)
        ratingLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        commentsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        descriptionLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .callout)
        topicLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
                                            forTextStyle: .footnote)
//        firstnameLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
//                                                forTextStyle: .caption2)
//        lastnameLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
//                                               forTextStyle: .caption2)
        dateLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                               forTextStyle: .caption2)
        
        guard let constraint_1 = titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_2 = statsView.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_3 = descriptionLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_4 = topicView.getAllConstraints().filter({$0.identifier == "height"}).first,
              let item = item else { return }
        
        setNeedsLayout()
        constraint_1.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width,
                                                  font: titleLabel.font)
        constraint_2.constant = String(describing: item.rating).height(withConstrainedWidth: ratingLabel.bounds.width,
                                                                       font: ratingLabel.font)
        constraint_3.constant = item.truncatedDescription.height(withConstrainedWidth: ratingLabel.bounds.width,
                                                                       font: ratingLabel.font)
        constraint_4.constant = item.topic.title.height(withConstrainedWidth: ratingLabel.bounds.width,
                                                                       font: ratingLabel.font)
        layoutIfNeeded()
        topicLabel.frame.origin = .zero
    }
}

