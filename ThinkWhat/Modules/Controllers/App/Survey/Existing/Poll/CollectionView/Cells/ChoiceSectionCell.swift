//
//  ChoiceSectionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ChoiceSectionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    ///Внимание, вызывается из collectionView.didSelect!
    var owner: PollCollectionView!
    var item: Survey! {
        didSet {
            guard !item.isNil else { return }
            color = item.topic.tagColor
            collectionView.dataItems = item.answers
            let constraint = collectionView.heightAnchor.constraint(equalToConstant: 200)
            constraint.identifier = "height"
            constraint.isActive = true
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - Private Properties
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
        instance.text = "vote_noun".localized.uppercased()
        return instance
    }()
    private lazy var collectionView: ChoiceCollectionView = {
        let instance = ChoiceCollectionView(listener: self, callbackDelegate: self)
        return instance
        }()
    private var observers: [NSKeyValueObservation] = []
    private let icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "list.bullet"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        return instance
    }()
    
    // Stacks
    private lazy var horizontalStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [icon, disclosureLabel])
        let constraint = rootStack.heightAnchor.constraint(equalToConstant: 40)
        constraint.identifier = "height"
        constraint.isActive = true
        rootStack.alignment = .center
        rootStack.distribution = .fillProportionally
        return rootStack
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, collectionView])
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    // Layout
    private let padding: CGFloat = 0
    private var color: UIColor = .secondaryLabel {
        didSet {
            disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color
            guard let imageView = icon.get(all: UIImageView.self).first else { return }
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color
        }
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
        
        let constraint =
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
    }
    
    private func setObservers() {
        observers.append(collectionView.observe(\ChoiceCollectionView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.collectionView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue else { return }
            self.setNeedsLayout()
            constraint.constant = value.height
            self.layoutIfNeeded()
        })
        observers.append(collectionView.observe(\ChoiceCollectionView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                 forTextStyle: .footnote)
        guard let constraint = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint.constant = max(String(describing: item.rating).height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font), 40)
        layoutIfNeeded()
    }
    
    // MARK: - Public methods
    public func onImagesHeightChange(_ height: CGFloat) {
        print(height)
        guard let constraint = collectionView.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
        self.owner.onQuestionsHeightChange()
        self.setNeedsLayout()
        constraint.constant = height
        self.layoutIfNeeded()
//        self.owner.onQuestionsHeightChange()
//        guard let constraint = self.pollImagesContainerView.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
//        UIView.animate(withDuration: 0.2) {
//            self.scrollContentView.setNeedsLayout()
//            constraint.constant = self.imageItems.isEmpty ? 1 : height == 0 ? 1 : height
//            self.scrollContentView.layoutIfNeeded()
//        }
    }
}

extension ChoiceSectionCell: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        
    }
}
