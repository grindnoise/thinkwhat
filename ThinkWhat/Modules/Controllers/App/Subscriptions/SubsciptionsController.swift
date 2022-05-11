//
//  SubsciptionsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubsciptionsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = SubsciptionsModel()
               
        self.controllerOutput = view as? SubsciptionsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        ProtocolSubscriptions.subscribe(self)
        title = "subscriptions".localized
        setupUI()
        setObservers()
        controllerOutput?.onDidLoad()
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
    
    private func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSubscribedForUpdated), name: Notifications.Userprofiles.SubscribedForUpdated, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.onSubscriptionsUpdated), name: Notifications.Surveys.UpdateSubscriptions, object: nil)
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
                                             action: #selector(SubsciptionsController.toggleBarButton))
        barButton.addGestureRecognizer(gesture)
        NSLayoutConstraint.activate([
            barButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            barButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
            barButton.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            barButton.widthAnchor.constraint(equalTo: barButton.heightAnchor)
            ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    @objc
    private func onSubscribedForUpdated() {
        controllerOutput?.onSubscribedForUpdated()
    }
    
//    @objc
//    private func onSubscriptionsUpdated() {
//        controllerOutput?.onSubscriptionsUpdated()
//    }
    
    @objc
    func toggleBarButton() {
        controllerOutput?.onUpperContainerShown(isBarButtonOn)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut) {
            self.barButton.transform = self.isBarButtonOn ? CGAffineTransform(rotationAngle: Double.pi) : .identity
        } completion: { _ in
            self.isBarButtonOn = !self.isBarButtonOn
        }
    }
    
    // MARK: - Properties
    var controllerOutput: SubsciptionsControllerOutput?
    var controllerInput: SubsciptionsControllerInput?
    private let barButton: UIImageView = {
        let v = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
        v.contentMode = .scaleAspectFit
        v.image = ImageSigns.chevronDownFilled.image
        v.isUserInteractionEnabled = true
        return v
    }()
    private var isBarButtonOn = true
}

// MARK: - View Input
extension SubsciptionsController: SubsciptionsViewInput {
    func onSurveyTapped(_ surveyReference: SurveyReference) {
        if let nav = navigationController as? CustomNavigationController {
            nav.transitionStyle = .Default
            nav.duration = 0.5
//            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
        }
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(PollController(surveyReference: surveyReference, showNext: false), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onDataSourceUpdate() {
        controllerInput?.loadSubscriptions()
    }
    
    var userprofiles: [Userprofile] {
        guard !controllerInput.isNil else { return [] }
        return controllerInput!.userprofiles
    }
    
    func onSubscribersTapped() {
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(SubscribersController(mode: .Subscribers), animated: true)
    }
    
    func onSubscpitionsTapped() {
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(SubscribersController(mode: .Subscriptions), animated: true)
    }
}

// MARK: - Model Output
extension SubsciptionsController: SubsciptionsModelOutput {
    func onError(_ error: Error) {
#if DEBUG
        print(error.localizedDescription)
#endif
        controllerOutput?.onError()
    }
}

extension SubsciptionsController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
