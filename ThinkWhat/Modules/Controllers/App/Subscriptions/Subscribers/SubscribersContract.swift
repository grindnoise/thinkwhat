//
//  SubscribersContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol SubscribersViewInput: class {
    
    var controllerOutput: SubscribersControllerOutput? { get set }
    var controllerInput: SubscribersControllerInput? { get set }
    var userprofiles: [Userprofile] { get }
    var mode: SubscribersController.Mode { get }
    // View input methods here
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol SubscribersControllerInput: class {
    
    var modelOutput: SubscribersModelOutput? { get set }
    var userprofiles: [Userprofile] { get }
    
    func unsubscribe(_: [Userprofile])
    func loadSubscribers()
    func loadSubscriptions()
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol SubscribersModelOutput: class {
    var userprofiles: [Userprofile] { get }
    var mode: SubscribersController.Mode { get }
    
    func onAPIError()
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol SubscribersControllerOutput: class {
    var viewInput: SubscribersViewInput? { get set }
    var unsubscribeList: [Userprofile] { get }
    
    func enableEditing()
    func disableEditing()
    func onAPIError()
    func onSubscribedForUpdated()
}
