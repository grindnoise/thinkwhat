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
//    var surveyStack: [Survey] { get set }
    func onReject(_: Survey)
    func onEmptyStack()
    func onVote(survey: Survey)
    func onClaim(survey: Survey, reason: Claim)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol HotControllerInput: class {
    
    var modelOutput: HotModelOutput? { get set }
    func loadSurveys()
    func claim(survey: Survey, reason: Claim)
    func reject(_: Survey)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol HotModelOutput: class {
    func onRequestCompleted()
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol HotControllerOutput: class {
    var viewInput: HotViewInput? { get set }
    
    func onLoad()
    func skipCard()
    func onDidAppear()
    func onDidLayout()
    func populateStack()
}
