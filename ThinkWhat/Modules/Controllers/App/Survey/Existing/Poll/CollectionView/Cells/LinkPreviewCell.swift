//
//  LinkPreviewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import LinkPresentation

class LinkPreviewCell: UICollectionViewCell {
    
    // MARK: - Overriden properties
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    // MARK: - Public Properties
    var item: Survey! {
        didSet {
            guard !item.isNil, !item.url.isNil else { return }
            guard let url = item.url else { return }
            LPMetadataProvider().startFetchingMetadata(for: url) { [weak self] data, error in
                guard let self = self, let data = data, error.isNil else { return }
                Task {
                    self.linkPreview.metadata = data
                }
            }
        }
    }
    public weak var callbackDelegate: CallbackObservable?
    
    // MARK: - Private Properties
    private lazy var headerContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 10),
            horizontalStack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -10),
            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor, constant: -10),
        ])
        
        return instance
    }()
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = false
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
        instance.addEquallyTo(to: shadowView)
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = max(value.height, value.width) * 0.05
        })
        return instance
    }()
    private lazy var disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.text = "web_link".localized.uppercased()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
        instance.textColor = .secondaryLabel
        instance.addEquallyTo(to: shadowView)
//                let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
//                constraint.identifier = "height"
//                constraint.isActive = true
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private lazy var disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.tintColor = .secondaryLabel
        disclosureIndicator.contentMode = .center
        disclosureIndicator.widthAnchor.constraint(equalTo: disclosureIndicator.heightAnchor, multiplier: 1/1).isActive = true
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    private lazy var icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "link"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        
        observers.append(imageView.observe(\UIImageView.bounds, options: .new, changeHandler: { view, change in
            guard let newValue = change.newValue else { return }
            
            view.image = UIImage(systemName: "link", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height, weight: .light, scale: .medium))
        }))
        
        return instance
    }()
    // Stacks
    private lazy var horizontalStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
        rootStack.alignment = .center
        rootStack.distribution = .fillProportionally
        rootStack.spacing = 4
        
        let constraint = rootStack.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: contentView.bounds.width, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)!))
        constraint.identifier = "height"
        constraint.isActive = true
       
        return rootStack
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [headerContainer, shadowView])//, browserButton])
        verticalStack.axis = .vertical
        verticalStack.spacing = 0
        return verticalStack
    }()
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    private lazy var shadowView: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        instance.layer.shadowRadius = 4
        instance.layer.shadowOffset = .zero
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 9/16).isActive = true
        observers.append(instance.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { view, change in
            guard let value = change.newValue else { return }
            view.layer.shadowPath = UIBezierPath(roundedRect: value, cornerRadius: value.width*0.05).cgPath
        })
        return instance
    }()
    @MainActor private lazy var linkPreview: LPLinkView = {
        let instance = LPLinkView()
        instance.addEquallyTo(to: background)
        opaqueView.addEquallyTo(to: background)
        return instance
    }()
    private lazy var opaqueView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.layer.zPosition = 10
        instance.accessibilityIdentifier = "opaqueView"
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.openURL))
        instance.addGestureRecognizer(recognizer)
        return instance
    }()
    private let padding: CGFloat = 10
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setObservers()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
//        horizontalStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        disclosureLabel.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor).isActive = true
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
        ])
        
        closedConstraint = disclosureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint = linkPreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
        openConstraint?.priority = .defaultLow

        updateAppearance(animated: false)
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance(animated: Bool = true) {
        closedConstraint?.isActive = isSelected
        openConstraint?.isActive = !isSelected

        guard animated else {
            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2)
            self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2)
            self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
        }
    }
    
    private func setObservers() {}
    
    @objc
    private func openURL() {
        guard let url = item.url else { return }
        callbackDelegate?.callbackReceived(url as Any)
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        verticalStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
            $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
        }
        
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white
//        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        if let imageView = icon.get(all: UIImageView.self).first {
//            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                 forTextStyle: .caption1)
        guard let constraint = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
        layoutIfNeeded()
    }
}
