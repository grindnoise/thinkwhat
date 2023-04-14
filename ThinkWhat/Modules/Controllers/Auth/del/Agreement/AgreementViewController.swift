//
//  AgreementViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class AgreementViewController: UIViewController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
               
        self.controllerOutput = view as? AgreementView
        self.controllerOutput?
            .viewInput = self
    }

    // MARK: - Properties
    var controllerOutput: AgreementControllerOutput?
}

// MARK: - View Input
extension AgreementViewController: AgreementViewInput {
    // Implement methods
}

