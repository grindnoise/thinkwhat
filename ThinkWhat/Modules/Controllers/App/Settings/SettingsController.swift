//
//  SettingsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = SettingsModel()
               
        self.controllerOutput = view as? SettingsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        title = "settings".localized
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Properties
    var controllerOutput: SettingsControllerOutput?
    var controllerInput: SettingsControllerInput?
}

// MARK: - View Input
extension SettingsController: SettingsViewInput {
    // Implement methods
}

// MARK: - Model Output
extension SettingsController: SettingsModelOutput {
    // Implement methods
}

