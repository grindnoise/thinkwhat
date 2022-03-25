//
//  ListContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol ListViewInput: class {
    
    var controllerOutput: ListControllerOutput? { get set }
    var controllerInput: ListControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol ListControllerInput: class {
    
    var modelOutput: ListModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol ListModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol ListControllerOutput: class {
    var viewInput: ListViewInput? { get set }
    
    func onDidLayout()
}
