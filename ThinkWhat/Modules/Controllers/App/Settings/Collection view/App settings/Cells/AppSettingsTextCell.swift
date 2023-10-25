//
//  AppSettingsPolicyCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AppSettingsTextCell: UICollectionViewListCell {
    
    enum Mode: String {
        case TermsOfUse = "terms_privacy_policy"
        case Licenses = "licenses"
        case Feedback = "feedback"
        case AppVersion = "app_version"
    }
    
    // MARK: - Public properties
    public var mode: Mode! {
        didSet {
            guard !mode.isNil else { return }
            
            updateUI()
        }
    }
    //Publishers
    public var tapPublisher = CurrentValueSubject<Mode?, Never>(nil)
//    public var contentLanguagePublisher = CurrentValueSubject<Bool?, Never>(nil)//CurrentValueSubject<[AppSettings: [String: Bool]]?, Never>(nil)
    //UI
    public var color: UIColor = Constants.UI.Colors.System.Red.rawValue {
        didSet {
            disclosure.tintColor = color
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
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        instance.textColor = .label//traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "terms_privacy_policy".localized
        instance.textAlignment = .left
        instance.numberOfLines = 1
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.heightAnchor.constraint(equalToConstant: "text".height(withConstrainedWidth: 400, font: instance.font) + 10).isActive = true
//        instance.publisher(for: \.bounds, options: .new)
//            .sink { [weak self] rect in
//                guard let self = self,
//                      instance.getConstraint(identifier: "height").isNil,
//                      let text = instance.text
//                else { return }
//
//                let constraint_1 = instance.heightAnchor.constraint(equalToConstant: text.height(withConstrainedWidth: 400, font: instance.font) + 10)
//                constraint_1.identifier = "height"
//                constraint_1.priority = .defaultHigh
//                constraint_1.isActive = true
//            }
//            .store(in: &subscriptions)

        return instance
    }()
    private lazy var valueLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.textAlignment = .right
        instance.numberOfLines = 1
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)

        return instance
    }()
    private lazy var disclosure: UIImageView = {
        let instance = UIImageView()
        instance.isUserInteractionEnabled = true
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        instance.backgroundColor = .clear
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : Constants.UI.Colors.main
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5))!)
            }
            .store(in: &subscriptions)

        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let opaque = UILabel()
        opaque.isUserInteractionEnabled = false
//        opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        opaque.backgroundColor = .clear
        
        let instance = UIStackView(arrangedSubviews: [
            titleLabel,
//            opaque,
            disclosure,
        ])
        
        instance.axis = .horizontal
        instance.spacing = 0
        
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
        
        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
//        disclosure.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        //Reset publishers
        tapPublisher = CurrentValueSubject<Mode?, Never>(nil)
    }
}

private extension AppSettingsTextCell {
    
    func setTasks() {}
    
    func setupUI() {
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        
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
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }
    
    func updateUI() {
        titleLabel.text = mode.rawValue.localized
        
        guard mode != .AppVersion else {
            horizontalStack.removeArrangedSubview(disclosure)
            disclosure.removeFromSuperview()
            horizontalStack.addArrangedSubview(valueLabel)
            
            guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                  let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            else { return }
            
            valueLabel.text = version + " " + build
            return
        }
    }
    
    @objc
    func handleTap() {
        guard mode != .AppVersion else { return }
        
        tapPublisher.send(mode)
    }
}

