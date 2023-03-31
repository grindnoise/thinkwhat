//
//  RankingCreationContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol RankingCreationViewInput: class {
    
    var controllerOutput: RankingCreationControllerOutput? { get set }
    var controllerInput: RankingCreationControllerInput? { get set }
    
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol RankingCreationControllerInput: class {
    
    var modelOutput: RankingCreationModelOutput? { get set }
    
    // Controller input methods here
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol RankingCreationModelOutput: class {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol RankingCreationControllerOutput: class {
    var viewInput: RankingCreationViewInput? { get set }
    
    // Controller output methods here
}
