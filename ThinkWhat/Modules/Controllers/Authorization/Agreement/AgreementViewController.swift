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
       
        let view = AgreementView()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        
        self.view = view as UIView
    }

    // MARK: - Properties
    var controllerOutput: AgreementControllerOutput?
}

// MARK: - View Input
extension AgreementViewController: AgreementViewInput {
    // Implement methods
}

