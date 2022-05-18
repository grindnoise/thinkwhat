//
//  SettingsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SettingsView: UIView {
    
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
    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: SettingsViewInput?
    private var shadowPath: CGPath!
    private var isSetupCompleted = false
    private var read: CurrentUserProfileView!
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var card: UIView! {
        didSet {
            card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var cardShadow: UIView!
}

// MARK: - Controller Output
extension SettingsView: SettingsControllerOutput {
    func onWillAppear() {
        
    }
    
    func onDidLayout() {
        guard !isSetupCompleted else { return }
        isSetupCompleted = true
        ///Add shadow
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        alpha = 0
        cardShadow.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        shadowPath = UIBezierPath(roundedRect: cardShadow.bounds, cornerRadius: cardShadow.frame.width * 0.05).cgPath
        cardShadow.layer.shadowPath = shadowPath
        cardShadow.layer.shadowRadius = 7
        cardShadow.layer.shadowOffset = .zero
        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.alpha = 1
            self.transform = .identity
        } completion: { _ in }
    }
}

// MARK: - UI Setup
extension SettingsView {
    private func setupUI() {
        card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        card.layer.masksToBounds = true
        card.layer.cornerRadius = card.frame.width * 0.05
        alpha = 0
        
        read = CurrentUserProfileView()
        read.addEquallyTo(to: card)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
}


