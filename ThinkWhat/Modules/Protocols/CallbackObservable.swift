//
//  Protocols.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol CallbackObservable: AnyObject {
    func callbackReceived(_ sender: Any)
}

protocol CallbackCallable: AnyObject {
    var callbackDelegate: CallbackObservable? { get set }
}
