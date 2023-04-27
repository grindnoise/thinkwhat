//
//  ProfileCreationViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

class ProfileCreationViewController: UIViewController {
  
  
  // MARK: - Public properties
  var controllerOutput: ProfileCreationControllerOutput?
  var controllerInput: ProfileCreationControllerInput?
  
  // MARK: - Overridden Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = ProfileCreationView()
    let model = ProfileCreationModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
  }
}

extension ProfileCreationViewController: ProfileCreationViewInput {
  
}

extension ProfileCreationViewController: ProfileCreationModelOutput {
  
}
