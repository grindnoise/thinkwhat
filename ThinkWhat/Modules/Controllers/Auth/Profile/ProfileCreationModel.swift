//
//  ProfileCreationModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

class ProfileCreationModel {
  
  weak var modelOutput: ProfileCreationModelOutput?
}

extension ProfileCreationModel: ProfileCreationControllerInput {
  
}
