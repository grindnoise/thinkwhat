//
//  NewAccountModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

class NewAccountModel {
  
  weak var modelOutput: NewAccountModelOutput?
}

extension NewAccountModel: NewAccountControllerInput {
  
}
