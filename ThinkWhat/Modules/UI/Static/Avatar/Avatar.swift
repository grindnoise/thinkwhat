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
//            let imageView = UIImageView(image: image)
//            imageView.contentMode = .scaleAspectFill
//            imageView.alpha  = 0
//            imageView.isUserInteractionEnabled = true
//            imageView.backgroundColor = .tertiarySystemBackground
//            imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
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
    private var isBordered: Bool = false
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
        self.isBordered = borderColor != .clear
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
