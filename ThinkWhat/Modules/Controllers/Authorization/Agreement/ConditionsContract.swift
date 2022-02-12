//
//  AgreementContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol ConditionsViewInput: class {
    
    var controllerOutput: ConditionsControllerOutput? { get set }
    var controllerInput: ConditionsControllerInput? { get set }
    func onAcceptTappedWithSuccess()
    func onAcceptTappedWithError()
    func onAcceptTappedWhileLoading()
//    func onViewInit()
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol ConditionsControllerOutput: class {
    var viewInput: ConditionsViewInput? { get set }
    func getTermsConditionsURL(_: URL)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol ConditionsControllerInput: class {
    
    var modelOutput: ConditionsModelOutput? { get set }
    func getTermsConditionsURL()
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol ConditionsModelOutput: class {
    // Model output methods here
    func onTermsConditionsURLReceived(_: URL)
}
