//
//  Avatar.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

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
    
    enum Mode {
        case Default, Editing, Choice, Selection
    }
    
    // MARK: - Public properties
    public var mode: Mode = .Default {
        didSet {
            guard oldValue != mode else { return }
                
            if mode == .Selection {
//                button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0) { [unowned self] in
//                    self.button.alpha = 1
//                    self.button.transform = .identity
//                }
            } else if mode == .Default, oldValue == .Selection {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, animations: { [unowned self] in
                    self.button.alpha = 0
                    self.button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }) { _ in
                    self.button.transform = .identity
                }
            } else if mode == .Editing {
                button.menu = prepareMenu()
                button.alpha = 1
                button.setImage(UIImage(systemName: "pencil",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: button.bounds.height*0.6,
                                                                                         weight: .semibold)),
                                  for: .normal)
                button.imageView?.contentMode = .center
            }
        }
    }
    public weak var userprofile: Userprofile! {
        didSet {
            guard !userprofile.isNil else { return }
            setImage()
        }
    }
    public var isSelected: Bool = false {
        didSet {
            button.setImage(UIImage(systemName: isSelected ? "pencil" : "",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: button.bounds.height*0.6,
                                                                                     weight: .semibold)),
                              for: .normal)
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
    public lazy var buttonBgLightColor: UIColor = .systemBackground{
        didSet {
            guard traitCollection.userInterfaceStyle != .dark else { return }
            button.backgroundColor = buttonBgLightColor
        }
    }
    public lazy var buttonBgDarkColor: UIColor = .systemBackground{
        didSet {
            guard traitCollection.userInterfaceStyle == .dark else { return }
            button.backgroundColor = buttonBgDarkColor
        }
    }

    public lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.clipsToBounds = true
        instance.backgroundColor = .systemBackground
        
        coloredBackground.addEquallyTo(to: instance)
        
        instance.publisher(for: \.bounds, options: .new).sink { rect in
            instance.cornerRadius = rect.height/2
        }.store(in: &subscriptions)
        
        return instance
    }()
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
//                imageView.heightAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.85),
            ])
        } else {
//            imageView.addEquallyTo(to: instance)
            imageView.layoutCentered(in: instance)
        }
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.cornerRadius = rect.height/2
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    public lazy var imageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.accessibilityIdentifier = "imageView"
        instance.layer.masksToBounds = true
        instance.backgroundColor = .clear//.systemGray2
        instance.isUserInteractionEnabled = true
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        
        if let userprofile = userprofile, let image = userprofile.image {
            instance.image = image
        } else {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: instance.bounds.height*0.65, weight: .regular, scale: .medium)
            instance.image = UIImage(systemName: "face.smiling.fill", withConfiguration: largeConfig)
            instance.tintColor = .white
            instance.contentMode = .center
        }
        
        instance.publisher(for: \.bounds, options: .new).sink { [weak self] rect in
            instance.cornerRadius = rect.height/2
            
            guard let self = self, self.userprofile == Userprofile.anonymous else {
                instance.contentMode = .scaleAspectFill
                return
            }
            
            instance.contentMode = .scaleAspectFill
            instance.image = UIImage(named: "anon")
        }.store(in: &subscriptions)
        
        return instance
    }()
    public var choiceColor: UIColor = .clear {
        didSet {
            guard oldValue != choiceColor, mode == .Choice else { return }
            
            button.tintColor = choiceColor
        }
    }
    @MainActor public private(set) var isUploading = false {
        didSet {
#if DEBUG
      print(isUploading)
#endif
        }
    }
    //Publishers
    public let galleryPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public let cameraPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public let previewPublisher = CurrentValueSubject<UIImage?, Never>(nil)
    public let tapPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public let selectionPublisher = CurrentValueSubject<[Userprofile: Bool]?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
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
    private lazy var button: UIButton = {
        let instance = UIButton()
        instance.alpha = 0
        instance.showsMenuAsPrimaryAction = true
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? buttonBgDarkColor : buttonBgLightColor
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
//        instance.isContextMenuInteractionEnabled = true
//        instance.addInteraction(UIContextMenuInteraction(delegate: self))

        instance.publisher(for: \.bounds, options: .new).sink { [weak self] rect in
            guard let self = self else { return }
            
            var systemImage = ""
            
            switch self.mode {
            case .Selection:
                systemImage = self.isSelected ? "checkmark" : ""
            case .Editing:
                systemImage = "pencil"
            case .Choice:
                systemImage = "circlebadge.fill"
            default:
                systemImage = ""
            }
            
            instance.cornerRadius = rect.height/2
            instance.setImage(UIImage(systemName: systemImage,
                                      withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.6,
                                                                                     weight: .semibold)),
                              for: .normal)
            instance.imageView?.contentMode = .center
        }.store(in: &subscriptions)
        
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
    init(userprofile: Userprofile? = nil, isShadowed: Bool = false, isBordered: Bool = false, borderColor: UIColor = .clear, mode: Mode = .Default) {
        self.mode = mode
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
        
//        guard mode != .Default else { return }
        
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.275),
        ])
        
        let constraintX = button.centerXAnchor.constraint(equalTo: leadingAnchor)
        constraintX.isActive = true
        constraintX.identifier = "constraintX"
        
        let constraintY = button.centerYAnchor.constraint(equalTo: topAnchor)
        constraintY.isActive = true
        constraintY.identifier = "constraintY"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

            guard let constraintY = button.getConstraint(identifier: "constraintY"),
                  let constraintX = button.getConstraint(identifier: "constraintX")
            else { return }
            
            let point = pointOnCircle(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: bounds.height/2, angleInDegrees: 135)
            constraintY.constant = point.y
            constraintX.constant = point.x
    }
    
    private func setObservers() {
        tasks.append(Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.ImageDownloaded) {
                guard let self = self,
                      let object = notification.object as? Userprofile,
                      object === self.userprofile,
                      let image = self.userprofile.image
                else { return }

                self.coloredBackground.stopShimmering()
                self.imageView.image = image
            }
        })
    }
    
    private func setImage() {
        guard userprofile != Userprofile.anonymous else {
            self.imageView.contentMode = .scaleAspectFill
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
                        self.imageView.contentMode = .scaleAspectFill
                    }

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
            self.imageView.contentMode = .scaleAspectFill
        }
    }
    
    private func pointOnCircle(center: CGPoint, radius: CGFloat, angleInDegrees: CGFloat) -> CGPoint {
        func deg2rad(_ number: Double) -> CGFloat {
            return number * .pi / 180
        }
        
        let radian = deg2rad(angleInDegrees)
        
        return CGPoint(x: center.x + radius * sin(radian),
                       y: center.y + radius * cos(radian))
    }
    
    private func prepareMenu() -> UIMenu {
        var actions: [UIAction]!
        
        switch mode {
        case .Editing:
            let camera: UIAction = .init(title: "camera".localized.capitalized,
                                         image: UIImage(systemName: "camera.fill"),
                                         identifier: nil,
                                         discoverabilityTitle: nil,
                                         attributes: .init(),
                                         state: .off,
                                         handler: { [weak self] _ in
                guard let self = self else { return }
                
                self.cameraPublisher.send(true)
            })
            
            let photos: UIAction = .init(title: "photo_album".localized.capitalized, image: UIImage(systemName: "photo"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] _ in
                guard let self = self else { return }
                
                self.galleryPublisher.send(true)
            })
            
            actions = [photos, camera]
        case .Choice:
            print("")
        default:
            print("")
        }
        
        return UIMenu(title: "change_avatar".localized, image: nil, identifier: nil, options: .init(), children: actions)
    }
    
    @objc
    private func handleTap() {
        switch mode {
        case .Editing:
            guard !isUploading, let image = imageView.image else { return }
            
            previewPublisher.send(image)
        case .Selection:
            isSelected = !isSelected
            button.setImage(UIImage(systemName: isSelected ? "checkmark" : "",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: button.bounds.height*0.6,
                                                                                     weight: .heavy)),
                              for: .normal)
            
            switch isSelected {
            case true:
                button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                button.alpha = 0
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) { [unowned self] in
                    self.button.alpha = 1
                    self.button.transform = .identity
                }
            case false:
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) { [unowned self] in
                    self.button.alpha = 0
                    self.button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }
            }
            

            selectionPublisher.send([userprofile: isSelected])
        default:
            tapPublisher.send(userprofile)
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
    
//    public func setSelectionMode(_ on: Bool) {
//        mode = on ? .Selection : .Default
//    }
    
    public func setSelected(_ isSelected: Bool) {
        guard mode == .Selection else { return }
        
        button.isSelected = isSelected
    }
    
    public func imageUploadStarted(_ image: UIImage) {
        guard mode == .Editing else { return }
        
        isUploading = true
        
        let fade = UIView()
        fade.backgroundColor = .black.withAlphaComponent(0.6)
        fade.accessibilityIdentifier = "fade"
        fade.alpha = 0
        fade.addEquallyTo(to: imageView)
        
        let spinner = UIActivityIndicatorView()
        spinner.accessibilityIdentifier = "spinner"
        spinner.style = .large
        spinner.alpha = 0
        spinner.color = .white
        spinner.startAnimating()
        spinner.addEquallyTo(to: imageView)
        
        Animations.changeImageCrossDissolve(imageView: imageView, image: image)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) { [weak self] in
            guard let self = self else { return }
            
            self.button.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            self.button.alpha = 0
            fade.alpha = 1
            spinner.alpha = 1
        }
    }
    
    public func imageUploadFinished(_ image: UIImage) {
        isUploading = false
        Animations.changeImageCrossDissolve(imageView: imageView, image: image)
        
        guard let fade = imageView.getSubview(type: UIView.self, identifier: "fade"),
              let spinner = imageView.getSubview(type: UIActivityIndicatorView.self, identifier: "spinner")
        else { return }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: { [weak self] in
            guard let self = self else { return }
            
            self.button.transform = .identity
            self.button.alpha = 1
            fade.alpha = 0
            spinner.alpha = 0
        }) { _ in
            fade.removeFromSuperview()
            spinner.removeFromSuperview()
        }
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        shadowView.layer.shadowOpacity = isShadowed ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
        button.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? buttonBgDarkColor : buttonBgLightColor
    }
}

//extension Avatar: UIContextMenuInteractionDelegate {
//
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//
//        return UIContextMenuConfiguration(
//            identifier: nil,
//            previewProvider: makeRatePreview) { [weak self] _ in
//                guard let self = self else { return nil }
//
//                return self.prepareMenu()
//            }
//    }
//
//    func makeRatePreview() -> UIViewController {
//      let viewController = UIViewController()
//
//      // 1
//      let imageView = UIImageView(image: UIImage(named: "rating_star"))
//      viewController.view = imageView
//
//      // 2
//      imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//      imageView.translatesAutoresizingMaskIntoConstraints = false
//
//      // 3
//      viewController.preferredContentSize = imageView.frame.size
//
//      return viewController
//    }
//}
