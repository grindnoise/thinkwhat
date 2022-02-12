//
//  _LoginContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol LoginViewInput: class {
    
    var controllerOutput: LoginControllerOutput? { get set }
    var controllerInput: LoginControllerInput? { get set }
    
    func onIncorrectFields()
    func onLogin(username: String, password: String)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol LoginControllerInput: class {
    
    var modelOutput: LoginModelOutput? { get set }
    func performLogin(username: String, password: String)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol LoginModelOutput: class {
    func onError(_: Error)
    func onSuccess()
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol LoginControllerOutput: class {
    var viewInput: LoginViewInput? { get set }
    func onError(_: Error)
    func onSuccess()
}
