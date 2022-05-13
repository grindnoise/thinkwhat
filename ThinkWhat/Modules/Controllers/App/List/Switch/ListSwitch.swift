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
        case Top, New, Watching
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
        new.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        new.tintColor = .white
        bg.insertSubview(mark, at: 0)
        bg.clipsToBounds = false
        mark.clipsToBounds = false
        mark.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        top.tintColor = state == .Top ? .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        new.tintColor = state == .New ? .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        watching.tintColor = state == .Watching ? .white : .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        mark.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        guard let v = recognizer.view else { return }
        if v === top {
            state = .Top
        } else if v === new {
            state = .New
        } else {
            state = .Watching
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var top: UIImageView! {
        didSet {
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
    
    var state: ListSwitch.State = .New {
        didSet {
            guard state != oldValue else { return }
            callbackDelegate?.callbackReceived(state)
            var oldView: UIView!
            switch oldValue {
            case .Top:
                oldView = top
            case .New:
                oldView = new
            case .Watching:
                oldView = watching
            }
            var newView: UIView!
            switch state {
            case .Top:
                newView = top
            case .New:
                newView = new
            case .Watching:
                newView = watching
            }
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: [.curveEaseInOut]) {
                self.mark.center.x  = newView.center.x
                oldView.tintColor = .secondaryLabel//self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
                oldView.transform = .identity
                newView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                newView.tintColor = .white
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
