//
//  Errors.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.10.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

enum AppError: Error {
  case apiNotSupported
  case webContent
  case tikTokContent
  case imageDownload
  case invalidURL
  case server
  case maximumImages
  case maximumCharactersExceeded(maxValue: Int)
  case minimumCharactersExceeded(minValue: Int)
  case minimumChoices
  case minimumLimits
  case insufficientBalance
}

extension AppError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .webContent:
      return "web".localized
    case .tikTokContent:
      return "tiktok_web_error".localized
    case .imageDownload:
      return "image_loading_error".localized
    case .server:
      return "backend_error".localized
    case .maximumCharactersExceeded(let maxValue):
      return "maximum_characters_exceeded".localized + String(describing: maxValue)
    case .minimumCharactersExceeded(let minValue):
      return "minimum_characters_needed".localized + String(describing: minValue)
    case .invalidURL:
      return "invalid_url".localized
    case .maximumImages:
      return "images_limit".localized
    case .minimumChoices:
      return "minimum_choices".localized
    case .minimumLimits:
      return "minimum_limits".localized
    case .insufficientBalance:
      return "insufficient_balance".localized
    case .apiNotSupported:
      return "api_not_supported".localized
    }
  }
}

enum APIError: Error {
  case httpStatusCodeMissing
  case apiUnreachable
  case invalidPassword
  case notFound
  case invalidURL
  case badImage
  case badData
  case unexpected(code: Int)
  case backend(code: Int, value: Any?)
//  case backendDict(code: Int, value: [String: Any])
}

extension APIError {
  var isFatal: Bool {
    if case APIError.unexpected = self { return true }
    else { return false }
  }
}

extension APIError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .httpStatusCodeMissing:
      return NSLocalizedString(
        "HTTP status code is missing.",
        comment: "Server Response Error"
      )
    case .apiUnreachable:
      return NSLocalizedString(
        "Server is not reachable.",
        comment: "API is Unreachable"
      )
    case .invalidPassword:
      return NSLocalizedString(
        "The provided password is not valid.",
        comment: "Invalid Password"
      )
    case .notFound:
      return NSLocalizedString(
        "The specified item could not be found.",
        comment: "Resource Not Found"
      )
    case .unexpected(let code):
      return NSLocalizedString(
        "Error code \(code)",
        comment: "Unexpected Error"
      )
    case .invalidURL:
      return NSLocalizedString(
        "Error occured while requesting URL",
        comment: "Invalid URL"
      )
    case .badImage:
      return NSLocalizedString(
        "Can't compose image from data",
        comment: "Image error"
      )
    case .badData:
      return NSLocalizedString(
        "Can't resolve data",
        comment: "Data error"
      )
    case let .backend(_/*code*/, value):
      var errorDescription = ""
      var comment = "Server error"
      
      if let json = value as? JSON {
        if let error = json["error"].string,
           error == "invalid_grant" {
          errorDescription = "log_in_error".localized
        } else if let status = json["status"].string,
                  status == "error",
                  let error = json["error"].string {
          
          errorDescription += error.localized
          if error == "insufficient_balance", let shortage = json["shortage"].int {
            errorDescription += "insufficient_balance_shortage".localized + String(describing: abs(shortage)) + "insufficient_balance_shortage_points".localized + ". "  + "insufficient_balance_shortage_hint".localized
          }
        } else if let array = json["email"].array,
                  let first = array.first,
                  let error = first.string,
                  error.contains("We couldn't find an account associated with that email. Please try a different e-mail address.")  {
          errorDescription = "email_not_found".localized
        }
      } else if let string = value as? String {
        errorDescription = string
      }
      
      return NSLocalizedString(
//        "Code \(code): \(errorDescription)",
        errorDescription,
        comment: comment
      )
    }
  }
}
