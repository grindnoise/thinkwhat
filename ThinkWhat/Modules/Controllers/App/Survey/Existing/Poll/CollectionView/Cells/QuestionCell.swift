//
//  QuestionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class QuestionCell: UICollectionViewCell {
    
    // MARK: - Public properties
    public var item: Survey! {
        didSet {
            guard !item.isNil else { return }
            color = item.topic.tagColor
            collectionView.dataItems = item.answers
            if mode == .ReadOnly {
                collectionView.reloadUsingSorting()
            }
            textView.text = item.question
            let constraint_1 = textView.heightAnchor.constraint(equalToConstant: max(item.question.height(withConstrainedWidth: textView.bounds.width, font: textView.font!), 40))
            constraint_1.identifier = "height"
            constraint_1.isActive = true
            let constraint_2 = collectionView.heightAnchor.constraint(equalToConstant: 1)
            constraint_2.priority = .defaultHigh
            constraint_2.identifier = "height"
            constraint_2.isActive = true
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    public var mode: PollController.Mode = .Write {
        didSet {
            guard collectionView.mode != mode else { return }
            collectionView.mode = mode
        }
    }
    public weak var boundsListener: BoundsListener?
    public weak var answerListener: AnswerListener? {
        didSet {
            collectionView.answerListener = answerListener
        }
    }
    public weak var callbackDelegate: CallbackObservable?
    
    
    // MARK: - Private properties
    private lazy var collectionView: ChoiceCollectionView = {
        let instance = ChoiceCollectionView(answerListener: answerListener, callbackDelegate: self)
        return instance
        }()
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.text = "poll_question".localized.uppercased()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
        return instance
    }()
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.SemiboldItalic.rawValue, forTextStyle: .headline)
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
        let instance = UIStackView(arrangedSubviews: [horizontalStack, textView, collectionView])
//        let instance = UIStackView(arrangedSubviews: [horizontalStack, textView])
        instance.axis = .vertical
        instance.clipsToBounds = false
        instance.spacing = padding
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 0
    private var color: UIColor = .secondaryLabel {
        didSet {
//            textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
            disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            guard let imageView = icon.get(all: UIImageView.self).first else { return }
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
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
        })
        observers.append(collectionView.observe(\ChoiceCollectionView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.collectionView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue,
                      value.height != constraint.constant else { return }
            self.setNeedsLayout()
            constraint.constant = value.height
            self.layoutIfNeeded()
            self.boundsListener?.onBoundsChanged(view.frame)
        })
    }

    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

//        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        if let imageView = icon.get(all: UIImageView.self).first {
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }

        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }

        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Italic.rawValue,
                                          forTextStyle: .headline)
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                                 forTextStyle: .footnote)
        guard let constraint_1 = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
              let constraint_2 = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint_1.constant = textView.contentSize.height
        constraint_2.constant = max(item.question.height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font), 40)
        layoutIfNeeded()
    }
}

// MARK: - CallbackObservable
extension QuestionCell: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        //Passthrough
        callbackDelegate?.callbackReceived(sender)
    }
}
