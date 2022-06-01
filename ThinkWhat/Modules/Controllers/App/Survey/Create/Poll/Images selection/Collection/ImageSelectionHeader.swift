//
//  ImagesSelectionHeader.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class ImageSelectionHeader: UICollectionReusableView {
    
    let titleLabel = UILabel()
    let addButton = UIButton()
    var color = UIColor.systemYellow {
        didSet {
//            let largeConfig = UIImage.SymbolConfiguration(scale: .large)
//            let infoImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
//             for: .normal)
            addButton.setImage(addButton.image(for: .normal)?.withTintColor(color), for: .normal)
//            guard let image = addButton.currentImage else { return }
//            image.
        }
    }
    
    // Callback closure to handle info button tap
    var addButtonTapCallback: Closure?//(() -> Void)?

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
extension ImageSelectionHeader {
    
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

        // Setup label and add to stack view
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        stackView.addArrangedSubview(titleLabel)

        // Set button image
        let largeConfig = UIImage.SymbolConfiguration(scale: .large)
        let infoImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        addButton.setImage(infoImage, for: .normal)
        
        // Set button action
        addButton.addAction(UIAction(handler: { [unowned self] (_) in
            // Trigger callback when button tapped
            self.addButtonTapCallback?()
        }), for: .touchUpInside)
        
        // Add button to stack view
        stackView.addArrangedSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalTo: stackView.heightAnchor)
        ])
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
}

