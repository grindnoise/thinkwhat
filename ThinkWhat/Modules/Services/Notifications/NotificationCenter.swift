//
//  NotificationCenter.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UserNotifications
import UIKit

//final class NotificationCenter: NSObject {
//}

extension NotificationCenter: UNUserNotificationCenterDelegate {
  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    return [.banner, .sound, .badge]
  }
  
  @MainActor
  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
  ) async {
    if let surveyId = response.notification.request.content.userInfo["survey_id"] as? String,
       let mainController = appDelegate.window?.rootViewController as? MainController,
       let navigationController = mainController.selectedViewController as? UINavigationController {
      print(surveyId)
      navigationController.navigationBar.backItem?.title = ""
      navigationController.pushViewController(PollController(surveyId: surveyId), animated: true)
      mainController.setTabBarVisible(visible: false, animated: true)
      mainController.toggleLogo(on: false)
    }
    
//    let identity = response.notification.request.content.categoryIdentifier
//    guard identity == PushNotifications.categoryIdentifier,
//      let action = PushNotifications.ActionIdentifier(rawValue: response.actionIdentifier) else {
//      return
//    }
//
//    print("You pressed \(response.actionIdentifier)")
  }
}

