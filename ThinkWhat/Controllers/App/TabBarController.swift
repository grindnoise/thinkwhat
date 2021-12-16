//
//  TabBarController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit
import UserNotifications

class TabBarController: UITabBarController, ServerProtocol, StorageProtocol {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? .lightContent
    }
    override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
    
//    override var viewControllers: [UIViewController]? {
//        didSet { setNeedsStatusBarAppearanceUpdate() }
//    }
    
    //    public lazy var serverAPI:     APIServerProtocol          = self.initializeServerAPI()
//    public lazy var fileStorageAPI: FileStoringProtocol       = self.initializeFileStoringAPI()
    let sdelegate = ScrollingTabBarControllerDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.window?.rootViewController = self
//        UITabBar.appearance().layer.borderWidth = 1.0
//        UITabBar.appearance().clipsToBounds = true
        tabBar.backgroundColor = .white
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Semibold", size: 11)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 11)!], for: .selected)
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 12)!], for: .focused)
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 12)!], for: .highlighted)

        delegate = sdelegate
        navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.handleTokenState), name: Notifications.OAuth.TokenRevoked, object: nil)
        viewControllers?.forEach {
            if let navController = $0 as? UINavigationController {
                navController.topViewController?.view
            } else {
                $0.view.description
            }
        }

//        UITabBar.appearance().backgroundImage = UIImage.colorForNavBar(color: .white)
//        UITabBar.appearance().shadowImage = UIImage.colorForNavBar(color: .lightGray)
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

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleTokenState() {
        if tokenState == .Revoked {
            performSegue(withIdentifier: Segues.App.Logout, sender: nil)
        }
    }
    
    override func present(_ viewControllerToPresent: UIViewController,
                            animated flag: Bool,
                            completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
      }
    
//    private func initializeServerAPI() -> APIServerProtocol {
//        return appDelegate.container.resolve(APIServerProtocol.self)!
//    }
//
//    private func initializeFileStoringAPI() -> FileStoringProtocol {
//        return appDelegate.container.resolve(FileStoringProtocol.self)!
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
