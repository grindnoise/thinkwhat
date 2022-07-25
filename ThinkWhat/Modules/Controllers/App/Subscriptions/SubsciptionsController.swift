//
//  SubsciptionsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubsciptionsController: UIViewController {

    // MARK: - Properties
    var controllerOutput: SubsciptionsControllerOutput?
    var controllerInput: SubsciptionsControllerInput?
    private var observers: [NSKeyValueObservation] = []
    private lazy var barButton: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        instance.layer.shadowRadius = 7
        instance.layer.shadowOffset = .zero
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.layer.shadowPath = UIBezierPath(ovalIn: newValue).cgPath
        })
        
        let button = UIButton()
        observers.append(button.observe(\UIButton.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.size.height/2
            let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height * 0.55, weight: .semibold, scale: .medium)
            let image = UIImage(systemName: "chevron.down", withConfiguration: largeConfig)
            view.setImage(image, for: .normal)
        })
        button.addTarget(self, action: #selector(self.toggleBarButton), for: .touchUpInside)
        button.accessibilityIdentifier = "button"
        button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        button.imageView?.contentMode = .center
        button.imageView?.tintColor = .white
        button.addEquallyTo(to: instance)

        return instance
    }()
    private var isBarButtonOn = true
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barButton.alpha = 1
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        controllerOutput?.onWillAppear()
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
        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(barButton)
        barButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            barButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            barButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            barButton.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            barButton.widthAnchor.constraint(equalTo: barButton.heightAnchor)
            ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        barButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
        button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
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
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseOut) {
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.barButton.transform = self.isBarButtonOn ? upsideDown :.identity
        } completion: { _ in
            self.isBarButtonOn = !self.isBarButtonOn
        }
    }
}

// MARK: - View Input
extension SubsciptionsController: SubsciptionsViewInput {
    func updateSurveyStats(_ instances: [SurveyReference]) {
        controllerInput?.updateSurveyStats(instances)
    }
    
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
    
    func onDataSourceRequest() {
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
