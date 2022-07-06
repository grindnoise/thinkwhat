//
//  ProcessInfo.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

extension ProcessInfo {
    func getValue(_ key: String) -> String? {
        guard ProcessInfo.processInfo.environment.keys.contains(key) else { return nil}
        return ProcessInfo.processInfo.environment[key]
    }
}
