//
//  ChoiceCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ChoiceCell: UICollectionViewCell {
    
    // MARK: - Public properties
    public var color: UIColor = .secondarySystemBackground {
        didSet {
            textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
        }
    }
    public var item: Answer! {
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
    
    // MARK: - Private properties
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    private let padding: CGFloat = 0
    private var observers: [NSKeyValueObservation] = []
    
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
        
        contentView.addSubview(textView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            textView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
        ])
        
        let constraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
    }
    
    private func setObservers() {
        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard let self = self,
                  let constraint = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue else { return }
            self.setNeedsLayout()
            constraint.constant = value.height
            self.layoutIfNeeded()
//            print(self.contentView.frame)
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                          forTextStyle: .body)
        guard let constraint = textView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint.constant = textView.contentSize.height
        layoutIfNeeded()
    }
    
}
