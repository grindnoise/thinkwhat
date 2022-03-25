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
protocol SettingsViewInput: class {
    
    var controllerOutput: SettingsControllerOutput? { get set }
    var controllerInput: SettingsControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol SettingsControllerInput: class {
    
    var modelOutput: SettingsModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol SettingsModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol SettingsControllerOutput: class {
    var viewInput: SettingsViewInput? { get set }
    
    func onDidLayout()
}
