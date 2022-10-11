//
//  LanguageListViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class LanguageListViewController: UIViewController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = LanguageListView()
        let model = LanguageListModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        title = "content_language".localized
    }

    // MARK: - Properties
    var controllerOutput: LanguageListControllerOutput?
    var controllerInput: LanguageListControllerInput?
}

// MARK: - View Input
extension LanguageListViewController: LanguageListViewInput {
    // Implement methods
}

// MARK: - Model Output
extension LanguageListViewController: LanguageListModelOutput {
    // Implement methods
}
