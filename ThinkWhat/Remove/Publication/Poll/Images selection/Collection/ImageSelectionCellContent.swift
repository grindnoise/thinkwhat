//
//  ImageSelectionCellContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class ImageSelectionCellContent: UIView {

    init(configuration: ImageSelectionCellConfiguration) {
        super.init(frame: .zero)
        commonInit()
        setObservers()
        setupUI()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        descriptionLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .tertiarySystemBackground
//    }
    
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
    
//
    private var currentConfiguration: ImageSelectionCellConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? ImageSelectionCellConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    private var observers: [NSKeyValueObservation] = []
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var descriptionLabel: InsetLabel! {
        didSet {
//            descriptionLabel.backgroundColor = .secondarySystemBackground//traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        }
    }
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
}

@available(iOS 14.0, *)
extension ImageSelectionCellContent: UIContentView {
    func apply(configuration: ImageSelectionCellConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        imageView.image = currentConfiguration.image
        descriptionLabel.text = currentConfiguration.title
    }
    
    private func setupUI() {
        
    }
    
    private func setObservers() {
        observers.append(imageView.observe(\UIImageView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self,
            let rect = change.newValue else { return }
            self.imageView.cornerRadius = rect.height * 0.25
        })
        observers.append(descriptionLabel.observe(\InsetLabel.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self,
            let rect = change.newValue else { return }
            let value = rect.height * 0.1
            self.descriptionLabel.cornerRadius = rect.height * 0.25
            self.descriptionLabel.insets = UIEdgeInsets(top: value, left: value, bottom: value, right: value)
        })
    }
}
