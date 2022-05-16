//
//  TopicsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopicsController: UIViewController {
    
    enum Mode {
        case Parent, Child, List, Search
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = TopicsModel()
               
        self.controllerOutput = view as? TopicsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        title = "topics".localized
        ProtocolSubscriptions.subscribe(self)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barButton.alpha = 1
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        controllerOutput?.onWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controllerOutput?.onDidLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barButton.alpha = 0
    }

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(barButton)
        barButton.layer.cornerRadius = UINavigationController.Constants.ImageSizeForLargeState / 2
        barButton.clipsToBounds = true
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        barButton.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(TopicsController.handleTap))
        barButton.addGestureRecognizer(gesture)
        NSLayoutConstraint.activate([
            barButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            barButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
            barButton.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            barButton.widthAnchor.constraint(equalTo: barButton.heightAnchor)
        ])
    }
    
    
    @objc private func handleTap() {
        if mode == .Child {
            mode = .Parent
        } else if mode == .List {
            mode = .Child
        } else {
            mode = .List
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }

    // MARK: - Properties
    var controllerOutput: TopicsControllerOutput?
    var controllerInput: TopicsControllerInput?
    var mode: Mode = .Parent {
        didSet {
            switch mode {
            case .Parent:
                guard oldValue != mode else { return }
                onParentMode()
                controllerOutput?.onParentMode()
            case .Child:
                if oldValue == .List {
                    controllerOutput?.onListToChildMode()
                } else {
                    onChildMode()
                    controllerOutput?.onChildMode()
                }
            case .List:
                controllerOutput?.onListMode()
            case .Search:
                fatalError()
            }
        }
    }
    
    private let barButton: UIImageView = {
        let v = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
        v.contentMode = .scaleAspectFill
        v.image = ImageSigns.magnifyingGlassFilled.image
        v.isUserInteractionEnabled = true
        return v
    }()
}

// MARK: - View Input
extension TopicsController: TopicsViewInput {
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
    
    func onDataSourceRequest(_ topic: Topic) {
        controllerInput?.onDataSourceRequest(topic)
    }
    
    private func onChildMode() {
        UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.barButton.image = ImageSigns.arrowLeft.image
        } completion: { _ in }
    }
    
    private func onParentMode() {
        UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.barButton.image = ImageSigns.magnifyingGlassFilled.image
        } completion: { _ in }
    }
}

// MARK: - Model Output
extension TopicsController: TopicsModelOutput {
    func onError(_: Error) {
        func onError(_ error: Error) {
    #if DEBUG
            print(error.localizedDescription)
    #endif
            controllerOutput?.onError()
        }
    }
}

extension TopicsController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
