//
//  BaseError.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 06.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

enum BaseError: Error {
    case unexpected
}

extension BaseError {
    var isFatal: Bool {
        if case BaseError.unexpected = self { return true }
        else { return false }
    }
}
