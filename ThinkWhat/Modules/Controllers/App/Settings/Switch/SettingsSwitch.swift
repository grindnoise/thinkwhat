//
//  SettingsSwitch.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SettingsSwitch: UIView {
        
    //MARK: - IB
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.accessibilityIdentifier = "backgroundView"
            backgroundView.layer.masksToBounds = false
            backgroundView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
            backgroundView.publisher(for: \.bounds, options: .new)
                .sink { [weak self] rect in
                    guard let self = self else { return }
                    
                    self.backgroundView.cornerRadius = rect.height/2
                }
                .store(in: &subscriptions)
        }
    }
    @IBOutlet weak var shadowView: UIView! {
        didSet {
            shadowView.clipsToBounds = false
            shadowView.backgroundColor = .clear
            shadowView.accessibilityIdentifier = "shadow"
            shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            shadowView.layer.shadowRadius = 5
            shadowView.layer.shadowOffset = .zero
            shadowView.publisher(for: \.bounds, options: .new)
                .sink { [weak self] rect in
                    guard let self = self else { return }
                    
                    self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.width/2).cgPath
                }
                .store(in: &subscriptions)
        }
    }
    @IBOutlet weak var stackView: UIStackView!
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
    
    
    
    //MARK: - Public properties
    //Publishers
    public var statePublisher = CurrentValueSubject<SettingsController.Mode?, Never>(nil)
    
    
    //MARK: - Overridden properties
//    override var bounds: CGRect {
//        didSet {
//            guard oldValue != bounds, !backgroundView.isNil else { return }
//            backgroundView.cornerRadius = bounds.height / 2
//            mark.frame = CGRect(origin: .zero, size: CGSize(width: bounds.height, height: bounds.height))
//            mark.cornerRadius = bounds.height / 2
//        }
//    }
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Logic
    public var state: SettingsController.Mode = .Profile {
        didSet {
            guard state != oldValue else { return }
            
            statePublisher.send(state)
//            callbackDelegate?.callbackReceived(state)
            var imageName: String!
            var newView: UIView!
            
            switch state {
            case .Profile:
                newView = profile
                imageName = "person.fill"
            case .Settings:
                newView = settings
                imageName = "gear"
            }
            let image = UIImage(systemName: imageName,
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: mark.bounds.size.height * 0.45, weight: .semibold, scale: .medium))
            
            guard let imageView = mark.getSubview(type: UIImageView.self, identifier: "innerView") else { return }
//            UIView.transition(with: imageView, duration: 0.175, options: .transitionCrossDissolve) { [weak self] in
//                guard let self = self,
//                      let constraint = self.mark.getConstraint(identifier: "leading")
//                else { return }
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.3,
                options: [.curveEaseInOut],
                animations: { [weak self] in
            guard let self = self,
                      let constraint = self.mark.getConstraint(identifier: "leading")
                else { return }
//                self.mark.center.x  = newView.center.x
                self.setNeedsLayout()
                constraint.constant = newView.frame.origin.x
                self.layoutIfNeeded()
                imageView.image = image
            }) { _ in }
        }
    }
    //UI
    public var color: UIColor = Constants.UI.Colors.System.Red.rawValue {
        didSet {
            gradient.colors = getGradientColors()
        }
    }
    
    
    
    
//    private weak var callbackDelegate: CallbackObservable?
    private lazy var mark: UIView = {
        let instance = UIView()
        instance.layer.zPosition = 10
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "mark"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        instance.layer.shadowRadius = 7
        instance.layer.shadowOffset = .zero
        instance.layer.addSublayer(gradient)
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self else { return }
                
                instance.cornerRadius = rect.height/2
                
                                guard rect != .zero,
                                      let layer = instance.layer.getSublayer(identifier: "radialGradient"),
                                      layer.bounds != rect
                                else { return }
                
                                layer.frame = rect

//                guard rect != .zero,
//                      let layer = instance.layer.getSublayer(identifier: "radialGradient") as? CAGradientLayer,
//                      layer.bounds != rect
//                else { return }
//
//                layer.frame = rect
//                layer.endPoint = CGPoint(x: 1,
//                                         y: 0.5 + rect.width / rect.height / 2)
            }
            .store(in: &subscriptions)

        let innerView = UIImageView()
        innerView.clipsToBounds = false
        innerView.accessibilityIdentifier = "innerView"
        innerView.contentMode = .center
        innerView.image = UIImage(systemName: "person.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: innerView.bounds.height * 0.45, weight: .semibold, scale: .medium))
        innerView.addEquallyTo(to: instance)
        innerView.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        innerView.tintColor = .white
        innerView.publisher(for: \.bounds, options: .new)
            .sink { rect in
                innerView.cornerRadius = rect.height/2
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var gradient: CAGradientLayer = {
        let instance = CAGradientLayer()
        instance.type = .radial
        instance.colors = getGradientColors()
        instance.locations = [0, 0.5, 1.15]
        instance.setIdentifier("radialGradient")
        instance.startPoint = CGPoint(x: 0.5, y: 0.5)
        instance.endPoint = CGPoint(x: 1, y: 1)
        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.cornerRadius = rect.height/2
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    
    
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    
    
    // MARK: - Initialization
//    init(callbackDelegate: CallbackObservable) {
//        self.callbackDelegate = callbackDelegate
//        super.init(frame: .zero)
//        commonInit()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setTasks()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
        setTasks()
    }
    
    
    
//    private func setupUI() {
//        profile.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//        profile.tintColor = .white
//        backgroundView.insertSubview(mark, at: 0)
//        backgroundView.clipsToBounds = false
//        mark.clipsToBounds = false
//        mark.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        profile.tintColor = traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel
//        settings.tintColor = state == .Settings ? traitCollection.userInterfaceStyle == .dark ? .black : .white : .secondaryLabel
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        backgroundView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        mark.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        gradient.colors = getGradientColors()
    }
}

private extension SettingsSwitch {
    func setupUI() {
//        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
//
//        contentView.backgroundColor = .clear
//        addSubview(contentView)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//        ])
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        shadowView.addSubview(mark)
        contentView.backgroundColor = .clear
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
    
    func setTasks() {
//        tasks.append(Task { [weak self] in
//            guard !self.isNil else { return }
//            for await _ in await NotificationCenter.default.notifications(for: UIApplication.willResignActiveNotification) {
//                print("UIApplication.willResignActiveNotification")
//            }
//        })
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        guard let v = recognizer.view else { return }
        if v === profile {
            state = .Profile
        } else if v === settings {
            state = .Settings
        }
    }
    
    func getGradientColors() -> [CGColor] {
        return [
            color.cgColor,
            color.cgColor,
            color.lighter(0.15).cgColor,
//            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
//            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
//            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.lighter(0.2).cgColor : K_COLOR_RED.lighter(0.2).cgColor,
        ]
    }
}
