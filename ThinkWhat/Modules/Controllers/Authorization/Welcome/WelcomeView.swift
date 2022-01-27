//
//  WelcomeView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class WelcomeView: UIView {
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var logo: Icon! {
        didSet {
            logo.iconColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.systemBlue
                default:
                    return K_COLOR_RED
                }
            }
            logo.scaleMultiplicator = 1.2
            logo.backgroundColor = .clear
            logo.category = .Eye
        }
    }
    @IBOutlet weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.textColor = .label
        }
    }
    @IBAction func getStartedTapped(_ sender: Any) {
        controller?.onGetStartedTap()
    }
    @IBOutlet weak var getStartedButton: UIButton! {
        didSet {
            getStartedButton.backgroundColor = K_COLOR_RED
            getStartedButton.setTitle(NSLocalizedString("get_started", comment: ""), for: .normal)
        }
    }
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
    
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib()
                    else { fatalError("View could not load from nib") }
                addSubview(contentView)

        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    override func layoutSubviews() {
        guard getStartedButton != nil else { return }
        getStartedButton.cornerRadius = getStartedButton.frame.height/2.25
    }

    // MARK: - Properties
    weak var controller: WelcomeViewInput?
}

// MARK: - UI Setup
extension WelcomeView {
    private func setupUI() {
        getStartedButton.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var logoAnimation: CAAnimation!
        var initialColor: CGColor!
        var destinationColor: CGColor!
        switch traitCollection.userInterfaceStyle {
        case .dark:
            initialColor = UIColor.black.cgColor
            destinationColor = UIColor.systemBlue.cgColor
        default:
            destinationColor = UIColor.black.cgColor
            initialColor = UIColor.systemBlue.cgColor
        }
        logoAnimation = Animations.get(property: .FillColor,
                                       fromValue: initialColor,
                                       toValue: destinationColor,
                                       duration: 0.3,
                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                       delegate: nil,
                                       isRemovedOnCompletion: false)
        logo.icon.add(logoAnimation, forKey: nil)
        (logo.icon as! CAShapeLayer).fillColor = K_COLOR_RED.cgColor
    }
}

extension WelcomeView: WelcomeControllerOutput {}


