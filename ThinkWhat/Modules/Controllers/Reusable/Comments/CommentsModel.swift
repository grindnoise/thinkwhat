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
        guard let survey = replyTo?.replyTo?.survey?.reference else { return }
        Task {
            do {
                let _ = try await API.shared.surveys.postComment(body, survey: survey, replyTo: replyTo, username: username)
            } catch {
                await MainActor.run {
                    modelOutput?.commentPostFailure()
                }
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
    
    func requestComments(rootComment: Comment, exclude: [Comment]) {
        Task {
            do {
                try await API.shared.surveys.requestChildComments(rootComment: rootComment, excludedComments: exclude)
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
}
