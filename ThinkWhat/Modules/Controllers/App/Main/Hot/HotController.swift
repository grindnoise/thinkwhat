//
//  HotController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class HotController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = HotModel()
               
        self.controllerOutput = view as? HotView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
//        title = "hot".localized
//        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !isViewLayedOut else { return }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        controllerOutput?.onDidLayout()
    }
    
    // MARK: - Properties
    var controllerOutput: HotControllerOutput?
    var controllerInput: HotControllerInput?
    private var isViewLayedOut = false
}

// MARK: - View Input
extension HotController: HotViewInput {
    // Implement methods
}

// MARK: - Model Output
extension HotController: HotModelOutput {
    // Implement methods
}
