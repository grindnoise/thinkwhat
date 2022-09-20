//
//  CurrentUserSocialMediaCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CurrentUserSocialMediaCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public weak var userprofile: Userprofile! {
        didSet {
            guard !userprofile.isNil else { return }
            
            setupTextFields()
            setupButtons()
        }
    }
    //Publishers
    public let facebookPublisher = CurrentValueSubject<String?, Never>(nil)
    public let instagramPublisher = CurrentValueSubject<String?, Never>(nil)
    public let tiktokPublisher = CurrentValueSubject<String?, Never>(nil)
    public let googlePublisher = CurrentValueSubject<String?, Never>(nil)
    public let twitterPublisher = CurrentValueSubject<String?, Never>(nil)
    public let openURLPublisher = CurrentValueSubject<URL?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding: CGFloat = 8
    private lazy var facebookIcon: FacebookLogo = {
        let instance = FacebookLogo()
        instance.isOpaque = false
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        
        return instance
    }()
    private lazy var facebookTextField: UnderlinedSignTextField = {
        let instance = UnderlinedSignTextField(lowerTextFieldTopConstant: -4)
        instance.customRightView = nil
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.clearButtonMode = .always
        instance.text = ""
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.spellCheckingType = .no
        instance.autocorrectionType = .no
        instance.attributedPlaceholder = NSAttributedString(string: "facebook_link".localized, attributes: [
            NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])
        instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
        instance.delegate = self
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard instance.getConstraint(identifier: "height").isNil else { return }
                
                let constraint = instance.heightAnchor.constraint(equalToConstant: rect.height)
                constraint.identifier = "height"
                constraint.isActive = true
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var facebookButton: UIButton = {
        let instance = UIButton()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.imageView?.contentMode = .center
        instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var facebookView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [facebookIcon, facebookTextField, facebookButton])
        instance.axis = .horizontal
        instance.spacing = 8
        
        return instance
    }()
    private lazy var instagramIcon: InstagramLogo = {
        let instance = InstagramLogo()
        instance.isOpaque = false
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        
        return instance
    }()
    private lazy var instagramTextField: UnderlinedSignTextField = {
        let instance = UnderlinedSignTextField(lowerTextFieldTopConstant: -4)
        instance.text = ""
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.spellCheckingType = .no
        instance.autocorrectionType = .no
        instance.attributedPlaceholder = NSAttributedString(string: "instagram_link".localized, attributes: [
            NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])
        instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
        instance.delegate = self
        
        return instance
    }()
    private lazy var instagramButton: UIButton = {
        let instance = UIButton()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.imageView?.contentMode = .center
        instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var instagramView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [instagramIcon, instagramTextField, instagramButton])
        instance.axis = .horizontal
        instance.spacing = 8
        
        return instance
    }()
    private lazy var tiktokIcon: TikTokLogo = {
        let instance = TikTokLogo()
        instance.isOpaque = false
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        
        return instance
    }()
    private lazy var tiktokTextField: UnderlinedSignTextField = {
        let instance = UnderlinedSignTextField(lowerTextFieldTopConstant: -8)
        instance.text = ""
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.spellCheckingType = .no
        instance.autocorrectionType = .no
        instance.attributedPlaceholder = NSAttributedString(string: "tiktok_link".localized, attributes: [
            NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])
        instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
        instance.delegate = self
        
        return instance
    }()
    private lazy var tiktokButton: UIButton = {
        let instance = UIButton()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.imageView?.contentMode = .center
        instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var tiktokView: UIStackView = {
        let instance =  UIStackView(arrangedSubviews: [tiktokIcon, tiktokTextField, tiktokButton])
        instance.axis = .horizontal
        instance.spacing = 8

        
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [facebookView, instagramView, tiktokView])
        instance.axis = .vertical
        instance.spacing = 8
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
        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
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
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        
//        let constraint = verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        constraint.priority = .defaultLow
//        constraint.isActive = true
    }
    
    private func setTasks() {
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.FacebookURL) {
//                guard let self = self,
//                      let userprofile = notification.object as? Userprofile,
//                      userprofile.isCurrent
//                else { return }
//
//                self.isBadgeEnabled = false
//            }
//        })
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.InstagramURL) {
//                guard let self = self,
//                      self.mode == .SocialMedia,
//                      let userprofile = notification.object as? Userprofile,
//                      userprofile.isCurrent
//                else { return }
//
//                self.isBadgeEnabled = false
//            }
//        })
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.TikTokURL) {
//                guard let self = self,
//                      let userprofile = notification.object as? Userprofile,
//                      userprofile.isCurrent
//                else { return }
//
//                self.isBadgeEnabled = false
//            }
//        })
    }
    
    @objc
    private func handleIO(_ instance: UnderlinedSearchTextField) {
//        guard let text = instance.text, text.count >= 4 else { return }
//        fatalError()
    }
    
    private func setupTextFields() {
        facebookTextField.text = userprofile.facebookURL?.absoluteString ?? ""
        instagramTextField.text = userprofile.instagramURL?.absoluteString ?? ""
        tiktokTextField.text = userprofile.tiktokURL?.absoluteString ?? ""
    }
    
    private func setupButtons() {
//        if #available(iOS 15, *) {
//            if !facebookButton.configuration.isNil {
//                facebookButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
//                    guard let self = self else { return .secondaryLabel }
//
//                    return self.userprofile.facebookURL.isNil ? .secondaryLabel : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//                }
//            }
//            if !instagramButton.configuration.isNil {
//                instagramButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
//                    guard let self = self else { return .secondaryLabel }
//
//                    return self.userprofile.instagramURL.isNil ? .secondaryLabel : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//                }
//            }
//            if !tiktokButton.configuration.isNil {
//                tiktokButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
//                    guard let self = self else { return .secondaryLabel }
//
//                    return self.userprofile.tiktokURL.isNil ? .secondaryLabel : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//                }
//            }
//        } else {
            facebookButton.tintColor = userprofile.facebookURL.isNil ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            instagramButton.tintColor = userprofile.instagramURL.isNil ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            tiktokView.tintColor = userprofile.tiktokURL.isNil ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        }
    }
    
    @objc
    private func handleTap(sender: UIButton) {
        if sender === facebookButton, let text = facebookTextField.text, let url = URL(string: text) {
            openURLPublisher.send(url)
        } else if sender === instagramButton, let text = instagramTextField.text, let url = URL(string: text) {
            openURLPublisher.send(url)
        } else if sender === tiktokButton, let text = tiktokTextField.text, let url = URL(string: text) {
            openURLPublisher.send(url)
        }
    }
    
    private func toggleButton(on: Bool, button: UIButton) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, animations: {[weak self] in
            guard let self = self else { return }
            
//            if #available(iOS 15, *) {
//                if !button.configuration.isNil {
//                    button.configuration?.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
//                        guard let self = self else { return .secondaryLabel }
//
//                        return !on ? .secondaryLabel : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//                    }
//                }
//            } else {
                button.tintColor = !on ? .secondaryLabel : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//            }
        }) { _ in
            button.isUserInteractionEnabled = on
        }
    }
    
    // MARK: - Public methods
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        facebookTextField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instagramTextField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        tiktokTextField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        
        guard let userprofile = userprofile else { return }
        
        facebookButton.tintColor = userprofile.facebookURL.isNil ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instagramButton.tintColor = userprofile.facebookURL.isNil ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instagramButton.tintColor = userprofile.facebookURL.isNil ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
    }
}

extension CurrentUserSocialMediaCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textField = textField as? UnderlinedSignTextField else { return true }
        
//        if textField.isShowingSign {
//            textField.hideSign()
//            textField.text = ""
//        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        if textField === facebookTextField {
            guard !text.isEmpty else {
                facebookPublisher.send("")
                facebookTextField.hideSign()
                toggleButton(on: false, button: facebookButton)
                return
            }
            
            guard text.isFacebookLink, let url = URL(string: text) else {
                facebookTextField.showSign(state: .InvalidHyperlink)
                
                delayAsync(delay: 1) {
                    self.facebookTextField.text = self.userprofile.facebookURL?.absoluteString ?? ""
                    self.facebookTextField.hideSign()
                    self.toggleButton(on: self.userprofile.facebookURL.isNil ? false : true, button: self.facebookButton)
                }
                
                return
            }
            facebookPublisher.send(url.absoluteString)
            facebookTextField.hideSign()
            toggleButton(on: true, button: facebookButton)
        } else if textField === instagramTextField {
            guard !text.isEmpty else {
                instagramPublisher.send("")
                instagramTextField.hideSign()
                toggleButton(on: false, button: instagramButton)
                return
            }
            
            guard text.isInstagramLink, let url = URL(string: text) else {
                instagramTextField.showSign(state: .InvalidHyperlink)
                
                delayAsync(delay: 1) {
                    self.instagramTextField.text = self.userprofile.instagramURL?.absoluteString ?? ""
                    self.instagramTextField.hideSign()
                    self.toggleButton(on: self.userprofile.instagramURL.isNil ? false : true, button: self.instagramButton)
                }
                
                return
            }
            instagramPublisher.send(url.absoluteString)
            instagramTextField.hideSign()
            toggleButton(on: true, button: instagramButton)
        } else if textField === tiktokTextField {
            guard !text.isEmpty else {
                tiktokPublisher.send("")
                tiktokTextField.hideSign()
                toggleButton(on: false, button: tiktokButton)
                return
            }
            
            guard text.isTikTokLink, let url = URL(string: text) else {
                tiktokTextField.showSign(state: .InvalidHyperlink)
                
                delayAsync(delay: 1) {
                    self.tiktokTextField.text = self.userprofile.tiktokURL?.absoluteString ?? ""
                    self.tiktokTextField.hideSign()
                    self.toggleButton(on: self.userprofile.instagramURL.isNil ? false : true, button: self.tiktokButton)
                }
                
                return
            }
            tiktokPublisher.send(url.absoluteString)
            tiktokTextField.hideSign()
            toggleButton(on: true, button: tiktokButton)
        }
    }
}

extension CurrentUserSocialMediaCell: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}
