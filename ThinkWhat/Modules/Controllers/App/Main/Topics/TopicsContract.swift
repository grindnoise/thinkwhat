//
//  TopicsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol TopicsViewInput: class {
    
    var controllerOutput: TopicsControllerOutput? { get set }
    var controllerInput: TopicsControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol TopicsControllerInput: class {
    
    var modelOutput: TopicsModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol TopicsModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol TopicsControllerOutput: class {
    var viewInput: TopicsViewInput? { get set }
    
    func onDidLayout()
}
