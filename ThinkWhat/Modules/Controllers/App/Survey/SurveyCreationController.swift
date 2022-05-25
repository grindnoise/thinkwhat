//
//  SurveyCreationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyCreationController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        controllerOutput = view as? SurveyCreationView
        controllerOutput?
            .viewInput = self
        
        controllerOutput?.onDidLoad()
        navigationItem.title = "new_single".localized
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        tabBarController?.setTabBarVisible(visible: true, animated: true)
    }
    
    var controllerOutput: SurveyCreationOutput?
}

extension SurveyCreationController: SurveyCreationViewInput {
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.height ?? 0
    }
}

protocol SurveyCreationOutput: class {
    var viewInput: SurveyCreationViewInput? { get set }
    
    func onDidLoad()
    
}

protocol SurveyCreationViewInput: class {
    var controllerOutput: SurveyCreationOutput? { get set }
    var tabBarHeight: CGFloat { get }
}
