//
//  ChoiceCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ChoiceCell: UICollectionViewCell {
    
    // MARK: - Override
    override var isSelected: Bool { didSet { updateAppearance() }}
    
    // MARK: - Public properties
    public var item: Answer! {
        didSet {
            guard !item.isNil else { return }
            textView.text = item.description
            let constraint = textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
            constraint.identifier = "height"
            constraint.isActive = true
            setNeedsLayout()
            layoutIfNeeded()
            guard let _color = item.survey?.topic.tagColor else { return }
            color = _color
        }
    }
    
    // MARK: - Private properties
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = false
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
        instance.addEquallyTo(to: shadowView)
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
//        constraint.identifier = "height"
//        constraint.isActive = true
        return instance
    }()
    private lazy var selectionView: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "selection"
        instance.alpha = 0
        instance.layer.masksToBounds = false
        instance.backgroundColor = .systemBackground
        background.insertSubview(instance, belowSubview: textView)
        instance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instance.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            instance.topAnchor.constraint(equalTo: background.topAnchor),
            instance.bottomAnchor.constraint(equalTo: background.bottomAnchor),
        ])
        let constraint = instance.widthAnchor.constraint(equalToConstant: 0)
        constraint.identifier = "width"
        constraint.isActive = true
//        instance.addEquallyTo(to: background)
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
//        constraint.identifier = "height"
//        constraint.isActive = true
        return instance
    }()
    private lazy var shadowView: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        instance.layer.shadowRadius = 5
        instance.layer.shadowOffset = .zero
        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
        constraint.identifier = "height"
        constraint.isActive = true
//        instance.addEquallyTo(to: background)
        return instance
    }()
    private lazy var textView: UITextView = {
        let instance = UITextView()
        instance.isUserInteractionEnabled = false
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        instance.backgroundColor = .clear
        instance.isEditable = false
        instance.isSelectable = false
        instance.addEquallyTo(to: background)
        return instance
    }()
    private let padding: CGFloat = 10
    private var observers: [NSKeyValueObservation] = []
    private var color: UIColor = .secondarySystemBackground {
        didSet {
            selectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.4)
            background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
            textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .clear : color.withAlphaComponent(0.1)
        }
    }
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [shadowView])
        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
        constraint.identifier = "height"
        constraint.isActive = true
        instance.alignment = .center
        instance.clipsToBounds = false
        instance.distribution = .fillProportionally
        return instance
    }()
    
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
        
        contentView.addSubview(horizontalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*2),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
//            textView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
        ])
        
        let constraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    private func setObservers() {
        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.shadowView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue else { return }
            self.setNeedsLayout()
            constraint.constant = value.height
            self.layoutIfNeeded()
            self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.cornerRadius).cgPath
        })
        observers.append(textView.observe(\UITextView.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
            self.background.cornerRadius = view.cornerRadius
            self.selectionView.cornerRadius = view.cornerRadius
        })
//        observers.append(background.observe(\UITextView.bounds, options: .new) { view, change in
//            guard let value = change.newValue else { return }
//            view.cornerRadius = value.width * 0.05
//        })
    }
    
    // MARK: - UI methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        horizontalStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
            $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
        }
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
        selectionView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.4)
        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .clear : color.withAlphaComponent(0.1)
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                          forTextStyle: .body)
        guard let constraint = textView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint.constant = textView.contentSize.height
        layoutIfNeeded()
    }
    
    private func updateAppearance() {
        guard let constraint = selectionView.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
            self.selectionView.alpha =  self.isSelected ? 1 : 0
            self.horizontalStack.setNeedsLayout()
            constraint.constant = self.isSelected ? self.background.frame.width : 0
            self.horizontalStack.layoutIfNeeded()
//            self.textView.backgroundColor = self.isSelected ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.4) : self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : self.color.withAlphaComponent(0.1)
        } completion: { _ in}
    }
    
}
