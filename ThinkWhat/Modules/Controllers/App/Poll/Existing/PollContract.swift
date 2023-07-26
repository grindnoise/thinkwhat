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
  var item: SurveyReference! { get }
  var mode: PollController.Mode { get }
  
  func openUserprofile()
  func openURL(_: URL)
//  func answerSelected(_: Answer)
  
  func onCommentClaim(comment: Comment, reason: Claim)
  func onAddFavorite(_: Bool)
  func vote(_: Answer)
  func post()
  
  func onExitWithSkip()
  func showVoters(for: Answer)
  func postComment(body: String, replyTo: Comment?, username: String?)
  func requestComments(_: [Comment])
  func updateCommentsStats(_: [Comment])
  func openCommentThread(_: Comment)
  func deleteComment(_: Comment)
}

protocol PollControllerInput: AnyObject {
  
  var modelOutput: PollModelOutput? { get set }
  var item: SurveyReference? { get }
  
  func claim(_: [SurveyReference :Claim])
  func load(_: SurveyReference, incrementViewCounter: Bool)
  func load(_: String)
  func toggleFavorite(_: Bool)
  func vote(_: Answer)
  func post(_: Survey)
  func incrementViewCounter()
  func updateResultsStats(_: Survey)
  func postComment(body: String, replyTo: Comment?, username: String?)
  func updateCommentsStats(_: [Comment])
  func updateSurveyState(_: SurveyReference)
  func commentClaim(comment: Comment, reason: Claim)
  func requestComments(_:[Comment])
  func deleteComment(_:Comment)
}

protocol PollModelOutput: AnyObject {
  var item: SurveyReference! { get }
  
  func postCallback(_: Result<Bool, Error>)
  func loadCallback(_: Result<Survey, Error>)
  func voteCallback(_: Result<Bool, Error>)
  func favoriteCallback(_: Result<Bool, Error>)
  func commentPostCallback(_: Result<Comment, Error>)
  func commentDeleteError()
}

protocol PollControllerOutput: AnyObject {
  var viewInput: (PollViewInput & UIViewController)? { get set }
  var item: Survey? { get set }
  
  func presentView(_: Survey)
  func postCallback(_ result: Result<Bool, Error>)
  func loadCallback(_: Result<Bool, Error>)
  func voteCallback(_: Result<Bool, Error>)
  func commentPostCallback(_: Result<Comment, Error>)
  func commentDeleteError()
}
