//
//  PollMediaCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollImageCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    ///Внимание, вызывается из collectionView.didSelect!
    override var isSelected: Bool { didSet { updateAppearance() } }
    var item: Survey! {
        didSet {
            guard !item.isNil else { return }
            //Prepare images
        }
    }
    
    // MARK: - Private Properties
    // Views
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        return instance
    }()
    private let imageContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .secondarySystemBackground
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        instance.backgroundColor = .red
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.tintColor = .secondaryLabel
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    
    // Stacks
    private lazy var horizontalStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [disclosureLabel, disclosureIndicator])
        rootStack.alignment = .center
        rootStack.distribution = .fillProportionally
        return rootStack
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, imageContainer])
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
        horizontalStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        disclosureLabel.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor).isActive = true
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),//, constant: padding),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])

        closedConstraint =
            disclosureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
            imageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        openConstraint?.priority = .defaultLow
        //Наоборот, тк изначально ячейка не выбрана, а надо развернуто показать
        disclosureLabel.text = !isSelected ? "hide_details".localized.uppercased() : "show_details".localized.uppercased()
        updateAppearance()
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance() {
        closedConstraint?.isActive = isSelected
        openConstraint?.isActive = !isSelected
        
        UIView.transition(with: disclosureLabel, duration: 0.1, options: .transitionCrossDissolve) { [unowned self] in
            //Наоборот, тк изначально ячейка не выбрана, а надо развернуто показать
            disclosureLabel.text = !isSelected ? "hide_details".localized.uppercased() : "show_details".localized.uppercased()
        } completion: { _ in }

        UIView.animate(withDuration: 0.3) {
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.disclosureIndicator.transform = !self.isSelected ? upsideDown :.identity
        }
    }
    
    private func setObservers() {
//        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
//            guard let self = self,
//                  let constraint = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
//                  let value = change.newValue else { return }
//            self.setNeedsLayout()
//            constraint.constant = value.height
//            self.layoutIfNeeded()
//        })
        observers.append(imageContainer.observe(\UITextView.bounds, options: .new, changeHandler: { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        }))
        observers.append(disclosureLabel.observe(\UILabel.bounds, options: .new, changeHandler: { view, change in
            guard let newValue = change.newValue else { return }
            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.3)
        }))
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    }
}
