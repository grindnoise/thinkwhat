//
//  ChoiceCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ChoiceCell: UICollectionViewCell {
    
    // MARK: - Override
    override var isSelected: Bool { didSet { updateAppearance() }}
    
    // MARK: - Public properties
    public var item: Answer! {
        didSet {
            guard !item.isNil else { return }
            textView.text = item.description
            let constraint = textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
            constraint.identifier = "height"
            constraint.isActive = true
            setNeedsLayout()
            layoutIfNeeded()
            guard let _color = item.survey?.topic.tagColor else { return }
            color = _color
        }
    }
    public var mode: PollController.Mode = .Write {
        didSet {
            guard oldValue != mode, mode == .ReadOnly, !leadingConstraint.isNil, !trailingConstraint.isNil else { return }
            guard let constraint = votersView.getAllConstraints().filter({ $0.identifier == "width" }).first else { return }
//            setupVotersView()
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                self.setNeedsLayout()
                constraint.constant = self.contentView.bounds.width/4
                self.shadowView.layer.shadowOpacity = 0
                self.leadingConstraint.constant = 0
                self.trailingConstraint.constant = 0
                self.layoutIfNeeded()
            } completion: { _ in
                self.setupVotersView()
                delayAsync(delay: 0.2) {
                    self.shadowView.layer.shadowOpacity = 1
                }
            }
        }
    }
    public weak var host: ChoiceCollectionView?
    public var isChosen = false
    
    // MARK: - Private properties
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = false
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
        instance.addEquallyTo(to: shadowView)
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
//        constraint.identifier = "height"
//        constraint.isActive = true
        return instance
    }()
    private lazy var selectionView: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "selection"
        instance.alpha = 0
        instance.layer.masksToBounds = false
        instance.backgroundColor = .systemBackground
        background.insertSubview(instance, belowSubview: textView)
        instance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instance.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            instance.topAnchor.constraint(equalTo: background.topAnchor),
            instance.bottomAnchor.constraint(equalTo: background.bottomAnchor),
        ])
        let constraint = instance.widthAnchor.constraint(equalToConstant: 0)
        constraint.identifier = "width"
        constraint.isActive = true
//        instance.addEquallyTo(to: background)
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
//        constraint.identifier = "height"
//        constraint.isActive = true
        return instance
    }()
    private lazy var shadowView: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        instance.layer.shadowRadius = 4
        instance.layer.shadowOffset = .zero
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
//        constraint.identifier = "height"
//        constraint.isActive = true
//        instance.addEquallyTo(to: background)
        return instance
    }()
    private lazy var textView: UITextView = {
        let instance = UITextView()
        instance.isUserInteractionEnabled = false
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        instance.backgroundColor = .clear
        instance.isEditable = false
        instance.isSelectable = false
        instance.addEquallyTo(to: background)
        return instance
    }()
    private lazy var votersView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "voters"
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.clipsToBounds = true
        let constraint = instance.widthAnchor.constraint(equalToConstant: 0)
        constraint.identifier = "width"
        constraint.isActive = true
        
        instance.addSubview(avatarsStackView)
        avatarsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarsStackView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.9),
            avatarsStackView.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
            avatarsStackView.centerYAnchor.constraint(equalTo: instance.centerYAnchor),
            avatarsStackView.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)!)*1.5)
        ])
        return instance
    }()
    private lazy var avatarsStackView: UIStackView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.accessibilityIdentifier = "chevron"
        imageView.clipsToBounds = true
        imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        imageView.contentMode = .center
        let instance = UIStackView(arrangedSubviews: [avatarsView, imageView])
        instance.spacing = 0
        return instance
    }()
    private lazy var avatarsView: UIView = {
       let instance = UIView()
        instance.backgroundColor = .clear
        instance.clipsToBounds = true
        return instance
    }()
    
    private let padding: CGFloat = 10
    private var observers: [NSKeyValueObservation] = []
    private var color: UIColor = .secondarySystemBackground {
        didSet {
            selectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.5)
            background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
            textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .clear : color.withAlphaComponent(0.2)
            avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "chevron" }).forEach({ $0.tintColor = color })
        }
    }
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [shadowView, votersView])
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
//        constraint.identifier = "height"
//        constraint.isActive = true
        instance.alignment = .center
        instance.clipsToBounds = false
//        instance.distribution = .fillProportionally
        return instance
    }()
    private var leadingConstraint: NSLayoutConstraint! {
        didSet {
            leadingConstraint.isActive = true
        }
    }
    private var trailingConstraint: NSLayoutConstraint! {
        didSet {
            trailingConstraint.isActive = true
        }
    }
    private var topConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint.isActive = true
        }
    }
    private var avatars: [Avatar] = []
    
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
        
        contentView.addSubview(horizontalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        leadingConstraint = horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mode == .ReadOnly ? 0 : padding*2)
        trailingConstraint = horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: mode == .ReadOnly ? 0 : -padding)
        topConstraint = horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            textView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            votersView.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor)
        ])
        
        let constraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    private func setObservers() {
        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue,
                  value.height >= self.textView.frame.height else { return }
            
            UIView.animate(withDuration: 0.15, delay: 0, animations: {
                self.contentView.setNeedsLayout()
                constraint.constant = value.height
                self.contentView.layoutIfNeeded()
            }) { _ in
//                self.host?.refresh()
                print(self.topConstraint.constant)
                self.updateConstraints()
            }
            
            let destinationPath = UIBezierPath(roundedRect: view.bounds,
                                               cornerRadius: self.shadowView.bounds.width * 0.05).cgPath
            let anim = Animations.get(property: .ShadowPath,
                                      fromValue: self.shadowView.layer.shadowPath as Any,
                                      toValue: destinationPath,
                                      duration: 0.2,
                                      delay: 0,
                                      repeatCount: 0,
                                      autoreverses: false,
                                      timingFunction: .linear,
                                      delegate: nil,
                                      isRemovedOnCompletion: true,
                                      completionBlocks: nil)
            self.shadowView.layer.add(anim, forKey: nil)
            self.shadowView.layer.shadowPath = destinationPath
//            self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.cornerRadius).cgPath
        })
        observers.append(textView.observe(\UITextView.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
            self.background.cornerRadius = view.cornerRadius
            self.selectionView.cornerRadius = view.cornerRadius
        })
//        observers.append(background.observe(\UITextView.bounds, options: .new) { view, change in
//            guard let value = change.newValue else { return }
//            view.cornerRadius = value.width * 0.05
//        })
    }
    
    private func setupVotersView() {
#if DEBUG
        let inset: CGFloat = (avatarsView.bounds.height*3 - avatarsView.bounds.width)/4
        
        for i in 0...2 {
            let avatar = Avatar(gender: .Male, borderColor: traitCollection.userInterfaceStyle == .dark ? .black : .white)
            avatar.layer.zPosition = 10 - CGFloat(i)
            avatars.append(avatar)
            avatarsView.addSubview(avatar)
            avatar.layer.masksToBounds = false
            avatar.translatesAutoresizingMaskIntoConstraints = false
            let centerY = avatar.centerYAnchor.constraint(equalTo: avatarsView.centerYAnchor)
            centerY.identifier = "centerY"
            centerY.isActive = true
            avatar.heightAnchor.constraint(equalTo: avatarsView.heightAnchor).isActive = true
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor).isActive = true
            
            if i == 0 {
                avatar.image = UIImage(systemName: "checkmark.seal.fill")
                avatar.leadingAnchor.constraint(equalTo: avatarsView.leadingAnchor, constant: 0).isActive = true
                avatar.imageView.tintColor = color
                avatar.imageView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
            } else {
                avatar.leadingAnchor.constraint(equalTo: avatars[i-1].leadingAnchor, constant: inset).isActive = true
            }
        }
#else
        guard item.totalVotes != 0 else {
            let instance = UILabel()
            instance.textAlignment = .center
            instance.numberOfLines = 0
            instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                              forTextStyle: .caption2)
            instance.text = "no_votes".localized
            instance.addEquallyTo(to: avatarsView)
            guard let chevron = avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "chevron" }).first else { return }
            avatarsStackView.removeArrangedSubview(chevron)
            chevron.removeFromSuperview()
            return
        }
#endif
    }
    
    // MARK: - UI methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        horizontalStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
            $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
        }
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
        selectionView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.5)
        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .clear : color.withAlphaComponent(0.2)
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                          forTextStyle: .body)
        guard let constraint = textView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint.constant = textView.contentSize.height
        layoutIfNeeded()
    }
    
    private func updateAppearance() {
        guard mode == .Write else { return }
        guard let constraint = selectionView.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
            self.selectionView.alpha =  self.isSelected ? 1 : 0
            self.horizontalStack.setNeedsLayout()
            constraint.constant = self.isSelected ? self.background.frame.width : 0
            self.horizontalStack.layoutIfNeeded()
//            self.textView.backgroundColor = self.isSelected ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.5) : self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : self.color.withAlphaComponent(0.2)
        } completion: { _ in}
    }
    
}
