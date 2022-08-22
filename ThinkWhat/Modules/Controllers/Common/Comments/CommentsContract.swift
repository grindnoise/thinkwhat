//
//  CommentsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol CommentsViewInput: class {
    
    var controllerOutput: CommentsControllerOutput? { get set }
    var controllerInput: CommentsControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol CommentsControllerInput: class {
    
    var modelOutput: CommentsModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol CommentsModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol CommentsControllerOutput: class {
    var viewInput: CommentsViewInput? { get set }
    
    // Controller output methods here
}
