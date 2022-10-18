//
//  SubsciptionsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SubscriptionsController: UIViewController {

    
    private enum Mode {
        case Default, Userprofile
    }
    
    // MARK: - Public properties
    var controllerOutput: SubsciptionsControllerOutput?
    var controllerInput: SubsciptionsControllerInput?
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Logic
    private var mode: Mode = .Default {
        didSet {
            guard oldValue != mode else { return }
            
            onModeChanged()
        }
    }
    private var period: Period = .AllTime {
        didSet {
            guard oldValue != period else { return }
            
            controllerOutput?.setPeriod(period)
            navigationItem.title = "subscriptions".localized + " (\(period.rawValue.localized.lowercased()))"
            
//            guard let button = barButton.getSubview(type: UIButton.self,
//                                                    identifier: "button")
//            else { return }
//
//            button.menu = prepareMenu()
            setRightBarButton()
        }
    }
    //UI
    private lazy var gradient: CAGradientLayer = {
        let instance = CAGradientLayer()
        instance.type = .radial
        instance.colors = getGradientColors()
        instance.locations = [0, 0.5, 1.15]
        instance.setIdentifier("radialGradient")
        instance.startPoint = CGPoint(x: 0.5, y: 0.5)
        instance.endPoint = CGPoint(x: 1, y: 1)
        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.cornerRadius = rect.height/2
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var barButton: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        instance.layer.shadowRadius = 7
        instance.layer.shadowOffset = .zero
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState).isActive = true
        instance.layer.addSublayer(gradient)
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.layer.shadowPath = UIBezierPath(ovalIn: rect).cgPath
                
                guard rect != .zero,
                      let layer = instance.layer.getSublayer(identifier: "radialGradient"),
                      layer.bounds != rect
                else { return }

                layer.frame = rect
            }
            .store(in: &subscriptions)
        
        let button = UIButton()
        button.menu = prepareMenu()
        button.showsMenuAsPrimaryAction = true
        button.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                    self .mode == .Default
                else { return }
                
                
                button.cornerRadius = rect.height/2
                let largeConfig = UIImage.SymbolConfiguration(pointSize: rect.height * 0.45, weight: .semibold, scale: .medium)
                let image = UIImage(systemName: "ellipsis", withConfiguration: largeConfig)
                button.setImage(image, for: .normal)
            }
            .store(in: &subscriptions)
        
        button.addTarget(self, action: #selector(self.onBarButtonTap), for: .touchUpInside)
        button.accessibilityIdentifier = "button"
        button.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        button.imageView?.contentMode = .center
        button.imageView?.tintColor = .white
        button.addEquallyTo(to: instance)

        return instance
    }()
    private var isBarButtonOn = true
    private var isOnScreen = true
    
    
    // MARK: - Overridden properties
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = SubscriptionsModel()
               
        self.controllerOutput = view as? SubscriptionsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        ProtocolSubscriptions.subscribe(self)
        
        setupUI()
        setTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false
        barButton.alpha = 1
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        controllerOutput?.onWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barButton.alpha = 0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        barButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        gradient.colors = getGradientColors()
    }
}

private extension SubscriptionsController {
    func setTasks() {
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.System.Tab) {
                guard let self = self,
                      let tab = notification.object as? Tab
                else { return }
                
                self.isOnScreen = tab == .Subscriptions
            }
        })
    }

    func setupUI() {
        setRightBarButton()
        
//        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        
//        navigationItem.setRightBarButton(UIBarButtonItem(customView: barButton), animated: true)
        
        navigationItem.title = "subscriptions".localized + " (\(period.rawValue.localized.lowercased()))"
//        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
//        navigationBar.addSubview(barButton)
//        barButton.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            barButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
//            barButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
//            barButton.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
//            barButton.widthAnchor.constraint(equalTo: barButton.heightAnchor)
//        ])
    }
    
    func setRightBarButton() {
        var button: UIBarButtonItem!
        switch mode {
        case .Default:
            button = UIBarButtonItem(title: "actions".localized.capitalized,
                                     image: UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                     primaryAction: nil,
                                     menu: prepareMenu())
        case .Userprofile:
            let action = UIAction { [weak self] _ in
                guard let self = self else { return }
                
                self.mode = .Default
            }
            
            button = UIBarButtonItem(title: "actions".localized.capitalized,
                                     image: UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                     primaryAction: action,
                                     menu: nil)
        }
        
        navigationItem.setRightBarButton(button, animated: true)
    }
        
    func getGradientColors() -> [CGColor] {
        return [
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.lighter(0.2).cgColor : K_COLOR_RED.lighter(0.2).cgColor,
        ]
    }
    
    func prepareMenu() -> UIMenu {
        let perDay: UIAction = .init(title: Period.PerDay.rawValue.localized,
                                     image: nil,
                                     identifier: nil,
                                     discoverabilityTitle: nil,
                                     attributes: .init(),
                                     state: period == .PerDay ? .on : .off,
                                     handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .PerDay
        })
        
        let perWeek: UIAction = .init(title: Period.PerWeek.rawValue.localized,
                                      image: nil,
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .init(),
                                      state: period == .PerWeek ? .on : .off,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .PerWeek
        })
        
        let perMonth: UIAction = .init(title: Period.PerMonth.rawValue.localized,
                                       image: nil,
                                       identifier: nil,
                                       discoverabilityTitle: nil,
                                       attributes: .init(),
                                       state: period == .PerMonth ? .on : .off,
                                       handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .PerMonth
        })
        
        let allTime: UIAction = .init(title: Period.AllTime.rawValue.localized,
                                      image: nil,
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .init(),
                                      state: period == .AllTime ? .on : .off,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .AllTime
        })
        
        let inlineMenu = UIMenu(title: "publications_per".localized,
                                image: nil,
                                identifier: nil,
                                options: .displayInline,
                                children: [
                                    perDay,
                                    perWeek,
                                    perMonth,
                                    allTime
                                ])
        
        var subscribersCount = ""
        if let userprofile = Userprofiles.shared.current {
            subscribersCount  = " (\(userprofile.subscribers.count))"
        }
        
        let filter: UIAction = .init(title: "my_subscribers".localized + subscribersCount,
                                     image: UIImage(systemName: "person.crop.circle.fill.badge.checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                     identifier: nil,
                                     discoverabilityTitle: nil,
                                     attributes: .init(),
                                     state: .off,
                                     handler: { [weak self] _ in
            guard let self = self,
                  let userprofile = Userprofiles.shared.current
            else { return }
            
            let backItem = UIBarButtonItem()
                backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            self.navigationController?.pushViewController(UserprofilesController(mode: .Subscribers, userprofile: userprofile), animated: true)
            self.tabBarController?.setTabBarVisible(visible: false, animated: true)
        })
        
        let children: [UIMenuElement] = [inlineMenu, filter]
        
        return UIMenu(title: "", children: children)
    }
    
    @objc
    func onBarButtonTap() {
        if mode == .Userprofile {
            mode = .Default
        }
    }
    
    func onModeChanged() {
        if mode == .Default {
            controllerOutput?.setDefaultFilter()
        }
        
        setRightBarButton()
//        guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
//
//        let largeConfig = UIImage.SymbolConfiguration(pointSize: button.bounds.height * 0.45,
//                                                      weight: .semibold, scale: .medium)
//        let image = UIImage(systemName: mode == .Userprofile ? "arrow.left" : "ellipsis",
//                            withConfiguration: largeConfig)
//        button.setImage(image, for: .normal)
//        button.showsMenuAsPrimaryAction = mode == .Default
        
        navigationItem.title = "subscriptions".localized + " (\(period.rawValue.localized.lowercased()))"
    }
}

extension SubscriptionsController: SubscriptionsViewInput {
    func onDataSourceRequest(userprofile: Userprofile) {
        controllerInput?.onDataSourceRequest(source: .Userprofile, topic: nil, userprofile: userprofile)
    }
    
    func setUserprofileFilter(_ userprofile: Userprofile) {
        mode = .Userprofile
        navigationItem.title = userprofile.name
    }
    
    func share(_ surveyReference: SurveyReference) {
        // Setting description
        let firstActivityItem = surveyReference.title
        
        // Setting url
        let queryItems = [URLQueryItem(name: "hash", value: surveyReference.shareHash), URLQueryItem(name: "enc", value: surveyReference.shareEncryptedString)]
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
        
        activityViewController.isModalInPresentation = false
        self.present(activityViewController,
                     animated: true,
                     completion: nil)
    }
    
    func claim(surveyReference: SurveyReference, claim: Claim) {
        controllerInput?.claim(surveyReference: surveyReference, claim: claim)
    }
    
    func addFavorite(_ surveyReference: SurveyReference) {
        controllerInput?.addFavorite(surveyReference: surveyReference)
    }
    
    func updateSurveyStats(_ instances: [SurveyReference]) {
        guard isOnScreen else { return }
        controllerInput?.updateSurveyStats(instances)
    }
    
    func onSurveyTapped(_ instance: SurveyReference) {
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(PollController(surveyReference: instance, showNext: false), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onDataSourceRequest(source: Survey.SurveyCategory, topic: Topic?) {
        controllerInput?.onDataSourceRequest(source: source, topic: topic, userprofile: nil)
    }
    
    func onSubscribersTapped() {
        
        guard let userprofile = Userprofiles.shared.current,
            userprofile.subscribersTotal != 0
        else { return }
        
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(UserprofilesController(mode: .Subscribers, userprofile: userprofile), animated: true)
    }
    
    func onSubscpitionsTapped() {
//        let backItem = UIBarButtonItem()
//            backItem.title = ""
//            navigationItem.backBarButtonItem = backItem
//        navigationController?.pushViewController(SubscribersController(mode: .Subscriptions), animated: true)
    }
    
//    @objc
//    func toggleBarButton() {
//        controllerOutput?.onUpperContainerShown(isBarButtonOn)
//        UIView.animate(withDuration: 0.3,
//                       delay: 0,
//                       options: .curveEaseOut) {
//            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
//            self.barButton.transform = self.isBarButtonOn ? upsideDown :.identity
//        } completion: { _ in
//            self.isBarButtonOn = !self.isBarButtonOn
//        }
//    }
    
}

extension SubscriptionsController: SubsciptionsModelOutput {
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        controllerOutput?.onRequestCompleted(result)
    }
}

extension SubscriptionsController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
