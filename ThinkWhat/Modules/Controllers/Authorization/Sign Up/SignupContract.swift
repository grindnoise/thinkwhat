//
//  SignupContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol SignupViewInput: class {
    
    var controllerOutput: SignupControllerOutput? { get set }
    var controllerInput: SignupControllerInput? { get set }
    
    func onProviderAuth(provider: AuthProvider) async throws
    func onSignup(username: String, email: String, password: String, completion: @escaping(Result<Bool,Error>)->())
    func checkCredentials(username: String, email: String, completion: @escaping(Result<Bool,Error>)->())
    func onCaptchaValidation(completion: @escaping(Result<Bool,Error>)->())
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol SignupControllerInput: class {
    
    var modelOutput: SignupModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol SignupModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol SignupControllerOutput: class {
    var viewInput: SignupViewInput? { get set }
    
//    func onSignupFailure(error: Error)
//    func onSignupSuccess()
//    func onCaptchaValidation(completion: @escaping(Result<Bool,Error>)->())
}
