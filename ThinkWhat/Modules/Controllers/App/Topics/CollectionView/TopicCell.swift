//
//  TopicCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

struct TopicCellConfiguration: UIContentConfiguration, Hashable {

    var topicItem: TopicItem!
    
    func makeContentView() -> UIView & UIContentView {
        return TopicCellContent(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard state is UICellConfigurationState else {
                return self
            }
        let updatedConfiguration = self
        return updatedConfiguration
    }
}

class TopicCell: UICollectionViewListCell {
        
    // MARK: - Public properties
    public var item: TopicItem!
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
        automaticallyUpdatesBackgroundConfiguration = false
//        accessories = state.isSelected ? [.checkmark(displayed: .always, options: UICellAccessory.CheckmarkOptions(isHidden: false, reservedLayoutWidth: nil, tintColor: self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor))] : []
        
        if state.isSelected, !callback.isNil { callback!() }
        
        var newConfiguration = TopicCellConfiguration().updated(for: state)
        newConfiguration.topicItem = item
        
        contentConfiguration = newConfiguration
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
        backgroundConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : item.topic.tagColor.withAlphaComponent(0.1)
        backgroundConfiguration = backgroundConfig

        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
        let accessoryConfig = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: UIImage(systemName: "chevron.right")), placement: .trailing(displayed: .always, at: {
            _ in 0
        }), isHidden: false, reservedLayoutWidth: nil, tintColor: tintColor, maintainsFixedSize: true)
        accessories = [UICellAccessory.customView(configuration: accessoryConfig)]
    }
}

class TopicCellContent: UIView, UIContentView {

    // MARK: - Public properties
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? TopicCellConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    
    // MARK: - Private properties
    private var currentConfiguration: TopicCellConfiguration!
    private var observers: [NSKeyValueObservation] = []
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [icon, titleLabel, viewsLabel])
        instance.axis = .horizontal
        instance.spacing = 8
        return instance
    }()
    private lazy var icon: Icon = {
        let instance = Icon()
        instance.isRounded = false
        instance.scaleMultiplicator = 1.1
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.isNil ? .systemGray : currentConfiguration.topicItem.topic.tagColor
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)
        instance.numberOfLines = 1
        instance.textColor = .label
        instance.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 300)
        constraint.identifier = "height"
        constraint.isActive = true
        
//        observers.append(instance.observe(\UILabel.bounds, options: [.new]) { [weak self] view, _ in
//            guard let self = self,
//                  let text = view.text,
//                  let constraint = view.getAllConstraints().filter({$0.identifier == "height"}).first
//            else { return }
//
//            let height = text.height(withConstrainedWidth: view.bounds.width, font: view.font)
//            guard height != constraint.constant else { return }
//
//            self.setNeedsLayout()
//            constraint.constant = height
//            self.layoutIfNeeded()
//        })
        
        return instance
    }()
    @MainActor private lazy var viewsLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .callout)
        instance.textAlignment = .right
        instance.textColor = .secondaryLabel
        
        return instance
    }()
    private let padding: CGFloat = 10
    
    // MARK: - Initalization
    init(configuration: TopicCellConfiguration) {
        super.init(frame: .zero)
        setupUI()
        setObservers()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func apply(configuration: TopicCellConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.topicItem.topic.tagColor
        icon.category = Icon.Category(rawValue: currentConfiguration.topicItem.topic.id) ?? .Null
        titleLabel.text = currentConfiguration.topicItem.title
        viewsLabel.text = String(describing: currentConfiguration.topicItem.topic.active.roundedWithAbbreviations)
        
        guard let constraint = titleLabel.getConstraint(identifier: "height"),
              let text = titleLabel.text
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = text.height(withConstrainedWidth: titleLabel.bounds.width, font: titleLabel.font)
        self.layoutIfNeeded()
    }

    private func setupUI() {
        addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//        icon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: padding/2),
            horizontalStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: padding),
//            horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1/1),
//            icon.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor),
//            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
//            horizontalStack.widthAnchor.constraint(equalTo: widthAnchor),
//            horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: padding)
        ])
        
        let constr = horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: padding/2)
        constr.priority = .defaultHigh
        constr.isActive = true
        
        let constraint = titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -padding/2)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }

    private func setObservers() {}
    
    

    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

//        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : tit
        guard let item = currentConfiguration.topicItem else { return }

        (icon.icon as! CAShapeLayer).fillColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : item.topic.tagColor.cgColor
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                            forTextStyle: .title3)
        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .callout)
        
        guard let constraint = titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        
        setNeedsLayout()
        constraint.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width, font: titleLabel.font)
        layoutIfNeeded()
    }
}
