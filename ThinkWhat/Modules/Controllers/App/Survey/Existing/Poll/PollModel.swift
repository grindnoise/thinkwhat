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
    func addView() {
        guard !survey.isNil else { modelOutput?.onVoteCallback(.failure(APIError.badData)); return }
        
        Task {
            do {
                try await API.shared.incrementViewCounterAsync(surveyReference: survey!.reference)
                await MainActor.run {
                    modelOutput?.onCountUpdateCallback(.success(true))
                }
            } catch {
                await MainActor.run {
                    modelOutput?.onCountUpdateCallback(.failure(error))
                }
            }
        }
    }
    
    func vote(_ answer: Answer) {
        guard !survey.isNil else { modelOutput?.onVoteCallback(.failure(APIError.badData)); return }
        Task {
            struct Failure {
                var errorFound = false
            }

            do {
                let json = try await API.shared.vote(answer: answer)
                for i in json {
                    if i.0 == "survey_result" {
                        for entity in i.1 {
                            guard let answerId = entity.1["answer"].int,
                                  let timeString = entity.1["timestamp"].string,
                                  let timestamp = Date(dateTimeString: timeString) else { break }
                            survey!.result = [answerId: timestamp]
                            Surveys.shared.hot.remove(object: self.survey!)
                            Userprofiles.shared.current!.balance += 1
                        }
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
                                    answer.addVoter(Userprofiles.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
                                }
//                                print(answer.voters)
                            }
                            self.survey?.totalVotes = totalVotes
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
        guard !survey.isNil else { return }
        Task {
            let json = try await API.shared.claim(survey: survey!, reason: reason)
            guard let value = json["status"].string else { throw "Unknown error" }
            guard value == "ok" else {
                guard let error = json["error"].string else { throw "Unknown error" }
                await MainActor.run {
                    modelOutput?.onClaimCallback(.failure(error))
                }
                return
            }
            await MainActor.run {
                modelOutput?.onClaimCallback(.success(true))
            }
        }
    }
    
    func loadPoll(_ reference: SurveyReference, incrementViewCounter: Bool = true) {
        Task {
            do {
                try await API.shared.downloadSurveyAsync(reference: reference, incrementCounter: incrementViewCounter)
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
                let data = try await API.shared.markFavoriteAsync(mark: mark, surveyReference: survey!.reference)
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
                    modelOutput?.onAddFavoriteCallback(.success(true))
                }
            } catch {
                await MainActor.run {
                    modelOutput?.onAddFavoriteCallback(.failure(error))
                }
            }
            
        }
    }
}
