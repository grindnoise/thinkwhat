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
//            let constraint = textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
//            constraint.identifier = "height"
//            constraint.isActive = true
//            setNeedsLayout()
//            layoutIfNeeded()
            guard let _color = item.survey?.topic.tagColor else { return }
            color = _color
        }
    }
    public var mode: PollController.Mode = .ReadOnly {
        didSet {
            if mode == .Write {
//                leadingConstraint.constant =  padding*2
//                trailingConstraint.constant = -padding
            } else if mode == .ReadOnly,
//                      oldValue == .Write,
                      !leadingConstraint.isNil,
                      !trailingConstraint.isNil,
                      let constraint_1 = votersView.getAllConstraints().filter({ $0.identifier == "width" }).first,
                      let constraint_2 = checkmark.getAllConstraints().filter({ $0.identifier == "width"}).first{
                
                UIView.animate(withDuration: 0.3) {
                    self.avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "chevron"}).forEach {
                        $0.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
                    }
                }
                
                //Decide if user has voted to show animations
                let animated = oldValue == .Write
                if item.totalVotes < 1, let imageView = avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "chevron"}).first, isChosen {
                    avatarsStackView.removeArrangedSubview(imageView)
                    imageView.removeFromSuperview()
                }
                if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                    self.contentView.setNeedsLayout()
                    constraint_1.constant = self.contentView.bounds.width/4
                    constraint_2.constant = 0
                    self.shadowView.layer.shadowOpacity = 0
                    self.contentView.layoutIfNeeded()
                } completion: { _ in
                    self.setupVotersView()
                    self.setPercentage()
                    delayAsync(delay: 0.2) {
                        self.shadowView.layer.shadowOpacity = 1
                    }
                }
                } else {
                    self.setNeedsLayout()
                    constraint_1.constant = self.contentView.bounds.width/4
                    constraint_2.constant = 0
//                    self.leadingConstraint.constant = 4
                    self.trailingConstraint.constant = 0
                    self.layoutIfNeeded()
                    self.setupVotersView()
                    self.setPercentage()
                }
            }
            self.selectionView.backgroundColor = self.mode == .ReadOnly ? self.color.withAlphaComponent(0.6) : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.6)
        }
    }
    public var color: UIColor = .tertiarySystemBackground {
        didSet {
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let self = self else { return }
                self.selectionView.backgroundColor = self.mode == .ReadOnly ? self.color.withAlphaComponent(0.6) : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.6)
                self.checkmark.get(all: UIImageView.self).first?.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
                self.avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "checkmark" }).forEach({
                    $0.tintColor = self.color
                })
                self.avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "chevron"}).forEach {
                    $0.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
                }
            }
        }
    }
    public weak var host: ChoiceCollectionView?
    public weak var callbackDelegate: CallbackObservable?
    
    // MARK: - Private properties
    private let padding: CGFloat = 5
    private var isChosen: Bool {
        return item.survey?.result?.keys.first == item.id
    }
    private var observers: [NSKeyValueObservation] = []
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
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = false
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        instance.addEquallyTo(to: shadowView)
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
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
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 200)
//        constraint.identifier = "height"
//        constraint.priority = .defaultLow
//        constraint.isActive = true
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.width*0.05).cgPath
//            view.cornerRadius = newValue.width*0.05
        })
        return instance
    }()
    private lazy var textView: UITextView = {
        let instance = UITextView()
//        instance.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        instance.isUserInteractionEnabled = false
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        instance.backgroundColor = .clear
        instance.isEditable = false
        instance.isSelectable = false
//        background.addSubview(instance)
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            instance.topAnchor.constraint(equalTo: background.topAnchor, constant: padding),
//            instance.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -padding),
//            instance.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: padding),
//            instance.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -padding),
//        ])
        instance.addEquallyTo(to: background)
        observers.append(instance.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard let self = self,
//                  let constraint = self.shadowView.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let constraint_2 = self.horizontalStack.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let value = change.newValue,
                  value.height >= self.textView.frame.height else { return }
            print(value.height)
            
            UIView.animate(withDuration: 0.15, delay: 0, animations: {
                self.contentView.setNeedsLayout()
//                constraint.constant = value.height + self.padding*2
                constraint_2.constant = value.height + self.padding//*2
                self.contentView.layoutIfNeeded()
            }) { _ in
                let space = view.bounds.size.height - view.contentSize.height
                let inset = max(0, space/2)
                view.contentInset = UIEdgeInsets(top: inset, left: view.contentInset.left, bottom: inset, right: view.contentInset.right)
                self.updateConstraints()
            }
            
//            let destinationPath = UIBezierPath(roundedRect: view.bounds,
//                                               cornerRadius: self.shadowView.bounds.width * 0.05).cgPath
//            let anim = Animations.get(property: .ShadowPath,
//                                      fromValue: self.shadowView.layer.shadowPath as Any,
//                                      toValue: destinationPath,
//                                      duration: 0.2,
//                                      delay: 0,
//                                      repeatCount: 0,
//                                      autoreverses: false,
//                                      timingFunction: .linear,
//                                      delegate: nil,
//                                      isRemovedOnCompletion: true,
//                                      completionBlocks: nil)
//            self.shadowView.layer.add(anim, forKey: nil)
//            self.shadowView.layer.shadowPath = destinationPath
        })
        observers.append(instance.observe(\UITextView.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
            self.background.cornerRadius = view.cornerRadius
//            self.selectionView.cornerRadius = view.cornerRadius
        })
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
        imageView.tintColor = mode == .Write ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color : color
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
    private lazy var checkmark: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let constr = instance.heightAnchor.constraint(equalToConstant: 0)
        constr.identifier = "width"
        constr.isActive = true
//        instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)!)*1.5 + 10).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        imageView.backgroundColor = .clear
        imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        imageView.contentMode = .scaleAspectFit
        instance.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1/1),
            imageView.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: instance.centerYAnchor),
        ])
        let constraint = imageView.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -10)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        instance.alpha = 1
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [checkmark, shadowView, votersView])
//        contentView.heightAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.heightAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
        constraint.identifier = "height"
        constraint.isActive = true
        instance.alignment = .center
        instance.clipsToBounds = false
//        instance.spacing = padding
//        instance.distribution = .fillProportionally
        return instance
    }()
    
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
        leadingConstraint = horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding)
        trailingConstraint = horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)//, constant: mode == .ReadOnly ? 0 : -padding)
        topConstraint = horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            votersView.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor),
        ])
        
        let constraint = background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.identifier = "bottom"
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    private func setObservers() {
//        observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
//            guard let self = self,
//                  let constraint = self.textView.getAllConstraints().filter({ $0.identifier == "height" }).first,
//                  let value = change.newValue,
//                  value.height >= self.textView.frame.height else { return }
//
//            UIView.animate(withDuration: 0.15, delay: 0, animations: {
//                self.contentView.setNeedsLayout()
//                constraint.constant = value.height
//                self.contentView.layoutIfNeeded()
//            }) { _ in
////                self.host?.refresh()
//                print(self.topConstraint.constant)
//                self.updateConstraints()
//            }
//
//            let destinationPath = UIBezierPath(roundedRect: view.bounds,
//                                               cornerRadius: self.shadowView.bounds.width * 0.05).cgPath
//            let anim = Animations.get(property: .ShadowPath,
//                                      fromValue: self.shadowView.layer.shadowPath as Any,
//                                      toValue: destinationPath,
//                                      duration: 0.2,
//                                      delay: 0,
//                                      repeatCount: 0,
//                                      autoreverses: false,
//                                      timingFunction: .linear,
//                                      delegate: nil,
//                                      isRemovedOnCompletion: true,
//                                      completionBlocks: nil)
//            self.shadowView.layer.add(anim, forKey: nil)
//            self.shadowView.layer.shadowPath = destinationPath
////            self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.cornerRadius).cgPath
//        })
//        observers.append(textView.observe(\UITextView.bounds, options: .new) { [weak self] view, change in
//            guard let self = self,
//                  let value = change.newValue else { return }
//            view.cornerRadius = value.width * 0.05
//            self.background.cornerRadius = view.cornerRadius
//            self.selectionView.cornerRadius = view.cornerRadius
//        })
//        observers.append(background.observe(\UITextView.bounds, options: .new) { view, change in
//            guard let value = change.newValue else { return }
//            view.cornerRadius = value.width * 0.05
//        })
    }
    
   
    
    private func setPercentage() {
        guard let constraint = selectionView.getAllConstraints().filter({ $0.identifier == "width" }).first else { return }
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.setNeedsLayout()
            self.selectionView.alpha = 1
            constraint.constant = self.textView.frame.width * self.item.percent
            self.layoutIfNeeded()
        } completion: { _ in }
    }
    
    private func setupVotersView() {
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
        
        let count = min(item.voters.count, 3)
        let inset: CGFloat = (avatarsView.bounds.width - avatarsView.bounds.height)/CGFloat(max(min(count-1, 1), count-1))
        
        for i in 0..<Int(count) {
            let avatar = Avatar(gender: .Male, borderColor: traitCollection.userInterfaceStyle == .dark ? .black : .white)
            avatar.layer.zPosition = 10 - CGFloat(i)
            avatars.append(avatar)
            avatar.alpha = 0
            avatar.isBordered = true
            avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            avatarsView.addSubview(avatar)
            avatar.layer.masksToBounds = false
            avatar.translatesAutoresizingMaskIntoConstraints = false
            let centerY = avatar.centerYAnchor.constraint(equalTo: avatarsView.centerYAnchor)
            centerY.identifier = "centerY"
            centerY.isActive = true
            avatar.heightAnchor.constraint(equalTo: avatarsView.heightAnchor).isActive = true
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor).isActive = true
            
            var voters = item.voters
            voters.remove(object: Userprofiles.shared.current!)
            
            if isChosen {
                if i == 0 {
                    if count == 1 {
                        avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor).isActive = true
                    } else {
                        avatar.leadingAnchor.constraint(equalTo: avatarsView.leadingAnchor).isActive = true
                    }
                    avatar.imageView.accessibilityIdentifier = "checkmark"
                    avatar.image = UIImage(systemName: "checkmark.seal.fill")
                    avatar.imageView.tintColor = color
                } else {
                    avatar.leadingAnchor.constraint(equalTo: avatars[i-1].leadingAnchor, constant: inset).isActive = true
                    guard let user = voters[i-1] as? Userprofile else { return }
                    if let image = user.image {
                        avatar.image = image
                    } else {
                        Task {
                            let image = try await user.downloadImageAsync()
                            await MainActor.run{
                                avatar.image = image
                            }
                        }
                    }
                }
            } else {
                if i == 0 {
                    if count == 1 {
                        avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor).isActive = true
                    } else {
                        avatar.leadingAnchor.constraint(equalTo: avatarsView.leadingAnchor).isActive = true
                    }
                } else {
                    avatar.leadingAnchor.constraint(equalTo: avatars[i].leadingAnchor, constant: inset).isActive = true
                }
                guard let user = voters[i] as? Userprofile else { return }
                if let image = user.image {
                    avatar.image = image
                } else {
                    Task {
                        let image = try await user.downloadImageAsync()
                        await MainActor.run {
                            avatar.imageView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
                            avatar.borderBg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
                            avatar.image = image
                        }
                    }
                }
            }
            avatar.lightColor = .white
            avatar.darkColor = .black
            UIView.animate(
                withDuration: 0.3,
                delay: 0.075 * Double(i),
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.1,
                options: [.curveEaseInOut],
                animations: {
                    avatar.alpha = 1
                    avatar.transform = .identity
                }) { _ in }
            avatar.imageView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
            avatar.borderBg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
        
    }
    
    // MARK: - Public methods

    
    // MARK: - UI methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        avatars.forEach {
            $0.imageView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
            $0.borderBg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
        
        avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "chevron"}).forEach {
            $0.tintColor = mode == .Write ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color : color
        }
        
        horizontalStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
            $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
        }
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        selectionView.backgroundColor = mode == .ReadOnly ? color.withAlphaComponent(0.6) : traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.6)
        self.checkmark.get(all: UIImageView.self).first?.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                          forTextStyle: .body)
        guard let constraint = shadowView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint.constant = textView.contentSize.height + padding*2
        layoutIfNeeded()
    }
    
    private func updateAppearance() {
        guard mode == .Write else {
            if isSelected, !item.voters.isEmpty {
                callbackDelegate?.callbackReceived(self)
            }
            return
        }
        guard let constraint_1 = selectionView.getAllConstraints().filter({ $0.identifier == "width"}).first,
              let constraint_2 = checkmark.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.selectionView.alpha =  self.isSelected ? 1 : 0
            self.horizontalStack.setNeedsLayout()
            constraint_2.constant =  self.isSelected ? "test".height(withConstrainedWidth: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)!)*1.5 + 10 : 0
            constraint_1.constant = self.isSelected ? self.background.frame.width : 0
            self.horizontalStack.layoutIfNeeded()
        } completion: { _ in}
    }
    
}
