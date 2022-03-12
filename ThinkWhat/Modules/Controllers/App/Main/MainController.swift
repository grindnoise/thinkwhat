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
            rootViewController.navigationItem.title = title.localized
            return navigationController
        }
        viewControllers = [
            createNavigationController(for: HotController(), title: "hot", image: UIImage(systemName: "flame"), selectedImage: UIImage(systemName: "flame.fill")),
            createNavigationController(for: SubsciptionsController(), title: "subscriptions", image: UIImage(systemName: "person.2"), selectedImage: UIImage(systemName: "person.2.fill")),
            createNavigationController(for: ListController(), title: "list", image: UIImage(systemName: "tray.full"), selectedImage: UIImage(systemName: "tray.full.fill")),
            createNavigationController(for: TopicsController(), title: "topics", image: UIImage(systemName: "circle.grid.2x2"), selectedImage: UIImage(systemName: "circle.grid.2x2.fill")),
            createNavigationController(for: SettingsController(), title: "settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        ]
    }
    
    private func setupUI() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .systemBlue
            default:
                return K_COLOR_TABBAR
            }
        }
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Semibold", size: 12)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 12)!], for: .selected)

        delegate = self//_delegate
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        UITabBar.appearance().barTintColor = .systemBackground
        
//        rootViewController.navigationItem.title = title
    }
    
    // MARK: - Properties
//    private let _delegate = ScrollingTabBarControllerDelegate()
    
//    override func present(_ viewControllerToPresent: UIViewController,
//                          animated flag: Bool,
//                          completion: (() -> Void)? = nil) {
//        viewControllerToPresent.modalPresentationStyle = .fullScreen
//        super.present(viewControllerToPresent, animated: flag, completion: completion)
//    }
}

//MARK: -  UITabBarControllerDelegate
extension MainController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ScrollingTransitionAnimator(tabBarController: tabBarController, lastIndex: tabBarController.selectedIndex)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navigationController = viewController as? CustomNavigationController, let vc = navigationController.viewControllers.first else { return }
        if vc.isKind(of: HotController.self) {
            navigationController.title = "subscriptions".localized
            vc.navigationItem.title = "hot".localized
        } else if vc.isKind(of: SubsciptionsController.self) {
            navigationController.title = "subscriptions".localized
            vc.navigationItem.title = "subscriptions".localized
        }
    }
}
