//
//  ProtocolSubscriptions.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class ProtocolSubscriptions {
    
    final class func subscribe(_ object: NSObject) {
        if object is AppTerminateObservable {
            object.perform(Selector("subscribeAppTerminateObservable"))
        }
        if object is Localizable {
            object.perform(Selector("subscribeLocalizable"))
        }
        if object is Localizable {
            object.perform(Selector("subscribeDataObservable"))
        }
    }
}
