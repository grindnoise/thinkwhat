//
//  SurveyCreationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyCreationController: UIViewController {
    
    enum Mode {
        case Poll, Ranking
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        controllerOutput = view as? SurveyCreationView
        controllerOutput?
            .viewInput = self
        
        controllerOutput?.onDidLoad()
        navigationItem.title = "new_single".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearNavigationBar(clear: false)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        clearNavigationBar(clear: true)
//    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        clearNavigationBar(clear: true)
    }
    
    var controllerOutput: SurveyCreationOutput?
}

extension SurveyCreationController: SurveyCreationViewInput {
    func onNext(_ mode: SurveyCreationController.Mode) {
//        if let nav = navigationController as? CustomNavigationController {
//            nav.transitionStyle = .Default
//            nav.duration = 0.5
////            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
//        }
        
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(mode == .Poll ? PollCreationController() : RankingCreationController(), animated: true)
    }
    
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
    
    func onNext(_: SurveyCreationController.Mode)
}
