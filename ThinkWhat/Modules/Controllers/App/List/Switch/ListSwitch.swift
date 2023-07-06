//
//  ListSwitch.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class ListSwitch: UIView {
    
    enum State {
        case Top, New, Watching, Own
    }
    
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
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadowView: UIView! {
      didSet {
        shadowView.clipsToBounds = false
        shadowView.backgroundColor = .clear
        shadowView.accessibilityIdentifier = "shadow"
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        shadowView.publisher(for: \.bounds)
          .sink { [weak self] in
            guard let self = self else { return }
            
            self.shadowView.layer.shadowRadius = $0.height/8
            self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2.25).cgPath
          }
          .store(in: &subscriptions)
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

    
    
    // MARK: - Private properties
    public let statePublisher = CurrentValueSubject<State?, Never>(nil)
    //UI
    public var color: UIColor = Colors.System.Red.rawValue {
        didSet {
            gradient.colors = getGradientColors()
        }
    }
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private var state: ListSwitch.State = .New {
        didSet {
            guard state != oldValue else { return }
            
            statePublisher.send(state)
            
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
//            UIView.transition(with: imageView, duration: 0.175, options: .transitionCrossDissolve) { [weak self] in
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.85,
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
            .filter { $0 != .zero }
            .sink { rect in
                instance.cornerRadius = rect.height/2
                
                guard let layer = instance.layer.getSublayer(identifier: "radialGradient"),
                      layer.bounds != rect
                else { return }
                
                layer.frame = rect
            }
            .store(in: &subscriptions)
        
        let innerView = UIImageView()
        innerView.clipsToBounds = false
        innerView.accessibilityIdentifier = "innerView"
        innerView.contentMode = .center
        innerView.image = UIImage(systemName: "tag.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: innerView.bounds.height * 0.45, weight: .semibold, scale: .medium))
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
//    private weak var callbackDelegate: CallbackObservable?
    
    
    
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
    init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    
    
    //MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        mark.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        backgroundView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        gradient.colors = getGradientColors()
    }
}
 
private extension ListSwitch {
    func setupUI() {
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
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
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
