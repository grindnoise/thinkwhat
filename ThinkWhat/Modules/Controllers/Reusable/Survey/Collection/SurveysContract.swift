//
//  SurveysContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol SurveysViewInput: AnyObject {
    
    var controllerOutput: SurveysControllerOutput? { get set }
    var controllerInput: SurveysControllerInput? { get set }
    var mode: Survey.SurveyCategory { get }
    var topic: Topic? { get }
    
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
protocol SurveysControllerInput: AnyObject {
    
    var modelOutput: SurveysModelOutput? { get set }
    
    func onDataSourceRequest(source: Survey.SurveyCategory, topic: Topic?)
    func updateSurveyStats(_: [SurveyReference])
    func addFavorite(surveyReference: SurveyReference)
    func claim(surveyReference: SurveyReference, claim: Claim)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol SurveysModelOutput: AnyObject {
    func onRequestCompleted(_: Result<Bool, Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol SurveysControllerOutput: AnyObject {
    var viewInput: SurveysViewInput? { get set }
    
    func onRequestCompleted(_: Result<Bool, Error>)
}
