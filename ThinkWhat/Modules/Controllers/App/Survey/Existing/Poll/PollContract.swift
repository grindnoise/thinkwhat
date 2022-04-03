//
//  PollContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol PollViewInput: class {
    
    var controllerOutput: PollControllerOutput? { get set }
    var controllerInput: PollControllerInput? { get set }
    var survey: Survey? { get }
    
    func onClaim()
    func onAddFavorite(_: Bool)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol PollControllerInput: class {
    
    var modelOutput: PollModelOutput? { get set }
    var survey: Survey? { get }
    
    func loadSurvey()
    func addFavorite(_: Bool)
    func claim()
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol PollModelOutput: class {
    var survey: Survey? { get }
    
    func onLoad(_: Result<Bool, Error>)
    func onCountUpdated()
    func onAddFavorite(_: Result<Bool,Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol PollControllerOutput: class {
    var viewInput: PollViewInput? { get set }
    var survey: Survey? { get }
    
    func onLoad(_: Result<Bool, Error>)
    func onCountUpdated()
}
