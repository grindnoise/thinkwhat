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
protocol SubscriptionsViewInput: AnyObject {
    var controllerOutput: SubsciptionsControllerOutput? { get set }
    var controllerInput: SubsciptionsControllerInput? { get set }
    
    func onSubscribersTapped()
    func onSubscpitionsTapped()
    func toggleBarButton()
    func onSurveyTapped(_: SurveyReference)
    func onDataSourceRequest(source: Survey.SurveyCategory, topic: Topic?)
    func updateSurveyStats(_: [SurveyReference])
    func addFavorite(_: SurveyReference)
    func share(_: SurveyReference)
    func claim(surveyReference: SurveyReference, claim: Claim)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol SubsciptionsControllerInput: AnyObject {
    var modelOutput: SubsciptionsModelOutput? { get set }
    
    func onDataSourceRequest(source: Survey.SurveyCategory, topic: Topic?)
    func updateSurveyStats(_: [SurveyReference])
    func addFavorite(surveyReference: SurveyReference)
    func claim(surveyReference: SurveyReference, claim: Claim)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol SubsciptionsModelOutput: AnyObject {
    func onRequestCompleted(_: Result<Bool, Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol SubsciptionsControllerOutput: AnyObject {
    var viewInput: SubscriptionsViewInput? { get set }
    
    func onUpperContainerShown(_: Bool)
    func onWillAppear()
    func onRequestCompleted(_: Result<Bool, Error>)
}
