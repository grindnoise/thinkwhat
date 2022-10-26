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
    private var userprofile: Userprofile? {
        didSet {
            guard !userprofile.isNil else { return }
            
            mode = .Userprofile
//            navigationItem.title = ""//userprofile.name
        }
    }
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
            navigationItem.title = "subscriptions".localized + (period == .AllTime ? "" : " " + "per".localized.lowercased() + " \(period.rawValue.localized.lowercased())")
            
            guard let button = navigationItem.rightBarButtonItem else { return }
            
            button.menu = prepareMenu()
        }
    }
    //UI
    private var isOnScreen = true
    private var isRightButtonSpinning = false {
        didSet {
            let spinner = UIActivityIndicatorView()
            spinner.color = .label
            spinner.style = .medium
            spinner.startAnimating()
            navigationItem.setRightBarButton(isRightButtonSpinning ? UIBarButtonItem(customView: spinner) : nil,
                                             animated: true)
        }
    }
    
    
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
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        controllerOutput?.onWillAppear()
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
        
        //On notifications switch server callback
        tasks.append(Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NotifyOnPublications) {
                guard let self = self,
                      self.mode == .Userprofile
                else { return }
                
                self.isRightButtonSpinning = false
                self.setBarItems()
            }
        })
        
        //On notifications switch server failure callback
        tasks.append(Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NotifyOnPublicationsFailure) {
                guard let self = self else { return }
                
                showBanner(bannerDelegate: self,
                           text: AppError.server.localizedDescription,
                           content: UIImageView(
                            image: UIImage(systemName: "exclamationmark.triangle.fill",
                                           withConfiguration: UIImage.SymbolConfiguration(scale: .small))),
                           color: UIColor.white,
                           textColor: .white,
                           dismissAfter: 0.75,
                           backgroundColor: UIColor.systemOrange.withAlphaComponent(1))
                self.isRightButtonSpinning = false
                self.setBarItems()
            }
        })
    }

    func setupUI() {
        setBarItems()
        
//        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        
//        navigationItem.setRightBarButton(UIBarButtonItem(customView: barButton), animated: true)
        
        navigationItem.title = "subscriptions".localized + (period == .AllTime ? "" : "per".localized.lowercased() + " \(period.rawValue.localized.lowercased())")
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
    
    func setBarItems(zeroSubscriptions: Bool = false) {
        guard !isRightButtonSpinning else { return }
        
        var rightButton: UIBarButtonItem!
        
        switch mode {
        case .Default:
            rightButton = UIBarButtonItem(title: "actions".localized.capitalized,
                                     image: UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                     primaryAction: nil,
                                          menu: prepareMenu(zeroSubscriptions: zeroSubscriptions))
            navigationItem.setRightBarButton(rightButton, animated: true)
            navigationItem.setLeftBarButton(nil, animated: true)
            
        case .Userprofile:
            guard let userprofile = userprofile,
                  let notify = userprofile.notifyOnPublication
            else { return }
            
            let notifyAction = UIAction { [weak self] _ in
                guard let self = self else { return }
                
                self.isRightButtonSpinning = true
                self.controllerInput?.switchNotifications(userprofile: userprofile,
                                                          notify: !notify)
            }
            
            rightButton = UIBarButtonItem(title: nil,
                                          image: UIImage(systemName: notify ? "bell.and.waves.left.and.right.fill" : "bell.slash.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .regular)),
                                          primaryAction: notifyAction,
                                          menu: nil)
            
            let action = UIAction { [weak self] _ in
                guard let self = self else { return }
                
                self.mode = .Default
            }
            
            let leftButton = UIBarButtonItem(title: "actions".localized.capitalized,
                                     image: UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                     primaryAction: action,
                                     menu: nil)
            
            delayAsync(delay: 0.1) { [weak self] in
                guard let self = self else { return }
                
                self.navigationItem.setLeftBarButton(leftButton, animated: true)
                self.navigationItem.setRightBarButton(rightButton, animated: true)
            }
        }
    }
    
    func prepareMenu(zeroSubscriptions: Bool = false) -> UIMenu {
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
        
        var children: [UIMenuElement] = []
        
        if !zeroSubscriptions {
            children.append(inlineMenu)
        }
        children.append(filter)
        
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
            controllerOutput?.setDefaultFilter(nil)
        }
        
        setBarItems()
        
        switch mode {
        case .Userprofile:
            guard let userprofile = userprofile else { return }
            navigationItem.title = userprofile.name
        case .Default:
            navigationItem.title = "subscriptions".localized + (period == .AllTime ? "" : " " + "per".localized.lowercased() + " \(period.rawValue.localized.lowercased())")
        }
    }
}

extension SubscriptionsController: SubscriptionsViewInput {
    func setDefaultMode() {
        mode = .Default
    }
    
    func onSubcriptionsCountEvent(zeroSubscriptions: Bool) {
        setBarItems(zeroSubscriptions: zeroSubscriptions)
    }
    
    func unsubscribe(from userprofile: Userprofile) {
        controllerInput?.unsubscribe(from: userprofile)
//        mode = .Default
    }
    
    func onProfileButtonTapped(_ userprofile: Userprofile) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(UserprofileController(userprofile: userprofile), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onDataSourceRequest(userprofile: Userprofile) {
        controllerInput?.onDataSourceRequest(source: .Userprofile, topic: nil, userprofile: userprofile)
    }
    
    func setUserprofileFilter(_ userprofile: Userprofile) {
        self.userprofile = userprofile
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
        tabBarController?.setTabBarVisible(visible: false, animated: true)
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
    func onAllUsersTapped(mode: UserprofilesViewMode) {
        guard let userprofile = Userprofiles.shared.current else { return }
        
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(UserprofilesController(mode:  mode, userprofile: userprofile), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
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

extension SubscriptionsController: BannerObservable {
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
