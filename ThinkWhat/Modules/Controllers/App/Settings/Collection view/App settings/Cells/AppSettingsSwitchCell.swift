//
//  AppSettingsNotificationsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AppSettingsSwitchCell: UICollectionViewListCell {
    
    
    
    // MARK: - Public properties
    public var mode: AppSettings! {
        didSet {
            guard !mode.isNil else { return }
            
            updateUI()
        }
    }
    public var isOn: Bool = true {
        didSet {
            toggleSwitch.isOn = isOn
        }
    }
    //Publishers
    public var valuePublisher = CurrentValueSubject<[AppSettings: Bool]?, Never>(nil)
    //UI
    public var color: UIColor = Colors.System.Red.rawValue {
        didSet {
            toggleSwitch.onTintColor = color
        }
    }
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding: CGFloat = 8
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = .label//traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "balance".localized.capitalized
        instance.textAlignment = .left
        instance.numberOfLines = 1
        instance.lineBreakMode = .byTruncatingTail
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      instance.getConstraint(identifier: "height").isNil,
                      let text = instance.text
                else { return }
                
                let constraint = instance.heightAnchor.constraint(equalToConstant: text.height(withConstrainedWidth: 300, font: instance.font) + 10)
                constraint.identifier = "height"
                constraint.isActive = true
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var toggleSwitch: UISwitch = {
        let instance = UISwitch()
//        instance.onTintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.addTarget(self, action: #selector(self.toggleSwitch(_:)), for: .valueChanged)
        
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let opaque = UILabel()
        opaque.backgroundColor = .clear
        
        let instance = UIStackView(arrangedSubviews: [
            titleLabel,
            opaque,
            toggleSwitch
        ])
        
        instance.axis = .horizontal
        instance.spacing = 4
//        instance.distribution = .fillProportionally
        
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
    
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
//        toggleSwitch.onTintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //Reset publishers
        valuePublisher = CurrentValueSubject<[AppSettings: Bool]?, Never>(nil)
    }
}

private extension AppSettingsSwitchCell {
    
    func setTasks() {
        
    }
    
    func setupUI() {
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        clipsToBounds = false
        
        contentView.addSubview(horizontalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*2),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding*2),
            //            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        
        let constraint = horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    func updateUI() {
        switch mode {
        case .notifications(.Completed):
            titleLabel.text = AppSettings.Notifications.Completed.rawValue.localized
        case .notifications(.Subscriptions):
            titleLabel.text = AppSettings.Notifications.Subscriptions.rawValue.localized
        case .notifications(.Watchlist):
            titleLabel.text = AppSettings.Notifications.Watchlist.rawValue.localized
        default:
            print("")
        }
    }
    
    @objc
    func toggleSwitch(_ sender: UISwitch) {
        valuePublisher.send([mode: sender.isOn])
    }
}


