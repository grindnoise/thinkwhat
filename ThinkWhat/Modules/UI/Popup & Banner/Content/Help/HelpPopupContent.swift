//
//  HelpPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import CoreData

class HelpPopupContent: UIView {
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private weak var parent: Popup?
    private weak var callbackDelegate: CallbackObservable?
    private lazy var label: UILabel = {
        let instance = UILabel()
        instance.alpha = 0
        instance.numberOfLines = 0
        instance.textAlignment = .center
        instance.addEquallyTo(to: middleContainer)
        
        let textContent_1 = "claim_sent".localized + "\n" + "\n"
        let textContent_2 = "thanks_for_feedback".localized
        let paragraph = NSMutableParagraphStyle()
        
        if #available(iOS 15.0, *) {
            paragraph.usesDefaultHyphenation = true
        } else {
            paragraph.hyphenationFactor = 1
        }
        paragraph.alignment = .center
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: textContent_1,
                                                   attributes: [
                                                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title1) as Any,
                                                    NSAttributedString.Key.foregroundColor: UIColor.label,
                                                   ] as [NSAttributedString.Key : Any]))
        
        attributedString.append(NSAttributedString(string: textContent_2,
                                                   attributes: [
                                                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title2) as Any,
                                                    NSAttributedString.Key.foregroundColor: UIColor.label,
                                                   ] as [NSAttributedString.Key : Any]))
        instance.attributedText = attributedString
        
        return instance
    }()
    @Published private var item: Claim?
    
    // MARK: - UI properties
    private lazy var verticalStackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topContainer, middleContainer, bottomContainer])
        instance.axis = .vertical
        instance.spacing = 16
        
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topContainer.heightAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.25),
            bottomContainer.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        return instance
    }()
    private lazy var icon: Icon = {
        let instance = Icon()
        instance.backgroundColor = .clear
        instance.isRounded = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.scaleMultiplicator = 1
        instance.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.category = .QuestionMarkCircleFill
        
        return instance
    }()
    private lazy var topContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: instance.topAnchor),
            icon.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
            icon.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
        ])
        
        return instance
    }()
    private lazy var middleContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground

        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.cornerRadius = rect.width * 0.05
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var actionButton: UIButton = {
        let instance = UIButton()
        
        instance.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        if #available(iOS 15, *) {
            let attrString = AttributedString("ok".localized.uppercased(), attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]))
            var config = UIButton.Configuration.filled()
            config.attributedTitle = attrString
            config.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            config.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
            config.imagePlacement = .trailing
            config.imagePadding = 8.0
            config.contentInsets.leading = 20
            config.contentInsets.trailing = 20
            config.buttonSize = .large

            instance.configuration = config
        } else {
            let attrString = NSMutableAttributedString(string: "ok".localized.uppercased(), attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
            instance.titleEdgeInsets.left = 20
            instance.titleEdgeInsets.right = 20
            instance.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            instance.imageView?.tintColor = .white
            instance.imageEdgeInsets.left = 8
//            instance.imageEdgeInsets.right = 8
            instance.setAttributedTitle(attrString, for: .normal)
            instance.semanticContentAttribute = .forceRightToLeft
            instance.backgroundColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED

            let constraint = instance.widthAnchor.constraint(equalToConstant: "ok".localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2)!))
            constraint.identifier = "width"
            constraint.isActive = true
        }
        
        observers.append(instance.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue
            else { return }
            
            view.cornerRadius = newValue.height/2.25
            
            guard let constraint = view.getConstraint(identifier: "width") else { return }
            self.setNeedsLayout()
            constraint.constant = "ok".localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!) + 40 + (view.imageView?.bounds.width ?? 0) + 60
            self.layoutIfNeeded()
        })

        return instance
    }()
    private lazy var bottomContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: instance.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
            actionButton.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
        ])
        
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
    init(callbackDelegate: CallbackObservable, parent: Popup?) {
        super.init(frame: .zero)
        self.callbackDelegate = callbackDelegate
        self.parent = parent
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        verticalStackView.addEquallyTo(to: self)
    }
    
    @objc
    private func close() {
        parent?.dismiss()
    }
    
    // MARK: - Public methods

    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        icon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED)
        
        if #available(iOS 15, *) {
            guard !actionButton.configuration.isNil else { return }
            actionButton.configuration?.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        } else {
            actionButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    }
}
