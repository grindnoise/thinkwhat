//
//  PollModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class PollModel {
  
  weak var modelOutput: PollModelOutput?
  var item: SurveyReference? {
    return modelOutput?.item
  }
}

// MARK: - Controller Input
extension PollModel: PollControllerInput {
  func post(_ instance: Survey) {
    Task {
      do {
        try await API.shared.surveys.post(instance.parameters)
        await MainActor.run {
          modelOutput?.postCallback(.success(true))
        }
      } catch {
        await MainActor.run {
          modelOutput?.postCallback(.failure(error))
        }
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func updateSurveyStats(_ instances: [SurveyReference]) {
    Task {
      do {
        try await API.shared.surveys.updateSurveyStats(instances)
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
  
  func commentClaim(comment: Comment, reason: Claim) {
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
  
//  func updateComments(excludeList: [Comment]) {
//    guard let survey = item else { return }
//    
//    Task {
//      do {
//        try await API.shared.surveys.getRootComments(surveyId: String(describing: survey.id),
//                                                     excludeList: excludeList.map { String(describing: $0.id) })
//      } catch {
//#if DEBUG
//        error.printLocalized(class: type(of: self), functionName: #function)
//#endif
//      }
//    }
//  }
  
  func postComment(body: String, replyTo: Comment? = nil, username: String? = nil) {
    guard let survey = item else { return }
    
    Task {
      do {
        let instance = try await API.shared.surveys.postComment(body,
                                                 survey: survey,
                                                 replyTo: replyTo,
                                                 username: username)
        await MainActor.run { modelOutput?.commentPostCallback(.success(instance)) }
      } catch {
        await MainActor.run { modelOutput?.commentPostCallback(.failure(error)) }
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  
  
  func incrementViewCounter() {
    guard let survey = item else { return }
    
    Task {
      do {
        try await API.shared.surveys.incrementViewCounter(surveyReference: survey)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func vote(_ answer: Answer) {
    Task {
      guard let survey = answer.survey else { return }
      do {
        let json = try await API.shared.surveys.vote(answer: answer)
        
        if let current = Userprofiles.shared.current {
          current.answers[answer.surveyID] = answer.id
        }
        
        let resultDetails = SurveyResult(choice: answer)
        for i in json {
          if i.0 == "survey_result" {
            for entity in i.1 {
              guard let answerId = entity.1["answer"].int,
                    let timeString = entity.1["timestamp"].string,
                    let timestamp = Date(dateTimeString: timeString) else { break }
              await MainActor.run {
                answer.survey?.result = [answerId: timestamp]
//                Surveys.shared.hot.remove(object: survey)
                Userprofiles.shared.current!.balance += 1
              }
            }
          } else if i.0 == "popular_vote", let isPopular = i.1.rawValue as? Bool {
            resultDetails.isPopular = isPopular
          } else if i.0 == "points", let points = i.1.int {
            resultDetails.points = points
          } else if i.0 == "hot" && !i.1.isEmpty {
            await MainActor.run {
              try? Surveys.shared.load(i.1)
            }
          } else if i.0 == "result_total" {
            do {
              var totalVotes = 0
              for entity in i.1 {
                guard let dict = entity.1.dictionary,
                      let data = try dict["voters"]?.rawData(),
                      let _answerID = dict["answer"]?.int,
                      let answer = survey.answers.filter({ $0.id == _answerID }).first,
                      let _total = dict["total"]?.int else { break }
                answer.totalVotes = _total
                totalVotes += _total
                
                let instances = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode([Userprofile].self, from: data)
                var voters: [Userprofile] = []

                instances.forEach { instance in voters.append(Userprofiles.shared.all.filter({ $0 == instance }).first ?? instance) }

                answer.appendVoters(voters)
              }
              survey.votesTotal = totalVotes
            } catch let error {
#if DEBUG
              print(error.localizedDescription)
#endif
              await MainActor.run {
                modelOutput?.voteCallback(.failure(error))
              }
              return
            }
          }
        }
        answer.survey?.resultDetails = resultDetails
        answer.survey?.isComplete = true
//        if let current = Userprofiles.shared.current, !answer.voters.contains(current) {
//          answer.voters.append(current)
//        }

        await MainActor.run {
          modelOutput?.voteCallback(.success(true))
        }
      } catch {
        await MainActor.run {
          modelOutput?.voteCallback(.failure(error))
        }
      }
    }
  }
  
  func claim(_ dict: [SurveyReference: Claim]) {
    guard let instance = dict.keys.first,
          let reason = dict.values.first
    else { return }
    
    Task {
      try await API.shared.surveys.claim(surveyReference: instance, reason: reason)
    }
  }
  
  func load(_ reference: SurveyReference, incrementViewCounter: Bool = true) {
    Task {
      do {
        let instance = try await API.shared.surveys.getSurvey(byReference: reference, incrementCounter: incrementViewCounter)
        await MainActor.run { modelOutput?.loadCallback(.success(instance)) }
      } catch {
        await MainActor.run { modelOutput?.loadCallback(.failure(error)) }
      }
    }
  }
  
  func loadSurvey(_ referenceId: Int) {
    Task {
      do {
        let instance = try await API.shared.surveys.getSurvey(byReferenceId: String(referenceId))
        await MainActor.run { modelOutput?.loadCallback(.success(instance)) }
      } catch {
        await MainActor.run { modelOutput?.loadCallback(.failure(error)) }
      }
    }
  }
  
//  func load(surveyId: Int) {
//    Task {
//      do {
//        let instance = try await API.shared.surveys.getSurvey(byReferenceId: String(surveyId))
//        await MainActor.run { modelOutput?.loadCallback(.success(instance)) }
//      } catch {
//        await MainActor.run { modelOutput?.loadCallback(.failure(error)) }
//      }
//    }
//  }
  
  func loadThread(threadId: Int,
                  excludeList: [Int],
                  includeList: [Int],
                  includeSelf: Bool,
                  threshold: Int) {
    Task {
      do {
        try await API.shared.surveys.getThreadComments(threadId: String(threadId),
                                                       excludeList: excludeList.map { String($0) },
                                                       includeSelf: includeSelf,
                                                       threshold: threshold)
        await MainActor.run { modelOutput?.loadThreadCallback(.success(Comments.shared.all.filter({ $0.id == threadId }).first)) }
      } catch {
        await MainActor.run { modelOutput?.loadThreadCallback(.failure(error)) }
      }
    }
  }
  
  func loadThread(root: Comment, includeList: [Int], threshold: Int) {
    Task {
      do {
        try await API.shared.surveys.getThreadComments(threadId: String(describing: root.id),
                                                       excludeList: Comments.shared.all.filter({ $0.parent == root }).map { String(describing: $0.id) },
                                                       includeList: includeList.map { String($0) },
                                                       includeSelf: false,
                                                       threshold: threshold)
        await MainActor.run { modelOutput?.loadThreadCallback(.success(root)) }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        await MainActor.run { modelOutput?.loadThreadCallback(.failure(error)) }
      }
    }
  }
  
  
  func loadSurveyAndThread(surveyId: Int,
                           threadId: Int,
                           includeList: [Int],
                           threshold: Int) {
    Task {
      do {
        let instance = try await API.shared.surveys.getSurveyThreadComments(surveyId: String(surveyId),
                                                             threadId: String(threadId),
                                                             includeList: includeList.map { String($0) },
                                                             threshold: threshold)
        
        await MainActor.run { modelOutput?.loadSurveyAndThreadCallback(.success(instance)) }
      } catch {
        await MainActor.run { modelOutput?.loadSurveyAndThreadCallback(.failure(error)) }
      }
    }
  }
  
  func toggleFavorite(_ mark: Bool) {
    guard let survey = item else { return }
    
    Task {
      await API.shared.surveys.markFavorite(mark: mark, surveyReference: survey)
    }
  }
  
  func getCommentsSurveyStateCommentsUpdates(_ instance: Survey) {
    Task {
      do {
        // Existing comments
        let comments = Comments.shared.all.filter { $0.isParentNode && $0.survey == instance }.map { $0.id }
        try await API.shared.surveys.getCommentsSurveyStateCommentsUpdates(surveyId: instance.id,
                                                                           excludeComments: comments,
                                                                           commentsToUpdate: comments,
        threshold: 40)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func updateCommentsStats(_ comments: [Comment]) {
    Task {
      do {
        try await API.shared.surveys.updateCommentsStats(comments)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
}
