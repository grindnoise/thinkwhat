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
    // Here we can decide what to do with the notification
    return [.banner, .sound, .badge] // Show default banner, sound and badge
  }
  
  @MainActor
  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
  ) async {
    switch response.notification.request.content.categoryIdentifier {
    case "NewPublication":
      guard let surveyId = response.notification.request.content.userInfo["survey_id"] as? Int,
            let mainController = appDelegate.window?.rootViewController as? MainController,
            let navigationController = mainController.selectedViewController as? UINavigationController
      else { return }
      
      navigationController.navigationBar.backItem?.title = ""
      navigationController.pushViewController(PollController(surveyId: surveyId), animated: true)
      mainController.setTabBarVisible(visible: false, animated: true)
      mainController.toggleLogo(on: false)
    case "OwnPublicationFinished", "WatchlistPublicationFinished":
      guard let surveyId = response.notification.request.content.userInfo["survey_id"] as? Int,
            let mainController = appDelegate.window?.rootViewController as? MainController,
            let navigationController = mainController.selectedViewController as? UINavigationController
      else { return }
      
      navigationController.navigationBar.backItem?.title = ""
      // Check if we already have one loaded
      if let found = SurveyReferences.shared.all.filter({ $0.id == surveyId }).first {
        navigationController.pushViewController(PollController(surveyReference: found, mode: .Read), animated: true)
      } else {
        navigationController.pushViewController(PollController(surveyId: surveyId, mode: .Read), animated: true)
      }
      mainController.setTabBarVisible(visible: false, animated: true)
      mainController.toggleLogo(on: false)
    case "NewReply":
      guard let surveyIdStr = response.notification.request.content.userInfo["survey_id"] as? String,
            let surveyId = Int(surveyIdStr),
            let replyIdStr = response.notification.request.content.userInfo["reply_id"] as? String, // Id of new reply
            let replyId = Int(replyIdStr),
            let replyToIdStr = response.notification.request.content.userInfo["reply_to_id"] as? String, // Id of new reply corresponding message
            let replyToId = Int(replyToIdStr),
            let threadIdStr = response.notification.request.content.userInfo["thread_id"] as? String, // Id of the thread
            let threadId = Int(threadIdStr),
            let mainController = appDelegate.window?.rootViewController as? MainController,
            let navigationController = mainController.selectedViewController as? UINavigationController
      else { return }
      
      navigationController.navigationBar.backItem?.title = ""
      // We need to check if current PollController controller is un navigation stack
      if let foundController = navigationController.viewControllers.filter({
        if let controller = $0 as? CommentsController, controller.item.id == threadId {
          return true
        }
        return false
      }).first as? CommentsController {
        foundController.setReply(replyId)
      } else if let foundController = navigationController.viewControllers.filter({
        // We need to check if current PollController controller is un navigation stack
        if let controller = $0 as? PollController, controller.item.id == surveyId {
          return true
        }
        return false
      }).first as? PollController {
        navigationController.popToViewController(foundController, animated: true)
        foundController.setThreadAndReplyFromPushNotification(threadId: threadId,
                                                              replyId: replyId,
                                                              replyToId: replyToId)
      } else {
        // Init and open new PollController
        navigationController.pushViewController(PollController(surveyId: surveyId,
                                                               threadId: threadId,
                                                               replyId: replyId,
                                                              replyToId: replyToId),
                                                animated: true)
      }
      mainController.setTabBarVisible(visible: false, animated: true)
      mainController.toggleLogo(on: false)
    default:
      return
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

