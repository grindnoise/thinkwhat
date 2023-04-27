//
//  TermsModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

class TermsModel {
  
  weak var modelOutput: TermsModelOutput?
}

extension TermsModel: TermsControllerInput {
  func getTermsConditionsURL() {
    guard let url = API_URLS.System.termsOfUse else { return }
    
    modelOutput?.onTermsConditionsURLReceived(url)
  }
}
