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
    
  }
  
  func updateSurveyState(_ instance: SurveyReference) {
    Task {
      do {
        try await API.shared.surveys.getSurveyState(instance)
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
  
  func requestComments(_ comments: [Comment]) {
    guard let survey = item else { return }
    
    Task {
      do {
        try await API.shared.surveys.requestRootComments(survey: survey, excludedComments: comments)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func postComment(body: String, replyTo: Comment? = nil, username: String? = nil) {
    guard let survey = item else { return }
    
    Task {
      do {
        let instance = try await API.shared.surveys.postComment(body, survey: survey, replyTo: replyTo, username: username)
        guard replyTo.isNil else { return }
        await MainActor.run {
          modelOutput?.commentPostCallback(.success(instance))
        }
      } catch {
        await MainActor.run {
          modelOutput?.commentPostCallback(.failure(error))
        }
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func addView() {
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
              Surveys.shared.load(i.1)
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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                let instances = try decoder.decode([Userprofile].self, from: data)
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
                modelOutput?.onVoteCallback(.failure(error))
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
          modelOutput?.onVoteCallback(.success(true))
        }
      } catch {
        await MainActor.run {
          modelOutput?.onVoteCallback(.failure(error))
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
        await MainActor.run { modelOutput?.onLoadCallback(.success(instance)) }
      } catch {
        await MainActor.run { modelOutput?.onLoadCallback(.failure(error)) }
      }
    }
  }
  
  func toggleFavorite(_ mark: Bool) {
    guard let survey = item else { return }
    
    Task {
      await API.shared.surveys.markFavorite(mark: mark, surveyReference: survey)
    }
  }
  
  func updateResultsStats(_ instance: Survey) {
    Task {
      do {
        try await API.shared.surveys.updateResultStats(instance)
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
