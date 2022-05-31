//
//  PollCreationContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol PollCreationViewInput: class {
    
    var controllerOutput: PollCreationControllerOutput? { get set }
    var controllerInput: PollCreationControllerInput? { get set }
    
    
    func onStageCompleted()
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol PollCreationControllerInput: class {
    
    var modelOutput: PollCreationModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol PollCreationModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol PollCreationControllerOutput: class {
    var viewInput: PollCreationViewInput? { get set }
    
    func onNextStage(_: PollCreationController.Stage)
}
