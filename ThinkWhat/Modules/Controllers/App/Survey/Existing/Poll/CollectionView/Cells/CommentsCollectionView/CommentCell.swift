//
//  CommentCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
//    // MARK: - Override
//    override var isSelected: Bool { didSet { updateAppearance() }}
//    
//    // MARK: - Public properties
//    public var item: Answer! {
//        didSet {
//            guard !item.isNil else { return }
//            textView.text = item.description
//            let constraint = textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
//            constraint.identifier = "height"
//            constraint.isActive = true
//            setNeedsLayout()
//            layoutIfNeeded()
//            guard let _color = item.survey?.topic.tagColor else { return }
//            color = _color
//        }
//    }
//    
//    // MARK: - Private properties
//    private lazy var textView: UITextView = {
//        let instance = UITextView()
//        instance.isUserInteractionEnabled = false
//        instance.backgroundColor = .secondarySystemBackground
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
//        instance.isEditable = false
//        instance.isSelectable = false
//        return instance
//    }()
//    private let padding: CGFloat = 8
//    private var observers: [NSKeyValueObservation] = []
//    private var color: UIColor = .secondarySystemBackground {
//        didSet {
//            textView.backgroundColor = isSelected ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color.withAlphaComponent(0.4) : traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
//        }
//    }
//    
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setObservers()
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Private methods
//    private func setupUI() {
//        backgroundColor = .clear
//        clipsToBounds = true
//        
//        contentView.addSubview(textView)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*2),
//            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
////            textView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
//        ])
//        
//        let constraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        constraint.priority = .defaultLow
//        constraint.isActive = true
//    }
//    
//    private func setObservers() {
//        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
//            guard let self = self,
//                  let constraint = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
//                  let value = change.newValue else { return }
//            self.setNeedsLayout()
//            constraint.constant = value.height
//            self.layoutIfNeeded()
//        })
//        observers.append(textView.observe(\UITextView.bounds, options: .new) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
//            guard let self = self, let value = change.newValue else { return }
//            self.textView.cornerRadius = value.width * 0.05
//        })
//    }
//    
//    // MARK: - UI methods
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        textView.backgroundColor = isSelected ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color.withAlphaComponent(0.4) : traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
//        
//        //Set dynamic font size
//        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
//        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                          forTextStyle: .body)
//        guard let constraint = textView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
//        setNeedsLayout()
//        constraint.constant = textView.contentSize.height
//        layoutIfNeeded()
//    }
//    
//    private func updateAppearance() {
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
//            self.textView.backgroundColor = self.isSelected ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.4) : self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : self.color.withAlphaComponent(0.1)
//        } completion: { _ in}
//    }
    
}
