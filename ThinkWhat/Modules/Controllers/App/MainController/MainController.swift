//
//  MainController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

import UIKit
import UserNotifications
import SwiftyJSON
import Combine

class MainController: UITabBarController {//}, StorageProtocol {
    
    
    
    // MARK: - Overridden properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? .lightContent
    }
    override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
    
    // MARK: - Public properties
    public private(set) var currentTab: Tab = .Hot {
        didSet {
            guard oldValue != currentTab else { return }
            
            NotificationCenter.default.post(name: Notifications.System.Tab, object: currentTab)
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    private let profileUpdater = PassthroughSubject<Date, Never>()
    private var loadingIndicator: LoadingIndicator?
    private var apiUnavailableView: APIUnavailableView?
    
    // MARK: - Deinitialization
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
    
    // MARK: - Public methods
    
    // MARK: - Private methods
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSubscriptions()
        setViewControllers()
        setupUI()
        loadData()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appDelegate.center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
    }
}

private extension MainController {
    
    func updateUserData() {
        Task {
            do {
                try await API.shared.profiles.updateCurrentUserStatistics()
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
    
    func setSubscriptions() {

        subscriptions.insert(
            Timer
            .publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .subscribe(profileUpdater)
        )
        
        profileUpdater
            .sink { [unowned self] _ in
                
                self.updateUserData()
            }
            .store(in: &subscriptions)
        
    }
    
    func loadData() {
        if loadingIndicator.isNil || loadingIndicator?.alpha != 1 {
            loadingIndicator!.alpha = 1
            loadingIndicator!.layoutCentered(in: view, multiplier: 0.6)
            loadingIndicator!.addEnableAnimation()
        }

        Task {
            do {
                try await appLaunch()
            } catch {
                await MainActor.run {
                    onServerUnavailable()
                }
            }
        }
    }
    
    func setViewControllers() {
        func createNavigationController(for rootViewController: UIViewController,
                                        title: String,
                                        image: UIImage?,
                                        selectedImage: UIImage?)-> UIViewController {
            let navigationController = NavigationController(rootViewController: rootViewController)
            navigationController.title = title.localized
            navigationController.tabBarItem.title = title.localized
            navigationController.modalPresentationCapturesStatusBarAppearance = true
            navigationController.tabBarItem.image = image
            navigationController.tabBarItem.selectedImage = selectedImage
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.setNavigationBarHidden(true, animated: false)
            rootViewController.navigationItem.title = title.localized
            return navigationController
        }
        
        viewControllers = [
            createNavigationController(for: HotController(), title: "hot", image: UIImage(systemName: "flame"), selectedImage: UIImage(systemName: "flame.fill")),
            createNavigationController(for: SubsciptionsController(), title: "subscriptions", image: UIImage(systemName: "bell"), selectedImage: UIImage(systemName: "bell.fill")),
            createNavigationController(for: ListController(), title: "list", image: UIImage(systemName: "square.stack.3d.up"), selectedImage: UIImage(systemName: "square.stack.3d.up.fill")),
            createNavigationController(for: TopicsController(), title: "topics", image: UIImage(systemName: "circle.grid.3x3"), selectedImage: UIImage(systemName: "circle.grid.3x3.fill")),
            createNavigationController(for: SettingsController(), title: "settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        ]
    }
    
    func setupUI() {
        view.isUserInteractionEnabled = false
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return K_COLOR_TABBAR
            }
        }
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 11)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11)], for: .selected)

        delegate = self//_delegate
        navigationItem.setHidesBackButton(true, animated: false)
        UITabBar.appearance().barTintColor = .systemBackground
        
        loadingIndicator = LoadingIndicator()//CGSize(width: view.frame.width, height: container.frame.height)))
        loadingIndicator!.alpha = 0
        setTabBarVisible(visible: false, animated: false)
    }
    
    func onServerUnavailable() {
        apiUnavailableView = APIUnavailableView(frame: view.frame, delegate: self)
        apiUnavailableView?.alpha = 0
        apiUnavailableView?.addEquallyTo(to: view)
        view.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseInOut) {
            self.loadingIndicator?.alpha = 0
        } completion: { _ in
            self.loadingIndicator?.removeAllAnimations()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.apiUnavailableView?.alpha = 1
            } completion: { _ in
                self.loadingIndicator?.removeFromSuperview()
            }
        }
    }
    
    func appLaunch() async throws {
        
        do {
            let json = try await API.shared.appLaunch()
//            API.shared.setWaitsForConnectivity()
//            if let balance = json[DjangoVariables.UserProfile.balance].int {
//                Userprofiles.shared.current!.balance = balance
//            }
            await MainActor.run {
                do {
                    guard let appData = json["app_data"] as? JSON,
                          let surveys = json["surveys"] as? JSON,
                          let userData = json["user_data"] as? JSON
                    else { throw AppError.server }
                    
                    try AppData.loadData(appData)
                    try Userprofiles.loadUserData(userData)
                    Surveys.shared.load(surveys)
                    
                    UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseInOut) {
                        self.loadingIndicator?.alpha = 0
                    } completion: { _ in
                        self.view.isUserInteractionEnabled = true
                        self.loadingIndicator?.removeAllAnimations()
                        self.loadingIndicator?.removeFromSuperview()
                        self.setTabBarVisible(visible: true, animated: true)
                        self.viewControllers?.forEach {
                            guard let nav = $0 as? UINavigationController,// CustomNavigationController,
                                  let target = nav.viewControllers.first as? DataObservable else { return }
                            target.onDataLoaded()
//                            self.timers.forEach { $0.fire() }
                        }
                    }
                } catch {
#if DEBUG
                    error.printLocalized(class: type(of: self), functionName: #function)
#endif
                }
//                requestAttempt = 0
            }
        } catch {
            throw error
        }
    }
}

//MARK: -  UITabBarControllerDelegate
extension MainController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ScrollingTransitionAnimator(tabBarController: tabBarController, lastIndex: tabBarController.selectedIndex)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let nav = viewController as? NavigationController,
           let controller = nav.viewControllers.first {
            switch controller.self {
            case is HotController:
                currentTab = .Hot
            case is SubsciptionsController:
                currentTab = .Subscriptions
            case is ListController:
                currentTab = .Feed
            case is TopicsController:
                currentTab = .Topics
            case is SettingsController:
                currentTab = .Settings
            default:
                print("")
#if DEBUG
                fatalError()
#endif
            }
        }
        
        guard let vc = navigationController?.viewControllers.first else { return }
        if viewController.isKind(of: HotController.self) {
            navigationController?.title = "hot".localized
            vc.navigationItem.title = "hot".localized
        } else if vc.isKind(of: SubsciptionsController.self) {
            navigationController?.title = "subscriptions".localized
            vc.navigationItem.title = "subscriptions".localized
        }
    }
}

extension MainController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if sender is APIUnavailableView {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.apiUnavailableView?.alpha = 0
            } completion: { _ in
                self.loadData()
            }
        }
    }
}

