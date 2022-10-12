//
//  AppSettingsLanguageCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import L10n_swift

class AppSettingsLanguageCell: UICollectionViewListCell {
    
    
    
    // MARK: - Public properties
    public var mode: AppSettings! {
        didSet {
            guard !mode.isNil else { return }
            
            updateUI()
        }
    }
    //Publishers
    public var appLanguagePublisher = CurrentValueSubject<[AppSettings: String]?, Never>(nil)
    public var contentLanguagePublisher = CurrentValueSubject<Bool?, Never>(nil)//CurrentValueSubject<[AppSettings: [String: Bool]]?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //UI
    private let padding: CGFloat = 8
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
//        instance.isUserInteractionEnabled = true
        instance.textColor = .label//traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "balance".localized.capitalized
        instance.textAlignment = .left
        instance.numberOfLines = 1
//        instance.lineBreakMode = .byTruncatingTail
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      instance.getConstraint(identifier: "width").isNil,
                      instance.getConstraint(identifier: "height").isNil,
                      let text = instance.text
                else { return }
                
                let height = text.height(withConstrainedWidth: 300, font: instance.font) + 10
                let constraint_1 = instance.heightAnchor.constraint(equalToConstant: height)
                constraint_1.identifier = "height"
                constraint_1.isActive = true
                
                let constraint_2 = instance.widthAnchor.constraint(equalToConstant: text.width(withConstrainedHeight: height, font: instance.font))
                constraint_2.identifier = "width"
                constraint_2.isActive = true

            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var languageLabel: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "balance".localized.capitalized
        instance.textAlignment = .right
        instance.numberOfLines = 1
        instance.lineBreakMode = .byTruncatingTail
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleLabelTap)))
//        instance.publisher(for: \.bounds, options: .new)
//            .sink { [weak self] rect in
//                guard let self = self,
//                      instance.getConstraint(identifier: "height").isNil,
//                      let text = instance.text
//                else { return }
//
//                let constraint = instance.heightAnchor.constraint(equalToConstant: text.height(withConstrainedWidth: 300, font: instance.font) + 10)
//                constraint.identifier = "height"
//                constraint.isActive = true
//            }
//            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var disclosureButton: UIButton = {
        let instance = UIButton()
        instance.showsMenuAsPrimaryAction = true
        instance.menu = prepareMenu()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.imageView?.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
            }
            .store(in: &subscriptions)
        instance.addTarget(self, action: #selector(self.handleButtonTap(_:)), for: .touchUpInside)
        
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let opaque = UILabel()
        opaque.backgroundColor = .clear
        
        let instance = UIStackView(arrangedSubviews: [
            titleLabel,
            opaque,
            languageLabel,
            disclosureButton
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
        
        setTasks()
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
        disclosureButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //Reset publishers
        appLanguagePublisher = CurrentValueSubject<[AppSettings: String]?, Never>(nil)
        contentLanguagePublisher = CurrentValueSubject<Bool?, Never>(nil)//CurrentValueSubject<[AppSettings: [String: Bool]]?, Never>(nil)
    }
}

private extension AppSettingsLanguageCell {
    
    func setTasks() {
        tasks.append(Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.System.AppLanguage) {
                guard let self = self else { return }
                
                self.disclosureButton.menu = self.prepareMenu()
            }
        })
        
        tasks.append(Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.System.ContentLanguage) {
                guard let self = self,
                      self.mode == .languages(.Content)
                else { return }
                
                self.updateUI()
            }
        })
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
    
    @objc
    func handleButtonTap(_ sender: UIButton) {
        contentLanguagePublisher.send(true)
    }
    
    @objc
    func handleLabelTap() {
        guard mode == .languages(.Content) else { return }
        
        contentLanguagePublisher.send(true)
    }
    
    func updateUI() {
        switch mode {
        case .languages(.App):
            titleLabel.text = AppSettings.Languages.App.rawValue.localized
            disclosureButton.showsMenuAsPrimaryAction = true
            languageLabel.text = Locale.current.localizedString(forIdentifier: L10n.shared.language.localized)?.capitalized
        case .languages(.Content):
            titleLabel.text = AppSettings.Languages.Content.rawValue.localized
            disclosureButton.showsMenuAsPrimaryAction = false
            var languages = ""
            for (row, languageCode) in UserDefaults.App.contentLanguages.enumerated() {
                guard let text = Locale(identifier: languageCode).localizedString(forIdentifier: languageCode) else { return }
                
                languages += (row == 0 ? text.capitalized : text) + ", "
            }
            
            languageLabel.text = String(languages.prefix(languages.count-2))
        default:
            print("")
        }
    }
    
    func prepareMenu() -> UIMenu {
        var actions: [UIAction] = []
        
        for language in L10n.supportedLanguages {
            let action = UIAction(title: Locale(identifier: language).localizedString(forIdentifier: language)!.capitalized, //Locale.current.localizedString(forIdentifier: language.localized)!.capitalized,
                                  image: nil,
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  attributes: .init(),
                                  state: L10n.shared.language == language ? .on : .off,
                                  handler: { [weak self] action in
                guard let self = self else { return }

                self.titleLabel.text = AppSettings.Languages.App.rawValue.localized
                self.languageLabel.text = Locale(identifier: language).localizedString(forIdentifier: language)?.capitalized
                self.appLanguagePublisher.send([AppSettings.languages(.App) : language])
            })
            actions.append(action)
        }
        
        return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
    }
}
