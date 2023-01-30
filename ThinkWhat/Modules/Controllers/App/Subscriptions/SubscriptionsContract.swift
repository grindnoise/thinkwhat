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
  var isOnScreen: Bool { get }
  
  func onSubscribersTapped()
  func onSubscpitionsTapped()
  //    func toggleBarButton()
  func onSurveyTapped(_: SurveyReference)
  func onDataSourceRequest(source: Survey.SurveyCategory, dateFilter: Period?, topic: Topic?, userprofile: Userprofile?)
  func updateSurveyStats(_: [SurveyReference])
  func addFavorite(_: SurveyReference)
  func share(_: SurveyReference)
  func claim(surveyReference: SurveyReference, claim: Claim)
  func setUserprofileFilter(_: Userprofile)
  func openUserprofile(_: Userprofile)
  func unsubscribe(from: Userprofile)
  func onAllUsersTapped(mode: UserprofilesViewMode)
  func onSubcriptionsCountEvent(zeroSubscriptions: Bool)
  func setDefaultMode()
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol SubsciptionsControllerInput: AnyObject {
  var modelOutput: SubsciptionsModelOutput? { get set }
  
  func onDataSourceRequest(source: Survey.SurveyCategory, dateFilter: Period?, topic: Topic?, userprofile: Userprofile?)
  func updateSurveyStats(_: [SurveyReference])
  func addFavorite(surveyReference: SurveyReference)
  func claim(surveyReference: SurveyReference, claim: Claim)
  func switchNotifications(userprofile: Userprofile, notify: Bool)
  func unsubscribe(from: Userprofile)
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
  var viewInput: (SubscriptionsViewInput & TintColorable)? { get set }
  
  func onWillAppear()
  func onRequestCompleted(_: Result<Bool, Error>)
  func hideUserCard(_: Closure?)
}
