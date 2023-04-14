//
//  SignInModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

class SignInModel {
  
  weak var modelOutput: SignInModelOutput?
}

extension SignInModel: SignInControllerInput {
  
}
