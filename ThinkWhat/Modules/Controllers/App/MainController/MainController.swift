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

class MainController: UITabBarController {//}, StorageProtocol {
    
    // MARK: - Lifecycle Methods
    deinit {
        print("MainController deinit()")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private func setViewControllers() {
        func createNavigationController(for rootViewController: UIViewController,
                                        title: String,
                                        image: UIImage?,
                                        selectedImage: UIImage?)-> UIViewController {
            let navigationController = CustomNavigationController(rootViewController: rootViewController)
            navigationController.title = title.localized
            navigationController.tabBarItem.title = title.localized
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
    
    private func setupUI() {
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
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Semibold", size: 12)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 12)!], for: .selected)

        delegate = self//_delegate
        navigationItem.setHidesBackButton(true, animated: false)
        UITabBar.appearance().barTintColor = .systemBackground
        
        loadingIndicator = LoadingIndicator()//CGSize(width: view.frame.width, height: container.frame.height)))
        loadingIndicator!.alpha = 0
        setTabBarVisible(visible: false, animated: false)
    }
    
    public func loadData() {
        if loadingIndicator.isNil || loadingIndicator?.alpha != 1 {
            loadingIndicator!.alpha = 1
            loadingIndicator!.layoutCentered(in: view, multiplier: 0.6)
            loadingIndicator!.addEnableAnimation()
        }
        requestAttempt += 1
        guard requestAttempt <= MAX_REQUEST_ATTEMPTS else {
            onServerUnavailable()
            return
        }
        Task {
            do {
                try await appLaunch()
            } catch {
                loadData()
            }
        }
    }
    
    private func onServerUnavailable() {
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
        requestAttempt = 0
    }
    
    @objc private func updateStats() {
        Task {
            do {
                let data = try await API.shared.surveys.updateStats()
                let json = try JSON(data: data, options: .mutableContainers)
                await MainActor.run {
                    Topics.shared.updateCount(json["count_by_categories"])
                    Userprofiles.shared.current?.updateCount(json["userprofile"])
                    Notification.send(names: [Notifications.System.UpdateStats])
                }
            } catch {
#if DEBUG
                print(error.localizedDescription)
#endif
            }
        }
    }
    
    func appLaunch() async throws {
        do {
            let json = try await API.shared.appLaunch()
            UserDefaults.App.minAPIVersion = json["api_version"].double
            ModelProperties.shared.importJson(json["field_properties"])
            PriceList.shared.importJson(json["pricelist"])
            if let balance = json[DjangoVariables.UserProfile.balance].int {
                Userprofiles.shared.current!.balance = balance
            }
            await MainActor.run {
                do {
                    let topics          = try json["categories"].rawData()
                    let claims          = try json["claim_categories"].rawData()
                    let subscribedFor   = try json["subscribed_for"].rawData()
                    let surveys         = json["surveys"]
                    Topics.shared.load(topics)
                    Claims.shared.load(claims)
                    Surveys.shared.load(surveys)
                    Userprofiles.shared.loadSubscribedFor(subscribedFor)

                    UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseInOut) {
                        self.loadingIndicator?.alpha = 0
                    } completion: { _ in
                        self.view.isUserInteractionEnabled = true
                        self.loadingIndicator?.removeAllAnimations()
                        self.loadingIndicator?.removeFromSuperview()
                        self.setTabBarVisible(visible: true, animated: true)
                        self.viewControllers?.forEach {
                            guard let nav = $0 as? CustomNavigationController, let target = nav.viewControllers.first as? DataObservable else { return }
                            target.onDataLoaded()
                            self.timers.forEach { $0.fire() }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                requestAttempt = 0
            }
        } catch {
            throw error
        }
    }

    
    // MARK: - Properties
    private var requestAttempt = 0
    private var loadingIndicator: LoadingIndicator?
    private var apiUnavailableView: APIUnavailableView?
    private lazy var timers: [Timer] = {
        var array: [Timer] = []
        let t = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(MainController.updateStats), userInfo: nil, repeats: true)
        array.append(t)
        return array
    }()
}

//MARK: -  UITabBarControllerDelegate
extension MainController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ScrollingTransitionAnimator(tabBarController: tabBarController, lastIndex: tabBarController.selectedIndex)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navigationController = viewController as? CustomNavigationController, let vc = navigationController.viewControllers.first else { return }
        if vc.isKind(of: HotController.self) {
            navigationController.title = "hot".localized
            vc.navigationItem.title = "hot".localized
        } else if vc.isKind(of: SubsciptionsController.self) {
            navigationController.title = "subscriptions".localized
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

