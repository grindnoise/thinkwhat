//
//  ChoiceCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//


import UIKit

class ChoiceCell: UICollectionViewCell {
    
    // MARK: - Overriden properties
    override var isSelected: Bool {
        didSet {
            if mode == .Write {//}, isSelected == oldValue {
                setSelection()
            } else {
                guard !item.isNil, item.totalVotes != 0 else { return }
                updateAppearance()
            }
        }
    }
    
    // MARK: - Public properties
    public var item: Answer! {
        didSet {
            guard !item.isNil else { return }
            textView.text = item.description
            votersCountLabel.text = String(describing: item.totalVotes.roundedWithAbbreviations)
//            votersLabel.text = "votes_total".localized.uppercased() + ": \(item.totalVotes.roundedWithAbbreviations)"
            
//            setNeedsDisplay()
//            if let survey = item.survey, survey.isComplete {
//                closedConstraint.isActive = false
//                openConstraint.isActive = true
//            }
//            layoutIfNeeded()
            
            guard let color = item.survey?.topic.tagColor else { return }
            self.color = color
        }
    }
    public var mode: PollController.Mode = .ReadOnly {
        didSet {
            if mode == .ReadOnly {
                disclosureIndicator.alpha = item.totalVotes == 0 ? 0 : 1
//                if oldValue == .Write {
//                    closedConstraint.isActive = false
//                    openConstraint.isActive = true
//                    //                    setNeedsDisplay()
////                    UIView.animate(withDuration: 0.3, delay: 0) {
////                        self.setNeedsDisplay()
////                        self.closedConstraint.constant += 58
//
////                        self.layoutIfNeeded()
////                    }
//
////                    layoutIfNeeded()
//                }
                
                setVoters()
                setProgress(animated: oldValue == .Write)
                setObservers()
                
                
//                guard animated else {
//                    horizontalStack.getSubview(type: UIImageView.self, identifier: "chevron")?.tintColor = mode == .Write ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color : color
//                    return
//                }
//
//                UIView.animate(withDuration: 0.2) {
//                    self.horizontalStack.getSubview(type: UIImageView.self, identifier: "chevron")?.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
//                }
            }

            UIView.animate(withDuration: 0.2, delay: 0) {
                if self.mode == .ReadOnly {
                    self.selectionView.backgroundColor = self.color.withAlphaComponent(self.isChosen ? 1 : 0.25)
                } else {
                    self.selectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.65)
                }
                
                if let imageView = self.horizontalStack.getSubview(type: UIImageView.self, identifier: "chevron") {
                    imageView.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
                }
                
//                if let imageView = self.progressStack.getSubview(type: UIImageView.self, identifier: "chevron") {
//                    imageView.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
//                }
                self.disclosureIndicator.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
            }
        }
    }
    public var color: UIColor = .tertiarySystemBackground {
        didSet {
            votersCountLabel.textColor = item.totalVotes == 0 ? .secondaryLabel : color
//            if mode == .ReadOnly, isChosen {
//                contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiaryLabel : color.withAlphaComponent(0.4)
//            }
            
//            avatars.forEach {
//                guard isChosen else { return }
//                $0.borderColor = traitCollection.userInterfaceStyle == .dark ? .tertiaryLabel : color.withAlphaComponent(0.4)
//            }
            
//            UIView.animate(withDuration: 0.2, delay: 0) {
                if self.mode == .ReadOnly {
                    self.selectionView.backgroundColor = self.color.withAlphaComponent(self.isChosen ? 1 : 0.25)
                } else {
                    self.selectionView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.65)
                }
//                self.selectionView.backgroundColor = self.mode == .ReadOnly ? self.color.withAlphaComponent(0.65) : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.65)
                
                if let imageView = self.horizontalStack.getSubview(type: UIImageView.self, identifier: "chevron") {
                    imageView.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
                }
//            if let imageView = self.progressStack.getSubview(type: UIImageView.self, identifier: "chevron") {
//                imageView.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
//            }
            self.disclosureIndicator.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
//            }
        }
    }
    public weak var host: ChoiceCollectionView?
    public weak var callbackDelegate: CallbackObservable?
    
    // MARK: - Private properties
    private var notifications: [Task<Void, Never>?] = []
    private let padding: CGFloat = 10
    private var isChosen: Bool {
        return item.survey?.result?.keys.first == item.id
    }
    private var observers: [NSKeyValueObservation] = []
    private var topConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint.isActive = true
        }
    }
    private lazy var avatars: [NewAvatar] = []
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = false
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemGray5
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
//            instance.trailingAnchor.constraint(equalTo: background.trailingAnchor)
        ])
        let constraint = instance.trailingAnchor.constraint(equalTo: background.trailingAnchor)
        constraint.identifier = "fullWidth"
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
        let constraint = instance.heightAnchor.constraint(equalToConstant: 200)
        constraint.identifier = "height"
//        constraint.priority = .defaultLow
        constraint.isActive = true
        
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.width*0.05).cgPath
        })
        
        return instance
    }()
    private lazy var textView: UITextView = {
        let instance = UITextView()
        instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: 8, bottom: instance.contentInset.bottom, right: 8)
        instance.isUserInteractionEnabled = false
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
        instance.backgroundColor = .clear
        instance.isEditable = false
        instance.isSelectable = false
        instance.addEquallyTo(to: background)
        
        observers.append(instance.observe(\UITextView.contentSize, options: .new) { [weak self] view, change in
            guard let self = self,
//                  let heightConstraint = self.progressStack.getConstraint(identifier: "height"),
                  let heightConstraint = self.shadowView.getConstraint(identifier: "height"),
                  let value = change.newValue else { return }
                self.contentView.setNeedsLayout()
                heightConstraint.constant = max(value.height, 40)
                self.contentView.layoutIfNeeded()
                let space = heightConstraint.constant - view.contentSize.height
                let inset = max(0, space/2)
                view.contentInset = UIEdgeInsets(top: inset, left: 8, bottom: inset, right: 8)
        })
        
        observers.append(instance.observe(\UITextView.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
            self.background.cornerRadius = view.cornerRadius
        })
        
        return instance
    }()
    private lazy var votersView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "voters"
        
        let constraint = instance.widthAnchor.constraint(equalToConstant: 100)
        constraint.identifier = "width"
        constraint.isActive = true

        return instance
    }()
    private lazy var votersLabel: UILabel = {
       let instance = UILabel()
        instance.backgroundColor = .clear
        instance.text = "voters".localized.uppercased() + ":"
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textColor = .secondaryLabel
        instance.textAlignment = .right
        
        return instance
    }()
    private lazy var votersCountLabel: UILabel = {
       let instance = UILabel()
        instance.backgroundColor = .clear
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline)
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.textAlignment = .right
        
        return instance
    }()
    private lazy var disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.right")
        disclosureIndicator.tintColor = mode == .Write ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color : color
//        disclosureIndicator.widthAnchor.constraint(equalTo: disclosureIndicator.heightAnchor, multiplier: 1/1).isActive = true
        disclosureIndicator.contentMode = .center
        disclosureIndicator.alpha = 0
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    private lazy var doubleDisclosureIndicator: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right.2"))
        imageView.accessibilityIdentifier = "chevron"
        imageView.clipsToBounds = true
        imageView.tintColor = mode == .Write ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color : color
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = .init(textStyle: .headline, scale: .small)
        
        return imageView
    }()
    private lazy var progressStack: UIStackView = {
//        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
//        imageView.accessibilityIdentifier = "chevron"
//        imageView.clipsToBounds = true
//        imageView.tintColor = mode == .Write ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color : color
//        imageView.contentMode = .center
        
        let instance = UIStackView(arrangedSubviews: [shadowView, disclosureIndicator])//imageView
        instance.axis = .horizontal
        instance.spacing = 4
        
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 200)
//        constraint.identifier = "height"
//        constraint.priority = .defaultLow
//        constraint.isActive = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        shadowView.translatesAutoresizingMaskIntoConstraints = false

//        NSLayoutConstraint.activate([
//            shadowView.heightAnchor.constraint(equalTo: instance.heightAnchor),
//            shadowView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.9),
//            shadowView.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
//            shadowView.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
////            imageView.heightAnchor.constraint(equalTo: instance.heightAnchor),
//        ])
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        disclosureIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shadowView.heightAnchor.constraint(equalTo: instance.heightAnchor),
            disclosureIndicator.heightAnchor.constraint(equalTo: instance.heightAnchor),
//            votersLabel.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.6)
        ])

        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [votersLabel, votersView, votersCountLabel, doubleDisclosureIndicator])
        instance.axis = .horizontal
        instance.clipsToBounds = false
        instance.spacing = 4
        
        votersLabel.translatesAutoresizingMaskIntoConstraints = false
        votersView.translatesAutoresizingMaskIntoConstraints = false
        doubleDisclosureIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            votersLabel.heightAnchor.constraint(equalTo: instance.heightAnchor),
            votersView.heightAnchor.constraint(equalTo: instance.heightAnchor),
            doubleDisclosureIndicator.heightAnchor.constraint(equalTo: instance.heightAnchor),
//            votersLabel.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.6)
        ])

        return instance
    }()
    private lazy var votersStack: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        
        instance.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
            horizontalStack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -16),
            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
        constraint.identifier = "height"
        constraint.isActive = true

        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [progressStack, votersStack])//[checkmark, shadowView, votersView])
        instance.axis = .vertical
        instance.alignment = .center
        instance.clipsToBounds = false
        instance.spacing = 8
        
        progressStack.translatesAutoresizingMaskIntoConstraints = false
        progressStack.widthAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
        votersStack.translatesAutoresizingMaskIntoConstraints = false
        votersStack.widthAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
        
        return instance
    }()
    // Constraints
    private var closedConstraint: NSLayoutConstraint!
    private var openConstraint: NSLayoutConstraint!
    //Last touch point
    private var lastPoint: CGPoint = .zero
    
    // MARK: - Destructor
    deinit {
        notifications.forEach { $0?.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setObservers()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor)//, constant: padding)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            votersView.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),// constant: padding),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),// constant: -padding),
//            votersView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        
        closedConstraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        closedConstraint.priority = .defaultLow
        closedConstraint.isActive = true
        
        openConstraint = verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -padding)
        openConstraint.priority = .defaultLow
        
        
        observers.append(contentView.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
    }
    
    private func setObservers() {
        //Only when is complete
        guard !item.isNil , let survey = item.survey, survey.isComplete else { return }
        
        //Observe last voters
        notifications.append(Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.SurveyAnswers.VotersAppend) {
                guard let self = self,
                      let instance = notification.object as? Answer,
                      self.item == instance
//                      let lastVoter = self.item.voters.first
//                      self.avatars.map({ $0.userprofile }).filter({ $0 == lastVoter }).isEmpty
//                      self.avatars.filter({ $0.userprofile == lastVoter}).isEmpty
                else { return }

                var users: Set<Userprofile>    = Set(instance.voters)
                let avatars: Set<Userprofile>  = Set(self.avatars.map { $0.userprofile })
                
                users.subtract(avatars)
                
                guard let lastVoter = users.first else { return }
                
                self.updateVoters(userprofile: lastVoter)
            }
        })
        
        //Observe votes count
        notifications.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.SurveyAnswers.TotalVotes) {
                guard let self = self,
                      let instance = notification.object as? Answer,
                      self.item.survey == instance.survey
                else { return }
                
                self.updateProgress()
            }
        })
    }

    private func setSelection() {
        guard mode == .Write else {
            if isSelected, !item.voters.isEmpty {
                callbackDelegate?.callbackReceived(self)
            }
            return
        }
//        guard let constraint_1 = selectionView.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }//,
//              let constraint_2 = checkmark.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }
        guard isSelected else {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.selectionView.alpha =  self.isSelected ? 1 : 0
            } completion: { _ in }
            return
        }
        reveal(view: selectionView, duration: 0.275, animateOpacity: true, completionBlocks: [])
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance(animated: Bool = true) {
        closedConstraint.isActive = !isSelected
        openConstraint.isActive = isSelected

        guard animated else {
            let upsideDown = CGAffineTransform(rotationAngle: .pi/2 )
            self.disclosureIndicator.transform = !self.isSelected ? upsideDown : .identity
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
            let upsideDown = CGAffineTransform(rotationAngle: .pi/2 )
            self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
        }
    }
    
    private func setProgress(animated: Bool = true) {
        
        if item.totalVotes != 0 {
            votersCountLabel.text = String(describing: item.totalVotes.roundedWithAbbreviations)
        }
        
        if let constraint = selectionView.getConstraint(identifier: "fullWidth"), let superview = selectionView.superview {
            if !isChosen {
                setNeedsLayout()
                constraint.constant = 0
                layoutIfNeeded()
            }
            superview.removeConstraint(constraint)
        }

        setNeedsLayout()
        let width = textView.frame.width * item.percent
        let newConstraint = selectionView.widthAnchor.constraint(equalToConstant: isChosen ? selectionView.bounds.width : 0)
        newConstraint.identifier = "width"
        newConstraint.isActive = true
        layoutIfNeeded()

        selectionView.alpha = 1

        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: .curveEaseInOut) { [weak self] in
                guard let self = self else { return }
                self.setNeedsLayout()
                newConstraint.constant = width
                self.layoutIfNeeded()
            } completion: { _ in }
        } else {
            self.setNeedsLayout()
            newConstraint.constant = width
            self.layoutIfNeeded()
        }
    }
    
    private func updateProgress() {
        
        if item.totalVotes != 0 {
            votersCountLabel.text = String(describing: item.totalVotes.roundedWithAbbreviations)
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
                self.disclosureIndicator.alpha = 1
            }
        }
        
        guard let constraint = selectionView.getConstraint(identifier: "width") else { return }
        let width = textView.frame.width * item.percent
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.35, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.setNeedsLayout()
            constraint.constant = width
            self.layoutIfNeeded()
        } completion: { _ in }
    }
    
    private func setVoters() {
        guard item.totalVotes != 0 else {
            votersView.alpha = 0
            votersLabel.alpha = 0
            horizontalStack.getSubview(type: UIImageView.self, identifier: "chevron")?.alpha = 0
            votersCountLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
            votersCountLabel.text = "no_votes".localized.uppercased()// + ": \(item.totalVotes)"
            votersCountLabel.textColor = .secondaryLabel
            
//            if let constraint = votersStack.getConstraint(identifier: "height") {
//                setNeedsLayout()
//                constraint.constant = "test".height(withConstrainedWidth: 1000, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)!)
//                layoutIfNeeded()
//            }
            
            return
        }
        
        votersCountLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline)
        if let constraint = horizontalStack.getConstraint(identifier: "height") {
            setNeedsLayout()
            constraint.constant = "test".height(withConstrainedWidth: 1000, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline)!)
            layoutIfNeeded()
        }

        //Reverse by timestamp
        var _voters = item.voters.reversed().map { $0 }

        //Place user at first position
        if isChosen, _voters.contains(Userprofiles.shared.current!) {
            _voters.remove(object: Userprofiles.shared.current!)
            _voters.insert(Userprofiles.shared.current!, at: 0)
//            contentView.backgroundColor = color.withAlphaComponent(0.4)
        }

        let voters = Array(_voters.suffix(3))
        
        if let constraint = votersView.getConstraint(identifier: "width") {
            setNeedsLayout()
            if voters.count == 0 {
                constraint.constant = 0
            } else if voters.count == 1 {
                constraint.constant = votersView.bounds.height
            } else if voters.count == 2 {
                constraint.constant = votersView.bounds.height * CGFloat(1.5)
            } else if voters.count == 3 {
                constraint.constant = votersView.bounds.height * CGFloat(2)
            }
            layoutIfNeeded()
        }

        voters.enumerated().forEach { index, userprofile in
            let avatar = NewAvatar(userprofile: userprofile, isBordered: true)//, borderColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : self.isChosen ? self.color.withAlphaComponent(0.4) : .systemBackground)
            avatar.layer.zPosition = 10 - CGFloat(index)
            avatars.append(avatar)
            votersView.addSubview(avatar)
            avatar.translatesAutoresizingMaskIntoConstraints = false

            avatar.heightAnchor.constraint(equalTo: votersView.heightAnchor).isActive = true
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1/1).isActive = true

            //Set layout
            switch voters.count {
            case 1:
                if index == 0 {
                    let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
                    constraint.identifier = "centerXAnchor"
                    constraint.isActive = true
                }
            case 2:
                if index == 0 {
                    let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor, constant: -votersView.bounds.height/4)
                    constraint.identifier = "centerXAnchor"
                    constraint.isActive = true
                } else if index == 1 {
                    let constraint =  avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor, constant: votersView.bounds.height/4)
                    constraint.identifier = "centerXAnchor"
                    constraint.isActive = true
                }
            default:
                if index == 0 {
                    let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor, constant: -votersView.bounds.height/2)
                    constraint.identifier = "centerXAnchor"
                    constraint.isActive = true
                } else if index == 1 {
                    let constraint =  avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
                    constraint.identifier = "centerXAnchor"
                    constraint.isActive = true
                } else if index == 2 {
                    let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor, constant: votersView.bounds.height/2)
                    constraint.identifier = "centerXAnchor"
                    constraint.isActive = true
                }
            }
        }
    }
    
    //Live voters updates
    private func updateVoters(userprofile: Userprofile) {
        let avatar = NewAvatar(userprofile: userprofile, isBordered: true)//, borderColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : self.isChosen ? self.color.withAlphaComponent(0.4) : .systemBackground)
        avatar.layer.zPosition = 10
        avatar.alpha = 0
        avatars.forEach{ $0.layer.zPosition -= 1 }
        votersView.addSubview(avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        
        avatar.heightAnchor.constraint(equalTo: votersView.heightAnchor).isActive = true
        avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1/1).isActive = true
        
        //Check if it's a first voter
        if avatars.isEmpty, let imageView = horizontalStack.getSubview(type: UIImageView.self, identifier: "chevron"), let widthConstraint = votersView.getConstraint(identifier: "width") {
            let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
            constraint.identifier = "centerXAnchor"
            constraint.isActive = true
            UIView.transition(with: votersCountLabel, duration: 0.5, options: .transitionCrossDissolve) {
                self.votersCountLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline)
                self.votersCountLabel.textColor = self.color
                self.votersCountLabel.text = String(describing: self.item.totalVotes)
                self.votersView.alpha = 1
                self.votersLabel.alpha = 1
                avatar.alpha = 1
                imageView.alpha = 1
                self.setNeedsLayout()
                widthConstraint.constant = self.votersView.bounds.height
                self.layoutIfNeeded()
            } completion: { _ in }
            
            return
        }
        
        switch avatars.count {
        case 1:
            let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor,
                                                             constant: isChosen ? votersView.bounds.height/4 : -votersView.bounds.height/4)
            constraint.identifier = "centerXAnchor"
            constraint.isActive = true

            guard let last = avatars.last,
                  let lastConstraint = last.getConstraint(identifier: "centerXAnchor"),
                  let widthConstraint = votersView.getConstraint(identifier: "width")
            else { return }
            
            avatar.layer.zPosition = isChosen ? last.layer.zPosition - 1 : 10
            last.layer.zPosition = isChosen ? last.layer.zPosition : last.layer.zPosition - 1

            avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.35, delay: 0, animations: {
                avatar.alpha = 1
                avatar.transform = .identity
                self.setNeedsLayout()
                widthConstraint.constant += self.votersView.bounds.height/2
                lastConstraint.constant += self.isChosen ? -last.frame.width/4 : last.frame.width/4
                self.layoutIfNeeded()
            }) { _ in
                if self.isChosen {
                    self.avatars.append(avatar)
                } else {
                    self.avatars.insert(avatar, at: 0)
                }
            }
        case 2:
            if isChosen {
                let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
                constraint.identifier = "centerXAnchor"
                constraint.isActive = true
            } else {
                let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor,
                                                                 constant: -votersView.bounds.height/2)
                constraint.identifier = "centerXAnchor"
                constraint.isActive = true
            }
         
            guard let leading = avatars.first,
                  let trailing = avatars.last,
                  let leadingConstraint = leading.getConstraint(identifier: "centerXAnchor"),
                  let trailingConstraint = trailing.getConstraint(identifier: "centerXAnchor"),
                  let widthConstraint = votersView.getConstraint(identifier: "width")
            else { return }
            
            if isChosen {
                avatar.layer.zPosition = leading.layer.zPosition - 1
                trailing.layer.zPosition -= 1
            } else {
                avatars.forEach { $0.layer.zPosition -= 1}
            }

            avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.35, delay: 0, animations: {
                avatar.alpha = 1
                avatar.transform = .identity
                self.setNeedsLayout()
                widthConstraint.constant += self.votersView.bounds.height / 2
                if self.isChosen {
                    leadingConstraint.constant -= leading.frame.width/4
                    trailingConstraint.constant += leading.frame.width/4
                } else {
                    trailingConstraint.constant += leading.frame.width/4
                    leadingConstraint.constant += leading.frame.width/4
                }
                self.layoutIfNeeded()
            }) { _ in
                if self.isChosen {
                    self.avatars.insert(avatar, at: 1)
                } else {
                    self.avatars.insert(avatar, at: 0)
                }
            }
        default:
            if isChosen {
                let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
                constraint.identifier = "centerXAnchor"
                constraint.isActive = true
            } else {
                let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor,
                                                                 constant: -votersView.bounds.height/2)
                constraint.identifier = "centerXAnchor"
                constraint.isActive = true
            }
         
            guard let leading = avatars.first,
                  let middle = avatars[1] as? NewAvatar,
                  let trailing = avatars.last,
                  let leadingConstraint = leading.getConstraint(identifier: "centerXAnchor"),
                  let middleConstraint = middle.getConstraint(identifier: "centerXAnchor"),
                  let trailingConstraint = trailing.getConstraint(identifier: "centerXAnchor")
            else { return }
            
            if isChosen {
                avatar.layer.zPosition = leading.layer.zPosition - 1
                middle.layer.zPosition -= 1
                trailing.layer.zPosition -= 1
            } else {
                avatars.forEach { $0.layer.zPosition -= 1}
            }

            avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.35, delay: 0, animations: {
                avatar.alpha = 1
                avatar.transform = .identity
                trailing.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                trailing.alpha = 0
                self.setNeedsLayout()
                leadingConstraint.constant += self.isChosen ? 0 : leading.frame.width/2
                middleConstraint.constant += leading.frame.width/2
                trailingConstraint.constant += leading.frame.width/2
                self.layoutIfNeeded()
            }) { _ in
                if self.isChosen {
                    self.avatars.insert(avatar, at: 1)
                } else {
                    self.avatars.insert(avatar, at: 0)
                }
                self.avatars.remove(object: trailing)
                trailing.removeFromSuperview()
            }
        }
    }
    
    private func reveal(view animatedView: UIView, duration: TimeInterval, animateOpacity: Bool = true, completionBlocks: [Closure] = []) {
        
        let circlePathLayer = CAShapeLayer()
        var _completionBlocks = completionBlocks
        var circleFrameTopCenter: CGRect {
            var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
            let circlePathBounds = circlePathLayer.bounds
            circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
            circleFrame.origin.y = circlePathBounds.minY - circleFrame.minY
            return circleFrame
        }
        
        var circleFrameTop: CGRect {
            var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
            let circlePathBounds = circlePathLayer.bounds
            circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
            circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
            return circleFrame
        }
        
        var circleFrameTopLeft: CGRect {
            return CGRect.zero
        }
        
        var circleFrameTouchPosition: CGRect {
            return CGRect(origin: lastPoint, size: .zero)
        }
        
        var circleFrameCenter: CGRect {
            var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
            let circlePathBounds = circlePathLayer.bounds
            circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
            circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
            return circleFrame
        }
        
        func circlePath(_ rect: CGRect) -> UIBezierPath {
            return UIBezierPath(ovalIn: rect)
        }
        
        circlePathLayer.frame = animatedView.bounds
        circlePathLayer.path = circlePath(circleFrameTouchPosition).cgPath
        animatedView.layer.mask = circlePathLayer
        
//        let center = lastPoint//(x: animatedView.bounds.midX, y: animatedView.bounds.midY)
        
        let finalRadius = max(abs(animatedView.bounds.width - lastPoint.x),
                                  abs(animatedView.bounds.width - (animatedView.bounds.width - lastPoint.x)))//sqrt((center.x*center.x) + (center.y*center.y))
        
        let radiusInset = finalRadius
        
        let outerRect = circleFrameTouchPosition.insetBy(dx: -radiusInset, dy: -radiusInset)
        
        let toPath = UIBezierPath(ovalIn: outerRect).cgPath
        
        let fromPath = circlePathLayer.path
        
        let anim = Animations.get(property: .Path, fromValue: fromPath, toValue: toPath, duration: duration, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: .easeInEaseOut, delegate: self, isRemovedOnCompletion: true, completionBlocks: [])
                
        circlePathLayer.add(anim, forKey: "path")
        circlePathLayer.path = toPath
//        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
//
//        maskLayerAnimation.fromValue = fromPath
//        maskLayerAnimation.toValue = toPath
//        maskLayerAnimation.duration = duration
//        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        maskLayerAnimation.isRemovedOnCompletion = true
//        _completionBlocks.append({ animatedView.layer.mask = nil })
//        maskLayerAnimation.delegate = self
//        maskLayerAnimation.setValue(_completionBlocks, forKey: "maskCompletionBlocks")
//        circlePathLayer.add(maskLayerAnimation, forKey: "path")
//        circlePathLayer.path = toPath
//        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
//        fadeAnim.fromValue = 0
//        fadeAnim.toValue = 1
        guard animateOpacity else { return }
        animatedView.alpha = 1
        animatedView.layer.opacity = 0
        let opacityAnim = Animations.get(property: .Opacity, fromValue: 0, toValue: 1, duration: duration, timingFunction: CAMediaTimingFunctionName.easeOut, delegate: nil)
//        opacityAnim.setValue(_completionBlocks, forKey: "completionBlocks")
//        let groupAnim = Animations.group(animations: [maskLayerAnimation, opacityAnim], duration: duration, delegate: nil)
//        let groupAnim = Animations.group(animations: [maskLayerAnimation, opacityAnim], repeatCount: 0, autoreverses: false, duration: duration, delay: 0, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: true)

//        circlePathLayer.add(groupAnim, forKey: "path")
//        circlePathLayer.path = toPath
//        animatedView.layer.opacity = 1
        animatedView.layer.add(opacityAnim, forKey: nil)
        animatedView.layer.opacity = 1
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        if mode == .ReadOnly {
            self.selectionView.backgroundColor = self.color.withAlphaComponent(self.isChosen ? 1 : 0.25)
//            if isChosen {
////                contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue.withAlphaComponent(0.4) : color.withAlphaComponent(0.4)
//                avatars.forEach {
//                    $0.borderColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue.withAlphaComponent(0.4) : color.withAlphaComponent(0.4)
//                }
//            } else {
//                avatars.forEach {
//                    $0.borderColor = .systemBackground
//                }
//            }
        } else {
            self.selectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.65)
        }

        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemGray5

        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                          forTextStyle: .body)
        guard let constraint = shadowView.getConstraint(identifier: "height") else { return }
//        guard let constraint = progressStack.getConstraint(identifier: "height") else { return }
        setNeedsLayout()
        constraint.constant = max(textView.contentSize.height, 40)
        layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: contentView) else { return }
        
        if let point = touch?.location(in: votersView), votersView.bounds.contains(point) {
            callbackDelegate?.callbackReceived(self)
        } else if let point = touch?.location(in: votersCountLabel), votersCountLabel.bounds.contains(point) {
            callbackDelegate?.callbackReceived(self)
        } else if let point = touch?.location(in: doubleDisclosureIndicator), doubleDisclosureIndicator.bounds.contains(point) {
            callbackDelegate?.callbackReceived(self)
        } else if let point = touch?.location(in: progressStack), progressStack.bounds.contains(point) {
            lastPoint = point
            super.touchesBegan(touches, with: event)
        }
    }
}

// MARK: - CAAnimationDelegate
extension ChoiceCell: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        }
    }
}


////
////  ChoiceCell.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 07.07.2022.
////  Copyright © 2022 Pavel Bukharov. All rights reserved.
////
//
//
//import UIKit
//
//class ChoiceCell: UICollectionViewCell {
//
//    // MARK: - Overriden properties
//    override var isSelected: Bool {
//        didSet {
//            if mode == .Write, isSelected == oldValue {
//                return
//            }
//            updateAppearance()
//        }
//    }
//
//    // MARK: - Public properties
//    public var item: Answer! {
//        didSet {
//            guard !item.isNil else { return }
//            textView.text = item.description
//            guard let color = item.survey?.topic.tagColor else { return }
//            self.color = color
//        }
//    }
//    public var mode: PollController.Mode = .ReadOnly {
//        didSet {
//            if mode == .ReadOnly, let constraint_1 = votersView.getConstraint(identifier: "width") { //,
//
//                UIView.animate(withDuration: 0.2) {
//                    self.avatarsStackView.getSubview(type: UIImageView.self, identifier: "chevron")?.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
//                }
//
//                //Decide if user has voted to show animations
//                let animated = oldValue == .Write
//                if item.totalVotes < 1, let imageView = avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "chevron"}).first, isChosen {
//                    avatarsStackView.removeArrangedSubview(imageView)
//                    imageView.removeFromSuperview()
//                }
//                if animated {
//                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
//                        self.contentView.setNeedsLayout()
//                        constraint_1.constant = self.contentView.bounds.width/4
//                        self.shadowView.layer.shadowOpacity = 0
//                        self.contentView.layoutIfNeeded()
//                    } completion: { _ in
//                        self.setupVotersView()
//                        self.setPercentage()
//                        delayAsync(delay: 0.2) {
//                            self.shadowView.layer.shadowOpacity = 1
//                        }
//                    }
//                } else {
//                    self.setNeedsLayout()
//                    constraint_1.constant = self.contentView.bounds.width/4
////                    self.trailingConstraint.constant = 0
//                    self.layoutIfNeeded()
//                    self.setupVotersView()
//                    self.setPercentage(animated: false)
//                }
//            }
//            self.selectionView.backgroundColor = self.mode == .ReadOnly ? self.color.withAlphaComponent(0.65) : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.65)
//        }
//    }
//    public var color: UIColor = .tertiarySystemBackground {
//        didSet {
////            UIView.animate(withDuration: 0.5) { [weak self] in
////                guard let self = self else { return }
//                self.selectionView.backgroundColor = self.mode == .ReadOnly ? self.color.withAlphaComponent(0.65) : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.65)
//                self.avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "checkmark" }).forEach({
//                    $0.tintColor = self.color
//                })
//                self.avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "chevron"}).forEach {
//                    $0.tintColor = self.mode == .Write ? self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color : self.color
//                }
////            }
//        }
//    }
//    public weak var host: ChoiceCollectionView?
//    public weak var callbackDelegate: CallbackObservable?
//
//    // MARK: - Private properties
//    private var notifications: [Task<Void, Never>?] = []
//    private let padding: CGFloat = 5
//    private var isChosen: Bool {
//        return item.survey?.result?.keys.first == item.id
//    }
//    private var observers: [NSKeyValueObservation] = []
////    private var trailingConstraint: NSLayoutConstraint! {
////        didSet {
////            trailingConstraint.isActive = true
////        }
////    }
//    private var topConstraint: NSLayoutConstraint! {
//        didSet {
//            topConstraint.isActive = true
//        }
//    }
//    private lazy var avatars: [NewAvatar] = []
//    private lazy var background: UIView = {
//        let instance = UIView()
//        instance.accessibilityIdentifier = "bg"
//        instance.layer.masksToBounds = false
//        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemGray5
//        instance.addEquallyTo(to: shadowView)
//        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
//            guard let value = change.newValue else { return }
//            view.cornerRadius = value.width * 0.05
//        })
////        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
////        constraint.identifier = "height"
////        constraint.isActive = true
//        return instance
//    }()
//    private lazy var selectionView: UIView = {
//        let instance = UIView()
//        instance.accessibilityIdentifier = "selection"
//        instance.alpha = 0
//        instance.layer.masksToBounds = false
//        background.insertSubview(instance, belowSubview: textView)
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            instance.leadingAnchor.constraint(equalTo: background.leadingAnchor),
//            instance.topAnchor.constraint(equalTo: background.topAnchor),
//            instance.bottomAnchor.constraint(equalTo: background.bottomAnchor),
////            instance.trailingAnchor.constraint(equalTo: background.trailingAnchor)
//        ])
//        let constraint = instance.trailingAnchor.constraint(equalTo: background.trailingAnchor)
//        constraint.identifier = "fullWidth"
//        constraint.isActive = true
//        return instance
//    }()
//    private lazy var shadowView: UIView = {
//        let instance = UIView()
//        instance.layer.masksToBounds = false
//        instance.clipsToBounds = false
//        instance.backgroundColor = .clear
//        instance.accessibilityIdentifier = "shadow"
//        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
//        instance.layer.shadowRadius = 4
//        instance.layer.shadowOffset = .zero
////        let constraint = instance.heightAnchor.constraint(equalToConstant: 200)
////        constraint.identifier = "height"
////        constraint.priority = .defaultLow
////        constraint.isActive = true
//
//        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
//            guard let newValue = change.newValue else { return }
//            view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.width*0.05).cgPath
////            view.cornerRadius = newValue.width*0.05
//        })
//
//        return instance
//    }()
//    private lazy var textView: UITextView = {
//        let instance = UITextView()
////        instance.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        instance.isUserInteractionEnabled = false
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
//        instance.backgroundColor = .clear
//        instance.isEditable = false
//        instance.isSelectable = false
//        instance.addEquallyTo(to: background)
//
//        observers.append(instance.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
//            guard let self = self,
////                  let constraint = self.shadowView.getAllConstraints().filter({ $0.identifier == "height" }).first,
//                  let heightConstraint = self.horizontalStack.getAllConstraints().filter({ $0.identifier == "height" }).first,
//                  let value = change.newValue,
//                  value.height >= self.textView.frame.height else { return }
//            UIView.animate(withDuration: 0.15, delay: 0, animations: {
//                self.contentView.setNeedsLayout()
////                constraint.constant = value.height + self.padding*2
//                heightConstraint.constant = value.height + self.padding//*2
//                self.contentView.layoutIfNeeded()
//            }) { _ in
//                let space = view.bounds.size.height - view.contentSize.height
//                let inset = max(0, space/2)
//                view.contentInset = UIEdgeInsets(top: inset, left: view.contentInset.left, bottom: inset, right: view.contentInset.right)
////                self.updateConstraints()
//            }
//
////            let destinationPath = UIBezierPath(roundedRect: view.bounds,
////                                               cornerRadius: self.shadowView.bounds.width * 0.05).cgPath
////            let anim = Animations.get(property: .ShadowPath,
////                                      fromValue: self.shadowView.layer.shadowPath as Any,
////                                      toValue: destinationPath,
////                                      duration: 0.2,
////                                      delay: 0,
////                                      repeatCount: 0,
////                                      autoreverses: false,
////                                      timingFunction: .linear,
////                                      delegate: nil,
////                                      isRemovedOnCompletion: true,
////                                      completionBlocks: nil)
////            self.shadowView.layer.add(anim, forKey: nil)
////            self.shadowView.layer.shadowPath = destinationPath
//        })
//        observers.append(instance.observe(\UITextView.bounds, options: .new) { [weak self] view, change in
//            guard let self = self,
//                  let value = change.newValue else { return }
//            view.cornerRadius = value.width * 0.05
//            self.background.cornerRadius = view.cornerRadius
////            self.selectionView.cornerRadius = view.cornerRadius
//        })
//        return instance
//    }()
//    private lazy var votersView: UIView = {
//        let instance = UIView()
//        instance.backgroundColor = .clear
//        instance.accessibilityIdentifier = "voters"
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        instance.clipsToBounds = true
//        let constraint = instance.widthAnchor.constraint(equalToConstant: 0)
//        constraint.identifier = "width"
//        constraint.isActive = true
//
//        instance.addSubview(avatarsStackView)
//        avatarsStackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            avatarsStackView.widthAnchor.constraint(equalTo: instance.widthAnchor),
//            avatarsStackView.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
//            avatarsStackView.centerYAnchor.constraint(equalTo: instance.centerYAnchor),
//            avatarsStackView.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)!)*1.65)
//        ])
//        return instance
//    }()
//    private lazy var avatarsStackView: UIStackView = {
//        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
//        imageView.accessibilityIdentifier = "chevron"
//        imageView.clipsToBounds = true
//        imageView.tintColor = mode == .Write ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color : color
//        imageView.contentMode = .center
//        let instance = UIStackView(arrangedSubviews: [avatarsView, imageView])
//        instance.spacing = 0
//        return instance
//    }()
//    private lazy var avatarsView: UIView = {
//       let instance = UIView()
//        instance.backgroundColor = .clear
//        instance.clipsToBounds = true
//        return instance
//    }()
//    private lazy var horizontalStack: UIStackView = {
//        let instance = UIStackView(arrangedSubviews: [shadowView, votersView])//[checkmark, shadowView, votersView])
//        shadowView.translatesAutoresizingMaskIntoConstraints = false
//        shadowView.heightAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
//        constraint.identifier = "height"
//        constraint.isActive = true
//        instance.alignment = .center
//        instance.clipsToBounds = false
//
//        return instance
//    }()
//
//    // MARK: - Destructor
//    deinit {
//        notifications.forEach { $0?.cancel() }
//        NotificationCenter.default.removeObserver(self)
//#if DEBUG
//        print("\(String(describing: type(of: self))).\(#function)")
//#endif
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
//        contentView.addSubview(horizontalStack)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//        topConstraint = horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding)
//
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            votersView.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor),
//            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//        ])
//
//        let constraint = background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        constraint.identifier = "bottom"
//        constraint.priority = .defaultLow
//        constraint.isActive = true
//    }
//
//    private func setObservers() {
//        //Observe votes count only when is complete
//        notifications.append(Task { @MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.SurveyAnswers.TotalVotes) {
//                guard let self = self,
//                      let instance = notification.object as? Answer,
//                      self.item.survey == instance.survey
//                else { return }
//
//                self.setPercentage()
//            }
//        })
//
//        //Observe last voters
//        notifications.append(Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.SurveyAnswers.VotersAppend) {
//                guard let self = self,
//                      let instance = notification.object as? Answer,
//                      self.item == instance,
//                      let lastVoter = self.item.voters.first,
////                      self.avatars.map({ $0.userprofile }).filter({ $0 == lastVoter }).isEmpty
//                      self.avatars.filter({ $0.userprofile == lastVoter}).isEmpty
//                else { return }
//
////                self.item.voters.forEach({ print($0.lastName)})
//                self.updateVotersView(userprofile: lastVoter)
//            }
//        })
//    }
//
//    private func updateAppearance() {
//        guard mode == .Write else {
//            if isSelected, !item.voters.isEmpty {
//                callbackDelegate?.callbackReceived(self)
//            }
//            return
//        }
////        guard let constraint_1 = selectionView.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }//,
////              let constraint_2 = checkmark.getAllConstraints().filter({ $0.identifier == "width"}).first else { return }
//        guard isSelected else {
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
//                self.selectionView.alpha =  self.isSelected ? 1 : 0
//            } completion: { _ in }
//            return
//        }
//        reveal(view: selectionView, duration: 0.25, completionBlocks: [])
//    }
//
//    private func setPercentage(animated: Bool = true) {
//        if let constraint = selectionView.getConstraint(identifier: "fullWidth"), let superview = selectionView.superview {
//
//            selectionView.alpha = 1
//            superview.removeConstraint(constraint)
//
//            let width = textView.frame.width * item.percent
//            let newConstraint = selectionView.widthAnchor.constraint(equalToConstant: animated ? 0 : width)
//            newConstraint.identifier = "width"
//            newConstraint.isActive = true
//
//            guard animated else { return }
//
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75, delay: 0, options: .curveEaseInOut) { [weak self] in
//                guard let self = self else { return }
//                self.setNeedsLayout()
//                newConstraint.constant = width
//                self.layoutIfNeeded()
//            } completion: { _ in }
//        } else if let constraint = selectionView.getConstraint(identifier: "width") {
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: .curveEaseInOut) { [weak self] in
//                guard let self = self else { return }
//                self.setNeedsLayout()
//                constraint.constant = self.textView.frame.width * self.item.percent
//                self.layoutIfNeeded()
//            } completion: { _ in }
//        }
//    }
//
//    private func setupVotersView() {
//        guard item.totalVotes != 0 else {
//            let instance = UILabel()
//            instance.accessibilityIdentifier = "label"
//            instance.textAlignment = .center
//            instance.numberOfLines = 0
//            instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                              forTextStyle: .caption2)
//            instance.text = "no_votes".localized
//            instance.addEquallyTo(to: avatarsView)
//            guard let chevron = avatarsStackView.getSubview(type: UIImageView.self , identifier: "chevron") else { return }
//            avatarsStackView.removeArrangedSubview(chevron)
//            chevron.removeFromSuperview()
//            return
//        }
//
//        var _voters = item.voters
//
//        //Place user at first position
//        if isChosen, _voters.contains(Userprofiles.shared.current!) {
//            _voters.remove(object: Userprofiles.shared.current!)
//            _voters.insert(Userprofiles.shared.current!, at: 0)
//        }
//
//        let voters = Array(_voters.suffix(3))
//
//        voters.enumerated().forEach { index, userpofile in
//            let avatar = NewAvatar(userprofile: userpofile)
//            avatar.layer.zPosition = 10 - CGFloat(index)
//            avatars.append(avatar)
//            avatarsView.addSubview(avatar)
//            avatar.translatesAutoresizingMaskIntoConstraints = false
//
//            avatar.heightAnchor.constraint(equalTo: avatarsView.heightAnchor).isActive = true
//            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1/1).isActive = true
//
//            //Set layout
//            switch voters.count {
//            case 1:
//                if index == 0 {
//                    let constraint = avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor)
//                    constraint.identifier = "centerXAnchor"
//                    constraint.isActive = true
//                }
//            case 2:
//                if index == 0 {
//                    let constraint = avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor, constant: -avatarsView.bounds.height/4)
//                    constraint.identifier = "centerXAnchor"
//                    constraint.isActive = true
//                } else if index == 1 {
//                    let constraint =  avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor, constant: avatarsView.bounds.height/4)
//                    constraint.identifier = "centerXAnchor"
//                    constraint.isActive = true
//                }
//            default:
//                if index == 0 {
//                    let constraint = avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor, constant: -avatarsView.bounds.height/2)
//                    constraint.identifier = "centerXAnchor"
//                    constraint.isActive = true
//                } else if index == 1 {
//                    let constraint =  avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor)
//                    constraint.identifier = "centerXAnchor"
//                    constraint.isActive = true
//                } else if index == 2 {
//                    let constraint = avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor, constant: avatarsView.bounds.height/2)
//                    constraint.identifier = "centerXAnchor"
//                    constraint.isActive = true
//                }
//            }
//        }
//    }
//
//    //Live voters updates
//    private func updateVotersView(userprofile: Userprofile) {
//        //Check if it's a first voter
//        if avatars.isEmpty, let label = avatarsView.getSubview(type: UILabel.self, identifier: "label") {
//            let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
//            imageView.accessibilityIdentifier = "chevron"
//            imageView.clipsToBounds = true
//            imageView.tintColor = mode == .Write ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color : color
//            imageView.contentMode = .center
//            imageView.alpha = 0
//
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
//                label.alpha = 0
//            } completion: { _ in
//                label.removeFromSuperview()
//                self.avatarsStackView.addArrangedSubview(imageView)
//                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0) {
//                    imageView.alpha = 1
//                }
//            }
//        }
//
//        let avatar = NewAvatar(userprofile: userprofile)
//        avatar.layer.zPosition = 10
//        avatar.alpha = 0
//        avatars.forEach{ $0.layer.zPosition -= 1 }
//        avatarsView.addSubview(avatar)
//        avatar.translatesAutoresizingMaskIntoConstraints = false
//
//        avatar.heightAnchor.constraint(equalTo: avatarsView.heightAnchor).isActive = true
//        avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1/1).isActive = true
//
//        switch avatars.count {
//        case 1:
//
//            let constraint = avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor, constant: -avatarsView.bounds.height/4)
//            constraint.identifier = "centerXAnchor"
//            constraint.isActive = true
//
//            guard let last = avatars.last,
//                  let lastConstraint = last.getConstraint(identifier: "centerXAnchor")
//            else { return }
//
//            avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, animations: {
//                avatar.alpha = 1
//                avatar.transform = .identity
//                self.setNeedsLayout()
//                lastConstraint.constant += last.frame.width/4
//                self.layoutIfNeeded()
//            }) { _ in self.avatars.append(avatar) }
//        case 2:
//            print("")
////            if index == 0 {
////                avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor, constant: -avatarsView.bounds.height/4).isActive = true
////            } else if index == 1 {
////                avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor, constant: avatarsView.bounds.height/4).isActive = true
////            }
//        default:
//            print("")
////            if index == 0 {
////                avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor, constant: -avatarsView.bounds.height/2).isActive = true
////            } else if index == 1 {
////                avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor).isActive = true
////            } else if index == 2 {
////                avatar.centerXAnchor.constraint(equalTo: avatarsView.centerXAnchor, constant: avatarsView.bounds.height/2).isActive = true
////            }
//        }
//    }
//
//    private func reveal(view animatedView: UIView, duration: TimeInterval, animateOpacity: Bool = true, completionBlocks: [Closure] = []) {
//
//        let circlePathLayer = CAShapeLayer()
//        var _completionBlocks = completionBlocks
//        var circleFrameTopCenter: CGRect {
//            var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
//            let circlePathBounds = circlePathLayer.bounds
//            circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
//            circleFrame.origin.y = circlePathBounds.minY - circleFrame.minY
//            return circleFrame
//        }
//
//        var circleFrameTop: CGRect {
//            var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
//            let circlePathBounds = circlePathLayer.bounds
//            circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
//            circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
//            return circleFrame
//        }
//
//        var circleFrameTopLeft: CGRect {
//            return CGRect.zero
//        }
//
//        var circleFrameCenter: CGRect {
//            var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
//            let circlePathBounds = circlePathLayer.bounds
//            circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
//            circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
//            return circleFrame
//        }
//
//        func circlePath(_ rect: CGRect) -> UIBezierPath {
//            return UIBezierPath(ovalIn: rect)
//        }
//
//        circlePathLayer.frame = animatedView.bounds
//        circlePathLayer.path = circlePath(circleFrameCenter).cgPath
//        animatedView.layer.mask = circlePathLayer
//        if !animateOpacity {
//            animatedView.alpha = 1
//            animatedView.layer.opacity = 0
//        }
//
//        let center = (x: animatedView.bounds.midX, y: animatedView.bounds.midY)
//
//        let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
//
//        let radiusInset = finalRadius
//
//        let outerRect = circleFrameCenter.insetBy(dx: -radiusInset, dy: -radiusInset)
//
//        let toPath = UIBezierPath(ovalIn: outerRect).cgPath
//
//        let fromPath = circlePathLayer.path
//
//        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
//
//        maskLayerAnimation.fromValue = fromPath
//        maskLayerAnimation.toValue = toPath
//        maskLayerAnimation.duration = duration
//        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        maskLayerAnimation.isRemovedOnCompletion = true
//        _completionBlocks.append({ animatedView.layer.mask = nil })
//        maskLayerAnimation.delegate = self
//        maskLayerAnimation.setValue(_completionBlocks, forKey: "maskCompletionBlocks")
//        circlePathLayer.add(maskLayerAnimation, forKey: "path")
//        circlePathLayer.path = toPath
////        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
////        fadeAnim.fromValue = 0
////        fadeAnim.toValue = 1
//        let opacityAnim = Animations.get(property: .Opacity, fromValue: 0, toValue: 1, duration: duration, timingFunction: CAMediaTimingFunctionName.easeIn, delegate: nil)
////        opacityAnim.setValue(_completionBlocks, forKey: "completionBlocks")
////        let groupAnim = Animations.group(animations: [maskLayerAnimation, opacityAnim], duration: duration, delegate: nil)
////        let groupAnim = Animations.group(animations: [maskLayerAnimation, opacityAnim], repeatCount: 0, autoreverses: false, duration: duration, delay: 0, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: true)
//
////        circlePathLayer.add(groupAnim, forKey: "path")
////        circlePathLayer.path = toPath
////        animatedView.layer.opacity = 1
//        animatedView.layer.add(opacityAnim, forKey: nil)
//        animatedView.layer.opacity = 1
//    }
//
//    // MARK: - Overriden methods
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
////        avatars.forEach {
////            $0.imageView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
////            $0.borderBg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
////        }
//
//        avatarsStackView.get(all: UIImageView.self).filter({ $0.accessibilityIdentifier == "chevron"}).forEach {
//            $0.tintColor = mode == .Write ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : color : color
//        }
//
//        horizontalStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
//            $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        }
//        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemGray5
//        selectionView.backgroundColor = mode == .ReadOnly ? color.withAlphaComponent(0.65) : traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color.withAlphaComponent(0.65)
////        self.checkmark.get(all: UIImageView.self).first?.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
//
//        //Set dynamic font size
//        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
//        textView.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                          forTextStyle: .body)
//        guard let constraint = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
//        setNeedsLayout()
//        constraint.constant = textView.contentSize.height + padding*2
//        layoutIfNeeded()
//    }
//}
//
//// MARK: - CAAnimationDelegate
//extension ChoiceCell: CAAnimationDelegate {
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
//            completionBlocks.forEach{ $0() }
//        }
//    }
//}
