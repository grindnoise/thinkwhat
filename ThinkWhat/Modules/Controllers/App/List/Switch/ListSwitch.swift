//
//  ListSwitch.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ListSwitch: UIView {

    enum State {
        case Top, New, Watching, Own
    }
    
    private var observers: [NSKeyValueObservation] = []
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.accessibilityIdentifier = "backgroundView"
            backgroundView.layer.masksToBounds = false
            backgroundView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
            observers.append(backgroundView.observe(\UIView.bounds, options: .new) { view, change in
                guard let value = change.newValue else { return }
                view.cornerRadius = value.height/2
            })
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadowView: UIView! {
        didSet {
            shadowView.clipsToBounds = false
            shadowView.backgroundColor = .clear
            shadowView.accessibilityIdentifier = "shadow"
            shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            shadowView.layer.shadowRadius = 5
            shadowView.layer.shadowOffset = .zero
            observers.append(shadowView.observe(\UIView.bounds, options: .new) { view, change in
                guard let newValue = change.newValue else { return }
                view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.height/2).cgPath
            })
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var top: UIImageView! {
        didSet {
            top.layer.zPosition = 10
            top.isUserInteractionEnabled = true
            top.contentMode = .center
            top.image = ImageSigns.capslockFilled.image
            top.tintColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            top.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var new: UIImageView! {
        didSet {
            new.isUserInteractionEnabled = true
            new.contentMode = .center
            new.image = ImageSigns.tagFilled.image
            new.tintColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            new.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var watching: UIImageView! {
        didSet {
            watching.isUserInteractionEnabled = true
            watching.contentMode = .center
            watching.image = ImageSigns.binocularsFilled.image
            watching.tintColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            watching.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var own: UIImageView! {
        didSet {
            own.isUserInteractionEnabled = true
            own.contentMode = .center
            own.image = ImageSigns.figureWave.image
            own.tintColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            own.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        }
    }
    
    var state: ListSwitch.State = .New {
        didSet {
            guard state != oldValue else { return }
            callbackDelegate?.callbackReceived(state)
            
            var imageName: String!
            var newView: UIView!
            
            switch state {
            case .Top:
                imageName = "capslock.fill"
                newView = top
            case .New:
                newView = new
                imageName = "tag.fill"
            case .Watching:
                imageName = "binoculars.fill"
                newView = watching
            case .Own:
                imageName = "figure.wave"
                newView = own
            }
            
            let image = UIImage(systemName: imageName,
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: mark.bounds.size.height * 0.45, weight: .semibold, scale: .medium))
            
            guard let imageView = mark.getSubview(type: UIImageView.self, identifier: "innerView") else { return }
            UIView.transition(with: imageView, duration: 0.175, options: .transitionCrossDissolve) { [weak self] in
                guard let self = self else { return }
                self.mark.center.x  = newView.center.x
                imageView.image = image
            } completion: { _ in }
        }
    }
    
    private lazy var mark: UIView = {
        let instance = UIView()
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "mark"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        instance.layer.shadowRadius = 7
        instance.layer.shadowOffset = .zero
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
//            guard let newValue = change.newValue else { return }
//            view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.height/2).cgPath
//        })
        let innerView = UIImageView()
        innerView.accessibilityIdentifier = "innerView"
        innerView.contentMode = .center
        innerView.addEquallyTo(to: instance)
        innerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        innerView.tintColor = .white
        observers.append(innerView.observe(\UIImageView.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height * 0.45, weight: .semibold, scale: .medium)
            let image = UIImage(systemName: "tag.fill", withConfiguration: largeConfig)
            view.image = image
            view.cornerRadius = view.bounds.height/2
        })

        return instance
    }()
    private weak var callbackDelegate: CallbackObservable?
    
    // MARK: - Initialization
    init(callbackDelegate: CallbackObservable) {
        self.callbackDelegate = callbackDelegate
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        shadowView.addSubview(mark)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mark.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mark.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            mark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        let constraint = mark.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: 0)
        constraint.identifier = "leading"
        constraint.isActive = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        mark.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        backgroundView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
//        top.tintColor = state == .Top ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        new.tintColor = state == .New ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        watching.tintColor = state == .Watching ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        own.tintColor = state == .Own ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        mark.getSubview(type: UIView.self, identifier: "innerView")?.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        guard let v = recognizer.view else { return }
        if v === top {
            state = .Top
        } else if v === new {
            state = .New
        } else if v === watching {
            state = .Watching
        } else {
            state = .Own
        }
    }
}
