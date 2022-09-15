//
//  SettingsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol SettingsViewInput: AnyObject {
    
    var controllerOutput: SettingsControllerOutput? { get set }
    var controllerInput: SettingsControllerInput? { get set }
    
    func updateUsername(_: [String: String])
    func updateBirthDate(_: Date)
    func updateGender(_: Gender)
    func openCamera()
    func openGallery()
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol SettingsControllerInput: AnyObject {
    
    var modelOutput: SettingsModelOutput? { get set }
    
    func updateUserprofile(parameters: [String: Any], image: UIImage?)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol SettingsModelOutput: AnyObject {
    func onError(_: Error)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol SettingsControllerOutput: AnyObject {
    var viewInput: (SettingsViewInput & UIViewController)? { get set }

    func onError(_: Error)
}
