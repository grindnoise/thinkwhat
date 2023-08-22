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
//  func updateComments(excludeList: [Comment])
//  func updateCommentsStats(_: [Comment])
  func openCommentThread(root: Comment, reply: Comment?, shouldRequest: Bool, _ completion: Closure?)
  func deleteComment(_: Comment)
  func reportComment(_:Comment)
}

protocol PollControllerInput: AnyObject {
  
  var modelOutput: PollModelOutput? { get set }
  var item: SurveyReference? { get }
  
  func claim(_: [SurveyReference :Claim])
  func load(_: SurveyReference, incrementViewCounter: Bool)
  func loadSurvey(_: Int)
  func loadThread(root: Comment, includeList: [Int], threshold: Int)
  func loadThread(threadId: Int, excludeList: [Int], includeList: [Int], includeSelf: Bool, threshold: Int)
  func loadSurveyAndThread(surveyId: Int, threadId: Int, includeList: [Int], threshold: Int)
  func toggleFavorite(_: Bool)
  func vote(_: Answer)
  func post(_: Survey)
  func incrementViewCounter()
  func getCommentsSurveyStateCommentsUpdates(_: Survey)
  func postComment(body: String, replyTo: Comment?, username: String?)
  func updateSurveyStats(_: [SurveyReference])
  func deleteComment(_:Comment)
  func reportComment(comment: Comment, reason: Claim)
}

protocol PollModelOutput: AnyObject {
  var item: SurveyReference! { get }
  
  func postCallback(_: Result<Bool, Error>)
  func loadCallback(_: Result<Survey, Error>)
  func loadThreadCallback(_: Result<Comment?, Error>)
  func loadSurveyAndThreadCallback(_: Result<Survey, Error>)
  func voteCallback(_: Result<Bool, Error>)
  func favoriteCallback(_: Result<Bool, Error>)
  func commentPostCallback(_: Result<Comment, Error>)
  func commentDeleteError()
  func commentReportError()
}

protocol PollControllerOutput: AnyObject {
  var viewInput: (PollViewInput & UIViewController)? { get set }
  var item: Survey? { get set }
  
  func showCongratulations()
  func presentView(item: Survey, animated: Bool)
  func postCallback(_ result: Result<Bool, Error>)
  func loadCallback(_: Result<Bool, Error>)
  func voteCallback(_: Result<Bool, Error>)
  func commentPostCallback(_: Result<Comment, Error>)
  func commentDeleteError()
  func setBanned(_ completion: @escaping () -> ())
}
