//
//  SurveysContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol SurveysViewInput: AnyObject {
    
    var controllerOutput: SurveysControllerOutput? { get set }
    var controllerInput: SurveysControllerInput? { get set }
    var topic: Topic { get }
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol SurveysControllerInput: AnyObject {
    
    var modelOutput: SurveysModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol SurveysModelOutput: AnyObject {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol SurveysControllerOutput: AnyObject {
    var viewInput: SurveysViewInput? { get set }
    
    // Controller output methods here
}
