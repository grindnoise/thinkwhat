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
            collectionView.dataItems = item.answers
//            if mode == .ReadOnly {
//                collectionView.reload(sorted: true, animatingDifferences: false, shouldChangeColor: true)
//            }
            textView.text = item.question
            let constraint_1 = textView.heightAnchor.constraint(equalToConstant: max(item.question.height(withConstrainedWidth: textView.bounds.width, font: textView.font!), 400))
            constraint_1.identifier = "height"
            constraint_1.isActive = true
            let constraint_2 = collectionView.heightAnchor.constraint(equalToConstant: 100)
//            constraint_2.priority = .defaultHigh
            constraint_2.identifier = "height"
            constraint_2.isActive = true
//            setNeedsLayout()
//            layoutIfNeeded()
        }
    }
    public var mode: PollController.Mode = .Write {
        didSet {
            guard collectionView.mode != mode else { return }
            collectionView.mode = mode
        }
    }
    public weak var boundsListener: BoundsListener? {
        didSet {
            collectionView.boundsListener = boundsListener
        }
    }
    public weak var answerListener: AnswerListener? {
        didSet {
            collectionView.answerListener = answerListener
        }
    }
    public weak var callbackDelegate: CallbackObservable?
    
    
    // MARK: - Private properties
    private lazy var headerContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 10),
            horizontalStack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -10),
            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        
        return instance
    }()
    private lazy var collectionView: ChoiceCollectionView = {
        let instance = ChoiceCollectionView(answerListener: answerListener, callbackDelegate: self)
        return instance
        }()
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.text = "poll_question".localized.uppercased()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
        return instance
    }()
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    private lazy var icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "questionmark"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        
        observers.append(imageView.observe(\UIImageView.bounds, options: .new, changeHandler: { view, change in
            guard let newValue = change.newValue else { return }
            
            view.image = UIImage(systemName: "questionmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height, weight: .light, scale: .medium))
        }))
        
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [icon, disclosureLabel])
        instance.alignment = .center
        instance.axis = .horizontal
        instance.spacing = 4
        instance.distribution = .fillProportionally
        
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: contentView.bounds.width, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)!))
        constraint.identifier = "height"
        constraint.isActive = true
        
        instance.heightAnchor.constraint(equalTo: disclosureLabel.heightAnchor).isActive = true
        
        return instance
    }()
    private lazy var containerView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 200)
//        constraint.identifier = "height"
//        constraint.isActive = true
        
//        observers.append(imageView.observe(\UIImageView.bounds, options: .new, changeHandler: { view, change in
//            guard let newValue = change.newValue else { return }
//
//            view.image = UIImage(systemName: "questionmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height, weight: .light, scale: .medium))
//        }))
        
//        collectionView.addEquallyTo(to: instance)
        instance.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: instance.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
        ])

        let constraint = instance.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        constraint.identifier = "bottom"
//        constraint.priority = .defaultLow
        constraint.isActive = true
        
        return instance
    }()
    
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [headerContainer, textView, containerView/*collectionView*/])
//        let instance = UIStackView(arrangedSubviews: [horizontalStack, textView])
        instance.axis = .vertical
        instance.clipsToBounds = false
        instance.spacing = padding
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 0
    
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
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
//            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        let constraint = collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }

    private func setObservers() {
        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.textView.getConstraint(identifier: "height"),
                  let value = change.newValue else { return }
            self.setNeedsLayout()
            constraint.constant = value.height
            self.layoutIfNeeded()
        })
        observers.append(textView.observe(\UITextView.bounds, options: .new) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let value = change.newValue else { return }
            self.textView.cornerRadius = value.width * 0.05
        })
        observers.append(collectionView.observe(\ChoiceCollectionView.contentSize, options: .new) { [weak self] view, change in
            guard let self = self,
                  let constraint = self.collectionView.getConstraint(identifier: "height"),
                  let value = change.newValue else { return }//,
//                  value.height > view.frame.height else { return }
            guard value.height != 0, constraint.constant != value.height else { return }
            
            if value.height < constraint.constant {
                delayAsync(delay: 0.3) {
                    self.setNeedsLayout()
                    constraint.constant = value.height + 50
                    self.layoutIfNeeded()
                    self.boundsListener?.onBoundsChanged(view.frame)
                }
            } else {
                self.setNeedsLayout()
                constraint.constant = value.height + 50
                self.layoutIfNeeded()
//                self.boundsListener?.onBoundsChanged(view.frame)
            }
//            self.boundsListener?.onBoundsChanged(view.frame)
        })
    }

    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }

        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                          forTextStyle: .body)
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                 forTextStyle: .caption1)
        guard let constraint_1 = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
              let constraint_2 = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint_1.constant = textView.contentSize.height
        constraint_2.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
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

//extension QuestionCell: BoundsListener {
//    func onBoundsChanged(_ rect: CGRect) {
//        source.refresh()//animatingDifferences: true)
//    }
//}
