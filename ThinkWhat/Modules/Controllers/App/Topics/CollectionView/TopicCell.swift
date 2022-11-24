//
//  TopicCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

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
        
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    // MARK: - Public properties
    public var item: TopicItem!
    public var callback: Closure?
    public var touchSubject = PassthroughSubject<[Topic: CGPoint], Never>()
    
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
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
        addGestureRecognizer(tapRecognizer)
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

//        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
//        let accessoryConfig = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: UIImage(systemName: "chevron.right")), placement: .trailing(displayed: .always, at: {
//            _ in 0
//        }), isHidden: false, reservedLayoutWidth: nil, tintColor: tintColor, maintainsFixedSize: true)
//        accessories = [UICellAccessory.customView(configuration: accessoryConfig)]
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first
//        guard let point = touch?.location(in: self) else { return }
//
//        super.touchesBegan(touches, with: event)
//        guard let item = item else { return }
//        touchSubject.send([item.topic: point])
//    }
    
    override func prepareForReuse() {
//        touchSubject = .init(nil)
        super.prepareForReuse()
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        guard let item = item else { return }
        touchSubject.send([item.topic: recognizer.location(ofTouch: 0, in: self)])
    }
}

class TopicCellContent: UIView, UIContentView {
    
    // MARK: - Public properties
    public var configuration: UIContentConfiguration {
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
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private var currentConfiguration: TopicCellConfiguration!
    private lazy var horizontalStack: UIStackView = {
        let opaque = UIView()
        opaque.backgroundColor = .clear
        
        let instance = UIStackView(arrangedSubviews: [topicStack, opaque, viewsLabel])
        instance.axis = .horizontal
        instance.spacing = 4
        return instance
    }()
    private lazy var topicStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            topicLabel,
            topicDescription
        ])
        instance.axis = .vertical
        instance.alignment = .leading
        instance.spacing = 4
        
        return instance
    }()
    private lazy var topicLabel: UIView = {
        let instance = UIStackView(arrangedSubviews: [
            topicIcon,
            topicTitle
        ])
        instance.axis = .horizontal
        instance.spacing = 2
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                
                instance.cornerRadius = rect.height/2.25
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var topicDescription: UILabel = {
        let instance = UILabel()
        instance.text = "There's gonna be a description of the topic"
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
        instance.textAlignment = .left
        instance.numberOfLines = 1
        instance.lineBreakMode = .byTruncatingTail
        instance.textColor = .label
        
        return instance
    }()
    private lazy var topicIcon: Icon = {
        let instance = Icon()
        instance.isRounded = false
        instance.iconColor = .white
        instance.scaleMultiplicator = 1.75
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//        instance.iconColor = currentConfiguration.isNil ? .systemGray : currentConfiguration.topicItem.topic.tagColor
        return instance
    }()
    private lazy var topicTitle: InsetLabel = {
        let instance = InsetLabel()
        instance.textAlignment = .center
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .headline)
        instance.numberOfLines = 1
        instance.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        instance.textColor = .white
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
        instance.textColor = .label
        
        return instance
    }()
    private let padding: CGFloat = 10
    
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
    
    // MARK: - Initalization
    init(configuration: TopicCellConfiguration) {
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
        
        guard let item = currentConfiguration.topicItem else { return }
        
//        (topicIcon.icon as! CAShapeLayer).fillColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : item.topic.tagColor.cgColor
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        topicTitle.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                            forTextStyle: .title3)
        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .callout)
        
        guard let constraint = topicTitle.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        
        setNeedsLayout()
        constraint.constant = item.title.height(withConstrainedWidth: topicTitle.bounds.width, font: topicTitle.font)
        layoutIfNeeded()
    }
}

// MARK: - Private
private extension TopicCellContent {
    func apply(configuration: TopicCellConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
//        topicIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.topicItem.topic.tagColor
        topicIcon.category = Icon.Category(rawValue: currentConfiguration.topicItem.topic.id) ?? .Null
        topicTitle.text = currentConfiguration.topicItem.title.uppercased()
        viewsLabel.text = String(describing: currentConfiguration.topicItem.topic.active.roundedWithAbbreviations)
        topicLabel.backgroundColor = currentConfiguration.topicItem.topic.tagColor
        
        guard let constraint = topicTitle.getConstraint(identifier: "height") else { return }
        
        setNeedsLayout()
        //One line needed
        constraint.constant = "string".height(withConstrainedWidth: topicTitle.bounds.width, font: topicTitle.font)
        layoutIfNeeded()
    }
    
    @MainActor
    func setupUI() {
        addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        //        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        //        icon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: padding/2),
            horizontalStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: padding),
            topicLabel.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 100, font: topicTitle.font)),
            //            iconContainer.widthAnchor.constraint(equalTo: horizontalStack.widthAnchor, multiplier: 0.15)
            //            horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            //            icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1/1),
            //            icon.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor),
            //            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
            //            horizontalStack.widthAnchor.constraint(equalTo: widthAnchor),
            //            horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: padding)
        ])
        
        let constr = horizontalStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: padding/2)
        constr.priority = .defaultHigh
        constr.isActive = true
        
        let constraint = topicDescription.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -padding/2)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
}
