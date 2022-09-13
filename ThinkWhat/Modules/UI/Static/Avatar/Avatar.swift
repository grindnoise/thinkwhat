//
//  Avatar.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class delAvatar: UIView {
    
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
//        userPic.backgroundColor = .lightGray
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

class Avatar: UIView {
    
    // MARK: - Public properties
    public var isEditable: Bool {
        didSet {
            
        }
    }
    public weak var userprofile: Userprofile! {
        didSet {
            guard !userprofile.isNil else { return }
            setImage()
        }
    }
    public var isShadowed: Bool {
        didSet {
            shadowView.layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
        }
    }
    public var isBordered: Bool
    public var borderColor: UIColor {
        didSet {
            coloredBackground.backgroundColor = borderColor
        }
    }
    public var shadowColor: UIColor = .clear {
        didSet {
            shadowView.layer.shadowColor = shadowColor.withAlphaComponent(0.4).cgColor
        }
    }
    public lazy var coloredBackground: Shimmer = {
        let instance = Shimmer()
        instance.accessibilityIdentifier = "coloredBackground"
        instance.clipsToBounds = true
        instance.backgroundColor = borderColor
        
        if isBordered {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            instance.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: instance.centerYAnchor),
                imageView.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
                imageView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.85),
                imageView.heightAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.85),
            ])
        } else {
            imageView.addEquallyTo(to: instance)
        }
        
        observers.append(instance.observe(\Shimmer.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width/2
        })
        
        return instance
    }()
    public lazy var imageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.accessibilityIdentifier = "imageView"
        instance.layer.masksToBounds = true
        instance.backgroundColor = .clear//.systemGray2
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
//            if self.userprofile.isNil {
//                view.contentMode = .center
//                let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height*0.65, weight: .regular, scale: .medium)
//                instance.image = UIImage(systemName: "face.smiling.fill", withConfiguration: largeConfig)
//                return
//            }
            if self.userprofile == Userprofile.anonymous {
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.image = UIImage(named: "anon")
                return
            }
//            guard let _ = self.userprofile.image else {
//                view.contentMode = .center
//                let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height*0.65, weight: .regular, scale: .medium)
//                instance.image = UIImage(systemName: "face.smiling.fill", withConfiguration: largeConfig)
//                return
//            }
            view.contentMode = .scaleAspectFit
        })
        return instance
    }()
    
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
        background.addEquallyTo(to: instance)
        return instance
    }()
    private lazy var imageButton: UIButton = {
       let instance = UIButton()
        
        if #available(iOS 15, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "pencil.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
            config.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
                guard let self = self else { return .systemGray }

                return self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            }
            config.buttonSize = .large

            instance.configuration = config
        } else {
            let attrString = NSMutableAttributedString(string: "Мужчина", attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ])
            instance.setAttributedTitle(attrString, for: .normal)
            instance.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            instance.titleEdgeInsets.left = 2
//            instance.titleEdgeInsets.right = 8
            instance.titleEdgeInsets.top = 2
            instance.titleEdgeInsets.bottom = 2
            instance.setImage(UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
            instance.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            instance.imageView?.contentMode = .scaleAspectFit
            instance.imageEdgeInsets.left = 10
            instance.imageEdgeInsets.top = 2
            instance.imageEdgeInsets.bottom = 2
            instance.imageEdgeInsets.right = 2
            instance.semanticContentAttribute = .forceRightToLeft
            instance.backgroundColor = .secondarySystemBackground

            let constraint = instance.widthAnchor.constraint(equalToConstant: "Мужчина".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!))
            constraint.identifier = "width"
            constraint.isActive = true
        }
        
        observers.append(instance.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue
            else { return }
            
            view.cornerRadius = newValue.height * 0.15
        })
        return instance
    }()
    public lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.clipsToBounds = true
        instance.backgroundColor = .systemBackground
        
        coloredBackground.addEquallyTo(to: instance)
        
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width/2
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
    init(userprofile: Userprofile? = nil, isShadowed: Bool = false, isBordered: Bool = false, borderColor: UIColor = .clear, isEditable: Bool = false) {
        self.isEditable = isEditable
        self.isShadowed = isShadowed
        self.isBordered = isBordered
        self.borderColor = borderColor
        self.userprofile = userprofile
        
        super.init(frame: .zero)

        setObservers()
        setupUI()
        guard !userprofile.isNil else { return }
        setImage()
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
                      object === self.userprofile,
                      let image = self.userprofile.image
                else { return }
//                Animations.changeImageCrossDissolve(imageView: self.imageView, image: image)
                self.coloredBackground.stopShimmering()
                self.imageView.image = image
            }
        })
    }
    
    private func setImage() {
//        guard !userprofile.isNil else { return }
        guard userprofile != Userprofile.anonymous else {
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.image = UIImage(named: "anon")
            return
        }
        guard let image = userprofile.image else {
            coloredBackground.startShimmering()
            Task { [weak self] in
                guard let self = self else { return }
                
                do {
                    let image = try await self.userprofile.downloadImageAsync()
                    await MainActor.run {
                        self.imageView.contentMode = .scaleAspectFit
                    }
//                    Animations.changeImageCrossDissolve(imageView: self.imageView, image: image)
                    self.coloredBackground.stopShimmering()
                    self.imageView.image = image
                } catch {
                    await MainActor.run {
                        let largeConfig = UIImage.SymbolConfiguration(pointSize: self.imageView.bounds.height*0.65, weight: .regular, scale: .medium)
                        self.imageView.tintColor = .white
                        self.imageView.contentMode = .center
//                        Animations.changeImageCrossDissolve(imageView: self.imageView, image: UIImage(systemName: "face.smiling.fill", withConfiguration: largeConfig)!)
                        self.coloredBackground.stopShimmering()
                        self.imageView.image = UIImage(systemName: "face.smiling.fill", withConfiguration: largeConfig)!
                    }
                }
            }
            return
        }
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.coloredBackground.stopShimmering()
            self.imageView.image = image
            self.imageView.contentMode = .scaleAspectFit
        }
    }
    
    // MARK: - Public methods
    public func clearImage() {
//        let largeConfig = UIImage.SymbolConfiguration(pointSize: imageView.bounds.height*0.65, weight: .regular, scale: .medium)
//        imageView.image = UIImage(systemName: "face.smiling.fill", withConfiguration: largeConfig)
//        imageView.tintColor = .white
//        imageView.contentMode = .center
        imageView.image = nil
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        shadowView.layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    }
}
