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
        
        ProtocolSubscriptions.subscribe(self)
        navigationItem.title = "new".localized
        setupUI()
        setObservers()
        controllerOutput?.onDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listSwitch.alpha = 1
        tabBarController?.setTabBarVisible(visible: true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controllerOutput?.onDidLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listSwitch.alpha = 0
    }
    
    private func setObservers() {
//        let names = [Notifications.System.UpdateStats]
//        names.forEach { NotificationCenter.default.addObserver(view, selector: #selector(ListView.updateStats), name: $0, object: nil) }
    }

    private func setupUI() {
//        listSwitch = ListSwitch(callbackDelegate: self)
        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(listSwitch)
        listSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listSwitch.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            listSwitch.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            listSwitch.heightAnchor.constraint(equalToConstant: 40),
            listSwitch.widthAnchor.constraint(equalTo: listSwitch.heightAnchor, multiplier: 4)
            ])
    }
    
//    @objc
//    func updateStats() {
//        controllerOutput?.updateStats()
//    }

    
    // MARK: - Properties
    var controllerOutput: ListControllerOutput?
    var controllerInput: ListControllerInput?
    
    private lazy var listSwitch: ListSwitch = {
        return ListSwitch(callbackDelegate: self)
    }()
    var category: Survey.SurveyCategory = .New {
        didSet {
            controllerOutput?.onDataSourceChanged()
        }
    }
}

// MARK: - View Input
extension ListController: ListViewInput {
    var surveyCategory: Survey.SurveyCategory {
        return category
    }
    
    func onSurveyTapped(_ instance: SurveyReference) {
        if let nav = navigationController as? CustomNavigationController {
            nav.transitionStyle = .Default
            nav.duration = 0.5
//            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
        }
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(PollController(surveyReference: instance, showNext: false), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onDataSourceRequest() {
        controllerInput?.onDataSourceRequest()
    }
}

// MARK: - Model Output
extension ListController: ListModelOutput {
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            controllerOutput?.onRequestCompleted(result)
        case .failure(let error):
#if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
#endif
        }
    }
}

extension ListController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        controllerOutput?.onDidLoad()
    }
}

extension ListController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let state = sender as? ListSwitch.State {
            switch state {
            case .New:
                category = .New
                navigationItem.title = "new".localized
            case .Top:
                category = .Top
                navigationItem.title = "top".localized
            case .Watching:
                category = .Favorite
                navigationItem.title = "watching".localized
            case .Own:
                category = .Own
                navigationItem.title = "own".localized
            }
        }
    }
}
