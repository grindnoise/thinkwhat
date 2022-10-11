////
////  LanguageCell.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 11.10.2022.
////  Copyright © 2022 Pavel Bukharov. All rights reserved.
////
//
//
//import UIKit
//import Combine
//import L10n_swift
//
//class LanguageCell: UICollectionViewListCell {
//
//
//
//    // MARK: - Public properties
//    //Publishers
//    public var appLanguagePublisher = CurrentValueSubject<[AppSettings: String]?, Never>(nil)
//    public var contentLanguagePublisher = CurrentValueSubject<Bool?, Never>(nil)//CurrentValueSubject<[AppSettings: [String: Bool]]?, Never>(nil)
//
//    // MARK: - Private properties
//    private var observers: [NSKeyValueObservation] = []
//    private var subscriptions = Set<AnyCancellable>()
//    private var tasks: [Task<Void, Never>?] = []
//    //UI
//    private let padding: CGFloat = 8
//    private lazy var languageLabel: UILabel = {
//        let instance = UILabel()
////        instance.isUserInteractionEnabled = true
//        instance.textColor = .label//traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        instance.text = "balance".localized.capitalized
//        instance.textAlignment = .left
//        instance.numberOfLines = 1
////        instance.lineBreakMode = .byTruncatingTail
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        instance.publisher(for: \.bounds, options: .new)
//            .sink { [weak self] rect in
//                guard let self = self,
//                      instance.getConstraint(identifier: "width").isNil,
//                      instance.getConstraint(identifier: "height").isNil,
//                      let text = instance.text
//                else { return }
//
//                let constraint_1 = instance.heightAnchor.constraint(equalToConstant: text.height(withConstrainedWidth: 300, font: instance.font) + 10)
//                constraint_1.identifier = "height"
//                constraint_1.isActive = true
//            }
//            .store(in: &subscriptions)
//
//        return instance
//    }()
//
//
//    // MARK: - Destructor
//    deinit {
//        observers.forEach { $0.invalidate() }
//        tasks.forEach { $0?.cancel() }
//        subscriptions.forEach { $0.cancel() }
//        NotificationCenter.default.removeObserver(self)
//#if DEBUG
//        print("\(String(describing: type(of: self))).\(#function)")
//#endif
//    }
//
//
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setTasks()
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//
//    // MARK: - Public methods
//
//
//
//    // MARK: - Overriden methods
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
////        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        //Reset publishers
//        appLanguagePublisher = CurrentValueSubject<[AppSettings: String]?, Never>(nil)
//        contentLanguagePublisher = CurrentValueSubject<Bool?, Never>(nil)//CurrentValueSubject<[AppSettings: [String: Bool]]?, Never>(nil)
//    }
//}
//
//private extension LanguageCell {
//
//    func setTasks() {
//        tasks.append(Task { @MainActor [weak self] in
//            for await _ in NotificationCenter.default.notifications(for: Notifications.System.AppLanguage) {
//                guard let self = self else { return }
//
//                self.disclosureButton.menu = self.prepareMenu()
//            }
//        })
//    }
//
//    func setupUI() {
//        contentView.backgroundColor = .clear
//
//        contentView.addSubview(horizontalStack)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        languageLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            languageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            languageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
//            languageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
//            languageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        ])
//    }
//
//    @objc
//    func handleButtonTap(_ sender: UIButton) {
//        contentLanguagePublisher.send(true)
//    }
//
//    @objc
//    func handleLabelTap() {
//        guard mode == .languages(.Content) else { return }
//
//        contentLanguagePublisher.send(true)
//    }
//
//    func updateUI() {
//        switch mode {
//        case .languages(.App):
//            titleLabel.text = AppSettings.Languages.App.rawValue.localized
//            disclosureButton.showsMenuAsPrimaryAction = true
//            languageLabel.text = Locale.current.localizedString(forIdentifier: L10n.shared.language.localized)?.capitalized
//        case .languages(.Content):
//            titleLabel.text = AppSettings.Languages.Content.rawValue.localized
//            disclosureButton.showsMenuAsPrimaryAction = false
//            var languages = ""
//            for (row, languageCode) in UserDefaults.App.contentLanguages.enumerated() {
//                guard let text = Locale.current.localizedString(forIdentifier: languageCode) else { return }
//
//                languages += (row == 0 ? text.capitalized : text) + ", "
//            }
//
//            languageLabel.text = String(languages.prefix(languages.count-2))
//        default:
//            print("")
//        }
//    }
//
//    func prepareMenu() -> UIMenu {
//        var actions: [UIAction] = []
//
//        for language in L10n.supportedLanguages {
//            let action = UIAction(title: Locale(identifier: language).localizedString(forIdentifier: language)!.capitalized, //Locale.current.localizedString(forIdentifier: language.localized)!.capitalized,
//                                  image: nil,
//                                  identifier: nil,
//                                  discoverabilityTitle: nil,
//                                  attributes: .init(),
//                                  state: L10n.shared.language == language ? .on : .off,
//                                  handler: { [weak self] action in
//                guard let self = self else { return }
//
//                self.titleLabel.text = AppSettings.Languages.App.rawValue.localized
//                self.languageLabel.text = Locale(identifier: language).localizedString(forIdentifier: language)?.capitalized
//                self.appLanguagePublisher.send([AppSettings.languages(.App) : language])
//            })
//            actions.append(action)
//        }
//
//        return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
//    }
//}
//
