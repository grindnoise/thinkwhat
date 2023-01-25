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
    func onDataSourceRequest(source: Survey.SurveyCategory, dateFilter: Period?, topic: Topic?)
    func updateSurveyStats(_: [SurveyReference])
    func addFavorite(_: SurveyReference)
    func share(_: SurveyReference)
    func claim(surveyReference: SurveyReference, claim: Claim)
    func openUserprofile(_: Userprofile)
    func unsubscribe(from: Userprofile)
    func subscribe(to: Userprofile)
}

protocol SurveysControllerInput: AnyObject {
    
    var modelOutput: SurveysModelOutput? { get set }
    
    func onDataSourceRequest(source: Survey.SurveyCategory, dateFilter: Period?, topic: Topic?)
    func updateSurveyStats(_: [SurveyReference])
    func addFavorite(surveyReference: SurveyReference)
    func claim(surveyReference: SurveyReference, claim: Claim)
    func unsubscribe(from: Userprofile)
    func subscribe(to: Userprofile)
}

protocol SurveysModelOutput: AnyObject {
    func onRequestCompleted(_: Result<Bool, Error>)
}

protocol SurveysControllerOutput: AnyObject {
    var viewInput: SurveysViewInput? { get set }
    
    func onRequestCompleted(_: Result<Bool, Error>)
  func viewDidDisappear()
}
