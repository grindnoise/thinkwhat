//
//  ImageSelectionHeaderContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 06.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class ImageSelectionHeaderContent: UIView {

    init(configuration: ImageSelectionHeaderConfiguration) {
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
        addButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }

    @objc
    private func handleTap() {
        addButtonTapCallback?()
    }
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        contentView.backgroundColor = .tertiarySystemBackground
//    }

    private var currentConfiguration: ImageSelectionHeaderConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? ImageSelectionHeaderConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    var addButtonTapCallback: Closure?
    var color = UIColor.systemYellow {
        didSet {
            print(color)
            addButton.tintColor = color
        }
    }
    private var observers: [NSKeyValueObservation] = []

    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var addButton: UIImageView! {
        didSet {
            addButton.isUserInteractionEnabled = true
            addButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            addButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        }
    }
    @IBOutlet weak var titleLabel: InsetLabel!
    @IBOutlet weak var height: NSLayoutConstraint!
}

@available(iOS 14.0, *)
extension ImageSelectionHeaderContent: UIContentView {
    func apply(configuration: ImageSelectionHeaderConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        titleLabel.text = "total_images".localized.capitalized +  ": \(currentConfiguration.count!)/3"
        color = currentConfiguration.color
        height.constant = 60
    }

    private func setupUI() {
//        contentView.backgroundColor = .blue
    }

    private func setObservers() {
        observers.append(titleLabel.observe(\InsetLabel.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self,
            let rect = change.newValue else { return }
            self.titleLabel.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: rect.height * 0.4)
        })
    }
}

