//
//  Avatar.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class Avatar: UIView {
    
    private var gender: Gender = .Male
    @MainActor public var image: UIImage? {
        didSet {
            guard let image = image, !container.isNil else {
                return
            }
            imageView.image = image
            imageView.addEquallyTo(to: container)
            let icon = self.container.get(all: Icon.self).first
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseOut) { [weak self] in
                guard let self = self else { return }
                self.imageView.alpha = 1
                self.imageView.transform = .identity
                icon?.alpha = 0
            } completion: { _ in
                guard !icon.isNil else { return }
                icon!.removeFromSuperview()
            }
        }
    }
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha  = 0
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        imageView.addEquallyTo(to: container)
//        let icon = self.container.get(all: Icon.self).first
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseOut) { [weak self] in guard !self.isNil else { return }
//            imageView.alpha = 1
//            imageView.transform = .identity
//            icon?.alpha = 0
//        } completion: { _ in
//            guard !icon.isNil else { return }
//            icon!.removeFromSuperview()
//        }
        return imageView
    }()

    public var lightColor = K_COLOR_RED {
        didSet {
            border.backgroundColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return self.darkColor
                default:
                    return self.lightColor
                }
            }
        }
    }
    public var darkColor = UIColor.systemBlue {
        didSet {
            border.backgroundColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return self.darkColor
                default:
                    return self.lightColor
                }
            }
        }
    }
    weak var delegate: CallbackObservable?
    public lazy var isBordered: Bool = false {
        didSet {
            guard isBordered, let constraint = container.getAllConstraints().filter({ $0.identifier == "ratio" }).first else { return }
            container.superview!.removeConstraint(constraint)
            let new = container.heightAnchor.constraint(equalTo: border.heightAnchor, multiplier: 0.9)
            new.identifier = "ratio"
            new.isActive = true
        }
    }
    private var observers: [NSKeyValueObservation] = []
    
    //MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var borderBg: UIView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var container: UIView!
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(gender: Gender, image: UIImage? = nil, borderColor: UIColor = .clear) {
        super.init(frame: .zero)
        self.gender = gender
        self.image = image
//        self.isBordered = borderColor != .clear
        self.lightColor = borderColor
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setObservers()
        setupUI()
    }
    
    private func setObservers() {
        observers.append(container.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard !self.isNil, let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height / 2
        })
        observers.append(borderBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard !self.isNil, let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height / 2
        })
        observers.append(border.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard !self.isNil, let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height / 2
        })
    }
    
    private func setupUI() {
        var userPic: UIView!
        if image.isNil {
            userPic = Icon(category: gender == .Male ? .ManFace : .GirlFace, scaleMultiplicator: 1.5)
        } else {
            userPic = UIImageView(image: image)
            userPic.isUserInteractionEnabled = true
            userPic.contentMode = .scaleAspectFill
        }
        userPic.backgroundColor = .lightGray
        userPic.addEquallyTo(to: container)
        userPic.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(self.handleTap)))
        
        guard !isBordered else {
            border.backgroundColor = traitCollection.userInterfaceStyle == .dark ? darkColor : lightColor
            return
        }
        
//        container.getAllConstraints().forEach{ container.removeConstraint($0) }
////        container.translatesAutoresizingMaskIntoConstraints = false
//        container.leadingAnchor.constraint(equalTo: border.leadingAnchor).isActive = true
//        container.trailingAnchor.constraint(equalTo: border.trailingAnchor).isActive = true
//        container.topAnchor.constraint(equalTo: border.topAnchor).isActive = true
//        container.bottomAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        
//        guard let constraint = container.getAllConstraints().filter({ $0.identifier == "ratio" }).first else { return }
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.removeConstraint(constraint)
//        container.heightAnchor.constraint(equalTo: border.heightAnchor).isActive = true
//        container.widthAnchor.constraint(equalTo: border.widthAnchor).isActive = true

    }
    
    @objc
    private func handleTap() {
        delegate?.callbackReceived(self)
    }
}

class NewAvatar: UIView {
    
    // MARK: - Public properties
    public var userprofile: Userprofile! {
        didSet {
            guard let userprofile = userprofile else { return }
            guard let image = userprofile.image else {
                Task {
                    let image = try await userprofile.downloadImageAsync()
                    await MainActor.run {
                        imageView.contentMode = .scaleAspectFit
                    }
                    Animations.changeImageCrossDissolve(imageView: imageView, image: image)
                }
                return
            }
//            imageView.contentMode = .scaleAspectFit
            Task { @MainActor in imageView.image = image }
            
//            Animations.changeImageCrossDissolve(imageView: imageView, image: image)
        }
    }
    public var isShadowed: Bool {
        didSet {
            shadowView.layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
        }
    }
    public var shadowColor: UIColor = .clear {
        didSet {
            shadowView.layer.shadowColor = shadowColor.withAlphaComponent(0.4).cgColor
        }
    }
    
    // MARK: - Private properties
    private var notifications: [Task<Void, Never>?] = []
    private var observers: [NSKeyValueObservation] = []
    private lazy var shadowView: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadowView"
        instance.layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        instance.layer.shadowRadius = 4
        instance.layer.shadowOffset = .zero
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.layer.shadowPath = UIBezierPath(ovalIn: newValue).cgPath
        })
        imageView.addEquallyTo(to: instance)
        return instance
    }()
    private lazy var imageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.accessibilityIdentifier = "imageView"
        instance.layer.masksToBounds = true
        instance.backgroundColor = .systemGray2
        if let userprofile = userprofile, let image = userprofile.image {
            instance.image = image
        } else {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: instance.bounds.height*0.65, weight: .regular, scale: .medium)
            instance.image = UIImage(systemName: "face.smiling.fill", withConfiguration: largeConfig)
            instance.tintColor = .white
            instance.contentMode = .center
        }
        observers.append(instance.observe(\UIImageView.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue
            else { return }
            view.cornerRadius = newValue.height/2
            guard let _ = self.userprofile.image else {
                view.contentMode = .center
                let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height*0.65, weight: .regular, scale: .medium)
                instance.image = UIImage(systemName: "face.smiling.fill", withConfiguration: largeConfig)
                return
            }
            view.contentMode = .scaleAspectFit
        })
        return instance
    }()
    
    // MARK: - Destructor
    deinit {
        notifications.forEach { $0?.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }

    // MARK: - Initialization
    init(userprofile: Userprofile? = nil, isShadowed: Bool = false) {
        self.userprofile = userprofile
        self.isShadowed = isShadowed
        super.init(frame: .zero)
        
        setObservers()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = false

        addSubview(shadowView)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: topAnchor),
            shadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setObservers() {
        notifications.append(Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.ImageDownloaded) {
                guard let self = self,
                      let object = notification.object as? Userprofile,
                      object === userprofile,
                      let image = self.userprofile.image
                else { return }
                Animations.changeImageCrossDissolve(imageView: self.imageView, image: image)
            }
        })
    }
    
    // MARK: - Public methods
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        shadowView.layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    }
}
