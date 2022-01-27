//
//  WelcomeContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol WelcomeViewInput: class {
    func onGetStartedTap()
}

protocol WelcomeControllerOutput: class {
    var controller: WelcomeViewInput? { get set }
}
