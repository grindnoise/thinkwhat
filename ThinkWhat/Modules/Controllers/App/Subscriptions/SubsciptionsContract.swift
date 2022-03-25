//
//  SubsciptionsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol SubsciptionsViewInput: class {
    
    var controllerOutput: SubsciptionsControllerOutput? { get set }
    var controllerInput: SubsciptionsControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol SubsciptionsControllerInput: class {
    
    var modelOutput: SubsciptionsModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol SubsciptionsModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol SubsciptionsControllerOutput: class {
    var viewInput: SubsciptionsViewInput? { get set }
    
    func onDidLayout()
}
