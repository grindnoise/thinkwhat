//
//  PollContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol PollViewInput: AnyObject {
    
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
    func onImageTapped(mediafile: Mediafile)
    func onURLTapped(_: URL)
    func onExitWithSkip()
//    func onVotersTapped(answer: Answer, indexPath: IndexPath, color: UIColor)
    func onVotersTapped(answer: Answer, color: UIColor)
    func postComment(_: String, replyTo: Comment?)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol PollControllerInput: AnyObject {
    
    var modelOutput: PollModelOutput? { get set }
    var survey: Survey? { get }
    
    func loadPoll(_: SurveyReference, incrementViewCounter: Bool)
    func addFavorite(_: Bool)
    func claim(_: Claim)
    func vote(_: Answer)
    func addView()
    func updateResultsStats(_: SurveyReference)
    func postComment(_: String, replyTo: Comment?)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol PollModelOutput: AnyObject {
    var survey: Survey? { get }
    
    func onLoadCallback(_: Result<Bool, Error>)
    func onAddFavoriteCallback(_: Result<Bool,Error>)
    func onVoteCallback(_: Result<Bool,Error>)
    func onClaimCallback(_: Result<Bool,Error>)
    func commentPostCallback(_: Result<Comment,Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol PollControllerOutput: AnyObject {
    var viewInput: (PollViewInput & UIViewController)? { get set }
    var survey: Survey? { get }
    var surveyReference: SurveyReference { get }
//    var hasVoted: Bool { get }
//    var showNext: Bool { get }
    var mode: PollController.Mode { get }
//    @Published var lastContentOffsetY: CGFloat { get }
    var scrollOffsetPublisher: Published<CGFloat>.Publisher { get }
    
//    func onSurveyLoaded()
    func onLoadCallback()
    func onVoteCallback(_: Result<Bool,Error>)
    func onClaimCallback(_: Result<Bool,Error>)
//    func startLoading()
    func onAddFavoriteCallback()
}
