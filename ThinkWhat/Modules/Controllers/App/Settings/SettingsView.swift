//
//  SettingsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import Agrume

class SettingsView: UIView {
    
    
    
    // MARK: - Public properties
    weak var viewInput: (SettingsViewInput & UIViewController)?
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = true
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        
        userSettingsView.addEquallyTo(to: instance)
        appSettingsView.addEquallyTo(to: instance)
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.cornerRadius = rect.width * 0.05
            }
            .store(in: &subscriptions)
        
        traitCollection.publisher(for: \.userInterfaceStyle)
            .sink { style in
                instance.backgroundColor = style == .dark ? .secondarySystemBackground : .systemBackground
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var userSettingsView: UserSettingsCollectionView = {
        let instance = UserSettingsCollectionView()
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.cornerRadius = rect.width * 0.05
            }
            .store(in: &subscriptions)
        
        
        //            .sink { style in
        //                instance.backgroundColor = style == .dark ? .secondarySystemBackground : .systemBackground
        //            }
        //            .store(in: &subscriptions)
//        traitCollection.publisher(for: \.userInterfaceStyle)
//            .sink { style in
//                instance.backgroundColor = style == .dark ? .secondarySystemBackground : .systemBackground
//            }
//            .store(in: &subscriptions)
        
        instance.namePublisher
            .sink { [unowned self] in
                guard let dict = $0 else { return }
                
                self.viewInput?.updateUsername(dict)
            }
            .store(in: &subscriptions)
        
        instance.datePublisher
            .sink { [unowned self] in
                guard let date = $0 else { return }
                
                self.viewInput?.updateBirthDate(date)
            }
            .store(in: &subscriptions)
        
        instance.genderPublisher
            .sink { [unowned self] in
                guard let gender = $0 else { return }
                
                self.viewInput?.updateGender(gender)
            }
            .store(in: &subscriptions)
        
        instance.cameraPublisher
            .sink { [unowned self] in
                guard !$0.isNil else { return }
                
                self.viewInput?.openCamera()
            }
            .store(in: &subscriptions)
        
        instance.galleryPublisher
            .sink { [unowned self] in
                guard !$0.isNil else { return }
                
                self.viewInput?.openGallery()
            }
            .store(in: &subscriptions)
        
        instance.previewPublisher
            .sink { [unowned self] in
                guard let image = $0,
                      let controller = self.viewInput
                else { return }
                
                let agrume = Agrume(images: [image], startIndex: 0, background: .colored(.black))
                agrume.show(from: controller)
                
            }
            .store(in: &subscriptions)
        
        instance.cityFetchPublisher
            .sink { [unowned self] in
                guard let string = $0 else { return }
                
                self.viewInput?.onCitySearch(string)
            }
            .store(in: &self.subscriptions)
        
        instance.citySelectionPublisher
            .sink { [unowned self] in
                guard let city = $0 else { return }
                
                self.viewInput?.updateCity(city)
            }
            .store(in: &self.subscriptions)
        
        instance.facebookPublisher
            .sink { [unowned self] in
                guard let url = $0 else { return }
                
                self.viewInput?.updateFacebook(url)
            }
            .store(in: &self.subscriptions)
        
        instance.instagramPublisher
            .sink { [unowned self] in
                guard let url = $0 else { return }
                
                self.viewInput?.updateInstagram(url)
            }
            .store(in: &self.subscriptions)
        
        instance.tiktokPublisher
            .sink { [unowned self] in
                guard let url = $0 else { return }
                
                self.viewInput?.updateTiktok(url)
            }
            .store(in: &self.subscriptions)
        
        instance.openURLPublisher
            .sink { [unowned self] in
                guard let url = $0 else { return }
                
                self.viewInput?.openURL(url)
            }
            .store(in: &self.subscriptions)
        
        instance.interestPublisher
            .sink { [unowned self] in
                guard let topic = $0 else { return }
                
                self.viewInput?.onTopicSelected(topic)
            }
            .store(in: &subscriptions)
        
        instance.publicationsPublisher
            .sink { [unowned self] in
                guard !$0.isNil else { return }
                
                self.viewInput?.onPublicationsSelected()
            }
            .store(in: &subscriptions)
        
        instance.subscribersPublisher
            .sink { [unowned self] in
                guard !$0.isNil else { return }
                
                self.viewInput?.onSubscribersSelected()
            }
            .store(in: &subscriptions)
        
        instance.subscriptionsPublisher
            .sink { [unowned self] in
                guard !$0.isNil else { return }
                
                self.viewInput?.onSubscriptionsSelected()
            }
            .store(in: &subscriptions)
        
        instance.watchingPublisher
            .sink { [unowned self] in
                guard !$0.isNil else { return }
                
                self.viewInput?.onWatchingSelected()
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var appSettingsView: AppSettingsCollectionView = {
        let instance = AppSettingsCollectionView()
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.cornerRadius = rect.width * 0.05
            }
            .store(in: &subscriptions)
        
        instance.notificationSettingsPublisher
            .sink { [weak self] in
                guard let self = self,
                      let settings = $0
                else { return }
                
                self.viewInput?.updateAppSettings(settings)
            }
            .store(in: &subscriptions)
        
        instance.appLanguagePublisher
            .sink { [weak self] in
                guard let self = self,
                      let settings = $0
                else { return }
                
                self.viewInput?.updateAppSettings(settings)
                
                let banner = Popup(callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: 0.5)
                banner.present(content: PopupContent(parent: banner,
                                                     systemImage: "lightbulb.circle.fill",
                                                     text: "restart",
                                                     buttonTitle: "ok",
                                                     fixedSize: false,
                                                     spacing: 24))
                
            }
            .store(in: &subscriptions)
        
        instance.contentLanguagePublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.viewInput?.onContentLanguageTap()
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadowView: UIView! {
        didSet {
            shadowView.layer.masksToBounds = false
            shadowView.clipsToBounds = false
            shadowView.backgroundColor = .clear
            shadowView.accessibilityIdentifier = "shadow"
            shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            shadowView.layer.shadowRadius = 5
            shadowView.layer.shadowOffset = .zero
            
            traitCollection.publisher(for: \.userInterfaceStyle)
                .sink { [unowned self] style in
                    self.shadowView.layer.shadowOpacity = style == .dark ? 0 : 1
                }
                .store(in: &subscriptions)
            
            shadowView.publisher(for: \.bounds, options: .new)
                .sink { [weak self] rect in
                    guard let self = self else { return }
                    
                    self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.width*0.05).cgPath
                }
                .store(in: &subscriptions)
            
            background.addEquallyTo(to: shadowView)
        }
    }
    
    
    
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
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setTasks()
        setupUI()
    }
    
    
    
    // MARK: - Overrriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        userSettingsView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        appSettingsView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print(touches)
    }
}

private extension SettingsView {
    func setupUI() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        let touch = UITapGestureRecognizer(target: self, action:#selector(self.hideKeyboard))
        addGestureRecognizer(touch)
    }
    
    func setTasks() {
//        //Hide keyboard
//        tasks.append( Task {@MainActor [weak self] in
//            for await _ in NotificationCenter.default.notifications(for: UIApplication.keyboardDidShowNotification) {
//                guard let self = self else { return }
//
//                let touch = UITapGestureRecognizer(target:self, action:#selector(self.hideKeyboard))
//                self.addGestureRecognizer(touch)
//            }
//        })
    }
    
    @objc
    func hideKeyboard() {
        endEditing(true)
    }
}

extension SettingsView: SettingsControllerOutput {
    func onError(_ error: Error) {
        showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: UIImageView(image: UIImage(systemName: "exclamationmark.icloud.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemOrange.withAlphaComponent(1), shadowed: false)
    }
}

extension SettingsView: BannerObservable {
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


