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
        case Read, Edit, Settings
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
        read.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        read.tintColor = .white
        bg.insertSubview(mark, at: 0)
        bg.clipsToBounds = false
        mark.clipsToBounds = false
        mark.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        read.tintColor = state == .Read ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        edit.tintColor = state == .Edit ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        settings.tintColor = state == .Settings ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        mark.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        guard let v = recognizer.view else { return }
        if v === read {
            state = .Read
        } else if v === edit {
            state = .Edit
        } else if v === settings {
            state = .Settings
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var read: UIImageView! {
        didSet {
            read.isUserInteractionEnabled = true
            read.contentMode = .center
            read.image = ImageSigns.personFilled.image
            read.tintColor = .secondaryLabel
            read.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var edit: UIImageView! {
        didSet {
            edit.isUserInteractionEnabled = true
            edit.contentMode = .center
            edit.image = ImageSigns.pencil.image
            edit.tintColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            edit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
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
    
    var state: SettingsSwitch.State = .Read {
        didSet {
            guard state != oldValue else { return }
            callbackDelegate?.callbackReceived(state)
            var oldView: UIView!
            switch oldValue {
            case .Read:
                oldView = read
            case .Edit:
                oldView = edit
            case .Settings:
                oldView = settings
            }
            var newView: UIView!
            switch state {
            case .Read:
                newView = read
            case .Edit:
                newView = edit
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

