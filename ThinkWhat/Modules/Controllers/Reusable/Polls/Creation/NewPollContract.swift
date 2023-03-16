//
//  NewPollContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol NewPollViewInput: class {
    
    var controllerOutput: NewPollControllerOutput? { get set }
    var controllerInput: NewPollControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol NewPollControllerInput: class {
    
    var modelOutput: NewPollModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol NewPollModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol NewPollControllerOutput: class {
    var viewInput: NewPollViewInput? { get set }
    
    // Controller output methods here
}
