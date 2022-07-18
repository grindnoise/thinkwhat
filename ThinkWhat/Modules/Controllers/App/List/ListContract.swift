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
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol ListControllerInput: class {
    
    var modelOutput: ListModelOutput? { get set }
    
    func onDataSourceRequest()
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol ListModelOutput: class {
    // Model output methods here
    var surveyCategory: Survey.SurveyCategory { get }
    
    func onError(_: Error)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol ListControllerOutput: class {
    var viewInput: ListViewInput? { get set }
    
    func onDidLayout()
    func onDidLoad()
    func onDataSourceChanged()
    func onError()
}
