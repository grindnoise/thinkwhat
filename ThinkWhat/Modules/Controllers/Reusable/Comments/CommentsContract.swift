//
//  CommentsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol CommentsViewInput: AnyObject {
  
  var controllerOutput: CommentsControllerOutput? { get set }
  var controllerInput: CommentsControllerInput? { get set }
  var survey: Survey? { get }
  var item: Comment { get }
  var reply: Comment? { get } // Used to focus on new reply
  
  func getComments(excludeList: [Int], includeList: [Int])
  func updateCommentsAndGetNew(mode: CommentsCollectionView.Mode, excludeList: [Int], updateList: [Int])
  func postComment(body: String, replyTo: Comment?, username: String?)
  func postClaim(comment: Comment, reason: Claim)
  func deleteComment(_:Comment)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol CommentsControllerInput: AnyObject {
  
  var modelOutput: CommentsModelOutput? { get set }
  
  func updateCommentsAndGetNew(mode: CommentsCollectionView.Mode, excludeList: [Int], updateList: [Int])
  func getComments(rootComment: Comment, excludeList: [Int], includeList: [Int])
  func postComment(body: String, replyTo: Comment?, username: String?)
  func postClaim(comment: Comment, reason: Claim)
  func deleteComment(_:Comment)
  func loadThread(root: Comment)
  func getReply(threadId: Int, replyId: Int)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol CommentsModelOutput: AnyObject {
  var survey: Survey? { get }
  
  func commentPostFailure()
  func commentDeleteError()
  func getReplyCallback(_: Result<Comment?, Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol CommentsControllerOutput: AnyObject {
  var viewInput: CommentsViewInput? { get set }
  
  func focusOnReply(_: Comment)
  func commentPostFailure()
  func commentDeleteError()
}
