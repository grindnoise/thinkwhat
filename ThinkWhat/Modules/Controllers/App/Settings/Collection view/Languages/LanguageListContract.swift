//
//  LanguageListContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol LanguageListViewInput: class {
    
    var controllerOutput: LanguageListControllerOutput? { get set }
    var controllerInput: LanguageListControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol LanguageListControllerInput: class {
    
    var modelOutput: LanguageListModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol LanguageListModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol LanguageListControllerOutput: class {
    var viewInput: LanguageListViewInput? { get set }
    
    // Controller output methods here
}
