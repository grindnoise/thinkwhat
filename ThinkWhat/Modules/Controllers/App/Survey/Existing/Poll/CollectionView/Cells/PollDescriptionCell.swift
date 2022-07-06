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
            textView.text = item.description
            let constraint = textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
            constraint.identifier = "height"
            constraint.isActive = true
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - Private Properties
    // Views
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
        instance.text = "details".localized.uppercased()
        return instance
    }()
    private let textView: UITextView = {
        let instance = UITextView()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        instance.backgroundColor = .secondarySystemBackground
        instance.isEditable = false
        instance.isSelectable = false
        return instance
        }()
    private var observers: [NSKeyValueObservation] = []
    private let icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        return instance
    }()
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.tintColor = .secondaryLabel
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
        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, textView])
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    
    // Layout
    private let padding: CGFloat = 0
    
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

        closedConstraint =
            disclosureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        openConstraint?.priority = .defaultLow
        
//        disclosureLabel.text = !isSelected ? "hide_details".localized.uppercased() : "show_details".localized.uppercased()
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

        UIView.animate(withDuration: 0.3) {
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.disclosureIndicator.transform = !self.isSelected ? upsideDown :.identity
        }
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
        observers.append(textView.observe(\UITextView.bounds, options: .new, changeHandler: { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let value = change.newValue else { return }
            self.textView.cornerRadius = value.width * 0.05
        }))
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
        constraint_2.constant = max(String(describing: item.rating).height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font), 40)
        layoutIfNeeded()
    }
}

