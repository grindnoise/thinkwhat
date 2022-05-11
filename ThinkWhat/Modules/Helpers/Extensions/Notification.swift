//
//  Notification.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

extension Notification {
    static func send(names: [NSNotification.Name]) {
        names.forEach { NotificationCenter.default.post(name: $0, object: nil) }
    }
}
