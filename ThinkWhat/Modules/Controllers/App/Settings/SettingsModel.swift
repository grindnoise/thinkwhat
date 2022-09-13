//
//  SettingsModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SettingsModel {
    
    weak var modelOutput: SettingsModelOutput?
}

// MARK: - Controller Input
extension SettingsModel: SettingsControllerInput {
    func updateUserprofile(parameters: [String: Any], image: UIImage? = nil) {
        Task {
            do {
                let data = try await API.shared.profiles.updateUserprofileAsync(data: parameters, uploadProgress: { progress in
#if DEBUG
                    print(progress)
#endif
                })
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                Userprofiles.shared.current = try decoder.decode(Userprofile.self, from: data)
                Userprofiles.shared.current?.image = image
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
                await MainActor.run {
                    modelOutput?.onError(error)
                }
            }
        }
    }
}
