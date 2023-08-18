//
//  CommentsModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class CommentsModel {
  weak var modelOutput: CommentsModelOutput?
}

// MARK: - Controller Input
extension CommentsModel: CommentsControllerInput {
  func makeComplaint(_ complaint: [Comment: Claim]) {
    
  }
  
  func updateCommentsAndGetNew(mode: CommentsCollectionView.Mode, excludeList: [Int], updateList: [Int]) {
    guard let thread = modelOutput?.item else { return }
    
    Task {
      do {
        try await API.shared.surveys.getCommentsSurveyStateCommentsUpdates(surveyId: thread.surveyId,
                                                                           threadId: thread.id,
                                                                           excludeComments: excludeList,
                                                                           commentsToUpdate: updateList)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func deleteComment(_ comment: Comment) {
    Task {
      do {
        try await API.shared.surveys.deleteComment(comment: comment)
      } catch {
        await MainActor.run {
          modelOutput?.commentDeleteError()
        }
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func postClaim(comment: Comment, reason: Claim) {
    Task {
      do {
        try await API.shared.surveys.claimComment(comment: comment, reason: reason)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func postComment(body: String, replyTo: Comment?, username: String?) {
    guard let survey = replyTo?.survey?.reference else { return }
    
    Task {
      do {
        let instance = try await API.shared.surveys.postComment(body,
                                                 survey: survey,
                                                 replyTo: replyTo, username: username)
        await MainActor.run { modelOutput?.commentPostCallback(.success(instance)) }
      } catch {
        await MainActor.run { modelOutput?.commentPostCallback(.failure(error)) }
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func getComments(rootComment: Comment, excludeList: [Int], includeList: [Int]) {
    Task {
      do {
        try await API.shared.surveys.getThreadComments(threadId: String(describing: rootComment.id),
                                                       excludeList: excludeList.map { String(describing: $0) },
                                                       includeList: includeList.map { String(describing: $0) })
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func getReply(threadId: Int, replyId: Int) {
    Task {
      do {
        try await API.shared.surveys.getThreadComments(threadId: String(describing: threadId),
                                                       excludeList: Comments.shared.all.filter({ $0.parentId == threadId }).map { String(describing: $0.id) },
                                                       includeList: [String(describing: replyId)],
                                                       includeSelf: false)
        await MainActor.run { modelOutput?.getReplyCallback(.success(Comments.shared.all.filter({ $0.id == threadId }).first )) }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        await MainActor.run { modelOutput?.getReplyCallback(.failure(error)) }
      }
    }
  }
  
  func loadThread(root: Comment) {
    Task {
      do {
        try await API.shared.surveys.getThreadComments(threadId: String(describing: root.id),
                                                       excludeList: Comments.shared.all.filter({ $0.parent == root }).map { String(describing: $0.id) },
                                                       includeList: [],
                                                       includeSelf: false)
//        await MainActor.run { modelOutput?.loadThreadCallback(.success(())) }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
//        await MainActor.run { modelOutput?.loadThreadCallback(.failure(error)) }
      }
    }
  }
}
