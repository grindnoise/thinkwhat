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
        
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
        
        profileView.addEquallyTo(to: instance)
        
        return instance
    }()
    private lazy var profileView: CurrentUserProfileCollectionView = {
        let instance = CurrentUserProfileCollectionView()
        
        instance.namePublisher.sink { [unowned self] in
            guard let dict = $0 else { return }
            
            self.viewInput?.updateUsername(dict)
        }.store(in: &subscriptions)
        
        instance.datePublisher.sink { [unowned self] in
            guard let date = $0 else { return }
            
            self.viewInput?.updateBirthDate(date)
        }.store(in: &subscriptions)
        
        instance.genderPublisher.sink { [unowned self] in
            guard let gender = $0 else { return }
            
            self.viewInput?.updateGender(gender)
        }.store(in: &subscriptions)
        
        instance.cameraPublisher.sink { [unowned self] in
            guard !$0.isNil else { return }
            
            self.viewInput?.openCamera()
        }.store(in: &subscriptions)
        
        instance.galleryPublisher.sink { [unowned self] in
            guard !$0.isNil else { return }
            
            self.viewInput?.openGallery()
        }.store(in: &subscriptions)
        
        instance.previewPublisher.sink { [weak self] in
            guard let self = self,
                  let image = $0,
                  let controller = self.viewInput
            else { return }
            
            let agrume = Agrume(images: [image], startIndex: 0, background: .colored(.black))
            agrume.show(from: controller)
            
        }.store(in: &subscriptions)
        
        instance.cityFetchPublisher.sink { [weak self] in
            guard let self = self,
                  let string = $0
            else { return }
            
            self.viewInput?.onCitySearch(string)
        }.store(in: &self.subscriptions)

        instance.citySelectionPublisher.sink { [weak self] in
            guard let self = self,
                  let city = $0
            else { return }
            
            self.viewInput?.updateCity(city)
        }.store(in: &self.subscriptions)
        
        instance.facebookPublisher.sink { [weak self] in
            guard let self = self,
                  let url = $0
            else { return }
            
            self.viewInput?.updateFacebook(url)
        }.store(in: &self.subscriptions)
        
        instance.instagramPublisher.sink { [weak self] in
            guard let self = self,
                  let url = $0
            else { return }
            
            self.viewInput?.updateInstagram(url)
        }.store(in: &self.subscriptions)
        
        instance.tiktokPublisher.sink { [weak self] in
            guard let self = self,
                  let url = $0
            else { return }
            
            self.viewInput?.updateTiktok(url)
        }.store(in: &self.subscriptions)
        
        instance.openURLPublisher.sink { [weak self] in
            guard let self = self,
                  let url = $0
            else { return }
            
            self.viewInput?.openURL(url)
        }.store(in: &self.subscriptions)
        
        instance.interestPublisher
            .sink { [weak self] in
                guard let self = self,
                      let topic = $0
                else { return }
                
                self.viewInput?.onTopicSelected(topic)
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
            observers.append(shadowView.observe(\UIView.bounds, options: .new) { view, change in
                guard let newValue = change.newValue else { return }
                view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.width*0.05).cgPath
            })
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
    
    private func setupUI() {
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
    
    private func setTasks() {
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
    private func hideKeyboard() {
        endEditing(true)
    }
    
    // MARK: - Overrriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        profileView.backgroundColor = .clear
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print(touches)
    }
}

// MARK: - Controller Output
extension SettingsView: SettingsControllerOutput {
    func onError(_ error: Error) {
        showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: UIImageView(image: UIImage(systemName: "exclamationmark.icloud.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemOrange.withAlphaComponent(1), shadowed: false)
    }
}

// MARK: - BannerObservable
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


