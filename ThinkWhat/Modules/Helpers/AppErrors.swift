//
//  AppErrors.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

enum AppError: Error {
    case webContent
    case tikTokContent
    case imageDownload
    case server
    case maximumCharactersExceeded(maxValue: Int)
    case minimumCharactersExceeded(minValue: Int)
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
    case backend(code: Int, description: String?)
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
        case let .backend(code, description):
            return NSLocalizedString(
                "Code \(code): \(String(describing: description))",
                comment: "Server error"
            )
        }
    }
}
