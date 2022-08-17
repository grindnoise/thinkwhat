//
//  ListContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol ListViewInput: class {
    
    var controllerOutput: ListControllerOutput? { get set }
    var controllerInput: ListControllerInput? { get set }
    var surveyCategory: Survey.SurveyCategory { get }
    
    func onSurveyTapped(_: SurveyReference)
    func onDataSourceRequest()
    func updateSurveyStats(_: [SurveyReference])
    func addFavorite(_: SurveyReference)
    func share(_: SurveyReference)
    func claim(_: SurveyReference)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol ListControllerInput: class {
    
    var modelOutput: ListModelOutput? { get set }
    
    func onDataSourceRequest()
    func updateSurveyStats(_: [SurveyReference])
    func addFavorite(surveyReference: SurveyReference)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol ListModelOutput: class {
    // Model output methods here
    var surveyCategory: Survey.SurveyCategory { get }
    
    func onRequestCompleted(_: Result<Bool, Error>)
    func onAddFavoriteCallback(_: Result<Bool,Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol ListControllerOutput: class {
    var viewInput: ListViewInput? { get set }
    
    func onDidLayout()
    func onDidLoad()
    func onDataSourceChanged()
    func onRequestCompleted(_: Result<Bool, Error>)
    func onAddFavoriteCallback(_: Result<Bool,Error>)
}
