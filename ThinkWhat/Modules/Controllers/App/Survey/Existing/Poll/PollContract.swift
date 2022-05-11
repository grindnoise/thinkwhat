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
    var surveyReference: SurveyReference { get }
    var showNext: Bool { get }
    var mode: PollController.Mode { get }
    
    func onClaim(_: Claim)
    func onAddFavorite(_: Bool)
    func onVote(_: Answer)
    func onImageTapped(image: UIImage, title: String)
    func onURLTapped(_: URL)
    func onExitWithSkip()
    func onVotersTapped(answer: Answer, indexPath: IndexPath, color: UIColor)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol PollControllerInput: class {
    
    var modelOutput: PollModelOutput? { get set }
    var survey: Survey? { get }
    
    func loadPoll(_: SurveyReference, incrementViewCounter: Bool)
    func addFavorite(_: Bool)
    func claim(_: Claim)
    func vote(_: Answer)
    func addView()
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol PollModelOutput: class {
    var survey: Survey? { get }
    
    func onLoadCallback(_: Result<Bool, Error>)
    func onCountUpdateCallback(_: Result<Bool,Error>)
    func onAddFavoriteCallback(_: Result<Bool,Error>)
    func onVoteCallback(_: Result<Bool,Error>)
    func onClaimCallback(_: Result<Bool,Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol PollControllerOutput: class {
    var viewInput: PollViewInput? { get set }
    var survey: Survey? { get }
    var surveyReference: SurveyReference { get }
    var hasVoted: Bool { get }
    var showNext: Bool { get }
    var mode: PollController.Mode { get }
    
    func onLoad(_: Result<Bool, Error>)
    func onCountUpdated()
    func onVote(_: Result<Bool,Error>)
    func onClaim(_: Result<Bool,Error>)
    func startLoading()
    func onAddFavorite()
}
