//
//  TopicHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

struct TopicCellHeaderConfiguration: UIContentConfiguration, Hashable {

    var topicItem: TopicHeaderItem!
    
    func makeContentView() -> UIView & UIContentView {
        return TopicCellHeaderContent(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard state is UICellConfigurationState else {
                return self
            }
        let updatedConfiguration = self
        return updatedConfiguration
    }
}

class TopicCellHeader: UICollectionViewListCell {
    
    // MARK: - Public properties
    public var item: TopicHeaderItem!
    public var callback: Closure?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overriden methods
    override func updateConfiguration(using state: UICellConfigurationState) {
        automaticallyUpdatesContentConfiguration = false
//        automaticallyUpdatesBackgroundConfiguration = false
//        accessories = state.isSelected ? [.checkmark(displayed: .always, options: UICellAccessory.CheckmarkOptions(isHidden: false, reservedLayoutWidth: nil, tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor))] : []
//        
//        if state.isSelected, !callback.isNil { callback!() }
        
        var newConfiguration = TopicCellHeaderConfiguration().updated(for: state)
        newConfiguration.topicItem = item
        
        contentConfiguration = newConfiguration
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.isNil ? .systemGray : item.topic.tagColor
    }
}

class TopicCellHeaderContent: UIView, UIContentView {

    // MARK: - Public properties
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? TopicCellHeaderConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    
    // MARK: - Private properties
    private var currentConfiguration: TopicCellHeaderConfiguration!
    private var observers: [NSKeyValueObservation] = []
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [iconContainer, verticalStack, viewsLabel])
        instance.axis = .horizontal
//        instance.distribution = .fillProportionally
//        instance.isLayoutMarginsRelativeArrangement = true
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
//        constraint.identifier = "height"
//        constraint.isActive = true

        instance.spacing = 8
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [titleView, statsView])
        instance.axis = .vertical
//        instance.distribution = .fillEqually
        instance.spacing = 4
        return instance
    }()
    private lazy var iconContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            icon.topAnchor.constraint(equalTo: instance.topAnchor),
            icon.heightAnchor.constraint(equalTo: instance.heightAnchor),
//            icon.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1/1)
        ])
        
        return instance
    }()
    private lazy var icon: Icon = {
        let instance = Icon()
        instance.isRounded = false
        instance.scaleMultiplicator = 1.3
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.isNil ? .systemGray : currentConfiguration.topicItem.topic.tagColor
        
        return instance
    }()
    private lazy var titleView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: instance.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        
        return instance
    }()
    private lazy var titleLabel: InsetLabel = {
        let instance = InsetLabel()
//        instance.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        instance.textAlignment = .center
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .headline)
        instance.numberOfLines = 1
        instance.textColor = .white
        instance.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = instance.widthAnchor.constraint(equalToConstant: 50)
        widthConstraint.identifier = "width"
        widthConstraint.isActive = true
        
        let heightConstraint = instance.heightAnchor.constraint(equalToConstant: 300)
        heightConstraint.identifier = "height"
        heightConstraint.isActive = true
        
        observers.append(instance.observe(\InsetLabel.bounds, options: [.new]) { view, change in//[weak self] view, change in
//            guard let self = self,
//                  let newValue = change.newValue,
//                  let constraint = view.getConstraint(identifier: "width"),
//                  let topic = self.currentConfiguration.topicItem.topic as? Topic
//            else { return }
//
////            guard newValue.width != view.bounds.width else { return }
//
//            view.insets = UIEdgeInsets(top: 0, left: newValue.height/2.25, bottom: 0, right: newValue.height/2.25)
//            let width = topic.title.width(withConstrainedHeight: view.bounds.height, font: view.font)
//
//            self.setNeedsLayout()
//            constraint.constant = width + view.insets.right*2 + view.insets.left*2
//            self.layoutIfNeeded()
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height/2.25
        })
        
        return instance
    }()
    private let hotCountView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
        instance.tintColor = .systemRed
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    private lazy var hotCountLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
        instance.textAlignment = .center
        instance.textColor = .secondaryLabel
//        observers.append(instance.observe(\UILabel.bounds, options: [.new]) {[weak self] view, _ in
//            guard let self = self,
//                  let text = view.text else { return }
//            //            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.8)
//            guard let constraint = self.statsView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
//            self.setNeedsLayout()
//            constraint.constant = text.height(withConstrainedWidth: view.bounds.width, font: view.font)
//            self.layoutIfNeeded()
//        })
        return instance
    }()
    private lazy var viewsCountView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "eye.fill"))
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    private lazy var viewsCountLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
        instance.textAlignment = .center
        instance.textColor = .secondaryLabel

        return instance
    }()
    private lazy var statsStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [viewsCountView, viewsCountLabel, hotCountView, hotCountLabel,])
        instance.alignment = .center
        instance.spacing = 4
        return instance
    }()
    private lazy var statsView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.translatesAutoresizingMaskIntoConstraints = false
        
//        let heightConstraint = instance.heightAnchor.constraint(equalToConstant: 300)
//        heightConstraint.identifier = "height"
//        heightConstraint.isActive = true
        
        instance.addSubview(statsStack)
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statsStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            statsStack.topAnchor.constraint(equalTo: instance.topAnchor),
            statsStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        
        return instance
    }()
    @MainActor private lazy var viewsLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .callout)
        instance.textAlignment = .right
        instance.textColor = .secondaryLabel
        
//        let constraint = instance.widthAnchor.constraint(equalToConstant: 50)
//        constraint.identifier = "width"
//        constraint.isActive = true

        return instance
    }()
    private let padding: CGFloat = 10
    
    // MARK: - Initalization
    init(configuration: TopicCellHeaderConfiguration) {
        super.init(frame: .zero)
        setupUI()
        setObservers()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func apply(configuration: TopicCellHeaderConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.topicItem.topic.tagColor
        titleLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.topicItem.topic.tagColor
        icon.category = Icon.Category(rawValue: currentConfiguration.topicItem.topic.id) ?? .Null
        titleLabel.text = currentConfiguration.topicItem.title.uppercased()
        viewsLabel.text = String(describing: currentConfiguration.topicItem.topic.active.roundedWithAbbreviations)
        
        guard let constraint = titleLabel.getConstraint(identifier: "height") else { return }
        
        let height = "test".height(withConstrainedWidth: 100, font: titleLabel.font)
        constraint.constant = height// + 4
        self.layoutIfNeeded()
        titleLabel.cornerRadius = titleLabel.bounds.height/2.25
        
        refreshConstraints()
        viewsCountLabel.text = String(describing: 500023.roundedWithAbbreviations)
        hotCountLabel.text = String(describing: 1223.roundedWithAbbreviations)
    }

    private func setupUI() {
        addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: padding),
            horizontalStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            iconContainer.widthAnchor.constraint(equalTo: horizontalStack.widthAnchor, multiplier: 0.15)
//            horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
//            icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1/1)
//            icon.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor),
//            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
//            horizontalStack.widthAnchor.constraint(equalTo: widthAnchor),
        ])
        
        let constr = horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        constr.priority = .defaultLow
        constr.isActive = true
        
        let constraint = statsView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }

    private func setObservers() {}
    
    private func refreshConstraints() {
        guard let constraint = titleLabel.getConstraint(identifier: "width") else { return }
        
        titleLabel.insets = UIEdgeInsets(top: 0, left: titleLabel.bounds.height/3, bottom: 0, right: titleLabel.bounds.height/3)
        let width = currentConfiguration.topicItem.topic.title.width(withConstrainedHeight: titleLabel.bounds.height, font: titleLabel.font)
        
        self.setNeedsLayout()
        constraint.constant = width + titleLabel.cornerRadius*3
        self.layoutIfNeeded()
        titleLabel.frame.origin = .zero
        
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        guard let constraint_2 = statsStack.getConstraint(identifier: "height") else {
            let constraint_2 = statsStack.heightAnchor.constraint(equalToConstant: "1".height(withConstrainedWidth: 50, font: viewsCountLabel.font))
            constraint_2.identifier = "height"
            constraint_2.isActive = true
            return
        }
        constraint_2.constant = "1".height(withConstrainedWidth: 50, font: viewsCountLabel.font)
        
//        guard let constraint = titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
//              let constraint_2 = descriptionLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
//              let constraint_3 = topicLabel.getAllConstraints().filter({ $0.identifier == "width"}).first
//        else { return }
//
//        let height = item.title.height(withConstrainedWidth: titleLabel.bounds.width, font: titleLabel.font)
//        let height_2 = item.truncatedDescription.height(withConstrainedWidth: descriptionLabel.bounds.width, font: descriptionLabel.font)
//        let width = item.topic.title.width(withConstrainedHeight: topicLabel.bounds.height, font: topicLabel.font)
////        guard height != constraint.constant else { return }
//        setNeedsLayout()
//        constraint.constant = height + titleLabel.insets.top + titleLabel.insets.bottom
//        constraint_2.constant = height_2 + descriptionLabel.insets.top + descriptionLabel.insets.bottom
//        constraint_3.constant = width + topicLabel.insets.right*2.5 + topicLabel.insets.left*2.5
//        layoutIfNeeded()
//        topicStackView.updateConstraints()
//        topicLabel.frame.origin = .zero
//        avatar.imageView.image = UIImage(systemName: "face.smiling.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: avatar.bounds.size.height*0.5, weight: .regular, scale: .medium))
    }

    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        
        
        guard let item = currentConfiguration.topicItem else { return }
        
        titleLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
        (icon.icon as! CAShapeLayer).fillColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : item.topic.tagColor.cgColor
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
                                            forTextStyle: .headline)
        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .callout)
        viewsCountLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .footnote)
        hotCountLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .footnote)
        
        refreshConstraints()
    }
}
