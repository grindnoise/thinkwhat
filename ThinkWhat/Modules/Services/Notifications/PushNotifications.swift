//
//  PushNotifications.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import UserNotifications

enum PushNotifications {
  public static let categoryIdentifier = "AcceptOrReject"
  
  public enum ActionIdentifier: String {
    case accept, reject
  }
  
  static func saveToken(token: Data) {
    
    // If user is logged in then check if token has changed.
    // If token has been changed then we need to unregister the
    // old one and register new
    let newToken = PushNotificationToken(token: token)
    
    if !AppData.accessToken.isNil, !AppData.accessToken!.isEmpty,
       let prevToken = loadToken(),
       prevToken != newToken
    {
      Task {
        unregisterDevice(token: prevToken)
      }
    }
    Task {
      registerDevice(token: newToken)
    }
    KeychainService.saveApnsToken(token: token)
  }
  
  /// Loads token from keychain
  /// - Returns: `PushNotificationToken?'
  static func loadToken() -> PushNotificationToken? {
    guard let data = KeychainService.loadApnsToken() else { return nil }
    
    return PushNotificationToken(token: data)
  }
  
  static func registerDevice(token: PushNotificationToken) {
    Task {
      await API.shared.system.registerDevice(token: token)
    }
  }
  
  static func unregisterDevice(token: PushNotificationToken, completion: Closure? = nil) {
    Task {
      await API.shared.system.unregisterDevice(token: token)
      completion?()
    }
  }

  static func register(
    in application: UIApplication,
    using notificationCenterDelegate: UNUserNotificationCenterDelegate? = nil
  ) {
    Task {
      let center = UNUserNotificationCenter.current()

      try await center.requestAuthorization(options: [.badge, .sound, .alert])

      center.delegate = notificationCenterDelegate

      await MainActor.run {
        application.registerForRemoteNotifications()
      }
    }
  }
  
  static func registerCustomActions() {
    let accept = UNNotificationAction(
      identifier: ActionIdentifier.accept.rawValue,
      title: "Accept")

    let reject = UNNotificationAction(
      identifier: ActionIdentifier.reject.rawValue,
      title: "Reject")

    let category = UNNotificationCategory(
      identifier: Self.categoryIdentifier,
      actions: [accept, reject],
      intentIdentifiers: [])

    UNUserNotificationCenter.current().setNotificationCategories([category])
  }

}
