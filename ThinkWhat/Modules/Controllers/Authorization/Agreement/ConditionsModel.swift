//
//  ConditionsModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class ConditionsModel {
    
    weak var modelOutput: ConditionsModelOutput?
}

// MARK: - Controller Input
extension ConditionsModel: ConditionsControllerInput {
    func getTermsConditionsURL() {
        do {
            guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.termsOfUse) else { return }
//            let url = try ContentLoader.urlForResource(fromFileNamed: "terms_conditions", withExtension: "html", in: Bundle(for: Self.self))
            modelOutput?.onTermsConditionsURLReceived(url)
        } catch {
#if DEBUG
            print(error.localizedDescription)
#endif
        }
    }
}
