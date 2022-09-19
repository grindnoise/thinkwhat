//
//  SettingsSwitch.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SettingsSwitch: UIView {

    enum State {
        case Profile, Settings
    }
    
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
        
        contentView.backgroundColor = .clear
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setupUI()
    }
    
    private func setupUI() {
        profile.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        profile.tintColor = .white
        bg.insertSubview(mark, at: 0)
        bg.clipsToBounds = false
        mark.clipsToBounds = false
        mark.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        profile.tintColor = state == .Profile ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel
        settings.tintColor = state == .Settings ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel
        mark.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        guard let v = recognizer.view else { return }
        if v === profile {
            state = .Profile
        } else if v === settings {
            state = .Settings
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var profile: UIImageView! {
        didSet {
            profile.isUserInteractionEnabled = true
            profile.contentMode = .center
            profile.image = ImageSigns.personFilled.image
            profile.tintColor = .secondaryLabel
            profile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var settings: UIImageView! {
        didSet {
            settings.isUserInteractionEnabled = true
            settings.contentMode = .center
            settings.image = ImageSigns.gear.image
            settings.tintColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            settings.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        }
    }
    
    var state: SettingsSwitch.State = .Profile {
        didSet {
            guard state != oldValue else { return }
            callbackDelegate?.callbackReceived(state)
            var oldView: UIView!
            switch oldValue {
            case .Profile:
                oldView = profile
            case .Settings:
                oldView = settings
            }
            var newView: UIView!
            switch state {
            case .Profile:
                newView = profile
            case .Settings:
                newView = settings
            }
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: [.curveEaseInOut]) {
                self.mark.center.x  = newView.center.x
                oldView.tintColor = .secondaryLabel//self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
                oldView.transform = .identity
                newView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                newView.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .black : .white
            } completion: { _ in }
        }
    }
    
    private let mark = UIView(frame: .zero)
    private weak var callbackDelegate: CallbackObservable?
    
    override var bounds: CGRect {
        didSet {
            guard oldValue != bounds, !bg.isNil else { return }
            bg.cornerRadius = bounds.height / 2
            mark.frame = CGRect(origin: .zero, size: CGSize(width: bounds.height, height: bounds.height))
            mark.cornerRadius = bounds.height / 2
        }
    }
}

