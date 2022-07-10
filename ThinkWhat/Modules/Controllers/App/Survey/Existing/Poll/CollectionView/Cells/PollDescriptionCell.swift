//
//  PollDescriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollDescriptionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    ///Внимание, вызывается из collectionView.didSelect!
    override var isSelected: Bool { didSet { updateAppearance() } }
    var item: Survey! {
        didSet {
            guard !item.isNil else { return }
            color = item.topic.tagColor
            textView.text = item.description
//            let constraint = textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
//            constraint.identifier = "height"
//            constraint.isActive = true
//            setNeedsLayout()
//            layoutIfNeeded()
        }
    }
    
    // MARK: - Private Properties
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .systemBlue
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
        instance.text = "details".localized.uppercased()
        return instance
    }()
    private lazy var shadowView: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        instance.layer.shadowRadius = 5
        instance.layer.shadowOffset = .zero
        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
        constraint.identifier = "height"
        constraint.isActive = true
        return instance
    }()
    private lazy var textView: UITextView = {
        let instance = UITextView()
        instance.layer.masksToBounds = false
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white//.secondarySystemBackground
        instance.isEditable = false
        instance.isSelectable = false
        instance.addEquallyTo(to: shadowView)
        return instance
        }()
    private var observers: [NSKeyValueObservation] = []
    private let icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        return instance
    }()
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.tintColor = .systemBlue
        disclosureIndicator.widthAnchor.constraint(equalTo: disclosureIndicator.heightAnchor, multiplier: 1/1).isActive = true
        disclosureIndicator.contentMode = .center
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    
    // Stacks
    private lazy var horizontalStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
        let constraint = rootStack.heightAnchor.constraint(equalToConstant: 40)
        constraint.identifier = "height"
        constraint.isActive = true
        rootStack.alignment = .center
        rootStack.distribution = .fillProportionally
        return rootStack
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, shadowView])
        verticalStack.layer.masksToBounds = false
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    private var color: UIColor = .systemBlue {
        didSet {
//            textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
            disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            guard let imageView = icon.get(all: UIImageView.self).first else { return }
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    
    // Layout
    private let padding: CGFloat = 10
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        layer.masksToBounds = false
        setObservers()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = false
        layer.masksToBounds = false
        contentView.layer.masksToBounds = false
        
        disclosureLabel.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor).isActive = true
        contentView.addSubview(verticalStack)
//        contentView.addSubview(opaqueView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
//        opaqueView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
        ])

        closedConstraint =
            disclosureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
            shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        openConstraint?.priority = .defaultLow
        
//        shadowView.addEquallyTo(to: textView)
//        textView.insertSubview(shadowView, at: 0)
//        shadowView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            shadowView.widthAnchor.constraint(equalTo: textView.widthAnchor),
//            shadowView.heightAnchor.constraint(equalTo: textView.heightAnchor),
//            shadowView.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
//            shadowView.centerXAnchor.constraint(equalTo: textView.centerXAnchor),
//        ])
        
        updateAppearance()
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance() {
        closedConstraint?.isActive = isSelected
        openConstraint?.isActive = !isSelected
        
//        UIView.transition(with: disclosureLabel, duration: 0.1, options: .transitionCrossDissolve) { [unowned self] in
            //Наоборот, тк изначально ячейка не выбрана, а надо развернуто показать
//            disclosureLabel.text = !isSelected ? "hide_details".localized.uppercased() : "show_details".localized.uppercased()
//        } completion: { _ in }

        UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.disclosureIndicator.transform = !self.isSelected ? upsideDown :.identity
            self.shadowView.alpha = self.isSelected ? 0 : 1
        }
    }
    
    private func setObservers() {
        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
//                  let constraint = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let constraint = self.shadowView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue else { return }
            self.setNeedsLayout()
            constraint.constant = value.height
//            constraint2.constant = value.height
            self.layoutIfNeeded()
            self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.cornerRadius).cgPath
        })
        observers.append(textView.observe(\UITextView.bounds, options: .new, changeHandler: { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
//            self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.cornerRadius).cgPath
        }))
//        observers.append(shadowView.observe(\UIView.bounds, options: .new) { [weak self] view, change in
//            guard let self = self, let newValue = change.newValue else { return }
//            view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: 10).cgPath
//        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white
        verticalStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
            $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
        }
        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        if let imageView = icon.get(all: UIImageView.self).first {
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                          forTextStyle: .body)
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                 forTextStyle: .footnote)
        guard let constraint_1 = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
              let constraint_2 = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint_1.constant = textView.contentSize.height
        constraint_2.constant = max(String(describing: item.rating).height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font), 40)
        layoutIfNeeded()
    }
}

