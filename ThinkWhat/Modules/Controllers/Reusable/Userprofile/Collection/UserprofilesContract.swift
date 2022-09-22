//
//  UserprofilesContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol UserprofilesViewInput: AnyObject {
    
    var controllerOutput: UserprofilesControllerOutput? { get set }
    var controllerInput: UserprofilesControllerInput? { get set }
    var mode: UserprofilesController.Mode { get }
    var userprofile: Userprofile? { get }
    
    func onUserprofileTap(_: Userprofile)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol UserprofilesControllerInput: AnyObject {
    
    var modelOutput: UserprofilesModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol UserprofilesModelOutput: AnyObject {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol UserprofilesControllerOutput: AnyObject {
    var viewInput: UserprofilesViewInput? { get set }
    
    // Controller output methods here
}
