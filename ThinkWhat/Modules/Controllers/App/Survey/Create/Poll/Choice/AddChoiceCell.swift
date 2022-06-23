//
//  AddChoiceCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class AddChoiceCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var item: ChoiceItem! {
        didSet {
            guard !item.isNil else { return }
            textView.text = item.text
            let constraint = textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
            constraint.identifier = "height"
            constraint.isActive = true
            setObservers()
        }
    }
    var index = 0 {
        didSet {
//            guard oldValue != index else { return }
//            UIView.transition(with: orderLabel, duration: 0.3, options: .transitionCrossDissolve) {
                self.orderLabel.text = "edit_choice".localized + " #" + String(describing: self.index)
//            } completion: { _ in }
        }
    }
    var color: UIColor = .label {
        didSet {
            disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    override var isSelected: Bool { didSet { updateAppearance() } }
    weak var collectionView: AddChoiceCollectionView?
    
    
    // MARK: - Private Properties

    // Views
    private let orderLabel = UILabel()
    private let textView: UITextView = {
        let textView = UITextView()
        
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = false
        return textView
        }()
    private var observers: [NSKeyValueObservation] = []
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    
    // Stacks
    private lazy var horizontalStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [orderLabel, disclosureIndicator])
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
    private let padding: CGFloat = 8
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupUI()
//    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        orderLabel.textColor = .secondaryLabel
        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.performCallback)))
        horizontalStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
        
        // We need constraints that define the height of the cell when closed and when open
        // to allow for animating between the two states.
        closedConstraint =
            orderLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        openConstraint?.priority = .defaultLow
        
        updateAppearance()
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance() {
        closedConstraint?.isActive = !isSelected
        openConstraint?.isActive = isSelected
        
        UIView.animate(withDuration: 0.3) { // 0.3 seconds matches collection view animation
            // Set the rotation just under 180º so that it rotates back the same way
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.disclosureIndicator.transform = self.isSelected ? upsideDown :.identity
        }
    }
    
    private func setObservers() {
        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue else { return }
//            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            UIView.animate(withDuration: 0.2) {
                self.setNeedsLayout()
                constraint.constant = value.height
                self.layoutIfNeeded()
            }
        })
        observers.append(textView.observe(\UITextView.bounds, options: .new, changeHandler: { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let value = change.newValue else { return }
            self.textView.cornerRadius = value.width * 0.05
            self.textView.font = UIFont(name: Fonts.Regular,
                                        size: self.textView.frame.width * 0.05)
        }))
        observers.append(orderLabel.observe(\UILabel.bounds, options: .new, changeHandler: { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self else { return }
            self.orderLabel.font = UIFont(name: Fonts.Regular,
                                          size: self.orderLabel.frame.width * 0.06)

        }))
//        NotificationCenter.default.addObserver(self, selector: #selector(setNewIndex), name: Notification.Name("ChoiceItemIndex"), object: nil)
//        observers.append(item.observe(\ChoiceItem.index, options: .new, changeHandler: { [weak self] (_, index) in
//            guard let self = self else { return }
//            self.orderLabel.font = UIFont(name: Fonts.Regular,
//                                          size: self.orderLabel.frame.width * 0.06)
//
//        }))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
    
    @objc
    private func performCallback() {
        collectionView?.listener?.editChoice(item)
    }
    
//    @objc
//    private func setNewIndex() {
//        index = item.index
//    }
}


//@available(iOS 14.0, *)
//class AddChoiceCell: UICollectionViewListCell {
//    var item: ChoiceItem!
//
//    override func updateConfiguration(using state: UICellConfigurationState) {
//        var newConfiguration = AddChoiceCellConfiguration().updated(for: state)
//        newConfiguration.text = item.text
//        contentConfiguration = newConfiguration
//    }
//}
//
//@available(iOS 14.0, *)
//struct AddChoiceCellConfiguration: UIContentConfiguration, Hashable {
//
//    var text: String!
//
//    func makeContentView() -> UIView & UIContentView {
//        return AddChoiceContentView(configuration: self)
//    }
//
//    func updated(for state: UIConfigurationState) -> Self {
//        guard state is UICellConfigurationState else {
//                return self
//            }
//        let updatedConfiguration = self
//        return updatedConfiguration
//    }
//}
