//
//  ParentLoginBi.swift
//  SpamGuard
//
//  Created by Pavel Bukharov on 24.12.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class LoginButton: StateButton {
    var authVariant: AuthVariant!
}

protocol AnimationsRemover {
    func removeAllAnimations()
}
