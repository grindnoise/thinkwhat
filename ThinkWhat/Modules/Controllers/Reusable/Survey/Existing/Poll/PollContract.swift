//
//  PollContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

protocol PollViewInput: AnyObject {
    
    var controllerOutput: PollControllerOutput? { get set }
    var controllerInput: PollControllerInput? { get set }
    var item: SurveyReference { get }
    
    func onClaim(_: Claim)
    func onCommentClaim(comment: Comment, reason: Claim)
    func onAddFavorite(_: Bool)
    func onVote(_: Answer)
    func onURLTapped(_: URL)
    func onExitWithSkip()
    func onVotersTapped(answer: Answer)
    func postComment(body: String, replyTo: Comment?, username: String?)
    func requestComments(_:[Comment])
    func openCommentThread(_: Comment)
    func deleteComment(_:Comment)
}

protocol PollControllerInput: AnyObject {
    
    var modelOutput: PollModelOutput? { get set }
    var item: SurveyReference? { get }
    
    func load(_: SurveyReference, incrementViewCounter: Bool)
    func toggleFavorite(_: Bool)
    func claim(_: Claim)
    func vote(_: Answer)
    func addView()
    func updateResultsStats(_: SurveyReference)
    func postComment(body: String, replyTo: Comment?, username: String?)
    func commentClaim(comment: Comment, reason: Claim)
    func requestComments(_:[Comment])
    func deleteComment(_:Comment)
}

protocol PollModelOutput: AnyObject {
    var item: SurveyReference { get }
    
    func onLoadCallback(_: Result<Bool, Error>)
    func onAddFavoriteCallback(_: Result<Bool, Error>)
    func onVoteCallback(_: Result<Bool, Error>)
    func commentPostCallback(_: Result<Comment, Error>)
    func commentDeleteError()
}

protocol PollControllerOutput: AnyObject {
    var viewInput: (PollViewInput & UIViewController)? { get set }
    var item: Survey? { get set }
    
    func presentView(_: Survey)
    func onLoadCallback(_: Result<Bool, Error>)
    func onVoteCallback(_: Result<Bool, Error>)
    func commentPostCallback(_: Result<Comment, Error>)
    func commentDeleteError()
}
