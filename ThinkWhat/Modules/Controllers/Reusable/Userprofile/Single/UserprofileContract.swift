//
//  UserprofileContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol UserprofileViewInput: class {
    
    var controllerOutput: UserprofileControllerOutput? { get set }
    var controllerInput: UserprofileControllerInput? { get set }
    var userprofile: Userprofile { get }
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol UserprofileControllerInput: class {
    
    var modelOutput: UserprofileModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol UserprofileModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol UserprofileControllerOutput: class {
    var viewInput: UserprofileViewInput? { get set }
    
    // Controller output methods here
}
