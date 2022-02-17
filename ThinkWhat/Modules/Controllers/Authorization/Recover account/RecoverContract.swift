//
//  RecoverContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol RecoverViewInput: class {
    
    var controllerOutput: RecoverControllerOutput? { get set }
    var controllerInput: RecoverControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol RecoverControllerInput: class {
    
    var modelOutput: RecoverModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol RecoverModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol RecoverControllerOutput: class {
    var viewInput: RecoverViewInput? { get set }
    
    // Controller output methods here
}
