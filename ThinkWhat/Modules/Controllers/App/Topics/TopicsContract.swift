//
//  TopicsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol TopicsViewInput: AnyObject {
    
    var controllerOutput: TopicsControllerOutput? { get set }
    var controllerInput: TopicsControllerInput? { get set }
    var mode: TopicsController.Mode { get set }
    
    func openSettings()
    func onSurveyTapped(_: SurveyReference)
    func onDataSourceRequest(dateFilter: Period, topic: Topic)
    func onTopicSelected(_: Topic)
    func updateSurveyStats(_: [SurveyReference])
    func addFavorite(_: SurveyReference)
    func share(_: SurveyReference)
    func claim(surveyReference: SurveyReference, claim: Claim)
    func openUserprofile(_: Userprofile)
    func unsubscribe(from: Userprofile)
    func subscribe(to: Userprofile)
}

protocol TopicsControllerInput: AnyObject {
    
    var modelOutput: TopicsModelOutput? { get set }
    
    func onDataSourceRequest(dateFilter: Period, topic: Topic)
    func search(substring: String, excludedIds: [Int])
    func updateSurveyStats(_: [SurveyReference])
    func addFavorite(surveyReference: SurveyReference)
    func claim(surveyReference: SurveyReference, claim: Claim)
    func unsubscribe(from: Userprofile)
    func subscribe(to: Userprofile)
}

protocol TopicsModelOutput: AnyObject {
//    func onError(_: Error)
    func onSearchCompleted(_: [SurveyReference])
//    func onRequestCompleted(_: Result<Bool, Error>)
}

protocol TopicsControllerOutput: AnyObject {
    var viewInput: (TopicsViewInput & TintColorable)? { get set }
    
    func onDefaultMode(color: UIColor?)
    func onSearchMode()
    func onSearchCompleted(_: [SurveyReference])
//    func onRequestCompleted(_: Result<Bool, Error>)
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
