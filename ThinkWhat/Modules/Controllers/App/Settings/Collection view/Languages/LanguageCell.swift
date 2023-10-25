//
//  LanguageCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//


import UIKit
import Combine

class LanguageCell: UICollectionViewListCell {

    // MARK: - Public properties
    public var setting: [LanguageItem: Bool]! {
        didSet {
            guard !setting.isNil else { return }
            
            isContentLanguage = setting.values.first!
            updateUI()
        }
    }
    //Publishers
    public var contentLanguagePublisher = CurrentValueSubject<[LanguageItem: Bool]?, Never>(nil)

    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Logic
    private var language: LanguageItem? {
        return setting.keys.first
    }
    private var isContentLanguage: Bool!
    
    //UI
    private let padding: CGFloat = 8
    private lazy var languageLabel: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        instance.textColor = .label//traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "balance".localized.capitalized
        instance.textAlignment = .left
        instance.numberOfLines = 1
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
//        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      instance.getConstraint(identifier: "height").isNil,
                      let text = instance.text
                else { return }

                let constraint_1 = instance.heightAnchor.constraint(equalToConstant: text.height(withConstrainedWidth: 300, font: instance.font) + 10)
                constraint_1.identifier = "height"
                constraint_1.priority = .defaultHigh
                constraint_1.isActive = true
            }
            .store(in: &subscriptions)

        return instance
    }()
    private lazy var checkmark: UIImageView = {
        let instance = UIImageView()
        instance.isUserInteractionEnabled = true
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        instance.backgroundColor = .clear
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : Constants.UI.Colors.main
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5, weight: .semibold))!)
            }
            .store(in: &subscriptions)

        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let opaque = UILabel()
        opaque.isUserInteractionEnabled = true
        opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        opaque.backgroundColor = .clear
        
        let instance = UIStackView(arrangedSubviews: [
            languageLabel,
            opaque,
            checkmark,
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



    // MARK: - Public methods



    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

      checkmark.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : Constants.UI.Colors.main
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        //Reset publishers
        contentLanguagePublisher = CurrentValueSubject<[LanguageItem: Bool]?, Never>(nil)
    }
}

private extension LanguageCell {

    func setTasks() {
//        tasks.append(Task { @MainActor [weak self] in
//            for await _ in NotificationCenter.default.notifications(for: Notifications.System.AppLanguage) {
//                guard let self = self else { return }
//
//                self.disclosureButton.menu = self.prepareMenu()
//            }
//        })
    }

    func setupUI() {
        contentView.backgroundColor = .clear

        contentView.addSubview(horizontalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }

    @objc
    func handleTap() {
        guard let language = language else { return }
        
        isContentLanguage = !isContentLanguage
        contentLanguagePublisher.send([language: isContentLanguage])
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) { [weak self] in
            guard let self = self else { return }
            
            self.checkmark.alpha = self.isContentLanguage ? 1 : 0
        }
    }
    
    func updateUI() {
        guard let languageCode = language?.code,
              let isContentLanguage = isContentLanguage
        else { return }
        
        languageLabel.text = Locale(identifier: languageCode).localizedString(forIdentifier: languageCode)?.capitalized
        checkmark.alpha = isContentLanguage ? 1 : 0
    }
}

