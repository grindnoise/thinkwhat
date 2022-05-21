//
//  SettingsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SafariServices

class SettingsController: UIViewController {
    
    enum Mode {
        case Read, Edit, Settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = SettingsModel()
               
        self.controllerOutput = view as? SettingsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        navigationItem.title = "profile".localized
        setupUI()
//        setObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        controllerOutput?.onWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controllerOutput?.onDidLayout()
    }
    
    

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(settingsSwitch)
        settingsSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsSwitch.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            settingsSwitch.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            settingsSwitch.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState * 0.97),
            settingsSwitch.widthAnchor.constraint(equalTo: settingsSwitch.heightAnchor, multiplier: 3)
            ])
    }

    // MARK: - Properties
    var controllerOutput: SettingsControllerOutput?
    var controllerInput: SettingsControllerInput?
    
    var mode: SettingsController.Mode = .Read
    private lazy var settingsSwitch: SettingsSwitch = {
        return SettingsSwitch(callbackDelegate: self)
    }()
}

// MARK: - View Input
extension SettingsController: SettingsViewInput {
    func onSocialTapped(_ url: URL) {
        var vc: SFSafariViewController!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
}

// MARK: - Model Output
extension SettingsController: SettingsModelOutput {
    // Implement methods
}

extension SettingsController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension SettingsController: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let state = sender as? SettingsSwitch.State {
            switch state {
            case .Read:
                mode = .Read
                navigationItem.title = "profile".localized
            case .Edit:
                mode = .Edit
                navigationItem.title = "edit".localized
            case .Settings:
                mode = .Settings
                navigationItem.title = "settings".localized
            }
        }
    }
}
