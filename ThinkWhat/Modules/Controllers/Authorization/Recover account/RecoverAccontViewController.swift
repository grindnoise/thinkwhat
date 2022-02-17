//
//  RecoverAccontViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class RecoverAccontViewController: UIViewController {
    deinit {
        print("RecoverAccontViewController deinit")
    }
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = RecoverView()
        let model = RecoverModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        title = NSLocalizedString("recover_title", comment: "")
    }

    // MARK: - Properties
    var controllerOutput: RecoverControllerOutput?
    var controllerInput: RecoverControllerInput?
}

// MARK: - View Input
extension RecoverAccontViewController: RecoverViewInput {
    // Implement methods
}

// MARK: - Model Output
extension RecoverAccontViewController: RecoverModelOutput {
    // Implement methods
}

