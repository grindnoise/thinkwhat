//
//  TopicSelectionHeaderModernContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//


import UIKit

@available(iOS 14.0, *)
class TopicSelectionHeaderModernContent: UIView {

    init(configuration: TopicSelectionModernHeaderConfiguration) {
        super.init(frame: .zero)
        commonInit()
        setObservers()
//        setupUI()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        backgroundColor = .tertiarySystemBackground
        (icon.icon as! CAShapeLayer).fillColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : currentConfiguration.topicItem.topic.tagColor.cgColor
    }

    private var currentConfiguration: TopicSelectionModernHeaderConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? TopicSelectionModernHeaderConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    private var observers: [NSKeyValueObservation] = []

    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var icon: Icon! {
        didSet {
            icon.scaleMultiplicator = 1.3
            icon.isRounded = false
        }
    }
    @IBOutlet weak var titleLabel: InsetLabel! {
        didSet {
//            titleLabel.textColor = .secondaryLabel
        }
    }
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!
}

@available(iOS 14.0, *)
extension TopicSelectionHeaderModernContent: UIContentView {
    func apply(configuration: TopicSelectionModernHeaderConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.topicItem.topic.tagColor
        icon.category = Icon.Category(rawValue: currentConfiguration.topicItem.topic.id) ?? .Null
        titleLabel.text = currentConfiguration.topicItem.title.uppercased()
        height.constant = 60
        leading.constant = 0
    }

    private func setupUI() {
//        contentView.backgroundColor = .blue
    }

    private func setObservers() {
        observers.append(titleLabel.observe(\InsetLabel.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self,
            let rect = change.newValue else { return }
            self.titleLabel.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: rect.height * 0.35)
        })
    }
}
