//
//  AppDelegate.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
//import FBSDKCoreKit
import SwiftyVK
import GoogleSignIn

//var vkDelegateReference : SwiftyVKDelegate?
let deviceType = UIDevice().type

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let notificationCenter      = NotificationCenter()
  let transitionCoordinator   = TransitionCoordinator()
  let center                  = UNUserNotificationCenter.current()
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  
    API.shared.system.getCountryByIP()
    window = UIWindow()
    
    // Check if app was opened by push notification
    // surveyId or surveyId/commentId are passed to MainController to open specific controller
    var surveyId: String?
    var commentId: String?
    if let remoteNotification = launchOptions?[.remoteNotification] as?  [AnyHashable : Any],
       let _surveyId = remoteNotification["survey_id"] as? String {
      surveyId = _surveyId
    }
    
    var rootController: UIViewController!
    if AppData.accessToken.isNil || AppData.accessToken!.isEmpty {
      rootController = UINavigationController(rootViewController: StartViewController())
    } else {
      if !surveyId.isNil {
        rootController = MainController(surveyId: surveyId)
      } else if !commentId.isNil {
        rootController = MainController(commentId: commentId)
      } else {
        rootController = MainController(surveyId: nil)
      }
    }
    
    window?.rootViewController = rootController // UINavigationController(rootViewController: StartViewController())//
    window?.makeKeyAndVisible()
    
    PushNotifications.register(in: application, using: notificationCenter)
    return true
  }
  
  func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
#if DEBUG
    print(url)
#endif
    //    ApplicationDelegate.shared.application(
    //      app,
    //      open: url,
    //      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
    //      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    //    )
    VK.handle(url: url, sourceApplication: options[.sourceApplication] as? String)
    return GIDSignIn.sharedInstance.handle(url)
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Reset badge
    UserDefaults.extensions.badge = 0
    application.applicationIconBadgeNumber = 0
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    API.shared.cancelAllRequests()
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }
  
  func application(_ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      print(deviceToken.reduce("") { $0 + String(format: "%02x", $1) })
      PushNotifications.saveToken(token: deviceToken)
//      PushNotifications.registerCustomActions()
  }
  
  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(error.localizedDescription)
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
}
