//
//  LanguageListModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class LanguageListModel {
    
    weak var modelOutput: LanguageListModelOutput?
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
}

extension LanguageListModel: LanguageListControllerInput {
    func updateContentLanguage(language: LanguageItem, use: Bool) {
        Task {
            do {
                var parameters = ["locales": [[language.code: use]]]
                
                try await API.shared.system.updateAppSettings(parameters)
                
                if use, !UserDefaults.App.contentLanguages.contains(language.code) {
                    UserDefaults.App.contentLanguages.append(language.code)
                } else if !use, UserDefaults.App.contentLanguages.contains(language.code) {
                    UserDefaults.App.contentLanguages.remove(object: language.code)
                }
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
}
