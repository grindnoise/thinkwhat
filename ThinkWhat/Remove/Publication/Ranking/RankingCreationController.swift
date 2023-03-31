//
//  RankingCreationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class RankingCreationController: UIViewController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let model = RankingCreationModel()
               
        self.controllerOutput = view as? RankingCreationView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
    }

    // MARK: - Properties
    var controllerOutput: RankingCreationControllerOutput?
    var controllerInput: RankingCreationControllerInput?
}

// MARK: - View Input
extension RankingCreationController: RankingCreationViewInput {
    // Implement methods
}

// MARK: - Model Output
extension RankingCreationController: RankingCreationModelOutput {
    // Implement methods
}
