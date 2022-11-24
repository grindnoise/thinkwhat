//
//  TopicHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

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
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.isNil ? .systemGray : item.topic.tagColor
//    }
    
//    override func updateConstraints() {
//        super.updateConstraints()
//
//        separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 100).isActive = true
//        separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: .greatestFiniteMagnitude).isActive = true
//    }
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
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private var currentConfiguration: TopicCellHeaderConfiguration!
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [icon, verticalStack])//, viewsLabel])
        instance.axis = .horizontal
        
        instance.spacing = 6
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [titleView, topicDescription])
        instance.axis = .vertical
//                instance.distribution = .fillEqually
        instance.spacing = 0
        return instance
    }()
//    private lazy var iconContainer: UIView = {
//        let instance = UIView()
//        instance.backgroundColor = .clear
//        instance.addSubview(icon)
//
//        icon.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            icon.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
//            icon.topAnchor.constraint(equalTo: instance.topAnchor),
//            icon.heightAnchor.constraint(equalTo: instance.heightAnchor),
//            //            icon.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
//            icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1/1)
//        ])
//
//        return instance
//    }()
    private lazy var icon: Icon = {
        let instance = Icon()
        instance.isRounded = false
        instance.scaleMultiplicator = 1.75
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.iconColor = .white
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                
                instance.cornerRadius = rect.width/3.25
            }
            .store(in: &subscriptions)
        
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
        
        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.cornerRadius = rect.height/2.25
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var topicDescription: UILabel = {
        let instance = UILabel()
        instance.text = "There's gonna be a description of the topic"
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .left
        instance.numberOfLines = 1
        instance.lineBreakMode = .byTruncatingTail
        instance.textColor = .label

        return instance
    }()
//    private let hotCountView: UIImageView = {
//        let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
//        instance.tintColor = .systemRed
//        instance.contentMode = .scaleAspectFit
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
//        return instance
//    }()
//    private lazy var hotCountLabel: UILabel = {
//        let instance = UILabel()
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption1)
//        instance.textAlignment = .center
//        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//
//        return instance
//    }()
//    private lazy var viewsCountView: UIImageView = {
//        let instance = UIImageView(image: UIImage(systemName: "eye.fill"))
//        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        instance.contentMode = .scaleAspectFit
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
//        return instance
//    }()
//    private lazy var viewsCountLabel: UILabel = {
//        let instance = UILabel()
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption1)
//        instance.textAlignment = .center
//        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//
//        return instance
//    }()
//    private lazy var statsStack: UIStackView = {
//        let instance = UIStackView(arrangedSubviews: [viewsCountView, viewsCountLabel, hotCountView, hotCountLabel,])
//        instance.alignment = .center
//        instance.spacing = 2
//        return instance
//    }()
//    private lazy var statsView: UIView = {
//        let instance = UIView()
//        instance.backgroundColor = .clear
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        instance.addSubview(statsStack)
//
//        statsStack.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            statsStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
//            statsStack.topAnchor.constraint(equalTo: instance.topAnchor),
//            statsStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//        ])
//
//        return instance
//    }()
//    @MainActor private lazy var viewsLabel: UILabel = {
//        let instance = UILabel()
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .callout)
//        instance.textAlignment = .right
//        instance.textColor = .secondaryLabel
//
//        return instance
//    }()
    private let padding: CGFloat = 10
    
    
    
    // MARK: - Initalization
    init(configuration: TopicCellHeaderConfiguration) {
        super.init(frame: .zero)
        
        setupUI()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
//        viewsCountLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        hotCountLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
                                            forTextStyle: .headline)
        topicDescription.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                  forTextStyle: .caption2)
//        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                            forTextStyle: .callout)
//        viewsCountLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
//                                                 forTextStyle: .caption1)
//        hotCountLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
//                                               forTextStyle: .caption1)
        
        refreshConstraints()
    }
}

// MARK: - Private
private extension TopicCellHeaderContent {
    func apply(configuration: TopicCellHeaderConfiguration) {
        guard currentConfiguration != configuration else { return }
        
        currentConfiguration = configuration
        
        let color = currentConfiguration.topicItem.topic.tagColor
        
        //icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.topicItem.topic.tagColor
        icon.backgroundColor = color
        titleLabel.backgroundColor = color
        icon.category = Icon.Category(rawValue: currentConfiguration.topicItem.topic.id) ?? .Null
        titleLabel.text = currentConfiguration.topicItem.title.uppercased()
//        viewsLabel.text = String(describing: currentConfiguration.topicItem.topic.active.roundedWithAbbreviations)
        
//        if currentConfiguration.topicItem.topic.hotTotal == 0 {
//            statsStack.removeArrangedSubview(hotCountView)
//            statsStack.removeArrangedSubview(hotCountLabel)
//            hotCountView.removeFromSuperview()
//            hotCountLabel.removeFromSuperview()
//        } else {
//            if !statsStack.arrangedSubviews.contains(hotCountView) { statsStack.addArrangedSubview(hotCountView) }
//            if !statsStack.arrangedSubviews.contains(hotCountLabel) { statsStack.addArrangedSubview(hotCountLabel) }
//        }
//        viewsCountLabel.text = String(describing: currentConfiguration.topicItem.topic.viewsTotal.roundedWithAbbreviations)
//        hotCountLabel.text = String(describing: currentConfiguration.topicItem.topic.hotTotal.roundedWithAbbreviations)
        
        guard let constraint = titleLabel.getConstraint(identifier: "height") else { return }
        
        let height = "test".height(withConstrainedWidth: 100, font: titleLabel.font)
        constraint.constant = height// + 4
        self.layoutIfNeeded()
        titleLabel.cornerRadius = titleLabel.bounds.height/2.25
        
        refreshConstraints()
    }

    @MainActor
    func setupUI() {
        addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: padding),
            horizontalStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            icon.widthAnchor.constraint(equalTo: horizontalStack.widthAnchor, multiplier: 0.15),
        ])
        
        let constr = horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        constr.priority = .defaultLow
        constr.isActive = true
        
                let constraint = topicDescription.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -padding)
                constraint.priority = .defaultLow
                constraint.isActive = true
        
//        let constraint = statsView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -padding)
//        constraint.priority = .defaultLow
//        constraint.isActive = true
    }
    
    @MainActor
    private func refreshConstraints() {
        guard let constraint = titleLabel.getConstraint(identifier: "width") else { return }
        
        titleLabel.insets = UIEdgeInsets(top: 0, left: titleLabel.bounds.height/3, bottom: 0, right: titleLabel.bounds.height/3)
        let width = currentConfiguration.topicItem.topic.localized.width(withConstrainedHeight: titleLabel.bounds.height, font: titleLabel.font)
        
        self.setNeedsLayout()
        constraint.constant = width + titleLabel.cornerRadius*3
        self.layoutIfNeeded()
        titleLabel.frame.origin = .zero
        
//        statsStack.translatesAutoresizingMaskIntoConstraints = false
//        guard let constraint_2 = statsStack.getConstraint(identifier: "height") else {
//            let constraint_2 = statsStack.heightAnchor.constraint(equalToConstant: "1".height(withConstrainedWidth: 50, font: viewsCountLabel.font))
//            constraint_2.identifier = "height"
//            constraint_2.isActive = true
//            return
//        }
//        constraint_2.constant = "1".height(withConstrainedWidth: 50, font: viewsCountLabel.font)
        
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
}
