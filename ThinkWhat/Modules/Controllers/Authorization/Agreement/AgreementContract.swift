//
//  AgreementContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol AgreementViewInput: class {
    
    var controllerOutput: AgreementControllerOutput? { get set }
    
    // View input methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol AgreementControllerOutput: class {
    var viewInput: AgreementViewInput? { get set }
    
    // Controller output methods here
}
