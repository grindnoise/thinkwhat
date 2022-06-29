//
//  Avatar.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class Avatar: UIView {
    
    private var image: UIImage = UIImage(systemName: "person.circle.fill")!
    override var frame: CGRect {
        didSet {
            layoutSubviews()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            layoutSubviews()
        }
    }
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
    private var isBordered: Bool = true
    
    //
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var borderBg: UIView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(color: UIColor, image: UIImage, isBordered: Bool = true) {
        super.init(frame: .zero)
        self.image = image
        self.isBordered = isBordered
        self.lightColor = color
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
        setupUI()
    }
    
    override func layoutSubviews() {
        if !border.isNil { border.cornerRadius = border.bounds.height/2 }
        if !imageView.isNil {
            imageView.cornerRadius = imageView.bounds.width/2
            borderBg.cornerRadius = borderBg.bounds.width/2
        }
    }
    
    
    
    private func setupUI() {
        self.imageView.image = image
        let touch = UITapGestureRecognizer(target:self, action:#selector(Avatar.handleTap))
        imageView.addGestureRecognizer(touch)
        
        border.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return self.darkColor
            default:
                return self.lightColor
            }
        }
        
        guard !isBordered,
              let constraint = imageView.getAllConstraints().filter({ $0.identifier == "ratio" }).first else { return }
        imageView.removeConstraint(constraint)
        imageView.heightAnchor.constraint(equalTo: border.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: border.widthAnchor).isActive = true
//        let newConstraint = constraint.setMultiplierWithFade(1, duration: 0)
//        newConstraint.identifier = "ratio"
    }
    
    @objc
    private func handleTap() {
        delegate?.callbackReceived(self)
    }
    
    public func setImage(_ image: UIImage) {
        guard !imageView.isNil else { return }
        imageView.image = image
    }
}
