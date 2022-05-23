//
//  AppDelegate.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit
import CoreData
//import Swinject
import UserNotifications
import FBSDKCoreKit
import VK_ios_sdk
import SwiftyVK
import GoogleSignIn

//var vkDelegateReference : SwiftyVKDelegate?
let deviceType = UIDevice().type

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let transitionCoordinator   = TransitionCoordinator()
//    let container               = Container()
    let center                  = UNUserNotificationCenter.current()
    let notificationDelegate    = CustomNotificationDelegate()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        var rootViewController: UIViewController!
        
        API.shared.getCountryByIP() 
        do {
            try UserDefaults.Profile.authorize()
            rootViewController = MainController()
        } catch {
            rootViewController = CustomNavigationController(rootViewController: GetStartedViewController())
        }
        window = UIWindow()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
//        vkDelegateReference = VKDelegate()
//        GIDSignIn.sharedInstance.restorePreviousSignIn()
//        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//        Settings.shared.isAdvertiserTrackingEnabled = false
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
#if DEBUG
        print(url)
#endif
        ///FB
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        ///VK
        let app = options[.sourceApplication] as? String
        VK.handle(url: url, sourceApplication: app)
        ///Google
        return GIDSignIn.sharedInstance.handle(url)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

//    func applicationDidBecomeActive(_ application: UIApplication) {
//        AppEvents.activateApp()
//    }

    func applicationWillTerminate(_ application: UIApplication) {
        API.shared.cancelAllRequests()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ThinkWhat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
//    func registerContainers() {
////        container.register(APIManagerProtocol.self) {
////            _ in APIManager()
////        }
//        container.register(FileStorageProtocol.self) {
//            _ in FileStorageManager()
//        }
//    }
    
    @objc func checkInternetConnection() {
        
        if Reachability.isConnectedToNetwork() {
            internetConnection = .Available
        } else {
            internetConnection = .None
        }
    }

}

//extension AppDelegate: ServerProtocol {
//
//}

