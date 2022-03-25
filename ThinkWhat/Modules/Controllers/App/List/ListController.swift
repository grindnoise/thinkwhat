//
//  ListController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ListController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = ListModel()
               
        self.controllerOutput = view as? ListView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        title = "list".localized
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Properties
    var controllerOutput: ListControllerOutput?
    var controllerInput: ListControllerInput?
}

// MARK: - View Input
extension ListController: ListViewInput {
    // Implement methods
}

// MARK: - Model Output
extension ListController: ListModelOutput {
    // Implement methods
}
