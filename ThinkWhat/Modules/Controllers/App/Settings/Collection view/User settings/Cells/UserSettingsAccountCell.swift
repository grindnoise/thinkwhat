//
//  CurrentUserAccountCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserSettingsAccountCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public weak var userprofile: Userprofile! {
        didSet {
            guard !userprofile.isNil else { return }
            
//            setText()
//            setColors()
        }
    }
    //Publishers
    public var logoutPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public var deletePublisher = CurrentValueSubject<Bool?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //UI
    private let padding: CGFloat = 8
    private lazy var logoutButton: UIButton = {
        let instance = UIButton()
        
        if #available(iOS 15, *) {
            let attrString = AttributedString("logout".localized.uppercased(),
                                              attributes: AttributeContainer([
                                                .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline) as Any,
                                                .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : .label
                                              ]))
            var config = UIButton.Configuration.plain()
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [weak self] incoming in
                guard let self = self else { return incoming }
                
                var outgoing = incoming
                    outgoing.foregroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
                    return outgoing
            }
            config.baseBackgroundColor = .clear
            config.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
                guard let self = self else { return .label }

                return self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
            }
            config.contentInsets.top = 8
            config.contentInsets.bottom = 8
            config.attributedTitle = attrString
            config.image = UIImage(systemName: "rectangle.portrait.and.arrow.forward", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
            config.imagePlacement = .trailing
            config.imagePadding = 8.0
            config.buttonSize = .large

            instance.configuration = config
        } else {
            let attrString = NSMutableAttributedString(string: "logout".localized.uppercased(),
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline) as Any,
                                                        .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : .label
                                                       ])
            instance.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.forward", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
            instance.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : .label
            instance.imageEdgeInsets.left = 8
            instance.contentEdgeInsets.top = 8
            instance.contentEdgeInsets.bottom = 8
            instance.setAttributedTitle(attrString, for: .normal)
            instance.semanticContentAttribute = .forceRightToLeft
        }
 
        return instance
    }()
    private lazy var deleteButton: UIButton = {
        let instance = UIButton()
        
        if #available(iOS 15, *) {
            let attrString = AttributedString("delete_account".localized.uppercased(),
                                              attributes: AttributeContainer([
                                                .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline) as Any,
                                                .foregroundColor: UIColor.systemRed
                                              ]))
            var config = UIButton.Configuration.plain()
            config.contentInsets.top = 8
            config.contentInsets.bottom = 8
            config.baseBackgroundColor = .clear
            config.imageColorTransformer = UIConfigurationColorTransformer { _ in return .systemRed }
            config.attributedTitle = attrString
            config.image = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
            config.imagePlacement = .trailing
            config.imagePadding = 8.0
            config.buttonSize = .large

            instance.configuration = config
        } else {
            let attrString = NSMutableAttributedString(string: "delete_account".localized.uppercased(),
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline) as Any,
                                                        .foregroundColor: UIColor.systemRed
                                                       ])
            instance.setImage(UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
            instance.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : .systemRed
            instance.imageEdgeInsets.left = 8
            instance.contentEdgeInsets.top = 8
            instance.contentEdgeInsets.bottom = 8
            instance.setAttributedTitle(attrString, for: .normal)
            instance.semanticContentAttribute = .forceRightToLeft
        }
        
        return instance
    }()
    
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            logoutButton,
            deleteButton
        ])
        
        instance.axis = .vertical
        instance.spacing = 4
        instance.distribution = .fillEqually
        
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //Reset publishers
        logoutPublisher = CurrentValueSubject<Bool?, Never>(nil)
        deletePublisher = CurrentValueSubject<Bool?, Never>(nil)
    }
}

private extension UserSettingsAccountCell {
    
    func setTasks() {
        
    }
    
    func setupUI() {
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        clipsToBounds = false
        
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*2),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            //            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        
        let constraint = verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    @objc
    func handleButtonTap(_ sender: UIButton) {
        if sender === logoutButton {
            logoutPublisher.send(true)
        } else if sender === deleteButton {
            deletePublisher.send(true)
        }
    }
}

