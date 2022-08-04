//
//  PollController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SafariServices
import Combine

class PollController: UIViewController {

    enum Mode {
        case ReadOnly, Write
    }
    
    // MARK: - Public properties
    var controllerOutput: PollControllerOutput?
    var controllerInput: PollControllerInput?
    var mode: Mode {
        return _mode
    }
    
    // MARK: - Private properties
    private var _mode: Mode = .Write
    private var userHasVoted = false
    private var _survey: Survey! {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = !_survey.isNil
            guard !_survey.isNil else { return }
            setBarButtonItem()
        }
    }
    private var _surveyReference: SurveyReference!
    private var _showNext: Bool = false
    private let watchButton: UIImageView = {
        let v = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
        v.contentMode = .center
        return v
    }()
    private var isAddedToFavorite = false {
        didSet {
            if isAddedToFavorite {
                watchButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
            } else {
                watchButton.tintColor = .systemGray
            }
        }
    }
    private lazy var stackView: UIStackView = {
        let v = UIStackView()
        v.accessibilityIdentifier = "stackView"
        v.spacing = 8
        observers.append(v.observe(\UIStackView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard !self.isNil,
                  let newValue = change.newValue,
                  let label = view.arrangedSubviews.filter({ $0.isKind(of: UILabel.self) }).first as? UILabel else { return }
            label.font = UIFont(name: Fonts.Bold, size: newValue.width * 0.1)
        })
        return v
    }()
    private lazy var avatar: NewAvatar = {
        return NewAvatar(userprofile: surveyReference.owner)
//        return Avatar(gender: surveyReference.owner.gender, image: surveyReference.owner.image)
    }()
    private lazy var progressIndicator: CircleButton = {
        let customTitle = CircleButton(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)), useAutoLayout: true)
        customTitle.accessibilityIdentifier = "progressIndicator"
        customTitle.color = .clear
        customTitle.icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        customTitle.icon.backgroundColor = .clear
        customTitle.layer.masksToBounds = false
        customTitle.icon.layer.masksToBounds = false
        customTitle.oval.masksToBounds = false
        customTitle.icon.scaleMultiplicator = 1.7
        customTitle.category = Icon.Category(rawValue: surveyReference.topic.id) ?? .Null
        customTitle.state = .Off
        customTitle.contentView.backgroundColor = .clear
        customTitle.oval.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : surveyReference.topic.tagColor.cgColor
        customTitle.oval.lineCap = .round
        customTitle.oval.strokeStart = survey.isNil ? 0 : CGFloat(survey!.progress)
        return customTitle
    }()
    private lazy var titleView: Icon = {
        let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        icon.backgroundColor = .clear
        icon.iconColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self._surveyReference.topic.tagColor
        icon.isRounded = false
        icon.scaleMultiplicator = 1.4
        icon.category = Icon.Category(rawValue: self._surveyReference.topic.id) ?? .Null
        
        return icon
    }()
    private var observers: [NSKeyValueObservation] = []
    private var tasks: [Task<Void, Never>?] = []
    private var subscriptions = Set<AnyCancellable>()
    private var hidesLargeTitle: Bool = false
    
    // MARK: - Overriden properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Destructor
    deinit {
        tasks.forEach { $0?.cancel() }
        NotificationCenter.default.removeObserver(self)
        subscriptions.forEach{ $0.cancel() }
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    init(surveyReference: SurveyReference, showNext __showNext: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self._surveyReference = surveyReference
        self._survey = surveyReference.survey
        self._showNext = __showNext
        self._mode = (surveyReference.isComplete || surveyReference.isOwn) ? .ReadOnly : .Write
        if !_survey.isNil { self.setBarButtonItem() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func setupUI() {
        if !_survey.isNil { controllerOutput?.onLoadCallback() }
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        self.navigationController?.navigationBar.standardAppearance = appearance
//        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            
        navigationBar.addSubview(avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.rightBarButtonItem?.isEnabled = !_survey.isNil

        NSLayoutConstraint.activate([
            avatar.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            avatar.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            avatar.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor)
            ])
        
        stackView.axis = .horizontal
        navigationBar.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: navigationBar.leftAnchor, constant: UINavigationController.Constants.ImageRightMargin),
            stackView.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            stackView.heightAnchor.constraint(equalTo: avatar.heightAnchor),
            stackView.trailingAnchor.constraint(equalTo: avatar.leadingAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForSmallState)
        ])
        
        let indicator = CircleButton(frame: .zero)
        indicator.accessibilityIdentifier = "progress"
        indicator.color = surveyReference.topic.tagColor
        indicator.oval.strokeStart = CGFloat(1) - CGFloat(surveyReference.progress)/100
        indicator.oval.lineCap = .round
        indicator.ovalBg.strokeStart = 0
        indicator.icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        indicator.icon.backgroundColor = .clear
        indicator.backgroundColor = .clear
        indicator.icon.scaleMultiplicator = 1.5
        indicator.category = Icon.Category(rawValue: surveyReference.topic.id) ?? .Null
        indicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        if !surveyReference.isComplete {
            indicator.oval.opacity = 0
            indicator.ovalBg.opacity = 0
        }
        stackView.addArrangedSubview(indicator)
        
       
        let titleContainer = UIView()
        titleContainer.backgroundColor = .clear
        stackView.addArrangedSubview(titleContainer)
        
        let label = InsetLabel()
        label.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        label.textColor = .white
        label.text = surveyReference.topic.title.uppercased()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .headline)
        label.numberOfLines = 1
        label.accessibilityIdentifier = "label"
        
        let width = surveyReference.topic.title.width(withConstrainedHeight: 100, font: label.font)
        let height = surveyReference.topic.title.height(withConstrainedWidth: width, font: label.font)
        
        label.insets = UIEdgeInsets(top: 0, left: height/3, bottom: 0, right: height/3)
        
        let widthConstraint = label.widthAnchor.constraint(equalToConstant: width + height/2.25*3)
        widthConstraint.identifier = "width"
        widthConstraint.isActive = true
        
//        let heightConstraint = label.heightAnchor.constraint(equalToConstant: height)
//        heightConstraint.identifier = "height"
//        heightConstraint.isActive = true
        label.cornerRadius = height/2.25
        
        let titleStackView = UIStackView()
        titleStackView.spacing = 4
        titleContainer.addSubview(titleStackView)
        titleStackView.accessibilityIdentifier = "titleStackView"
        
        let heightConstraint = titleStackView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.identifier = "height"
        heightConstraint.isActive = true
        
        let marksStackView = UIStackView()
        marksStackView.spacing = 4
        marksStackView.accessibilityIdentifier = "marksStackView"
        
        titleStackView.addArrangedSubview(label)
        titleStackView.addArrangedSubview(marksStackView)
        
        if surveyReference.isOwn {
            let container = UIView()
            container.backgroundColor = .clear
            container.accessibilityIdentifier = "isOwn"
            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
            
            let instance = UIImageView(image: UIImage(systemName: "figure.wave"))
            instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
            instance.contentMode = .scaleAspectFit
            instance.addEquallyTo(to: container)
            marksStackView.addArrangedSubview(container)
        } else if surveyReference.isComplete {
            let container = UIView()
            container.backgroundColor = .clear
            container.accessibilityIdentifier = "isComplete"
            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
            
            let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill",
                                                      withConfiguration: UIImage.SymbolConfiguration(pointSize: marksStackView.frame.height, weight: .semibold, scale: .medium)))
            instance.contentMode = .center
            instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
            instance.contentMode = .scaleAspectFit
            instance.addEquallyTo(to: container)
            marksStackView.addArrangedSubview(container)
        }
        if surveyReference.isFavorite {
            let container = UIView()
            container.backgroundColor = .clear
            container.accessibilityIdentifier = "isFavorite"
            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
            
            let instance = UIImageView(image: UIImage(systemName: "binoculars.fill"))
            instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
            instance.contentMode = .scaleAspectFit
            instance.addEquallyTo(to: container)
            marksStackView.addArrangedSubview(container)
        }
        if surveyReference.isHot {
            let container = UIView()
            container.backgroundColor = .clear
            container.accessibilityIdentifier = "isHot"
            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
            
            let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
            instance.tintColor = .systemRed
            instance.contentMode = .scaleAspectFit
            instance.addEquallyTo(to: container)
            marksStackView.addArrangedSubview(container)
        }
        
        observers.append(label.observe(\InsetLabel.bounds, options: [.new]) { view, change in//[weak self] view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height/2.25
        })
        
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStackView.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            titleStackView.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor)
        ])
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.widthAnchor.constraint(equalTo: indicator.heightAnchor, multiplier: 1.0/1.0).isActive = true
        
//        let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
//        icon.backgroundColor = .clear
//        icon.iconColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self._surveyReference.topic.tagColor
//        icon.isRounded = false
//        icon.scaleMultiplicator = 1.4
//        icon.category = Icon.Category(rawValue: self._surveyReference.topic.id) ?? .Null
//        self.navigationItem.titleView = icon
//        self.navigationItem.titleView?.alpha = 0
//
//        self.navigationItem.titleView?.clipsToBounds = false
        
//        navigationBar.setNeedsLayout()
//        navigationBar.layoutIfNeeded()
        self.avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.stackView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.avatar.alpha = 0
        self.stackView.alpha = 0
    }
    
    private func setObservers() {
        guard let navBar = navigationController?.navigationBar else { return }
        observers.append(navBar.observe(\UINavigationBar.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue else { return }
            //                  let titleView = self.navigationItem.titleView else { return }
            
            if self.navigationItem.titleView.isNil {
                let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
                icon.backgroundColor = .clear
                icon.iconColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self._surveyReference.topic.tagColor
                icon.isRounded = false
                icon.scaleMultiplicator = 1.4
                icon.category = Icon.Category(rawValue: self._surveyReference.topic.id) ?? .Null
                self.navigationItem.titleView = self.titleView
                self.navigationItem.titleView?.alpha = 0
                
                self.navigationItem.titleView?.clipsToBounds = false
            }
            
            
            var largeAlpha: CGFloat = CGFloat(1) - max(CGFloat(UINavigationController.Constants.NavBarHeightLargeState - newValue.height), 0)/52
            let smallAlpha: CGFloat = max(CGFloat(UINavigationController.Constants.NavBarHeightLargeState - newValue.height), 0)/52
            
            largeAlpha = largeAlpha < 0.35 ? 0 : largeAlpha
            self.navigationItem.titleView?.alpha = smallAlpha
            self.avatar.alpha = largeAlpha
            self.stackView.alpha = largeAlpha
        })
    }
    
    private func setUpdaters() {
        guard surveyReference.isComplete else { return }
        
        //Set timer to request stats updates
        //Update survey stats every n seconds
        let events = EventEmitter().emit(every: 5)
        tasks.append(Task { [weak self] in
            for await _ in events {
                guard let self = self else { return }

                self.controllerInput?.updateResultsStats(self._surveyReference)
            }
        })
    }
    
    private func setSubscriptions() {
        //Need to toggle navigationBar.prefersLargeTitles
        if let controllerOutput = controllerOutput {
            controllerOutput.scrollOffsetPublisher.sink { [weak self] in
                guard let self = self else { return }
                self.hidesLargeTitle = $0 != 0
                self.navigationController?.navigationBar.prefersLargeTitles = true
                self.navigationItem.largeTitleDisplayMode = .always
            }.store(in: &subscriptions)
        }
    }
    
    private func setTasks() {
        tasks.append(Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SwitchFavorite) {
                guard let self = self,
                      let instance = notification.object as? SurveyReference,
                      self._surveyReference == instance
                else { return }

                await MainActor.run {
                    self.setBarButtonItem()

                    switch instance.isFavorite {
                    case true:
                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
                              marksStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isFavorite"}).isEmpty
                        else { return }

                        let container = UIView()
                        container.backgroundColor = .clear
                        container.accessibilityIdentifier = "isFavorite"
                        container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true

                        let instance = UIImageView(image: UIImage(systemName: "binoculars.fill"))
                        instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
                        instance.contentMode = .scaleAspectFit
                        instance.addEquallyTo(to: container)
                        marksStackView.insertArrangedSubview(container,
                                                             at: marksStackView.arrangedSubviews.isEmpty ? 0 : marksStackView.arrangedSubviews.count > 1 ? marksStackView.arrangedSubviews.count-1 : marksStackView.arrangedSubviews.count)
                    case false:
                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
                              let mark = marksStackView.getSubview(type: UIView.self, identifier: "isFavorite") else { return }
                        marksStackView.removeArrangedSubview(mark)
                        mark.removeFromSuperview()
                    }
                }
            }
        })

        tasks.append(Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Completed) {
                await MainActor.run {
                    guard let self = self,
                          let instance = notification.object as? SurveyReference,
                          self._surveyReference == instance
                    else { return }

                    switch instance.isComplete {
                    case true:
                        if let indicator = self.stackView.getSubview(type: CircleButton.self, identifier: "progress") {
                            let anim = Animations.get(property: .Opacity, fromValue: 0, toValue: 1, duration: 0.5, delegate: nil)
                            indicator.oval.add(anim, forKey: nil)
                            indicator.ovalBg.add(anim, forKey: nil)
                            indicator.oval.opacity = 1
                            indicator.ovalBg.opacity = 1
                        }
                        
                        self.setUpdaters()

                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
                              marksStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isComplete"}).isEmpty
                        else { return }

                        let container = UIView()
                        container.backgroundColor = .clear
                        container.accessibilityIdentifier = "isComplete"
                        container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true

                        let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
                        instance.contentMode = .center
                        instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self._surveyReference.topic.tagColor
                        instance.contentMode = .scaleAspectFit
                        instance.addEquallyTo(to: container)

                        marksStackView.insertArrangedSubview(container, at: 0)

                        self.observers.append(instance.observe(\UIImageView.bounds, options: .new) { view, change in
                            guard let newValue = change.newValue else { return }
                            view.cornerRadius = newValue.size.height/2
                            let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height * 1.9, weight: .semibold, scale: .medium)
                            let image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: largeConfig)
                            view.image = image
                        })
                    case false:
                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
                              let mark = marksStackView.getSubview(type: UIView.self, identifier: "isComplete") else { return }
                        marksStackView.removeArrangedSubview(mark)
                        mark.removeFromSuperview()
                    }
                }
            }
        })

        tasks.append(Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SwitchHot) {
                await MainActor.run {
                    guard let self = self,
                          let instance = notification.object as? SurveyReference,
                          self._surveyReference == instance
                    else { return }

                    switch instance.isHot {
                    case true:
                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
                              marksStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isHot"}).isEmpty
                        else { return }

                        let container = UIView()
                        container.backgroundColor = .clear
                        container.accessibilityIdentifier = "isHot"
                        container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true

                        let instance = UIImageView(image: UIImage(systemName: "flame.fill"))
                        instance.contentMode = .center
                        instance.tintColor = .systemRed
                        instance.contentMode = .scaleAspectFit
                        instance.addEquallyTo(to: container)

                        marksStackView.insertArrangedSubview(container, at: marksStackView.arrangedSubviews.count == 0 ? 0 : marksStackView.arrangedSubviews.count)

                        self.observers.append(instance.observe(\UIImageView.bounds, options: .new) { view, change in
                            guard let newValue = change.newValue else { return }
                            view.cornerRadius = newValue.size.height/2
                            let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height * 1.9, weight: .semibold, scale: .medium)
                            let image = UIImage(systemName: "flame.fill", withConfiguration: largeConfig)
                            view.image = image
                        })
                    case false:
                        guard let marksStackView = self.stackView.getSubview(type: UIStackView.self, identifier: "marksStackView"),
                              let mark = marksStackView.getSubview(type: UIView.self, identifier: "isHot") else { return }
                        marksStackView.removeArrangedSubview(mark)
                        mark.removeFromSuperview()
                    }
                }
            }
        })

        //Observe progress
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Progress) {
                guard let self = self,
                      let instance = notification.object as? SurveyReference,
                      self._surveyReference == instance,
                      let indicator = self.stackView.getSubview(type: CircleButton.self, identifier: "progress")
                else { return }

                indicator.oval.strokeStart = CGFloat(1) - CGFloat(instance.progress)/100
            }
        })
    }
    
    private func performChecks() {
        guard surveyReference.survey.isNil else {
            controllerInput?.addView()
            return
        }
        //        controllerOutput?.startLoading()
        controllerInput?.loadPoll(surveyReference, incrementViewCounter: true)
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let sender = recognizer.view else { return }
        if sender.isKind(of: CircleButton.self) {
            let popup = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: 0.5)
            popup.present(content: UIView(), dismissAfter: 1)
        }
    }
    
    private func setBarButtonItem() {
        var actionButton: UIBarButtonItem!
        let image =  UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline, scale: .large))
        let shareAction : UIAction = .init(title: "share".localized, image: image, identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
            guard let self = self, !self._survey.isNil else { return }
            // Setting description
            let firstActivityItem = self._surveyReference.title
            
            // Setting url
            let queryItems = [URLQueryItem(name: "hash", value: self._survey.shareHash), URLQueryItem(name: "enc", value: self._survey.shareEncryptedString)]
            var urlComps = URLComponents(string: API_URLS.Surveys.share!.absoluteString)!
            urlComps.queryItems = queryItems
            
            let secondActivityItem: URL = urlComps.url!
            
            // If you want to use an image
            let image : UIImage = UIImage(named: "anon")!
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
            
            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            
            // Pre-configuring activity items
            activityViewController.activityItemsConfiguration = [
                UIActivity.ActivityType.message
            ] as? UIActivityItemsConfigurationReading
            
            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.postToWeibo,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.postToFacebook
            ]
            
            activityViewController.isModalInPresentation = true
            self.present(activityViewController,
                         animated: true,
                         completion: nil)
        })
        
        if _survey.isOwn {
            let image =  UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline, scale: .large))
            actionButton = UIBarButtonItem(title: "share".localized, image: image, primaryAction: shareAction, menu: nil)
            navigationItem.rightBarButtonItem = actionButton
        } else {
            let watchAction : UIAction = .init(title: _survey.isFavorite ? "don't_watch".localized : "watch".localized, image: UIImage(systemName: "binoculars"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
                guard let self = self else { return }
                guard let instance = self._survey,
                      instance.isComplete else {
                    showBanner(bannerDelegate: self.controllerOutput as! BannerObservable, text: "finish_poll".localized, content: ImageSigns.exclamationMark, dismissAfter: 1)
                    return }
                self.controllerInput?.addFavorite(!instance.isFavorite)
            })
            watchAction.accessibilityIdentifier = "watch"
            
            let claimAction : UIAction = .init(title: "make_claim".localized, image: UIImage(systemName: "exclamationmark.triangle.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { (action) in
                //                    self.addButtonActionPressed(action: .advanced)
            })
            
            let actions = [watchAction, shareAction, claimAction]
            let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
            let image =  UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline, scale: .large))
            
            actionButton = UIBarButtonItem(title: "", image: image, primaryAction: nil, menu: menu)
        }
        navigationItem.rightBarButtonItem = actionButton
    }
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    ////                navigationController?.navigationBar.prefersLargeTitles = false
    //        navigationItem.largeTitleDisplayMode = .never
    //
    //    }
    
    
    // MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = PollModel()
        
        self.controllerOutput = view as? PollView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self

        setupUI()
        setTasks()
        setSubscriptions()
        setObservers()
        setUpdaters()
        
        performChecks()
        navigationController?.delegate = self
        setNavigationBarTintColor(.label)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.overrideUserInterfaceStyle = .unspecified
        setNeedsStatusBarAppearanceUpdate()
        
        if !hidesLargeTitle {
            self.titleView.alpha = 0
        }
        
        navigationController?.navigationBar.prefersLargeTitles = hidesLargeTitle ? false : true
        navigationItem.largeTitleDisplayMode = hidesLargeTitle ? .never : .always
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0.1, options: .curveEaseInOut, animations: {
            self.avatar.transform = .identity
            self.stackView.transform = .identity
            self.avatar.alpha = self.hidesLargeTitle ? 0 : 1
            self.stackView.alpha = self.hidesLargeTitle ? 0 : 1
            self.titleView.alpha = !self.hidesLargeTitle ? 0 : 1
        }) { _ in
            guard !self.hidesLargeTitle else { return }
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                self.titleView.alpha = 0
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hidesLargeTitle else { return }
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.titleView.alpha = 0
//        }
//        guard self.navigationItem.titleView.isNil else { return }
//
//        let icon = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
//        icon.backgroundColor = .clear
//        icon.iconColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self._surveyReference.topic.tagColor
//        icon.isRounded = false
//        icon.scaleMultiplicator = 1.4
//        icon.category = Icon.Category(rawValue: self._surveyReference.topic.id) ?? .Null
//        self.navigationItem.titleView = icon
//        self.navigationItem.titleView?.alpha = 0
//
//        self.navigationItem.titleView?.clipsToBounds = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.stackView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            self.titleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.avatar.alpha = 0
            self.stackView.alpha = 0
            self.titleView.alpha = 0
        }
        
        guard !hidesLargeTitle else { return }

        self.titleView.alpha = 0
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard parent.isNil else { return }
        
        if !hidesLargeTitle {
            self.titleView.alpha = 0
        }
        
        clearNavigationBar(clear: true)
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        
        if let titleView = self.navigationItem.titleView, titleView.alpha < 0.5 {
            self.navigationItem.titleView = nil
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.stackView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.avatar.alpha = 0
            self.stackView.alpha = 0
            self.navigationItem.titleView?.alpha = 0
        } completion: { _ in
            self.avatar.removeFromSuperview()
            self.stackView.removeFromSuperview()
        }
//        guard parent.isNil else { return }
//        clearNavigationBar(clear: true)
//        tabBarController?.setTabBarVisible(visible: true, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        //        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor)
        
        if let indicator = stackView.get(all: CircleButton.self).first {
            indicator.icon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor)
        }
        
        if let label = stackView.getSubview(type: InsetLabel.self, identifier: "label") {
            label.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        }
        
        if let isComplete = stackView.getSubview(type: UIView.self, identifier: "isComplete"), let imageView = isComplete.getSubview(type: UIImageView.self, identifier: nil) {
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        }
        
        if let isOwn = stackView.getSubview(type: UIView.self, identifier: "isOwn"), let imageView = isOwn.getSubview(type: UIImageView.self, identifier: nil) {
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        }
        
        if let isFavorite = stackView.getSubview(type: UIView.self, identifier: "isFavorite"), let imageView = isFavorite.getSubview(type: UIImageView.self, identifier: nil) {
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray
        }

        
        if let icon = navigationItem.titleView as? Icon {
            icon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor)
        }
        if isAddedToFavorite {
            watchButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        } else {
            watchButton.tintColor = .systemGray
        }
        
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory,
              let label = stackView.getSubview(type: InsetLabel.self, identifier: "label"),
              let titleStackView = stackView.getSubview(type: UIStackView.self, identifier: "titleStackView"),
              let widthConstraint = label.getConstraint(identifier: "width"),
              let heightConstraint = titleStackView.getConstraint(identifier: "height")
        else { return }
        
        label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
                                       forTextStyle: .headline)
        
        let width = surveyReference.topic.title.width(withConstrainedHeight: 100, font: label.font)
        let height = surveyReference.topic.title.height(withConstrainedWidth: width, font: label.font)
        label.insets = UIEdgeInsets(top: 0, left: height/3, bottom: 0, right: height/3)
        widthConstraint.constant =  width + height/2.25*3
        heightConstraint.constant = height
    }
}

// MARK: - View Input
extension PollController: PollViewInput {
    func onVotersTapped(answer: Answer, color: UIColor) {
        navigationController?.pushViewController(VotersController(answer: answer, color: color), animated: true)
        //        navigationController?.pushViewController(VotersController(answer: answer, indexPath: indexPath, color: color), animated: true)
    }
    
    func onImageTapped(mediafile: Mediafile) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(ImageViewer(mediafile: mediafile), animated: true)
    }
    
    var showNext: Bool {
        return _showNext
    }
    
    func onURLTapped(_ url: URL) {
        var vc: SFSafariViewController!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    func onImageTapped(image: UIImage, title: String) {
        navigationController?.pushViewController(ImageController(image: image, title: title), animated: true)
    }
    
    func onVote(_ choice: Answer) {
        controllerInput?.vote(choice)
//        delayAsync(delay: 0.5) {
//            self._mode = .ReadOnly
//            self.controllerOutput?.onVoteCallback(.success(true))
//        }
    }
    
    func onClaim(_ claim: Claim) {
        controllerInput?.claim(claim)
    }
    
    func onAddFavorite(_ mark: Bool) {
        controllerInput?.addFavorite(mark)
    }
    
    var survey: Survey? {
        get {
            return _surveyReference.survey
        }
    }
    
    var surveyReference: SurveyReference {
        get {
            return _surveyReference
        }
    }
}

// MARK: - Model Output
extension PollController: PollModelOutput {
    func onExitWithSkip() {
        Task {
            try await Task.sleep(nanoseconds: UInt64(0.25 * 1_000_000_000))
            await MainActor.run {
                if let vc = previousController as? HotController {
                    vc.shouldSkipCurrentCard = true
                }
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func onClaimCallback(_ result: Result<Bool, Error>) {
        controllerOutput?.onClaimCallback(result)
    }
    
    func onVoteCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            _mode = .ReadOnly
            userHasVoted = true
            //Show edu info
#if DEBUG
            delayAsync(delay: 1) {
                let popup = Popup(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: 0.4)
                popup.present(content: VoteEducation(topic: .Bankruptcy, color: .systemRed, callbackDelegate: popup))
            }
#else
            delayAsync(delay: 1) {
                guard UserDefaults.App.hasSeenPollVoteIntroduction.isNil else { return }
                
                let popup = Popup(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: 0.4)
                popup.present(content: VoteEducation(topic: .Bankruptcy, color: .systemRed, callbackDelegate: popup))
                
                UserDefaults.App.hasSeenPollVoteIntroduction = true
            }
#endif
        default:
#if DEBUG
            print("")
#endif
        }
        controllerOutput?.onVoteCallback(result)
    }
    
    func onAddFavoriteCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success(let mark):
            guard mark else { return }
            controllerOutput?.onAddFavoriteCallback()
//            setBarButtonItem()
        case .failure:
#if DEBUG
            print("")
#endif
        }
    }
    
    func onLoadCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            _survey = _surveyReference.survey
            controllerOutput?.onLoadCallback()
        case .failure:
            showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, content: ImageSigns.exclamationMark)
        }
    }
}

// MARK: - BannerObservable
extension PollController: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let banner = sender as? Popup {
            banner.removeFromSuperview()
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension PollController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? HotController, userHasVoted {
            vc.shouldSkipCurrentCard = true
        }
    }
}

// MARK: - CallbackObservable
extension PollController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
//        if sender is ChoiceCell, mode == .ReadOnly {
//            print("")
//        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PollController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
