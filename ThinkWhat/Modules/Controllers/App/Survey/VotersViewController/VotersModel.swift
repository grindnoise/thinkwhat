//
//  VotersModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class VotersModel {
    
    weak var modelOutput: VotersModelOutput?
}

// MARK: - Controller Input
extension VotersModel: VotersControllerInput {
    
    func loadData() {
        Task {
            do {
                guard let answer = modelOutput?.answer else {
                    await MainActor.run {
                        modelOutput?.onDataLoaded(.failure(APIError.badData))
                    }
                    return
                }
                let data = try await API.shared.getVotersAsync(answer: answer)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                let instances = try decoder.decode([Userprofile].self, from: data)
                await MainActor.run {
                    modelOutput?.onDataLoaded(.success(instances))
                }
            } catch {
                await MainActor.run {
                    modelOutput?.onDataLoaded(.failure(error))
                }
            }
        }
    }
}
