//
//  NotificationService.swift
//  Push service extension
//
//  Created by Pavel Bukharov on 08.06.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UserNotifications

//struct ROT13 {
//  static let shared = ROT13()
//
//  private let upper = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
//  private let lower = Array("abcdefghijklmnopqrstuvwxyz")
//  private var mapped: [Character: Character] = [:]
//
//  private init() {
//    for i in 0 ..< 26 {
//      let idx = (i + 13) % 26
//      mapped[upper[i]] = upper[idx]
//      mapped[lower[i]] = lower[idx]
//    }
//  }
//
//  public func decrypt(_ str: String) -> String {
//    return String(str.map { mapped[$0] ?? $0 })
//  }
//}

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
      bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

      guard let bestAttemptContent else {
        return
      }
      
//      bestAttemptContent.title = ROT13.shared.decrypt(bestAttemptContent.title)
//      bestAttemptContent.body = ROT13.shared.decrypt(bestAttemptContent.body)

      if let increment = bestAttemptContent.badge as? Int {
        if increment == 0 {
          UserDefaults.extensions.badge = 0
          bestAttemptContent.badge = 0
        } else {
          let current = UserDefaults.extensions.badge
          let new = current + increment

          UserDefaults.extensions.badge = new
          bestAttemptContent.badge = NSNumber(value: new)
        }
      }

      contentHandler(bestAttemptContent)
//
//      guard
//        let urlPath = request.content.userInfo["media-url"] as? String,
//        let url = URL(string: ROT13.shared.decrypt(urlPath))
//      else {
//        contentHandler(bestAttemptContent)
//        return
//      }
//
//      Task {
//        defer { contentHandler(bestAttemptContent) }
//
//        do {
//          let (data, response) = try await URLSession.shared.data(from: url)
//          let file = response.suggestedFilename ?? url.lastPathComponent
//          let destination = URL(fileURLWithPath: NSTemporaryDirectory())
//            .appendingPathComponent(file)
//          try data.write(to: destination)
//
//          let attachment = try UNNotificationAttachment(identifier: "", url: destination)
//          bestAttemptContent.attachments = [attachment]
//          contentHandler(bestAttemptContent)
//        } catch {
//          print("An error occurred.")
//        }
//      }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
