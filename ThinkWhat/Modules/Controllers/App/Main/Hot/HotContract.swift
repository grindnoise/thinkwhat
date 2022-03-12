//
//  HotContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol HotViewInput: class {
    
    var controllerOutput: HotControllerOutput? { get set }
    var controllerInput: HotControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol HotControllerInput: class {
    
    var modelOutput: HotModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol HotModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol HotControllerOutput: class {
    var viewInput: HotViewInput? { get set }
    
    func onDidLayout()
}
