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
}

// MARK: - Controller Input
extension PollModel: PollControllerInput {
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
        guard let survey = survey else { return }
        
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
        guard let survey = survey else { modelOutput?.onVoteCallback(.failure(APIError.badData)); return }

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
        guard !survey.isNil else { modelOutput?.onVoteCallback(.failure(APIError.badData)); return }
        
        Task {
            do {
                try await API.shared.surveys.incrementViewCounter(surveyReference: survey!.reference)
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
    
    func vote(_ answer: Answer) {
        print(answer.description)
        guard !survey.isNil else { modelOutput?.onVoteCallback(.failure(APIError.badData)); return }
        Task {
            struct Failure {
                var errorFound = false
            }

            do {
                let json = try await API.shared.vote(answer: answer)
                let resultDetails = SurveyResult(choice: answer)
                for i in json {
                    if i.0 == "survey_result" {
                        for entity in i.1 {
                            guard let answerId = entity.1["answer"].int,
                                  let timeString = entity.1["timestamp"].string,
                                  let timestamp = Date(dateTimeString: timeString) else { break }
                            await MainActor.run {
                                survey!.result = [answerId: timestamp]
                                Surveys.shared.hot.remove(object: self.survey!)
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
                                      let answer = self.survey?.answers.filter({ $0.id == _answerID }).first,
                                      let _total = dict["total"]?.int else { break }
                                answer.totalVotes = _total
                                totalVotes += _total
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                                           DateFormatter.dateTimeFormatter,
                                                                           DateFormatter.dateFormatter ]
                                let instances = try decoder.decode([Userprofile].self, from: data)
                                instances.forEach { instance in
                                    answer.voters.append(Userprofiles.shared.all.filter({ $0 == instance }).first ?? instance)
                                }
//                                print(answer.voters)
                            }
                            self.survey?.votesTotal = totalVotes
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
                survey?.resultDetails = resultDetails
                survey?.isComplete = true
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
    
    var survey: Survey? {
        return modelOutput?.survey
    }
    
    func claim(_ reason: Claim) {
        guard let survey = survey else { return }
        Task {
            try await API.shared.surveys.claim(surveyReference: survey.reference, reason: reason)
        }
    }
    
    func loadPoll(_ reference: SurveyReference, incrementViewCounter: Bool = true) {
        Task {
            do {
                try await API.shared.surveys.getSurvey(byReference: reference, incrementCounter: incrementViewCounter)
                await MainActor.run {
                    modelOutput?.onLoadCallback(.success(true))
                }
            } catch {
                await MainActor.run {
                    modelOutput?.onLoadCallback(.failure(error))
                }
            }
        }
    }
    
    func addFavorite(_ mark: Bool) {
        guard !survey.isNil else { modelOutput?.onAddFavoriteCallback(.failure("Survey is nil")); return }
        
        Task {
            do {
                let data = try await API.shared.surveys.markFavoriteAsync(mark: mark, surveyReference: survey!.reference)
                let json = try JSON(data: data, options: .mutableContainers)
                guard let value = json["status"].string else { throw "Unknown error" }
                guard value == "ok" else {
                    guard let error = json["error"].string else { throw "Unknown error" }
                    await MainActor.run {
                        modelOutput?.onAddFavoriteCallback(.failure(error))
                    }
                    return
                }
                await MainActor.run {
                    modelOutput?.onAddFavoriteCallback(.success(mark ? true : false))
                }
            } catch {
                await MainActor.run {
                    modelOutput?.onAddFavoriteCallback(.failure(error))
                }
            }
        }
    }
    
    func updateResultsStats(_ instance: SurveyReference) {
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
}
