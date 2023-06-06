//
//  PushToken.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

struct PushNotificationToken {
  private let encoder = JSONEncoder()

  let token: String
  let debug: Bool
  let language: String

  init(token: Data) {
    self.token = token.reduce("") { $0 + String(format: "%02x", $1) }
    language = Locale.preferredLanguages[0]

  #if DEBUG
    encoder.outputFormatting = .prettyPrinted
    debug = true
    print(String(describing: self))
  #else
    debug = false
  #endif
  }

  func encoded() -> Data {
    return try! encoder.encode(self)
  }
}

extension PushNotificationToken: Encodable {
  private enum CodingKeys: CodingKey {
    case token, debug, language
  }
}

extension PushNotificationToken: CustomStringConvertible {
  var description: String {
    return String(data: encoded(), encoding: .utf8) ?? "Invalid token"
  }
}

extension PushNotificationToken: Equatable {
  static func == (lhs: PushNotificationToken, rhs: PushNotificationToken) -> Bool {
    lhs.token == rhs.token
  }
}
