//
//  ImagesSelectionHeader.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class delImageSelectionHeader: UICollectionReusableView {
    
    let titleLabel = UILabel()
    let addButton = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
    var color = UIColor.systemYellow {
        didSet {
            addButton.tintColor = color
        }
    }
    
    // Callback closure to handle info button tap
    var addButtonTapCallback: Closure?//(() -> Void)?
    private var currentConfiguration: delImageSelectionHeaderConfiguration!
    private var observers: [NSKeyValueObservation] = []
    
    init(configuration: delImageSelectionHeaderConfiguration) {
        super.init(frame: .zero)
        configure()
        apply(configuration: configuration)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        addButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
    
    public func setTintColor(_ _color: UIColor) {
        
    }
    
}

@available(iOS 14.0, *)
extension delImageSelectionHeader {
    
    func configure() {
        
        // Add a stack view to section container
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        // Adjust top anchor constant & priority
        let topAnchor = stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 15)
        topAnchor.priority = UILayoutPriority(999)

        // Adjust bottom anchor constant & priority
        let bottomAnchor = stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -10)
        bottomAnchor.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: 40),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            topAnchor,
            bottomAnchor,
        ])

        stackView.addArrangedSubview(titleLabel)
        titleLabel.textColor = .secondaryLabel
//        // Set button image
//        let largeConfig = UIImage.SymbolConfiguration(scale: .large)
//        let infoImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
//        addButton.setImage(infoImage, for: .normal)
//
//        // Set button action
//        addButton.addAction(UIAction(handler: { [unowned self] (_) in
//            // Trigger callback when button tapped
//            self.addButtonTapCallback?()
//        }), for: .touchUpInside)
        addButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        addButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        
        // Add button to stack view
        stackView.addArrangedSubview(addButton)
        addButton.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            addButton.widthAnchor.constraint(equalTo: stackView.heightAnchor)
        ])
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        
        observers.append(titleLabel.observe(\UILabel.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let rect = change.newValue else { return }
            self.titleLabel.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: rect.height * 0.5)
        })
    }
    
    @objc
    private func handleTap() {
        addButtonTapCallback?()
    }
}

@available(iOS 14.0, *)
extension delImageSelectionHeader: UIContentView {
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? delImageSelectionHeaderConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    
    func apply(configuration: delImageSelectionHeaderConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        titleLabel.text = "total_images".localized.capitalized +  ": \(currentConfiguration.count!)/3"
    }
    
}

@available(iOS 14.0, *)
struct delImageSelectionHeaderConfiguration: UIContentConfiguration, Hashable {

    var count: Int!
    
    func makeContentView() -> UIView & UIContentView {
        return delImageSelectionHeader(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard state is UICellConfigurationState else {
                return self
            }
        let updatedConfiguration = self
        return updatedConfiguration
    }
}
