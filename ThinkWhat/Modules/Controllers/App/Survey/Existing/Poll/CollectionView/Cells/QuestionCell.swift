//
//  QuestionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class QuestionCell: UICollectionViewCell {
    
    // MARK: - Private properties
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.text = "poll_question".localized.uppercased()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
        return instance
    }()
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    private let icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "questionmark"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [icon, disclosureLabel])
        instance.alignment = .center
        instance.axis = .horizontal
        instance.distribution = .fillProportionally
        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
        constraint.identifier = "height"
        constraint.isActive = true
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, textView])
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 0
    
    
    // MARK: - Public properties
    public var question: String! {
        didSet {
            guard let question = question else { return }
            textView.text = question
            let constraint = textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
            constraint.identifier = "height"
            constraint.isActive = true
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        setObservers()
        setupUI()
    }

    // MARK: - UI methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        disclosureLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            verticalStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        let constraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    private func setObservers() {
        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue else { return }
            self.setNeedsLayout()
            constraint.constant = value.height
            self.layoutIfNeeded()
        })
        observers.append(textView.observe(\UITextView.bounds, options: .new) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let value = change.newValue else { return }
            self.textView.cornerRadius = value.width * 0.05
//            self.textView.font = UIFont(name: Fonts.Semibold,
//                                        size: self.textView.frame.width * 0.05)
        })
//        observers.append(disclosureLabel.observe(\InsetLabel.bounds, options: .new) { [weak self] view, _ in
//            guard let self = self else { return }
//            view.insets = UIEdgeInsets(top: view.insets.top, left: self.textView.cornerRadius, bottom: view.insets.bottom, right: view.insets.right)
//        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
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
        constraint_2.constant = max(question.height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font), 40)
        layoutIfNeeded()
    }
}

