//
//  PollTitleCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollTitleCell: UICollectionViewCell {
    
    // MARK: - UI
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .center
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .largeTitle)
        instance.numberOfLines = 0
        instance.textColor = .label
        return instance
    }()
    private let ratingView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "star.fill"))
        instance.tintColor = .secondaryLabel
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    private let ratingLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = .secondaryLabel
        return instance
    }()
    private let viewsView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "eye.fill"))
        instance.tintColor = .secondaryLabel
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    private let viewsLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = .secondaryLabel
        return instance
    }()
    private let bottomView: UIView = {
        let instance = UIView()
        let constraint = instance.heightAnchor.constraint(equalToConstant: 15)
        constraint.identifier = "height"
        constraint.isActive = true
        instance.backgroundColor = .clear
        return instance
    }()
    // Stacks
    private lazy var horizontalStack: UIStackView = {
        let horizontalStack = UIStackView(arrangedSubviews: [ratingView, ratingLabel, viewsView, viewsLabel])
        horizontalStack.alignment = .center
        horizontalStack.spacing = 4
        return horizontalStack
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [titleLabel, bottomView])
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        return verticalStack
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 40
    private var constraint: NSLayoutConstraint!
    
    // MARK: - Private properties
    public var item: Survey! {
        didSet {
            titleLabel.text = item.title
            ratingLabel.text = String(describing: item.rating)
            viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
            let constraint = titleLabel.heightAnchor.constraint(equalToConstant: 300)
            constraint.identifier = "height"
            constraint.isActive = true
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - Initialization
    init(_ item: Survey) {
        self.item = item
        super.init(frame: .zero)
        commonInit()
    }
    
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
        
        bottomView.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    horizontalStack.heightAnchor.constraint(equalTo: bottomView.heightAnchor),
                    horizontalStack.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
                    horizontalStack.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
                ])
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        constraint = bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    private func setObservers() {
        observers.append(titleLabel.observe(\UILabel.bounds, options: [.new]) { [weak self] view, _ in
            guard let self = self,
                  let text = view.text,
                  let constraint = view.getAllConstraints().filter({$0.identifier == "height"}).first,
                  let height = text.height(withConstrainedWidth: view.bounds.width, font: view.font) as? CGFloat,
                  height != constraint.constant else { return }
            self.setNeedsLayout()
            constraint.constant = height
            self.layoutIfNeeded()
        })
        observers.append(ratingLabel.observe(\UILabel.bounds, options: [.new]) {[weak self] view, _ in
            guard let self = self,
                  let text = view.text else { return }
            //            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.8)
            guard let constraint = self.bottomView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
            self.setNeedsLayout()
            constraint.constant = text.height(withConstrainedWidth: view.bounds.width, font: view.font)
            self.layoutIfNeeded()
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
                                            forTextStyle: .largeTitle)
        ratingLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        guard let constraint_1 = titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_2 = bottomView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint_1.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width,
                                                  font: titleLabel.font)
        constraint_2.constant = String(describing: item.rating).height(withConstrainedWidth: ratingLabel.bounds.width,
                                                                       font: ratingLabel.font)
        layoutIfNeeded()
        
    }
    
}
