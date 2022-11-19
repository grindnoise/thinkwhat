//
//  TopicsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol TopicsViewInput: class {
    
    var controllerOutput: TopicsControllerOutput? { get set }
    var controllerInput: TopicsControllerInput? { get set }
    var mode: TopicsController.Mode { get set }
    
    func onSurveyTapped(_: SurveyReference)
    func onDataSourceRequest()
    func onTopicSelected(_: Topic)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol TopicsControllerInput: AnyObject {
    
    var modelOutput: TopicsModelOutput? { get set }
    
    func onDataSourceRequest(_: Topic)
    func search(substring: String, excludedIds: [Int])
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol TopicsModelOutput: AnyObject {
//    func onError(_: Error)
    func onSearchCompleted(_: [SurveyReference])
    func onRequestCompleted(_: Result<Bool, Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol TopicsControllerOutput: AnyObject {
    var viewInput: (TopicsViewInput & UIViewController)? { get set }
    
    func onDefaultMode()
    func onSearchMode()
    func onSearchCompleted(_: [SurveyReference])
    func onRequestCompleted(_: Result<Bool, Error>)
//    func onTopicMode(_: Topic)
    func beginSearchRefreshing()
//    var topic: Topic? { get }
    
//    func onDidLayout()
//    func onWillAppear()
//    func onParentMode()
//    func onChildMode()
    
//    func onListToChildMode()
//    func onSearchToParentMode()
//    func onError()
}
